using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Database;
using ITapply.Services.Interfaces;
using MapsterMapper;
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
    }
} 