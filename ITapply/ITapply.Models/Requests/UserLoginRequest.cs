using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class UserLoginRequest
    {
        [Required(ErrorMessage = "Email is required.")]
        [StringLength(256, ErrorMessage = "Email cannot exceed 256 characters.")]
        [EmailAddress(ErrorMessage = "Email address is not in a valid format.")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Password is required.")]
        public string Password { get; set; }
    }
}
