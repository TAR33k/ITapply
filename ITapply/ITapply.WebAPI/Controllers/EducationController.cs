using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
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
        private readonly IEducationService _service;

        public EducationController(IEducationService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("candidate/{candidateId}")]
        public async Task<ActionResult<List<EducationResponse>>> GetByCandidateId(int candidateId)
        {
            return await _service.GetByCandidateIdAsync(candidateId);
        }

        [HttpGet("candidate/{candidateId}/highest-degree")]
        public async Task<ActionResult<string>> GetHighestDegree(int candidateId)
        {
            return await _service.GetHighestDegreeAsync(candidateId);
        }
    }
} 