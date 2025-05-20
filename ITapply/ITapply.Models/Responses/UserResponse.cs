using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Responses
{
    public class UserResponse
    {
        public int Id { get; set; }

        public string Email { get; set; } = string.Empty;

        public DateTime RegistrationDate { get; set; }

        public bool IsActive { get; set; }
    }
}
