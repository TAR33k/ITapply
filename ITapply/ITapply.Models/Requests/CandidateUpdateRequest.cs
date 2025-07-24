using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class CandidateUpdateRequest
    {
        [Required(ErrorMessage = "First name is required.")]
        [StringLength(100, ErrorMessage = "First name cannot exceed 100 characters.")]
        public string FirstName { get; set; }

        [Required(ErrorMessage = "Last name is required.")]
        [StringLength(100, ErrorMessage = "Last name cannot exceed 100 characters.")]
        public string LastName { get; set; }

        [StringLength(20, ErrorMessage = "Phone number cannot exceed 20 characters.")]
        [RegularExpression(@"^\+?[0-9\s\-\(\)]+$", ErrorMessage = "Phone number format is invalid.")]
        public string? PhoneNumber { get; set; }

        [StringLength(100, ErrorMessage = "Title cannot exceed 100 characters.")]
        public string? Title { get; set; }

        [StringLength(2000, ErrorMessage = "Bio cannot exceed 2000 characters.")]
        public string? Bio { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Location ID must be a positive number.")]
        public int? LocationId { get; set; }

        [Range(0, 100, ErrorMessage = "Experience years must be between 0 and 100.")]
        public int ExperienceYears { get; set; }

        public ExperienceLevel ExperienceLevel { get; set; }
    }
} 