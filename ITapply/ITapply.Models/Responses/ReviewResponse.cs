using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int CandidateId { get; set; }
        public string CandidateName { get; set; } = string.Empty;
        public int EmployerId { get; set; }
        public string CompanyName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;
        public ReviewRelationship Relationship { get; set; }
        public string Position { get; set; } = string.Empty;
        public ModerationStatus ModerationStatus { get; set; }
        public DateTime ReviewDate { get; set; }
    }
} 