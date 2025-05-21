using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;

namespace ITapply.WebAPI.Controllers
{
    public class UserRoleController 
        : BaseCRUDController<UserRoleResponse, UserRoleSearchObject, UserRoleInsertRequest, UserRoleUpdateRequest>
    {
        public UserRoleController(IUserRoleService userRoleService) : base(userRoleService)
        {
        }
    }
}
