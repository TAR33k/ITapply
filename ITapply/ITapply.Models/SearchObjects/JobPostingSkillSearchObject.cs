using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.SearchObjects
{
    public class JobPostingSkillSearchObject : BaseSearchObject
    {
        public int? JobPostingId { get; set; }
        public int? SkillId { get; set; }
    }
} 