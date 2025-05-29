using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class LocationController : BaseCRUDController<LocationResponse, LocationSearchObject, LocationInsertRequest, LocationUpdateRequest>
    {
        public LocationController(ILocationService locationService) : base(locationService)
        {
        }

        [HttpGet("")]
        [AllowAnonymous]
        public override async Task<PagedResult<LocationResponse>> Get([FromQuery] LocationSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<LocationResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public override async Task<LocationResponse> Create([FromBody] LocationInsertRequest request)
        {
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Administrator")]
        public override async Task<LocationResponse> Update(int id, [FromBody] LocationUpdateRequest request) 
        {
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrator")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
}
