using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class ApplicationInsertRequest
    {
        [Required(ErrorMessage = "Candidate ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Candidate ID must be a positive number.")]
        public int CandidateId { get; set; }

        [Required(ErrorMessage = "Job Posting ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Job Posting ID must be a positive number.")]
        public int JobPostingId { get; set; }

        [StringLength(5000, ErrorMessage = "Cover letter cannot exceed 5000 characters.")]
        public string CoverLetter { get; set; }

        [Required(ErrorMessage = "CV Document ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "CV Document ID must be a positive number.")]
        public int CVDocumentId { get; set; }

        [Required(ErrorMessage = "Availability information is required.")]
        [StringLength(100, ErrorMessage = "Availability information cannot exceed 100 characters.")]
        public string Availability { get; set; }

        public bool ReceiveNotifications { get; set; } = true;
    }
} 