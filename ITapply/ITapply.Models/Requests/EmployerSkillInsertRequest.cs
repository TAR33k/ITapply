using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class EmployerSkillInsertRequest
    {
        [Required(ErrorMessage = "Employer ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Employer ID must be a positive number.")]
        public int EmployerId { get; set; }

        [Required(ErrorMessage = "Skill ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Skill ID must be a positive number.")]
        public int SkillId { get; set; }
    }
} 