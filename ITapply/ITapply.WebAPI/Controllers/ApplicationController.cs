using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
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

        [Authorize(Roles = "Administrator,Employer,Candidate")]
        public override async Task<PagedResult<ApplicationResponse>> Get([FromQuery] ApplicationSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [Authorize(Roles = "Administrator,Employer,Candidate")]
        public override async Task<ApplicationResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Candidate")]
        public override async Task<ApplicationResponse> Create([FromBody] ApplicationInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<ApplicationResponse> Update(int id, [FromBody] ApplicationUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpPut("{id}/status")]
        [Authorize(Roles = "Employer,Candidate,Administrator")]
        public async Task<ActionResult<ApplicationResponse>> UpdateStatus(int id, [FromQuery] ApplicationStatus status)
        {
            return await _applicationService.UpdateStatusAsync(id, status);
        }

        [HttpPut("{id}/notifications")]
        [Authorize(Roles = "Administrator,Candidate")]
        public async Task<ActionResult<ApplicationResponse>> ToggleNotifications(int id)
        {
            return await _applicationService.ToggleNotificationsAsync(id);
        }

        [HttpGet("check")]
        [Authorize(Roles = "Candidate,Employer,Administrator")]
        public async Task<ActionResult<bool>> HasApplied([FromQuery] int candidateId, [FromQuery] int jobPostingId)
        {
            return await _applicationService.HasAppliedAsync(candidateId, jobPostingId);
        }
    }
} 