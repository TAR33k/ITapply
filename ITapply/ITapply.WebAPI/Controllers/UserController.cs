using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using ITapply.Services.Services;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class UserController : BaseCRUDController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        protected readonly IUserService _userService;

        public UserController(IUserService userService) : base(userService)
        {
            _userService = userService;
        }

        [HttpPost("login")]
        public async Task<ActionResult<UserResponse>> Login(UserLoginRequest request)
        {
            var user = await _userService.Login(request);
            if (user == null)
                return Unauthorized();

            return Ok(user);
        }
    }
}
