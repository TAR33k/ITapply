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
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Services.Services
{
    public class EmployerService
        : BaseCRUDService<EmployerResponse, EmployerSearchObject, Employer, EmployerInsertRequest, EmployerUpdateRequest>, IEmployerService
    {
        public EmployerService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Employer> AddInclude(IQueryable<Employer> query, EmployerSearchObject? search = null)
        {
            return query = query.Include(e => e.User).Include(e => e.Location);
        }

        public override async Task<EmployerResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Employers
                .Include(a => a.User)
                .Include(a => a.Location)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        public async Task<EmployerResponse> UpdateVerificationStatusAsync(int id, VerificationStatus status)
        {
            var entity = await _context.Employers.FindAsync(id);
            if (entity == null)
            {
                throw new UserException($"Employer with ID {id} not found");
            }

            if (!IsValidVerificationStatusTransition(entity.VerificationStatus, status))
            {
                throw new UserException($"Invalid status transition from {entity.VerificationStatus} to {status}");
            }

            entity.VerificationStatus = status;
            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        private bool IsValidVerificationStatusTransition(VerificationStatus currentStatus, VerificationStatus newStatus)
        {
            switch (currentStatus)
            {
                case VerificationStatus.Pending:
                    return newStatus == VerificationStatus.Approved || newStatus == VerificationStatus.Rejected;
                case VerificationStatus.Approved:
                    return newStatus == VerificationStatus.Rejected;
                case VerificationStatus.Rejected:
                    return newStatus == VerificationStatus.Pending || newStatus == VerificationStatus.Approved;
                default:
                    return true;
            }
        }

        protected override IQueryable<Employer> ApplyFilter(IQueryable<Employer> query, EmployerSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.CompanyName))
            {
                query = query.Where(e => e.CompanyName.Contains(search.CompanyName));
            }

            if (!string.IsNullOrEmpty(search.Industry))
            {
                query = query.Where(e => e.Industry.Contains(search.Industry));
            }

            if (search.MinYearsInBusiness.HasValue)
            {
                query = query.Where(e => e.YearsInBusiness >= search.MinYearsInBusiness.Value);
            }

            if (search.MaxYearsInBusiness.HasValue)
            {
                query = query.Where(e => e.YearsInBusiness <= search.MaxYearsInBusiness.Value);
            }

            if (search.LocationId.HasValue)
            {
                query = query.Where(e => e.LocationId == search.LocationId);
            }

            if (!string.IsNullOrEmpty(search.ContactEmail))
            {
                query = query.Where(e => e.ContactEmail.Contains(search.ContactEmail));
            }

            if (search.VerificationStatus.HasValue)
            {
                query = query.Where(e => e.VerificationStatus == search.VerificationStatus.Value);
            }

            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(e => e.User.Email.Contains(search.Email));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(e => e.User.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Employer entity, EmployerInsertRequest request)
        {
            var user = await _context.Users.FindAsync(request.UserId);
            if (user == null)
            {
                throw new UserException($"User with ID {request.UserId} not found");
            }

            var existingEmployer = await _context.Employers
                .FirstOrDefaultAsync(e => e.User.Id == request.UserId);
            if (existingEmployer != null)
            {
                throw new UserException($"User with ID {request.UserId} is already assigned to another employer");
            }

            var userHasEmployerRole = await _context.UserRoles
                .Include(ur => ur.Role)
                .AnyAsync(ur => ur.UserId == request.UserId && ur.Role.Name == "Employer");
            
            if (!userHasEmployerRole)
            {
                throw new UserException("User must have the Employer role to be assigned to an employer profile");
            }

            if (request.LocationId.HasValue)
            {
                var location = await _context.Locations.FindAsync(request.LocationId.Value);
                if (location == null)
                {
                    throw new UserException($"Location with ID {request.LocationId.Value} not found");
                }
            }

            entity.VerificationStatus = VerificationStatus.Pending;
            entity.User = user;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Employer entity, EmployerUpdateRequest request)
        {
            if (request.LocationId.HasValue)
            {
                var location = await _context.Locations.FindAsync(request.LocationId.Value);
                if (location == null)
                {
                    throw new UserException($"Location with ID {request.LocationId.Value} not found");
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeDelete(Employer entity)
        {
            var empSkills = await _context.EmployerSkills.Where(x => x.EmployerId == entity.Id).ToListAsync();

            foreach (var es in empSkills)
            {
                _context.EmployerSkills.Remove(es);

                await _context.SaveChangesAsync();
            }

            var reviews = await _context.Reviews.Where(x => x.EmployerId == entity.Id).ToListAsync();

            foreach (var review in reviews)
            {
                _context.Reviews.Remove(review);

                await _context.SaveChangesAsync();
            }

            var jobPostings = await _context.JobPostings.Where(x => x.EmployerId == entity.Id).ToListAsync();

            foreach (var job in jobPostings)
            {
                var applications = await _context.Applications.Where(x => x.JobPostingId == job.Id).ToListAsync();

                foreach (var app in applications)
                {
                    _context.Applications.Remove(app);
                }

                var jobSkills = await _context.JobPostingSkills.Where(x => x.JobPostingId == job.Id).ToListAsync();

                foreach (var sk in jobSkills)
                {
                    _context.JobPostingSkills.Remove(sk);
                }

                _context.JobPostings.Remove(job);

                await _context.SaveChangesAsync();
            }

            var roles = await _context.UserRoles.Where(x => x.UserId == entity.Id).ToListAsync();

            foreach (var r in roles)
            {
                _context.UserRoles.Remove(r);

                await _context.SaveChangesAsync();
            }

            var user = await _context.Users.Where(x => x.Id == entity.Id).ToListAsync();

            foreach (var u in user)
            {
                _context.Users.Remove(u);

                await _context.SaveChangesAsync();
            }

            await base.BeforeDelete(entity);
        }

        protected override EmployerResponse MapToResponse(Employer entity)
        {
            var response = _mapper.Map<EmployerResponse>(entity);

            if (entity.User != null)
            {
                response.Email = entity.User.Email;
                response.RegistrationDate = entity.User.RegistrationDate;
                response.IsActive = entity.User.IsActive;
            }

            if (entity.Location != null)
            {
                response.LocationName = $"{entity.Location.City}, {entity.Location.Country}";
            }

            return response;
        }
    }
} 