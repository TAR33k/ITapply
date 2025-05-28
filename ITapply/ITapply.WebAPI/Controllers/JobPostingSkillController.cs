using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;

namespace ITapply.WebAPI.Controllers
{
    public class JobPostingSkillController : BaseCRUDController<JobPostingSkillResponse, JobPostingSkillSearchObject, JobPostingSkillInsertRequest, JobPostingSkillUpdateRequest>
    {
        public JobPostingSkillController(IJobPostingSkillService jobPostingSkillService) : base(jobPostingSkillService)
        {
        }
    }
} 