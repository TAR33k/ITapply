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

        [HttpPut("{id}/verification-status")]
        public async Task<ActionResult<EmployerResponse>> UpdateVerificationStatus(int id, [FromQuery] VerificationStatus status)
        {
            return await _employerService.UpdateVerificationStatusAsync(id, status);
        }
    }
} 