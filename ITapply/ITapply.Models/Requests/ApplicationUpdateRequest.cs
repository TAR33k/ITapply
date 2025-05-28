using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class ApplicationUpdateRequest
    {
        [Required(ErrorMessage = "Application status is required.")]
        public ApplicationStatus Status { get; set; }

        [StringLength(2000, ErrorMessage = "Internal notes cannot exceed 2000 characters.")]
        public string InternalNotes { get; set; }

        [StringLength(2000, ErrorMessage = "Employer message cannot exceed 2000 characters.")]
        public string EmployerMessage { get; set; }
    }
} 