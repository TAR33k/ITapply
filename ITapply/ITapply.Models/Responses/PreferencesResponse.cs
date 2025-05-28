using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Responses
{
    public class PreferencesResponse
    {
        public int Id { get; set; }

        public int CandidateId { get; set; }

        public int? LocationId { get; set; }
        public string LocationName { get; set; } = string.Empty;

        public EmploymentType? EmploymentType { get; set; }

        public Remote? Remote { get; set; }
    }
} 