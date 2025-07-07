using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Responses
{
    public class JobPostingResponse
    {
        public int Id { get; set; }
        public int EmployerId { get; set; }
        public string EmployerName { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Requirements { get; set; } = string.Empty;
        public string Benefits { get; set; } = string.Empty;
        public EmploymentType EmploymentType { get; set; }
        public ExperienceLevel ExperienceLevel { get; set; }
        public int? LocationId { get; set; }
        public string LocationName { get; set; } = string.Empty;
        public Remote Remote { get; set; }
        public int MinSalary { get; set; }
        public int MaxSalary { get; set; }
        public DateTime ApplicationDeadline { get; set; }
        public DateTime PostedDate { get; set; }
        public JobPostingStatus Status { get; set; }
        public List<JobPostingSkillResponse> Skills { get; set; } = new List<JobPostingSkillResponse>();
        public int ApplicationCount { get; set; }
    }
} 