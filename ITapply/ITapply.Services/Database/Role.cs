using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace ITapply.Services.Database
{
    public class Role
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string Name { get; set; }

        // Navigation property
        public virtual ICollection<UserRole> UserRoles { get; set; }
    }
}
