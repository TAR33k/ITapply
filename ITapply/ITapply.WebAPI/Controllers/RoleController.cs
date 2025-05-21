using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;

namespace ITapply.WebAPI.Controllers
{
    public class RoleController : BaseCRUDController<RoleResponse, RoleSearchObject, RoleInsertRequest, RoleUpdateRequest>
    {
        public RoleController(IRoleService roleService) : base(roleService)
        {
        }
    }
}
