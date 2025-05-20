using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using static ITapply.Services.Database.Enums;

namespace ITapply.Services.Database
{
    public class Review
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int CandidateId { get; set; }
        [ForeignKey("CandidateId")]
        public Candidate Candidate { get; set; }

        [Required]
        public int EmployerId { get; set; }
        [ForeignKey("EmployerId")]
        public Employer Employer { get; set; }

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
        public string Position { get; set; } // Position held by the reviewer at the company

        [Required]
        public ModerationStatus ModerationStatus { get; set; } = ModerationStatus.Pending; // Default status

        [Required]
        public DateTime ReviewDate { get; set; } = DateTime.UtcNow;
    }
}
