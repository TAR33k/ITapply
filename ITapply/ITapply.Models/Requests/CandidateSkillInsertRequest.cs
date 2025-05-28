using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class CandidateSkillInsertRequest
    {
        [Required(ErrorMessage = "Candidate ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Candidate ID must be a positive number.")]
        public int CandidateId { get; set; }

        [Required(ErrorMessage = "Skill ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Skill ID must be a positive number.")]
        public int SkillId { get; set; }

        [Required(ErrorMessage = "Skill level is required.")]
        [Range(1, 5, ErrorMessage = "Skill level must be between 1 and 5.")]
        public int Level { get; set; }
    }
} 