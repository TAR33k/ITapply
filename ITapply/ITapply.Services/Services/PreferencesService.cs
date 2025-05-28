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

        protected override async Task BeforeInsert(Preferences entity, PreferencesInsertRequest request)
        {
            var candidate = await _context.Candidates.FindAsync(request.CandidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {request.CandidateId} not found");
            }

            var existingPreferences = await _context.Preferences
                .FirstOrDefaultAsync(p => p.CandidateId == request.CandidateId);
            
            if (existingPreferences != null)
            {
                throw new UserException("Candidate already has preferences set. Use update instead.");
            }

            if (request.LocationId.HasValue)
            {
                var location = await _context.Locations.FindAsync(request.LocationId.Value);
                if (location == null)
                {
                    throw new UserException($"Location with ID {request.LocationId.Value} not found");
                }
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Preferences entity, PreferencesUpdateRequest request)
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