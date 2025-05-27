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
    public class EducationService 
        : BaseCRUDService<EducationResponse, EducationSearchObject, Education, EducationInsertRequest, EducationUpdateRequest>, IEducationService
    {
        public EducationService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Education> AddInclude(IQueryable<Education> query, EducationSearchObject? search = null)
        {
            return query = query.Include(x => x.Candidate); ;
        }

        public override async Task<EducationResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Educations
                .Include(a => a.Candidate)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<Education> ApplyFilter(IQueryable<Education> query, EducationSearchObject search)
        {
            if (search.CandidateId.HasValue)
                query = query.Where(x => x.CandidateId == search.CandidateId);

            if (!string.IsNullOrEmpty(search.Institution))
                query = query.Where(x => x.Institution.Contains(search.Institution));

            if (!string.IsNullOrEmpty(search.Degree))
                query = query.Where(x => x.Degree.Contains(search.Degree));

            if (!string.IsNullOrEmpty(search.FieldOfStudy))
                query = query.Where(x => x.FieldOfStudy.Contains(search.FieldOfStudy));

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

        public async Task<List<EducationResponse>> GetByCandidateIdAsync(int candidateId)
        {
            var entities = await _context.Educations
                .Include(x => x.Candidate)
                .Where(x => x.CandidateId == candidateId)
                .OrderByDescending(x => x.EndDate == null)
                .ThenByDescending(x => x.EndDate)
                .ThenByDescending(x => x.StartDate)
                .ToListAsync();

            return entities.Select(MapToResponse).ToList();
        }

        public async Task<string> GetHighestDegreeAsync(int candidateId)
        {
            var education = await _context.Educations
                .Where(x => x.CandidateId == candidateId)
                .ToListAsync();

            if (!education.Any())
                return "No education listed";

            Dictionary<string, int> degreeRanks = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
            {
                { "High School", 1 },
                { "Associate", 2 },
                { "Bachelor", 3 },
                { "Master", 4 },
                { "PhD", 5 },
                { "Doctorate", 5 },
                { "Postdoctoral", 6 }
            };

            int highestRank = 0;
            string highestDegree = "Other";

            foreach (var edu in education)
            {
                foreach (var degree in degreeRanks)
                {
                    if (edu.Degree.Contains(degree.Key, StringComparison.OrdinalIgnoreCase) && degree.Value > highestRank)
                    {
                        highestRank = degree.Value;
                        highestDegree = edu.Degree;
                    }
                }
            }

            return highestDegree;
        }

        protected override EducationResponse MapToResponse(Education entity)
        {
            var response = _mapper.Map<EducationResponse>(entity);

            if (entity.Candidate != null)
            {
                response.CandidateName = $"{entity.Candidate.FirstName} {entity.Candidate.LastName}";
            }
            
            return response;
        }
    }
} 