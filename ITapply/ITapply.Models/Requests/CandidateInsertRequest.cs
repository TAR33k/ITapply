using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class CandidateInsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        [StringLength(100)]
        public string FirstName { get; set; }

        [Required]
        [StringLength(100)]
        public string LastName { get; set; }

        [StringLength(20)]
        public string PhoneNumber { get; set; }

        [StringLength(100)]
        public string Title { get; set; }

        [StringLength(2000)]
        public string Bio { get; set; }

        public int? LocationId { get; set; }

        [Range(0, 100)]
        public int ExperienceYears { get; set; }

        public ExperienceLevel ExperienceLevel { get; set; }
    }
} 