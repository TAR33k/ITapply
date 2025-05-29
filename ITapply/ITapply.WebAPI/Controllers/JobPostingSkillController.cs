using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class JobPostingSkillController : BaseCRUDController<JobPostingSkillResponse, JobPostingSkillSearchObject, JobPostingSkillInsertRequest, JobPostingSkillUpdateRequest>
    {
        public JobPostingSkillController(IJobPostingSkillService jobPostingSkillService) : base(jobPostingSkillService)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<JobPostingSkillResponse>> Get([FromQuery] JobPostingSkillSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<JobPostingSkillResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<JobPostingSkillResponse> Create([FromBody] JobPostingSkillInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<JobPostingSkillResponse> Update(int id, [FromBody] JobPostingSkillUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
} 