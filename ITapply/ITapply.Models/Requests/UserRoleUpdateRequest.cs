using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class UserRoleUpdateRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int RoleId { get; set; }
    }
}
