using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class CandidateController : BaseCRUDController<CandidateResponse, CandidateSearchObject, CandidateInsertRequest, CandidateUpdateRequest>
    {
        public CandidateController(ICandidateService candidateService) : base(candidateService)
        {
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<PagedResult<CandidateResponse>> Get([FromQuery] CandidateSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<CandidateResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [AllowAnonymous]
        public override async Task<CandidateResponse> Create([FromBody] CandidateInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<CandidateResponse> Update(int id, [FromBody] CandidateUpdateRequest request)
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