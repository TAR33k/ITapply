using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    [Authorize(Roles = "Administrator")] 
    public class RoleController : BaseCRUDController<RoleResponse, RoleSearchObject, RoleInsertRequest, RoleUpdateRequest>
    {
        public RoleController(IRoleService roleService) : base(roleService)
        {
        }
    }
}
