using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
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

        [AllowAnonymous]
        public override async Task<PagedResult<EmployerResponse>> Get([FromQuery] EmployerSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<EmployerResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [AllowAnonymous]
        public override async Task<EmployerResponse> Create([FromBody] EmployerInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<EmployerResponse> Update(int id, [FromBody] EmployerUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpPut("{id}/verification-status")]
        [Authorize(Roles = "Administrator")]
        public async Task<ActionResult<EmployerResponse>> UpdateVerificationStatus(int id, [FromQuery] VerificationStatus status)
        {
            var result = await _employerService.UpdateVerificationStatusAsync(id, status);
            if (result == null) return NotFound();
            return Ok(result);
        }
    }
} 