using ITapply.Models.Exceptions;
using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Database;
using ITapply.Services.Interfaces;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Services.Services
{
    public class WorkExperienceService : BaseCRUDService<WorkExperienceResponse, WorkExperienceSearchObject, WorkExperience, WorkExperienceInsertRequest, WorkExperienceUpdateRequest>, IWorkExperienceService
    {
        public WorkExperienceService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<WorkExperience> AddInclude(IQueryable<WorkExperience> query, WorkExperienceSearchObject? search = null)
        {
            return query = query.Include(x => x.Candidate);
        }

        public override async Task<WorkExperienceResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.WorkExperiences
                .Include(a => a.Candidate)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<WorkExperience> ApplyFilter(IQueryable<WorkExperience> query, WorkExperienceSearchObject search)
        {
            if (search.CandidateId.HasValue)
                query = query.Where(x => x.CandidateId == search.CandidateId);

            if (!string.IsNullOrEmpty(search.CompanyName))
                query = query.Where(x => x.CompanyName.Contains(search.CompanyName));

            if (!string.IsNullOrEmpty(search.Position))
                query = query.Where(x => x.Position.Contains(search.Position));

            if (search.IsCurrent.HasValue)
            {
                if (search.IsCurrent.Value)
                    query = query.Where(x => x.EndDate == null);
                else
                    query = query.Where(x => x.EndDate != null);
            }

            if (search.StartDateFrom.HasValue)
                query = query.Where(x => x.StartDate >= search.StartDateFrom);

            if (search.StartDateTo.HasValue)
                query = query.Where(x => x.StartDate <= search.StartDateTo);

            if (search.EndDateFrom.HasValue)
                query = query.Where(x => x.EndDate >= search.EndDateFrom);

            if (search.EndDateTo.HasValue)
                query = query.Where(x => x.EndDate <= search.EndDateTo);

            return query;
        }

        protected override async Task BeforeInsert(WorkExperience entity, WorkExperienceInsertRequest request)
        {
            var candidate = await _context.Candidates.FindAsync(request.CandidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {request.CandidateId} not found");
            }

            await base.BeforeInsert(entity, request);
        }

        public async Task<List<WorkExperienceResponse>> GetByCandidateIdAsync(int candidateId)
        {
            var candidate = await _context.Candidates.FindAsync(candidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {candidateId} not found");
            }

            var entities = await _context.WorkExperiences
                .Include(x => x.Candidate)
                .Where(x => x.CandidateId == candidateId)
                .OrderByDescending(x => x.EndDate == null)
                .ThenByDescending(x => x.EndDate)
                .ThenByDescending(x => x.StartDate)
                .ToListAsync();

            return entities.Select(MapToResponse).ToList();
        }

        public async Task<int> GetTotalExperienceMonthsAsync(int candidateId)
        {
            var candidate = await _context.Candidates.FindAsync(candidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {candidateId} not found");
            }

            var experiences = await _context.WorkExperiences
                .Where(x => x.CandidateId == candidateId)
                .ToListAsync();

            int totalMonths = 0;

            foreach (var exp in experiences)
            {
                var endDate = exp.EndDate ?? DateTime.Now;
                var months = ((endDate.Year - exp.StartDate.Year) * 12) + endDate.Month - exp.StartDate.Month;
                totalMonths += months;
            }

            return totalMonths;
        }

        protected override WorkExperienceResponse MapToResponse(WorkExperience entity)
        {
            var response = _mapper.Map<WorkExperienceResponse>(entity);

            if (entity.Candidate != null)
            {
                response.CandidateName = $"{entity.Candidate.FirstName} {entity.Candidate.LastName}";
            }
            
            return response;
        }
    }
} 