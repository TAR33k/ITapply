using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class CandidateController : BaseCRUDController<CandidateResponse, CandidateSearchObject, CandidateInsertRequest, CandidateUpdateRequest>
    {
        private readonly ICandidateService _candidateService;

        public CandidateController(ICandidateService candidateService) : base(candidateService)
        {
            _candidateService = candidateService;
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<CandidateResponse>> GetByUserId(int userId)
        {
            var result = await _candidateService.GetByUserIdAsync(userId);
            if (result == null)
            {
                return NotFound();
            }

            return Ok(result);
        }
    }
} 