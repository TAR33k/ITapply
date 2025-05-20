using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ITapply.Services.Database
{
    public class User
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(256)]
        [EmailAddress]
        public string Email { get; set; } // Using email as the primary identifier/username

        [Required]
        [StringLength(512)]
        public string PasswordHash { get; set; }

        [Required]
        [StringLength(128)]
        public string PasswordSalt { get; set; }

        public DateTime RegistrationDate { get; set; } = DateTime.UtcNow;

        public bool IsActive { get; set; } = true;

        // Navigation properties
        public Candidate Candidate { get; set; }
        public Employer Employer { get; set; }
        public ICollection<UserRole> UserRoles { get; set; }
    }
}
