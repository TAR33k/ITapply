using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class UserInsertRequest
    {
        [Required(ErrorMessage = "Email is required.")]
        [StringLength(256, ErrorMessage = "Email cannot exceed 256 characters.")]
        [EmailAddress(ErrorMessage = "Email address is not in a valid format.")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Password is required.")]
        [MinLength(8, ErrorMessage = "Password must be at least 8 characters long.")]
        public string Password { get; set; }

        [Required(ErrorMessage = "At least one role must be assigned.")]
        public List<int> RoleIds { get; set; } = new List<int>();
    }
}
