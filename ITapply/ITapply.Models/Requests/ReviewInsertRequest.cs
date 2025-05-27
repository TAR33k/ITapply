using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class ReviewInsertRequest
    {
        [Required]
        public int CandidateId { get; set; }

        [Required]
        public int EmployerId { get; set; }

        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }

        [Required]
        [StringLength(3000)]
        public string Comment { get; set; }

        [Required]
        public ReviewRelationship Relationship { get; set; }

        [Required]
        [StringLength(100)]
        public string Position { get; set; }
    }
} 