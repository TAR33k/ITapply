using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class EducationUpdateRequest
    {
        [StringLength(200, ErrorMessage = "Institution name cannot exceed 200 characters.")]
        public string Institution { get; set; }

        [StringLength(100, ErrorMessage = "Degree cannot exceed 100 characters.")]
        public string Degree { get; set; }

        [StringLength(100, ErrorMessage = "Field of study cannot exceed 100 characters.")]
        public string FieldOfStudy { get; set; }

        public DateTime? StartDate { get; set; }

        public DateTime? EndDate { get; set; }

        [StringLength(2000, ErrorMessage = "Description cannot exceed 2000 characters.")]
        public string Description { get; set; }
    }
} 