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
    public class UserRoleService
        : BaseCRUDService<UserRoleResponse, UserRoleSearchObject, UserRole, UserRoleInsertRequest, UserRoleUpdateRequest>, IUserRoleService
    {
        protected readonly ITapplyDbContext _context;

        public UserRoleService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        protected override IQueryable<UserRole> ApplyFilter(IQueryable<UserRole> query, UserRoleSearchObject search)
        {
            if (search.UserId != null)
            {
                query = query.Where(l => l.UserId == search.UserId);
            }
            if (search.RoleId != null)
            {
                query = query.Where(l => l.RoleId == search.RoleId);
            }
            if (!string.IsNullOrEmpty(search.RoleName))
            {
                query = query.Where(l => l.Role.Name.Contains(search.RoleName));
            }

            return query;
        }

        protected override async Task BeforeInsert(UserRole entity, UserRoleInsertRequest request)
        {
            var user = await _context.Users.FindAsync(request.UserId);
            if (user == null)
                throw new InvalidOperationException("Invalid user");

            var role = await _context.Roles.FindAsync(request.RoleId);
            if (role == null)
                throw new InvalidOperationException("Invalid role");

            var userRole = await _context.UserRoles.AnyAsync(u => u.RoleId == request.RoleId && u.UserId == request.UserId);
            if (role == null)
                throw new InvalidOperationException("User already has " + role.Name + " role.");
        }

        protected override async Task BeforeUpdate(UserRole entity, UserRoleUpdateRequest request)
        {
            var user = await _context.Users.FindAsync(request.UserId);
            if (user == null)
                throw new InvalidOperationException("Invalid user");

            var role = await _context.Roles.FindAsync(request.RoleId);
            if (role == null)
                throw new InvalidOperationException("Invalid role");

            var userRole = await _context.UserRoles.AnyAsync(u => u.RoleId == request.RoleId && u.UserId == request.UserId && u.Id != entity.Id);
            if (role == null)
                throw new InvalidOperationException("User already has " + role.Name + " role.");
        }
    }
}