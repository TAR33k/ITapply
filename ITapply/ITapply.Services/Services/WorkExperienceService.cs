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

        protected override IQueryable<WorkExperience> ApplyFilter(IQueryable<WorkExperience> query, WorkExperienceSearchObject search)
        {
            query = query.Include(x => x.Candidate);

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

        public async Task<List<WorkExperienceResponse>> GetByCandidateIdAsync(int candidateId)
        {
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