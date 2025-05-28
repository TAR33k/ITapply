using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Responses
{
    public class EmployerSkillResponse
    {
        public int Id { get; set; }

        public int EmployerId { get; set; }
        public string EmployerName { get; set; } = string.Empty;

        public int SkillId { get; set; }
        public string SkillName { get; set; } = string.Empty;
    }
} 