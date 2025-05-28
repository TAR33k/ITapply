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

namespace ITapply.Services.Services
{
    public class PreferencesService
        : BaseCRUDService<PreferencesResponse, PreferencesSearchObject, Preferences, PreferencesInsertRequest, PreferencesUpdateRequest>, IPreferencesService
    {
        public PreferencesService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Preferences> AddInclude(IQueryable<Preferences> query, PreferencesSearchObject search)
        {
            query = query.Include(p => p.Location);
            return query;
        }

        public override async Task<PreferencesResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Preferences
                .Include(a => a.Location)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<Preferences> ApplyFilter(IQueryable<Preferences> query, PreferencesSearchObject search)
        {
            if (search.CandidateId.HasValue)
            {
                query = query.Where(p => p.CandidateId == search.CandidateId);
            }

            if (search.LocationId.HasValue)
            {
                query = query.Where(p => p.LocationId == search.LocationId);
            }

            if (search.EmploymentType.HasValue)
            {
                query = query.Where(p => p.EmploymentType == search.EmploymentType);
            }

            if (search.Remote.HasValue)
            {
                query = query.Where(p => p.Remote == search.Remote);
            }

            return query;
        }

        protected override PreferencesResponse MapToResponse(Preferences entity)
        {
            var response = _mapper.Map<PreferencesResponse>(entity);

            if (entity.Location != null)
            {
                response.LocationName = entity.Location.City + ", " + entity.Location.Country;
            }

            return response;
        }
    }
} 