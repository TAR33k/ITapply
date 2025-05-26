using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class EmployerUpdateRequest
    {
        [Required]
        [StringLength(200)]
        public string CompanyName { get; set; }

        [StringLength(100)]
        public string Industry { get; set; }

        [Range(0, 1000)]
        public int YearsInBusiness { get; set; }

        [StringLength(5000)]
        public string Description { get; set; }

        [StringLength(3000)]
        public string Benefits { get; set; }

        [StringLength(500)]
        public string Address { get; set; }

        [StringLength(50)]
        public string Size { get; set; }

        [StringLength(200)]
        [Url]
        public string Website { get; set; }

        [StringLength(256)]
        [EmailAddress]
        public string ContactEmail { get; set; }

        [StringLength(20)]
        public string ContactPhone { get; set; }

        public int? LocationId { get; set; }

        public byte[]? Logo { get; set; }
    }
} 