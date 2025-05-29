using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class PreferencesController : BaseCRUDController<PreferencesResponse, PreferencesSearchObject, PreferencesInsertRequest, PreferencesUpdateRequest>
    {
        public PreferencesController(IPreferencesService preferencesService) : base(preferencesService)
        {
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<PagedResult<PreferencesResponse>> Get([FromQuery] PreferencesSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<PreferencesResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<PreferencesResponse> Create([FromBody] PreferencesInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<PreferencesResponse> Update(int id, [FromBody] PreferencesUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
} 