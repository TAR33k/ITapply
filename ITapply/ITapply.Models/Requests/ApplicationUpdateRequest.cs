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
        [Required]
        public ApplicationStatus Status { get; set; }

        [StringLength(2000)]
        public string InternalNotes { get; set; }

        [StringLength(2000)]
        public string EmployerMessage { get; set; }
    }
} 