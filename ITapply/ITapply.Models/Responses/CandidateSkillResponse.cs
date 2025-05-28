using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Responses
{
    public class CandidateSkillResponse
    {
        public int Id { get; set; }

        public int CandidateId { get; set; }
        public string CandidateName { get; set; } = string.Empty;

        public int SkillId { get; set; }
        public string SkillName { get; set; } = string.Empty;

        public int Level { get; set; }
    }
} 