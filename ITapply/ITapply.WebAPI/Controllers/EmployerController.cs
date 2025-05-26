using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.WebAPI.Controllers
{
    public class EmployerController : BaseCRUDController<EmployerResponse, EmployerSearchObject, EmployerInsertRequest, EmployerUpdateRequest>
    {
        private readonly IEmployerService _employerService;

        public EmployerController(IEmployerService employerService) : base(employerService)
        {
            _employerService = employerService;
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<EmployerResponse>> GetByUserId(int userId)
        {
            var result = await _employerService.GetByUserIdAsync(userId);
            if (result == null)
            {
                return NotFound();
            }

            return Ok(result);
        }

        [HttpPut("{id}/verification-status")]
        public async Task<ActionResult<EmployerResponse>> UpdateVerificationStatus(int id, [FromQuery] VerificationStatus status)
        {
            try
            {
                var result = await _employerService.UpdateVerificationStatusAsync(id, status);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
} 