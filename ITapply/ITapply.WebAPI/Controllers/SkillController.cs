using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class SkillController : BaseCRUDController<SkillResponse, SkillSearchObject, SkillInsertRequest, SkillUpdateRequest>
    {
        public SkillController(ISkillService skillService) : base(skillService)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<SkillResponse>> Get([FromQuery] SkillSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<SkillResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator")]
        public override async Task<SkillResponse> Create([FromBody] SkillInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator")]
        public override async Task<SkillResponse> Update(int id, [FromBody] SkillUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
} 