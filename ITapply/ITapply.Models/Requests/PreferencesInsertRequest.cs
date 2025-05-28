using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class PreferencesInsertRequest
    {
        [Required(ErrorMessage = "Candidate ID is required.")]
        [Range(1, int.MaxValue, ErrorMessage = "Candidate ID must be a positive number.")]
        public int CandidateId { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Location ID must be a positive number.")]
        public int? LocationId { get; set; }

        public EmploymentType? EmploymentType { get; set; }

        public Remote? Remote { get; set; }
    }
} 