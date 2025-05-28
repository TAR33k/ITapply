using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;

namespace ITapply.WebAPI.Controllers
{
    public class CandidateSkillController : BaseCRUDController<CandidateSkillResponse, CandidateSkillSearchObject, CandidateSkillInsertRequest, CandidateSkillUpdateRequest>
    {
        public CandidateSkillController(ICandidateSkillService candidateSkillService) : base(candidateSkillService)
        {
        }
    }
} 