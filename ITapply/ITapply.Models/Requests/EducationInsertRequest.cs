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
        [Required(ErrorMessage = "Candidate ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Candidate ID must be a positive number.")]
        public int CandidateId { get; set; }

        [Required(ErrorMessage = "Institution name is required.")]
        [StringLength(200, ErrorMessage = "Institution name cannot exceed 200 characters.")]
        public string Institution { get; set; }

        [Required(ErrorMessage = "Degree is required.")]
        [StringLength(100, ErrorMessage = "Degree cannot exceed 100 characters.")]
        public string Degree { get; set; }

        [Required(ErrorMessage = "Field of study is required.")]
        [StringLength(100, ErrorMessage = "Field of study cannot exceed 100 characters.")]
        public string FieldOfStudy { get; set; }

        [Required(ErrorMessage = "Start date is required.")]
        public DateTime StartDate { get; set; }

        public DateTime? EndDate { get; set; }

        [StringLength(2000, ErrorMessage = "Description cannot exceed 2000 characters.")]
        public string Description { get; set; }
    }
} 