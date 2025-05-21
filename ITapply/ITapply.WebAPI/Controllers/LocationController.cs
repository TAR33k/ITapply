using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    [Authorize(Roles = "Administrator")]
    public class LocationController : BaseCRUDController<LocationResponse, LocationSearchObject, LocationInsertRequest, LocationUpdateRequest>
    {
        public LocationController(ILocationService locationService) : base(locationService)
        {
        }

        [HttpGet("")]
        [AllowAnonymous]
        public override async Task<PagedResult<LocationResponse>> Get([FromQuery] LocationSearchObject? search = null)
        {
            return await _service.GetAsync(search ?? new LocationSearchObject());
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<LocationResponse> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
}
