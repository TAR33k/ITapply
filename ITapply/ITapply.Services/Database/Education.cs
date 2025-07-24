using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace ITapply.Services.Database
{
    public class Education
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int CandidateId { get; set; }
        [ForeignKey("CandidateId")]
        public Candidate Candidate { get; set; }

        [Required]
        [StringLength(200)]
        public string Institution { get; set; }

        [Required]
        [StringLength(100)]
        public string Degree { get; set; } // e.g., Bachelor's, Master's

        [Required]
        [StringLength(100)]
        public string FieldOfStudy { get; set; } // e.g., Computer Science, Electrical Engineering

        [Required]
        public DateTime StartDate { get; set; }

        public DateTime? EndDate { get; set; } // Nullable if currently studying

        [StringLength(2000)]
        public string? Description { get; set; } // Optional, e.g., relevant coursework, GPA
    }
}
