using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.SearchObjects
{
    public class UserRoleSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? RoleId { get; set; }
        public string? RoleName { get; set; }
    }
}
