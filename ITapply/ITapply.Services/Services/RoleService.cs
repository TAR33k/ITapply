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
    public class RoleService
        : BaseCRUDService<RoleResponse, RoleSearchObject, Role, RoleInsertRequest, RoleUpdateRequest>, IRoleService
    {
        public RoleService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Role> ApplyFilter(IQueryable<Role> query, RoleSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(l => l.Name.Contains(search.Name));
            }

            return query;
        }
    }
}
