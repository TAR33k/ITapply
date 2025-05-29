using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class UserController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public UserController(IUserService userService) : base(userService)
        {
        }

        [Authorize(Roles = "Administrator")]
        public override async Task<PagedResult<UserResponse>> Get([FromQuery] UserSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [Authorize(Roles = "Administrator")] 
        public override async Task<UserResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [AllowAnonymous]
        public override async Task<UserResponse> Create([FromBody] UserInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator")]
        public override async Task<UserResponse> Update(int id, [FromBody] UserUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
}
