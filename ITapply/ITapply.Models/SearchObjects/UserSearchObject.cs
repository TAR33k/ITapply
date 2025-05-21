using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string Email { get; set; } = string.Empty;
        public DateTime? RegistrationDate { get; set; }
        public bool? IsActive { get; set; }
    }
}
