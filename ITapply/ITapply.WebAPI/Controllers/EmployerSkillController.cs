using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;

namespace ITapply.WebAPI.Controllers
{
    public class EmployerSkillController : BaseCRUDController<EmployerSkillResponse, EmployerSkillSearchObject, EmployerSkillInsertRequest, EmployerSkillUpdateRequest>
    {
        public EmployerSkillController(IEmployerSkillService employerSkillService) : base(employerSkillService)
        {
        }
    }
} 