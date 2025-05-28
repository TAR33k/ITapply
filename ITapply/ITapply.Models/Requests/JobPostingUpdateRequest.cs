using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class JobPostingUpdateRequest
    {
        [Required(ErrorMessage = "Job title is required.")]
        [StringLength(200, ErrorMessage = "Job title cannot exceed 200 characters.")]
        public string Title { get; set; }

        [Required(ErrorMessage = "Job description is required.")]
        [StringLength(10000, ErrorMessage = "Job description cannot exceed 10000 characters.")]
        public string Description { get; set; }

        [StringLength(5000, ErrorMessage = "Requirements cannot exceed 5000 characters.")]
        public string Requirements { get; set; }

        [StringLength(3000, ErrorMessage = "Benefits cannot exceed 3000 characters.")]
        public string Benefits { get; set; }

        [Required(ErrorMessage = "Employment type is required.")]
        public EmploymentType EmploymentType { get; set; }

        [Required(ErrorMessage = "Experience level is required.")]
        public ExperienceLevel ExperienceLevel { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Location ID must be a positive number.")]
        public int? LocationId { get; set; }

        [Required(ErrorMessage = "Remote work option is required.")]
        public Remote Remote { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Minimum salary must be a positive number or zero.")]
        public int MinSalary { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Maximum salary must be a positive number or zero.")]
        public int MaxSalary { get; set; }

        [Required(ErrorMessage = "Application deadline is required.")]
        public DateTime ApplicationDeadline { get; set; }

        [Required(ErrorMessage = "Job posting status is required.")]
        public JobPostingStatus Status { get; set; }
        
        // List of skill IDs required for this job
        public List<int> SkillIds { get; set; } = new List<int>();
    }
} 