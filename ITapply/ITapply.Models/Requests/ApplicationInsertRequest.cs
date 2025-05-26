using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class ApplicationInsertRequest
    {
        [Required]
        public int CandidateId { get; set; }

        [Required]
        public int JobPostingId { get; set; }

        [StringLength(5000)]
        public string CoverLetter { get; set; }

        [Required]
        public int CVDocumentId { get; set; }

        [Required]
        [StringLength(100)]
        public string Availability { get; set; }

        public bool ReceiveNotifications { get; set; } = true;
    }
} 