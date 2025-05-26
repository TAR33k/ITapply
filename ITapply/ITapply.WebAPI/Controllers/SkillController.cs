using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;

namespace ITapply.WebAPI.Controllers
{
    public class SkillController : BaseCRUDController<SkillResponse, SkillSearchObject, SkillInsertRequest, SkillUpdateRequest>
    {
        public SkillController(ISkillService skillService) : base(skillService)
        {
        }
    }
} 