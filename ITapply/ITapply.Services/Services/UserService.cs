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
                throw new UserException("A user with this email already exists.");
            }

            byte[] salt;
            entity.PasswordHash = HashPassword(request.Password, out salt);
            entity.PasswordSalt = Convert.ToBase64String(salt);
        }

        protected override async Task BeforeUpdate(User entity, UserUpdateRequest request)
        {
            if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != entity.Id))
            {
                throw new UserException("A user with this email already exists.");
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

            if (!VerifyPassword(request.Password, user.PasswordHash, user.PasswordSalt))
                return null;

            return MapToResponse(user);
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
    }
}
