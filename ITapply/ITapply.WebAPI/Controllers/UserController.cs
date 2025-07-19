using ITapply.Models.Exceptions;
using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using ITapply.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class UserController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        private readonly IUserService _userService;
        public UserController(IUserService userService) : base(userService)
        {
            _userService = userService;
        }

        [AllowAnonymous]
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

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<UserResponse> Update(int id, [FromBody] UserUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [AllowAnonymous]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<ActionResult<UserResponse>> Login([FromBody] UserLoginRequest request)
        {
            var user = await _userService.Login(request);
            return Ok(user);
        }

        [HttpPut("{id}/change-password")]
        [Authorize]
        public async Task<ActionResult> ChangePassword(int id, [FromBody] ChangePasswordRequest request)
        {
            var result = await _userService.ChangePassword(id, request);
            if (!result)
            {
                return BadRequest();
            }
            return Ok();
        }
    }
}
