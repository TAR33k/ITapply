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

        protected override async Task BeforeInsert(Role entity, RoleInsertRequest request)
        {
            var roleExists = await _context.Roles
                .AnyAsync(r => r.Name.ToLower() == request.Name.ToLower());
            
            if (roleExists)
            {
                throw new UserException($"Role with name '{request.Name}' already exists");
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Role entity, RoleUpdateRequest request)
        {
            var roleExists = await _context.Roles
                .AnyAsync(r => r.Id != entity.Id && r.Name.ToLower() == request.Name.ToLower());
            
            if (roleExists)
            {
                throw new UserException($"Role with name '{request.Name}' already exists");
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeDelete(Role entity)
        {
            var isUsed = await _context.UserRoles.AnyAsync(ur => ur.RoleId == entity.Id);
            if (isUsed)
            {
                throw new UserException("This role cannot be deleted because it is currently assigned to one or more users.");
            }
            await base.BeforeDelete(entity);
        }
    }
}
