using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class UserUpdateRequest
    {
        [Required(ErrorMessage = "Email is required.")]
        [StringLength(256, ErrorMessage = "Email cannot exceed 256 characters.")]
        [EmailAddress(ErrorMessage = "Email address is not in a valid format.")]
        public string Email { get; set; }

        [MinLength(8, ErrorMessage = "Password must be at least 8 characters long.")]
        public string? Password { get; set; }

        public bool? IsActive { get; set; }
    }
}
