using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Services.Database
{
    public class JobPosting
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int EmployerId { get; set; }
        [ForeignKey("EmployerId")]
        public Employer Employer { get; set; }

        [Required]
        [StringLength(200)]
        public string Title { get; set; } // e.g., "Senior .NET Developer", "UX/UI Designer"

        [Required]
        [StringLength(10000)]
        public string Description { get; set; } // Detailed job description

        [StringLength(5000)]
        public string? Requirements { get; set; }

        [StringLength(3000)]
        public string? Benefits { get; set; }

        [Required]
        public EmploymentType EmploymentType { get; set; }

        [Required]
        public ExperienceLevel ExperienceLevel { get; set; }

        public int? LocationId { get; set; }
        [ForeignKey("LocationId")]
        public Location Location { get; set; }

        [Required]
        public Remote Remote { get; set; }

        [Range(0, int.MaxValue)]
        public int? MinSalary { get; set; }

        [Range(0, int.MaxValue)]
        public int? MaxSalary { get; set; }

        [Required]
        public DateTime ApplicationDeadline { get; set; }

        [Required]
        public DateTime PostedDate { get; set; } = DateTime.Now;

        [Required]
        public JobPostingStatus Status { get; set; } = JobPostingStatus.Active; // Default status

        // Navigation properties
        public ICollection<JobPostingSkill> JobPostingSkills { get; set; } // Required skills for this job
        public ICollection<Application> Applications { get; set; } // Applications received for this job
    }
}
