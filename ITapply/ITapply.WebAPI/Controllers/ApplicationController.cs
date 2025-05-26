using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.WebAPI.Controllers
{
    public class ApplicationController : BaseCRUDController<ApplicationResponse, ApplicationSearchObject, ApplicationInsertRequest, ApplicationUpdateRequest>
    {
        private readonly IApplicationService _applicationService;

        public ApplicationController(IApplicationService applicationService) : base(applicationService)
        {
            _applicationService = applicationService;
        }

        [HttpPut("{id}/status")]
        public async Task<ActionResult<ApplicationResponse>> UpdateStatus(int id, [FromQuery] ApplicationStatus status)
        {
            try
            {
                var result = await _applicationService.UpdateStatusAsync(id, status);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("check")]
        public async Task<ActionResult<bool>> HasApplied([FromQuery] int candidateId, [FromQuery] int jobPostingId)
        {
            try
            {
                var result = await _applicationService.HasAppliedAsync(candidateId, jobPostingId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
} 