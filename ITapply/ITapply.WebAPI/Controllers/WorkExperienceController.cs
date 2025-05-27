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
    public class WorkExperienceController : BaseCRUDController<WorkExperienceResponse, WorkExperienceSearchObject, WorkExperienceInsertRequest, WorkExperienceUpdateRequest>
    {
        private readonly IWorkExperienceService _service;

        public WorkExperienceController(IWorkExperienceService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("candidate/{candidateId}")]
        public async Task<ActionResult<List<WorkExperienceResponse>>> GetByCandidateId(int candidateId)
        {
            return await _service.GetByCandidateIdAsync(candidateId);
        }

        [HttpGet("candidate/{candidateId}/total-months")]
        public async Task<ActionResult<int>> GetTotalExperienceMonths(int candidateId)
        {
            return await _service.GetTotalExperienceMonthsAsync(candidateId);
        }
    }
} 