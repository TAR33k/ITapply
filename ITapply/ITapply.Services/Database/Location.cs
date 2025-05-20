using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ITapply.Services.Database
{
    public class Location
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string City { get; set; }

        [Required]
        [StringLength(100)]
        public string Country { get; set; }

        // Navigation property for JobPostings in this location
        public ICollection<JobPosting> JobPostings { get; set; }

        // Navigation property for Employers in this location
        public ICollection<Employer> Employers { get; set; }

        // Navigation property for Candidates in this location
        public ICollection<Candidate> Candidates { get; set; }
    }
}
