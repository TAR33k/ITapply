using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using static ITapply.Services.Database.Enums;

namespace ITapply.Services.Database
{
    public class Application
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int CandidateId { get; set; }
        [ForeignKey("CandidateId")]
        public Candidate Candidate { get; set; }

        [Required]
        public int JobPostingId { get; set; }
        [ForeignKey("JobPostingId")]
        public JobPosting JobPosting { get; set; }

        [Required]
        public DateTime ApplicationDate { get; set; } = DateTime.Now;

        [Required]
        public ApplicationStatus Status { get; set; } = ApplicationStatus.Applied; // Default status

        [StringLength(5000)]
        public string CoverLetter { get; set; }

        [Required]
        public int CVDocumentId { get; set; }
        [ForeignKey("CVDocumentId")]
        public CVDocument CVDocument { get; set; } // Reference to the specific CV document used for this application

        [Required]
        [StringLength(100)]
        public string Availability { get; set; }

        [StringLength(2000)]
        public string InternalNotes { get; set; } // For Employer's internal use

        [StringLength(2000)]
        public string EmployerMessage { get; set; } // Message from Employer to Candidate

        public bool ReceiveNotifications { get; set; } = true;
    }
}
