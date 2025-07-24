using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Services.Database
{
    public class Candidate
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public User User { get; set; }

        [Required]
        [StringLength(100)]
        public string FirstName { get; set; }

        [Required]
        [StringLength(100)]
        public string LastName { get; set; }

        [StringLength(20)]
        public string? PhoneNumber { get; set; }

        [StringLength(100)]
        public string? Title { get; set; }

        [StringLength(2000)]
        public string? Bio { get; set; }

        public int? LocationId { get; set; }
        [ForeignKey("LocationId")]
        public Location Location { get; set; }

        [Range(0, 100)]
        public int ExperienceYears { get; set; }

        public ExperienceLevel ExperienceLevel { get; set; }

        // Navigation properties
        public Preferences? Preferences { get; set; }
        public ICollection<WorkExperience> WorkExperiences { get; set; }
        public ICollection<Education> Educations { get; set; }
        public ICollection<CandidateSkill> CandidateSkills { get; set; } // Skills possessed by the candidate
        public ICollection<CVDocument> CVDocuments { get; set; }
        public ICollection<Application> Applications { get; set; }
        public ICollection<Review> Reviews { get; set; } // Reviews written by this candidate
    }
}
