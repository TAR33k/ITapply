using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class SkillInsertRequest
    {
        [Required(ErrorMessage = "Skill name is required.")]
        [StringLength(100, ErrorMessage = "Skill name cannot exceed 100 characters.")]
        public string Name { get; set; }
    }
} 