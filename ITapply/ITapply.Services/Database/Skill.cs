using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ITapply.Services.Database
{
    public class Skill
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; } // e.g., "C#", "React", "Agile", "Communication"

        // Navigation properties for many-to-many relationships
        public ICollection<CandidateSkill> CandidateSkills { get; set; }
        public ICollection<JobPostingSkill> JobPostingSkills { get; set; }
        public ICollection<EmployerSkill> EmployerSkills { get; set; } // Technologies used by this employer
    }
}
