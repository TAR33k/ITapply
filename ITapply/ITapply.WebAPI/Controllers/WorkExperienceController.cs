using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.WebAPI.Controllers
{
    public class WorkExperienceController : BaseCRUDController<WorkExperienceResponse, WorkExperienceSearchObject, WorkExperienceInsertRequest, WorkExperienceUpdateRequest>
    {
        private readonly IWorkExperienceService _workExperienceService;

        public WorkExperienceController(IWorkExperienceService service) : base(service)
        {
            _workExperienceService = service;
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<PagedResult<WorkExperienceResponse>> Get([FromQuery] WorkExperienceSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<WorkExperienceResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<WorkExperienceResponse> Create([FromBody] WorkExperienceInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<WorkExperienceResponse> Update(int id, [FromBody] WorkExperienceUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpGet("candidate/{candidateId}")]
        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public async Task<ActionResult<List<WorkExperienceResponse>>> GetByCandidateId(int candidateId)
        {
            var result = await _workExperienceService.GetByCandidateIdAsync(candidateId);
            return Ok(result);
        }

        [HttpGet("candidate/{candidateId}/total-months")]
        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public async Task<ActionResult<int>> GetTotalExperienceMonths(int candidateId)
        {
            var result = await _workExperienceService.GetTotalExperienceMonthsAsync(candidateId);
            return Ok(result);
        }
    }
} 