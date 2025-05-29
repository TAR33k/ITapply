using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class EmployerSkillController : BaseCRUDController<EmployerSkillResponse, EmployerSkillSearchObject, EmployerSkillInsertRequest, EmployerSkillUpdateRequest>
    {
        public EmployerSkillController(IEmployerSkillService employerSkillService) : base(employerSkillService)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<EmployerSkillResponse>> Get([FromQuery] EmployerSkillSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<EmployerSkillResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<EmployerSkillResponse> Create([FromBody] EmployerSkillInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<EmployerSkillResponse> Update(int id, [FromBody] EmployerSkillUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator,Employer")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
} 