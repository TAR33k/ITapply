using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.SearchObjects
{
    public class PreferencesSearchObject : BaseSearchObject
    {
        public int? CandidateId { get; set; }
        public int? LocationId { get; set; }
        public EmploymentType? EmploymentType { get; set; }
        public Remote? Remote { get; set; }
    }
} 