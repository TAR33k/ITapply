using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.WebAPI.Controllers
{
    public class JobPostingController : BaseCRUDController<JobPostingResponse, JobPostingSearchObject, JobPostingInsertRequest, JobPostingUpdateRequest>
    {
        private readonly IJobPostingService _jobPostingService;

        public JobPostingController(IJobPostingService jobPostingService) : base(jobPostingService)
        {
            _jobPostingService = jobPostingService;
        }

        [HttpGet("recommended/{candidateId}")]
        public async Task<ActionResult<List<JobPostingResponse>>> GetRecommendedJobs(int candidateId, [FromQuery] int count = 5)
        {
            try
            {
                var result = await _jobPostingService.GetRecommendedJobsForCandidateAsync(candidateId, count);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{id}/status")]
        public async Task<ActionResult<JobPostingResponse>> UpdateStatus(int id, [FromQuery] JobPostingStatus status)
        {
            try
            {
                var result = await _jobPostingService.UpdateStatusAsync(id, status);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
} 