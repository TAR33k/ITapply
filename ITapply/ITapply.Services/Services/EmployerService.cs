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

        public async Task<EmployerResponse> GetByUserIdAsync(int userId)
        {
            var entity = await _context.Employers
                .Include(e => e.User)
                .Include(e => e.Location)
                .FirstOrDefaultAsync(e => e.Id == userId);

            return _mapper.Map<EmployerResponse>(entity);
        }

        public async Task<EmployerResponse> UpdateVerificationStatusAsync(int id, VerificationStatus status)
        {
            var entity = await _context.Employers.FindAsync(id);
            if (entity == null)
            {
                throw new UserException($"Employer with ID {id} not found");
            }

            entity.VerificationStatus = status;
            await _context.SaveChangesAsync();

            return _mapper.Map<EmployerResponse>(entity);
        }

        protected override IQueryable<Employer> ApplyFilter(IQueryable<Employer> query, EmployerSearchObject search)
        {
            query = query.Include(e => e.User).Include(e => e.Location);

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
    }
} 