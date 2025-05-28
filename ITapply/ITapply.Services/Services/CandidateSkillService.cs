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
    public class CandidateSkillService
        : BaseCRUDService<CandidateSkillResponse, CandidateSkillSearchObject, CandidateSkill, CandidateSkillInsertRequest, CandidateSkillUpdateRequest>, ICandidateSkillService
    {
        public CandidateSkillService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<CandidateSkill> AddInclude(IQueryable<CandidateSkill> query, CandidateSkillSearchObject search)
        {
            query = query.Include(cs => cs.Candidate).Include(cs => cs.Skill);
            return query;
        }

        public override async Task<CandidateSkillResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.CandidateSkills
                .Include(a => a.Candidate)
                .Include(a => a.Skill)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<CandidateSkill> ApplyFilter(IQueryable<CandidateSkill> query, CandidateSkillSearchObject search)
        {
            if (search.CandidateId.HasValue)
            {
                query = query.Where(cs => cs.CandidateId == search.CandidateId);
            }

            if (search.SkillId.HasValue)
            {
                query = query.Where(cs => cs.SkillId == search.SkillId);
            }

            if (search.MinLevel.HasValue)
            {
                query = query.Where(cs => cs.Level >= search.MinLevel);
            }

            if (search.MaxLevel.HasValue)
            {
                query = query.Where(cs => cs.Level <= search.MaxLevel);
            }

            return query;
        }

        protected override async Task BeforeInsert(CandidateSkill entity, CandidateSkillInsertRequest request)
        {
            var candidate = await _context.Candidates.FindAsync(request.CandidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {request.CandidateId} not found");
            }

            var skill = await _context.Skills.FindAsync(request.SkillId);
            if (skill == null)
            {
                throw new UserException($"Skill with ID {request.SkillId} not found");
            }

            var existingSkill = await _context.CandidateSkills
                .FirstOrDefaultAsync(cs => cs.CandidateId == request.CandidateId && cs.SkillId == request.SkillId);
            
            if (existingSkill != null)
            {
                throw new UserException($"Candidate already has the skill '{skill.Name}'. Use update instead.");
            }

            await base.BeforeInsert(entity, request);
        }

        protected override CandidateSkillResponse MapToResponse(CandidateSkill entity)
        {
            var response = _mapper.Map<CandidateSkillResponse>(entity);

            if (entity.Candidate != null)
            {
                response.CandidateName = entity.Candidate.FirstName + " " + entity.Candidate.LastName;
            }

            if (entity.Skill != null)
            {
                response.SkillName = entity.Skill.Name;
            }

            return response;
        }
    }
} 