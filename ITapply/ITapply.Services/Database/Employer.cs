using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Services.Database
{
    public class Employer
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public User User { get; set; }

        [Required]
        [StringLength(200)]
        public string CompanyName { get; set; }

        [StringLength(100)]
        public string Industry { get; set; }

        [Range(0, 1000)]
        public int YearsInBusiness { get; set; }

        [StringLength(5000)]
        public string Description { get; set; }

        [StringLength(3000)]
        public string Benefits { get; set; }

        [StringLength(500)]
        public string Address { get; set; }

        [StringLength(50)]
        public string Size { get; set; }

        [StringLength(200)]
        [Url]
        public string Website { get; set; }

        [StringLength(256)]
        [EmailAddress]
        public string ContactEmail { get; set; }

        [StringLength(20)]
        public string ContactPhone { get; set; }

        [Required]
        public VerificationStatus VerificationStatus { get; set; } = VerificationStatus.Pending; // Default status

        public int? LocationId { get; set; }
        [ForeignKey("LocationId")]
        public Location Location { get; set; }

        public byte[]? Logo { get; set; }

        // Navigation properties
        public ICollection<JobPosting> JobPostings { get; set; }
        public ICollection<Review> ReceivedReviews { get; set; } // Reviews about this employer
        public ICollection<EmployerSkill> EmployerSkills { get; set; } // Technologies used by this employer
    }
}
