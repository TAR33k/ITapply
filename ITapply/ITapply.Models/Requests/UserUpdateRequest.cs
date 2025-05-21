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
        [Required]
        [StringLength(256)]
        [EmailAddress]
        public string Email { get; set; }

        [MinLength(8)]
        public string? Password { get; set; }
    }
}
