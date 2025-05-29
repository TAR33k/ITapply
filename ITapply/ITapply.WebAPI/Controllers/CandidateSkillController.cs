using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class CandidateSkillController : BaseCRUDController<CandidateSkillResponse, CandidateSkillSearchObject, CandidateSkillInsertRequest, CandidateSkillUpdateRequest>
    {
        public CandidateSkillController(ICandidateSkillService candidateSkillService) : base(candidateSkillService)
        {
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")] 
        public override async Task<PagedResult<CandidateSkillResponse>> Get([FromQuery] CandidateSkillSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<CandidateSkillResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<CandidateSkillResponse> Create([FromBody] CandidateSkillInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<CandidateSkillResponse> Update(int id, [FromBody] CandidateSkillUpdateRequest request)
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