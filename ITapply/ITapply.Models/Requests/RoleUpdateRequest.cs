using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class RoleUpdateRequest
    {
        [Required]
        [StringLength(50)]
        public string Name { get; set; }
    }
}
