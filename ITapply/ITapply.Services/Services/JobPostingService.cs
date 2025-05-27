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
    public class JobPostingService
        : BaseCRUDService<JobPostingResponse, JobPostingSearchObject, JobPosting, JobPostingInsertRequest, JobPostingUpdateRequest>, IJobPostingService
    {
        public JobPostingService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<List<JobPostingResponse>> GetRecommendedJobsForCandidateAsync(int candidateId, int count = 5)
        {
            // -------------------------
            // RECOMMENDER SYSTEM - TODO
            // -------------------------

            return new List<JobPostingResponse>();
        }

        public async Task<JobPostingResponse> UpdateStatusAsync(int id, JobPostingStatus status)
        {
            var entity = await _context.JobPostings.FindAsync(id);
            if (entity == null)
            {
                throw new UserException($"JobPosting with ID {id} not found");
            }

            entity.Status = status;
            await _context.SaveChangesAsync();

            return _mapper.Map<JobPostingResponse>(entity);
        }

        public override async Task<PagedResult<JobPostingResponse>> GetAsync(JobPostingSearchObject search)
        {
            var result = await base.GetAsync(search);

            foreach (var jobPosting in result.Items)
            {
                jobPosting.ApplicationCount = await _context.Applications
                    .CountAsync(a => a.JobPostingId == jobPosting.Id);
            }

            return result;
        }

        public override async Task<JobPostingResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.JobPostings
                .Include(jp => jp.Employer)
                .Include(jp => jp.Location)
                .Include(jp => jp.JobPostingSkills)
                    .ThenInclude(jps => jps.Skill)
                .FirstOrDefaultAsync(jp => jp.Id == id);

            if (entity == null)
            {
                return null;
            }

            var result = _mapper.Map<JobPostingResponse>(entity);

            result.ApplicationCount = await _context.Applications
                .CountAsync(a => a.JobPostingId == id);

            return result;
        }

        protected override IQueryable<JobPosting> ApplyFilter(IQueryable<JobPosting> query, JobPostingSearchObject search)
        {
            query = query
                .Include(jp => jp.Employer)
                .Include(jp => jp.Location)
                .Include(jp => jp.JobPostingSkills)
                    .ThenInclude(jps => jps.Skill);

            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(jp => jp.Title.Contains(search.Title));
            }

            if (search.EmployerId.HasValue)
            {
                query = query.Where(jp => jp.EmployerId == search.EmployerId);
            }

            if (!string.IsNullOrEmpty(search.EmployerName))
            {
                query = query.Where(jp => jp.Employer.CompanyName.Contains(search.EmployerName));
            }

            if (search.EmploymentType.HasValue)
            {
                query = query.Where(jp => jp.EmploymentType == search.EmploymentType);
            }

            if (search.ExperienceLevel.HasValue)
            {
                query = query.Where(jp => jp.ExperienceLevel == search.ExperienceLevel);
            }

            if (search.LocationId.HasValue)
            {
                query = query.Where(jp => jp.LocationId == search.LocationId);
            }

            if (search.Remote.HasValue)
            {
                query = query.Where(jp => jp.Remote == search.Remote);
            }

            if (search.MinSalary.HasValue)
            {
                query = query.Where(jp => jp.MinSalary >= search.MinSalary);
            }

            if (search.MaxSalary.HasValue)
            {
                query = query.Where(jp => jp.MaxSalary <= search.MaxSalary);
            }

            if (search.PostedAfter.HasValue)
            {
                query = query.Where(jp => jp.PostedDate >= search.PostedAfter);
            }

            if (search.DeadlineBefore.HasValue)
            {
                query = query.Where(jp => jp.ApplicationDeadline <= search.DeadlineBefore);
            }

            if (search.Status.HasValue)
            {
                query = query.Where(jp => jp.Status == search.Status);
            }

            if (search.SkillIds != null && search.SkillIds.Any())
            {
                query = query.Where(jp => jp.JobPostingSkills.Any(jps => search.SkillIds.Contains(jps.SkillId)));
            }

            if (!search.IncludeExpired)
            {
                query = query.Where(jp => jp.ApplicationDeadline > DateTime.Now);
            }

            return query;
        }

        protected override async Task BeforeInsert(JobPosting entity, JobPostingInsertRequest request)
        {
            var employer = await _context.Employers.FindAsync(request.EmployerId);
            if (employer == null)
            {
                throw new UserException($"Employer with ID {request.EmployerId} not found");
            }

            if (request.LocationId.HasValue)
            {
                var location = await _context.Locations.FindAsync(request.LocationId.Value);
                if (location == null)
                {
                    throw new UserException($"Location with ID {request.LocationId.Value} not found");
                }
            }

            entity.PostedDate = DateTime.Now;
            entity.Status = JobPostingStatus.Active;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task AfterInsert(JobPosting entity, JobPostingInsertRequest request)
        {
            if (request.SkillIds != null && request.SkillIds.Any())
            {
                foreach (var skillId in request.SkillIds)
                {
                    var skill = await _context.Skills.FindAsync(skillId);
                    if (skill == null)
                    {
                        throw new UserException($"Skill with ID {skillId} not found");
                    }

                    _context.JobPostingSkills.Add(new JobPostingSkill
                    {
                        JobPostingId = entity.Id,
                        SkillId = skillId
                    });
                }

                await _context.SaveChangesAsync();
            }

            await base.AfterInsert(entity, request);
        }

        protected override async Task BeforeUpdate(JobPosting entity, JobPostingUpdateRequest request)
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

        protected override async Task AfterUpdate(JobPosting entity, JobPostingUpdateRequest request)
        {
            if (request.SkillIds != null)
            {
                var existingSkills = await _context.JobPostingSkills
                    .Where(jps => jps.JobPostingId == entity.Id)
                    .ToListAsync();

                _context.JobPostingSkills.RemoveRange(existingSkills);

                foreach (var skillId in request.SkillIds)
                {
                    var skill = await _context.Skills.FindAsync(skillId);
                    if (skill == null)
                    {
                        throw new UserException($"Skill with ID {skillId} not found");
                    }

                    _context.JobPostingSkills.Add(new JobPostingSkill
                    {
                        JobPostingId = entity.Id,
                        SkillId = skillId
                    });
                }

                await _context.SaveChangesAsync();
            }

            await base.AfterUpdate(entity, request);
        }
    }
} 