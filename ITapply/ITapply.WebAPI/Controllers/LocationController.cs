using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class LocationController : BaseCRUDController<LocationResponse, LocationSearchObject, LocationInsertRequest, LocationUpdateRequest>
    {
        public LocationController(ILocationService locationService) : base(locationService)
        {
        }
    }
}
