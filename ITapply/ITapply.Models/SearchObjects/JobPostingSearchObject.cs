using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.SearchObjects
{
    public class JobPostingSearchObject : BaseSearchObject
    {
        public string Title { get; set; } = string.Empty;
        public int? EmployerId { get; set; }
        public string EmployerName { get; set; } = string.Empty;
        public EmploymentType? EmploymentType { get; set; }
        public ExperienceLevel? ExperienceLevel { get; set; }
        public int? LocationId { get; set; }
        public Remote? Remote { get; set; }
        public int? MinSalary { get; set; }
        public int? MaxSalary { get; set; }
        public DateTime? PostedAfter { get; set; }
        public DateTime? DeadlineBefore { get; set; }
        public JobPostingStatus? Status { get; set; }
        public List<int> SkillIds { get; set; } = new List<int>();
        public bool IncludeExpired { get; set; } = false;
    }
} 