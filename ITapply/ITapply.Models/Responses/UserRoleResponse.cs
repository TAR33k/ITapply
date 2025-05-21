using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Responses
{
    public class UserRoleResponse
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public UserResponse User { get; set; }

        public int RoleId { get; set; }

        public RoleResponse Role { get; set; }
    }
}
