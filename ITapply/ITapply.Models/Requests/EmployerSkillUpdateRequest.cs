using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class EmployerSkillUpdateRequest
    {
        [Required(ErrorMessage = "Skill ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Skill ID must be a positive number.")]
        public int SkillId { get; set; }
    }
} 