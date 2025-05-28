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
    public class SkillService
        : BaseCRUDService<SkillResponse, SkillSearchObject, Skill, SkillInsertRequest, SkillUpdateRequest>, ISkillService
    {
        public SkillService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Skill> ApplyFilter(IQueryable<Skill> query, SkillSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(s => s.Name.Contains(search.Name));
            }

            return query;
        }

        protected override async Task BeforeInsert(Skill entity, SkillInsertRequest request)
        {
            var skillExists = await _context.Skills
                .AnyAsync(s => s.Name.ToLower() == request.Name.ToLower());
            
            if (skillExists)
            {
                throw new UserException($"Skill with name '{request.Name}' already exists");
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Skill entity, SkillUpdateRequest request)
        {
            var skillExists = await _context.Skills
                .AnyAsync(s => s.Id != entity.Id && s.Name.ToLower() == request.Name.ToLower());
            
            if (skillExists)
            {
                throw new UserException($"Skill with name '{request.Name}' already exists");
            }

            await base.BeforeUpdate(entity, request);
        }
    }
} 