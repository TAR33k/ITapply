using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.SearchObjects
{
    public class EmployerSkillSearchObject : BaseSearchObject
    {
        public int? EmployerId { get; set; }
        public int? SkillId { get; set; }
    }
} 