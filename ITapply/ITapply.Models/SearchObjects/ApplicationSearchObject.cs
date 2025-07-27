using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.SearchObjects
{
    public class ApplicationSearchObject : BaseSearchObject
    {
        public int? CandidateId { get; set; }
        public int? JobPostingId { get; set; }
        public int? EmployerId { get; set; }
        public string JobTitle { get; set; } = string.Empty;
        public string CandidateName { get; set; } = string.Empty;
        public string CompanyName { get; set; } = string.Empty;
        public ApplicationStatus? Status { get; set; }
        public DateTime? ApplicationDateFrom { get; set; }
        public DateTime? ApplicationDateTo { get; set; }
    }
} 