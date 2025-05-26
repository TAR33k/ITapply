using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.SearchObjects
{
    public class CandidateSearchObject : BaseSearchObject
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public int? LocationId { get; set; }
        public int? MinExperienceYears { get; set; }
        public int? MaxExperienceYears { get; set; }
        public ExperienceLevel? ExperienceLevel { get; set; }
        public string Email { get; set; } = string.Empty;
        public bool? IsActive { get; set; }
    }
} 