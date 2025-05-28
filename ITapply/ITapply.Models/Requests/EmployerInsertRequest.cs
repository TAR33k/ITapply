using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class EmployerInsertRequest
    {
        [Required(ErrorMessage = "User ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "User ID must be a positive number.")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Company name is required.")]
        [StringLength(200, ErrorMessage = "Company name cannot exceed 200 characters.")]
        public string CompanyName { get; set; }

        [StringLength(100, ErrorMessage = "Industry cannot exceed 100 characters.")]
        public string Industry { get; set; }

        [Range(0, 1000, ErrorMessage = "Years in business must be between 0 and 1000.")]
        public int YearsInBusiness { get; set; }

        [StringLength(5000, ErrorMessage = "Description cannot exceed 5000 characters.")]
        public string Description { get; set; }

        [StringLength(3000, ErrorMessage = "Benefits cannot exceed 3000 characters.")]
        public string Benefits { get; set; }

        [StringLength(500, ErrorMessage = "Address cannot exceed 500 characters.")]
        public string Address { get; set; }

        [StringLength(50, ErrorMessage = "Size cannot exceed 50 characters.")]
        public string Size { get; set; }

        [StringLength(200, ErrorMessage = "Website URL cannot exceed 200 characters.")]
        [Url(ErrorMessage = "Website must be a valid URL.")]
        public string Website { get; set; }

        [StringLength(256, ErrorMessage = "Email cannot exceed 256 characters.")]
        [EmailAddress(ErrorMessage = "Contact email must be a valid email address.")]
        public string ContactEmail { get; set; }

        [StringLength(20, ErrorMessage = "Contact phone cannot exceed 20 characters.")]
        [RegularExpression(@"^\+?[0-9\s\-\(\)]+$", ErrorMessage = "Phone number format is invalid.")]
        public string ContactPhone { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Location ID must be a positive number.")]
        public int? LocationId { get; set; }

        public byte[]? Logo { get; set; }
    }
} 