using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class EducationInsertRequest
    {
        [Required]
        public int CandidateId { get; set; }

        [Required]
        [StringLength(200)]
        public string Institution { get; set; }

        [Required]
        [StringLength(100)]
        public string Degree { get; set; }

        [Required]
        [StringLength(100)]
        public string FieldOfStudy { get; set; }

        [Required]
        public DateTime StartDate { get; set; }

        public DateTime? EndDate { get; set; }

        [StringLength(2000)]
        public string Description { get; set; }
    }
} 