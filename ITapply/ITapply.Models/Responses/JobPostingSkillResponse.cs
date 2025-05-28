using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Responses
{
    public class JobPostingSkillResponse
    {
        public int Id { get; set; }

        public int JobPostingId { get; set; }
        public string JobPostingTitle { get; set; } = string.Empty;
        public string EmployerName { get; set; } = string.Empty;

        public int SkillId { get; set; }
        public string SkillName { get; set; } = string.Empty;
    }
} 