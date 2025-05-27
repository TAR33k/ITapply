using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class WorkExperienceUpdateRequest
    {
        [StringLength(200)]
        public string CompanyName { get; set; }

        [StringLength(200)]
        public string Position { get; set; }

        public DateTime? StartDate { get; set; }

        public DateTime? EndDate { get; set; }

        [StringLength(4000)]
        public string Description { get; set; }
    }
} 