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
    public class EmployerSkillService
        : BaseCRUDService<EmployerSkillResponse, EmployerSkillSearchObject, EmployerSkill, EmployerSkillInsertRequest, EmployerSkillUpdateRequest>, IEmployerSkillService
    {
        public EmployerSkillService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<EmployerSkill> AddInclude(IQueryable<EmployerSkill> query, EmployerSkillSearchObject search)
        {
            query = query.Include(es => es.Employer).Include(es => es.Skill);
            return query;
        }

        public override async Task<EmployerSkillResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.EmployerSkills
                .Include(a => a.Employer)
                .Include(a => a.Skill)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<EmployerSkill> ApplyFilter(IQueryable<EmployerSkill> query, EmployerSkillSearchObject search)
        {
            if (search.EmployerId.HasValue)
            {
                query = query.Where(es => es.EmployerId == search.EmployerId);
            }

            if (search.SkillId.HasValue)
            {
                query = query.Where(es => es.SkillId == search.SkillId);
            }

            return query;
        }

        protected override async Task BeforeInsert(EmployerSkill entity, EmployerSkillInsertRequest request)
        {
            var employer = await _context.Employers.FindAsync(request.EmployerId);
            if (employer == null)
            {
                throw new UserException($"Employer with ID {request.EmployerId} not found");
            }

            var skill = await _context.Skills.FindAsync(request.SkillId);
            if (skill == null)
            {
                throw new UserException($"Skill with ID {request.SkillId} not found");
            }

            var existingSkill = await _context.EmployerSkills
                .FirstOrDefaultAsync(es => es.EmployerId == request.EmployerId && es.SkillId == request.SkillId);
            
            if (existingSkill != null)
            {
                throw new UserException($"Employer already has the skill '{skill.Name}'");
            }

            await base.BeforeInsert(entity, request);
        }

        protected override EmployerSkillResponse MapToResponse(EmployerSkill entity)
        {
            var response = _mapper.Map<EmployerSkillResponse>(entity);

            if (entity.Employer != null)
            {
                response.EmployerName = entity.Employer.CompanyName;
            }

            if (entity.Skill != null)
            {
                response.SkillName = entity.Skill.Name;
            }

            return response;
        }
    }
} 