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
    public class EducationController : BaseCRUDController<EducationResponse, EducationSearchObject, EducationInsertRequest, EducationUpdateRequest>
    {
        private readonly IEducationService _educationService;

        public EducationController(IEducationService service) : base(service)
        {
            _educationService = service;
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<PagedResult<EducationResponse>> Get([FromQuery] EducationSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public override async Task<EducationResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<EducationResponse> Create([FromBody] EducationInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<EducationResponse> Update(int id, [FromBody] EducationUpdateRequest request)
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
        public async Task<ActionResult<List<EducationResponse>>> GetByCandidateId(int candidateId)
        {
            var result = await _educationService.GetByCandidateIdAsync(candidateId);
            return Ok(result);
        }

        [HttpGet("candidate/{candidateId}/highest-degree")]
        [Authorize(Roles = "Administrator,Candidate,Employer")]
        public async Task<ActionResult<string>> GetHighestDegree(int candidateId)
        {
            var result = await _educationService.GetHighestDegreeAsync(candidateId);
            if (string.IsNullOrEmpty(result)) return NotFound();
            return Ok(result);
        }
    }
} 