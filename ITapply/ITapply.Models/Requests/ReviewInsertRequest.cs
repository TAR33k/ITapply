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
        [Required(ErrorMessage = "Candidate ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Candidate ID must be a positive number.")]
        public int CandidateId { get; set; }

        [Required(ErrorMessage = "Employer ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Employer ID must be a positive number.")]
        public int EmployerId { get; set; }

        [Required(ErrorMessage = "Rating is required.")]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5.")]
        public int Rating { get; set; }

        [Required(ErrorMessage = "Comment is required.")]
        [StringLength(3000, ErrorMessage = "Comment cannot exceed 3000 characters.")]
        public string Comment { get; set; }

        [Required(ErrorMessage = "Relationship type is required.")]
        public ReviewRelationship Relationship { get; set; }

        [Required(ErrorMessage = "Position is required.")]
        [StringLength(100, ErrorMessage = "Position cannot exceed 100 characters.")]
        public string Position { get; set; }
    }
} 