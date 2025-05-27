using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? CandidateId { get; set; }
        public int? EmployerId { get; set; }
        public string CandidateName { get; set; } = string.Empty;
        public string CompanyName { get; set; } = string.Empty;
        public int? MinRating { get; set; }
        public int? MaxRating { get; set; }
        public ReviewRelationship? Relationship { get; set; }
        public ModerationStatus? ModerationStatus { get; set; }
        public DateTime? ReviewDateFrom { get; set; }
        public DateTime? ReviewDateTo { get; set; }
    }
} 