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
    public class JobPostingSkillService
        : BaseCRUDService<JobPostingSkillResponse, JobPostingSkillSearchObject, JobPostingSkill, JobPostingSkillInsertRequest, JobPostingSkillUpdateRequest>, IJobPostingSkillService
    {
        public JobPostingSkillService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<JobPostingSkill> AddInclude(IQueryable<JobPostingSkill> query, JobPostingSkillSearchObject search)
        {
            query = query
                .Include(a => a.JobPosting)
                    .ThenInclude(a => a.Employer)
                .Include(a => a.Skill);

            return query;
        }

        public override async Task<JobPostingSkillResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.JobPostingSkills
                .Include(a => a.JobPosting)
                    .ThenInclude(a => a.Employer)
                .Include(a => a.Skill)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<JobPostingSkill> ApplyFilter(IQueryable<JobPostingSkill> query, JobPostingSkillSearchObject search)
        {
            if (search.JobPostingId.HasValue)
            {
                query = query.Where(jps => jps.JobPostingId == search.JobPostingId);
            }

            if (search.SkillId.HasValue)
            {
                query = query.Where(jps => jps.SkillId == search.SkillId);
            }

            return query;
        }

        protected override JobPostingSkillResponse MapToResponse(JobPostingSkill entity)
        {
            var response = _mapper.Map<JobPostingSkillResponse>(entity);

            if (entity.JobPosting != null)
            {
                response.JobPostingTitle = entity.JobPosting.Title;

                if (entity.JobPosting.Employer != null)
                {
                    response.EmployerName = entity.JobPosting.Employer.CompanyName;
                }
            }

            if (entity.Skill != null)
            {
                response.SkillName = entity.Skill.Name;
            }

            return response;
        }
    }
} 