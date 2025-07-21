using ITapply.Models.Exceptions;
using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Database;
using ITapply.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ITapply.Services.Services
{
    public class UserService
        : BaseCRUDService<UserResponse, UserSearchObject, User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private const int SaltSize = 16;
        private const int KeySize = 32;
        private const int Iterations = 10000;
        protected readonly ITapplyDbContext _context;

        public UserService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        public override IQueryable<User> AddInclude(IQueryable<User> query, UserSearchObject? search = null)
        {
            return query = query.Include(x => x.UserRoles).ThenInclude(x => x.Role);
        }

        public override async Task<UserResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Users
                .Include(a => a.UserRoles)
                    .ThenInclude(c => c.Role)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(l => l.Email.Contains(search.Email));
            }
            if (search.IsActive != null)
            {
                query = query.Where(l => l.IsActive == search.IsActive);
            }
            if (search.RegistrationDate != null)
            {
                query = query.Where(l => l.RegistrationDate == search.RegistrationDate);
            }

            return query;
        }

        private string HashPassword(string password, out byte[] salt)
        {
            salt = new byte[SaltSize];
            using (var rng = new RNGCryptoServiceProvider())
            {
                rng.GetBytes(salt);
            }

            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations))
            {
                return Convert.ToBase64String(pbkdf2.GetBytes(KeySize));
            }
        }
        
        private bool VerifyPassword(string password, string passwordHash, string passwordSalt)
        {
            var salt = Convert.FromBase64String(passwordSalt);
            var hash = Convert.FromBase64String(passwordHash);
            var hashBytes = new Rfc2898DeriveBytes(password, salt, Iterations).GetBytes(KeySize);
            return hash.SequenceEqual(hashBytes);
        }

        protected override async Task BeforeInsert(User entity, UserInsertRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            {
                throw new UserException("A user with this email already exists");
            }

            if (request.RoleIds == null || !request.RoleIds.Any())
            {
                throw new UserException("At least one role must be assigned to the user");
            }

            var existingRoleIds = await _context.Roles
                .Where(r => request.RoleIds.Contains(r.Id))
                .Select(r => r.Id)
                .ToListAsync();

            var nonExistentRoleIds = request.RoleIds.Except(existingRoleIds).ToList();
            if (nonExistentRoleIds.Any())
            {
                throw new UserException($"The following role IDs do not exist: {string.Join(", ", nonExistentRoleIds)}");
            }

            var roleNames = await _context.Roles
                .Where(r => request.RoleIds.Contains(r.Id))
                .Select(r => r.Name)
                .ToListAsync();

            if (roleNames.Contains("Candidate") && roleNames.Contains("Employer"))
            {
                throw new UserException("A user cannot have both Candidate and Employer roles");
            }

            entity.RegistrationDate = DateTime.Now;
            entity.IsActive = true;

            byte[] salt;
            entity.PasswordHash = HashPassword(request.Password, out salt);
            entity.PasswordSalt = Convert.ToBase64String(salt);
        }

        protected override async Task AfterInsert(User entity, UserInsertRequest request)
        {
            var userRoles = request.RoleIds.Select(roleId => new UserRole
            {
                UserId = entity.Id,
                RoleId = roleId
            }).ToList();

            _context.UserRoles.AddRange(userRoles);
            await _context.SaveChangesAsync();

            await base.AfterInsert(entity, request);
        }

        protected override async Task BeforeUpdate(User entity, UserUpdateRequest request)
        {
            if (!string.IsNullOrEmpty(request.Email) && request.Email != entity.Email)
            {
                if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != entity.Id))
                {
                    throw new UserException("A user with this email already exists");
                }
            }

            if (!string.IsNullOrEmpty(request.Password))
            {
                byte[] salt;
                entity.PasswordHash = HashPassword(request.Password, out salt);
                entity.PasswordSalt = Convert.ToBase64String(salt);
            }
        }

        public async Task<UserResponse?> Login(UserLoginRequest request)
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Email == request.Email);
                
            if (user == null)
                return null;

            if (!user.IsActive)
            {
                throw new UserException("This account has been deactivated");
            }

            if (!VerifyPassword(request.Password, user.PasswordHash, user.PasswordSalt))
                return null;

            return MapToResponse(user);
        }

        public async Task<bool> ChangePassword(int userId, ChangePasswordRequest request)
        {
            var user = await _context.Users.FindAsync(userId);

            if (user == null)
            {
                throw new UserException("User not found.");
            }

            if (!VerifyPassword(request.OldPassword, user.PasswordHash, user.PasswordSalt))
            {
                throw new UserException("Incorrect current password.");
            }

            byte[] salt;
            user.PasswordHash = HashPassword(request.NewPassword, out salt);
            user.PasswordSalt = Convert.ToBase64String(salt);

            await _context.SaveChangesAsync();

            return true;
        }

        protected override UserResponse MapToResponse(User entity)
        {
            var response = _mapper.Map<UserResponse>(entity);
            
            if (entity.UserRoles != null)
            {
                response.Roles = entity.UserRoles
                    .Where(ur => ur.Role != null)
                    .Select(ur => _mapper.Map<RoleResponse>(ur.Role))
                    .ToList();
            }
            
            return response;
        }

        protected override async Task BeforeDelete(User entity)
        {
            var applications = await _context.Applications.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var app in applications)
            {
                _context.Applications.Remove(app);

                await _context.SaveChangesAsync();
            }

            var candidateSkills = await _context.CandidateSkills.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var skill in candidateSkills)
            {
                _context.CandidateSkills.Remove(skill);

                await _context.SaveChangesAsync();
            }

            var cvDocuments = await _context.CVDocuments.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var cv in cvDocuments)
            {
                _context.CVDocuments.Remove(cv);

                await _context.SaveChangesAsync();
            }

            var educations = await _context.Educations.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var ed in educations)
            {
                _context.Educations.Remove(ed);

                await _context.SaveChangesAsync();
            }

            var preferences = await _context.Preferences.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var pref in preferences)
            {
                _context.Preferences.Remove(pref);

                await _context.SaveChangesAsync();
            }

            var reviews = await _context.Reviews.Where(x => x.CandidateId == entity.Id || x.EmployerId == entity.Id).ToListAsync();

            foreach (var rev in reviews)
            {
                _context.Reviews.Remove(rev);

                await _context.SaveChangesAsync();
            }

            var works = await _context.WorkExperiences.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var w in works)
            {
                _context.WorkExperiences.Remove(w);

                await _context.SaveChangesAsync();
            }

            var empSkills = await _context.EmployerSkills.Where(x => x.EmployerId == entity.Id).ToListAsync();

            foreach (var es in empSkills)
            {
                _context.EmployerSkills.Remove(es);

                await _context.SaveChangesAsync();
            }

            var jobPostings = await _context.JobPostings.Where(x => x.EmployerId == entity.Id).ToListAsync();

            foreach (var job in jobPostings)
            {
                var jobApps = await _context.Applications.Where(x => x.JobPostingId == job.Id).ToListAsync();

                foreach (var jApp in jobApps)
                {
                    _context.Applications.Remove(jApp);
                }

                var jobSkills = await _context.JobPostingSkills.Where(x => x.JobPostingId == job.Id).ToListAsync();

                foreach (var sk in jobSkills)
                {
                    _context.JobPostingSkills.Remove(sk);
                }

                _context.JobPostings.Remove(job);

                await _context.SaveChangesAsync();
            }

            var candidate = await _context.Candidates.Where(x => x.Id == entity.Id).ToListAsync();

            foreach (var cand in candidate)
            {
                _context.Candidates.Remove(cand);

                await _context.SaveChangesAsync();
            }

            var employer = await _context.Employers.Where(x => x.Id == entity.Id).ToListAsync();

            foreach (var employ in employer)
            {
                _context.Employers.Remove(employ);

                await _context.SaveChangesAsync();
            }

            var roles = await _context.UserRoles.Where(x => x.UserId == entity.Id).ToListAsync();

            foreach (var r in roles)
            {
                _context.UserRoles.Remove(r);

                await _context.SaveChangesAsync();
            }

            await base.BeforeDelete(entity);
        }
    }
}
