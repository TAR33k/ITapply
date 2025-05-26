using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class JobPostingInsertRequest
    {
        [Required]
        public int EmployerId { get; set; }

        [Required]
        [StringLength(200)]
        public string Title { get; set; }

        [Required]
        [StringLength(10000)]
        public string Description { get; set; }

        [StringLength(5000)]
        public string Requirements { get; set; }

        [StringLength(3000)]
        public string Benefits { get; set; }

        [Required]
        public EmploymentType EmploymentType { get; set; }

        [Required]
        public ExperienceLevel ExperienceLevel { get; set; }

        public int? LocationId { get; set; }

        [Required]
        public Remote Remote { get; set; }

        [Range(0, int.MaxValue)]
        public int MinSalary { get; set; }

        [Range(0, int.MaxValue)]
        public int MaxSalary { get; set; }

        [Required]
        public DateTime ApplicationDeadline { get; set; }
        
        // List of skill IDs required for this job
        public List<int> SkillIds { get; set; } = new List<int>();
    }
} 