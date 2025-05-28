using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.SearchObjects
{
    public class CandidateSkillSearchObject : BaseSearchObject
    {
        public int? CandidateId { get; set; }
        public int? SkillId { get; set; }
        public int? MinLevel { get; set; }
        public int? MaxLevel { get; set; }
    }
} 