using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using static ITapply.Models.Responses.EnumResponse;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ITapply.WebAPI.Controllers
{
    public class JobPostingController : BaseCRUDController<JobPostingResponse, JobPostingSearchObject, JobPostingInsertRequest, JobPostingUpdateRequest>
    {
        private readonly IJobPostingService _jobPostingService;

        public JobPostingController(IJobPostingService jobPostingService) : base(jobPostingService)
        {
            _jobPostingService = jobPostingService;
        }

        [AllowAnonymous]
        public override async Task<PagedResult<JobPostingResponse>> Get([FromQuery] JobPostingSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<JobPostingResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<JobPostingResponse> Create([FromBody] JobPostingInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<JobPostingResponse> Update(int id, [FromBody] JobPostingUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpGet("recommended/{candidateId}")]
        [Authorize(Roles = "Administrator,Candidate")] 
        public async Task<ActionResult<List<JobPostingResponse>>> GetRecommendedJobs(int candidateId, [FromQuery] int count = 5)
        {
            var result = await _jobPostingService.GetRecommendedJobsForCandidateAsync(candidateId, count);
            return Ok(result);
        }

        [HttpPut("{id}/status")]
        [Authorize(Roles = "Administrator,Employer")]
        public async Task<ActionResult<JobPostingResponse>> UpdateStatus(int id, [FromQuery] JobPostingStatus status)
        {
            var result = await _jobPostingService.UpdateStatusAsync(id, status);
            if (result == null) return NotFound();
            return Ok(result);
        }
    }
} 