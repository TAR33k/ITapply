using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace ITapply.Services.Database
{
    public class JobPostingSkill
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int JobPostingId { get; set; }
        [ForeignKey("JobPostingId")]
        public JobPosting JobPosting { get; set; }

        [Required]
        public int SkillId { get; set; }
        [ForeignKey("SkillId")]
        public Skill Skill { get; set; }
    }
}
