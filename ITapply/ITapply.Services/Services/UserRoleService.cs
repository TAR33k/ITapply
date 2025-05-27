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
    public class UserRoleService
        : BaseCRUDService<UserRoleResponse, UserRoleSearchObject, UserRole, UserRoleInsertRequest, UserRoleUpdateRequest>, IUserRoleService
    {
        protected readonly ITapplyDbContext _context;

        public UserRoleService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        public override IQueryable<UserRole> AddInclude(IQueryable<UserRole> query, UserRoleSearchObject? search = null)
        {
            return query = query.Include(ur => ur.Role)
                        .Include(ur => ur.User)
                            .ThenInclude(u => u.UserRoles)
                                .ThenInclude(ur => ur.Role);
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
            var user = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == request.UserId);
                
            if (user == null)
                throw new UserException("Invalid user");

            var role = await _context.Roles.FindAsync(request.RoleId);
            if (role == null)
                throw new UserException("Invalid role");

            var existingUserRole = await _context.UserRoles
                .AnyAsync(u => u.RoleId == request.RoleId && u.UserId == request.UserId);
                
            if (existingUserRole)
                throw new UserException($"User already has {role.Name} role.");
        }

        protected override async Task BeforeUpdate(UserRole entity, UserRoleUpdateRequest request)
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == request.UserId);
                
            if (user == null)
                throw new UserException("Invalid user");

            var role = await _context.Roles.FindAsync(request.RoleId);
            if (role == null)
                throw new UserException("Invalid role");

            var existingUserRole = await _context.UserRoles
                .AnyAsync(u => u.RoleId == request.RoleId && u.UserId == request.UserId && u.Id != entity.Id);
                
            if (existingUserRole)
                throw new UserException($"User already has {role.Name} role.");
        }

        public override async Task<UserRoleResponse> GetByIdAsync(int id)
        {
            var entity = await _context.UserRoles
                .Include(ur => ur.Role)
                .Include(ur => ur.User)
                .FirstOrDefaultAsync(ur => ur.Id == id);

            return entity != null ? MapToResponse(entity) : null;
        }

        protected override UserRoleResponse MapToResponse(UserRole entity)
        {
            var response = _mapper.Map<UserRoleResponse>(entity);

            if (entity.User != null)
            {
                response.UserEmail = entity.User.Email;
            }

            if (entity.Role != null)
            {
                response.RoleName = entity.Role.Name;
            }

            return response;
        }
    }
}