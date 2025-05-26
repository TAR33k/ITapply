using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Responses
{
    public class ApplicationResponse
    {
        public int Id { get; set; }
        public int CandidateId { get; set; }
        public string CandidateName { get; set; } = string.Empty;
        public string CandidateEmail { get; set; } = string.Empty;
        public int JobPostingId { get; set; }
        public string JobTitle { get; set; } = string.Empty;
        public string CompanyName { get; set; } = string.Empty;
        public DateTime ApplicationDate { get; set; }
        public ApplicationStatus Status { get; set; }
        public string CoverLetter { get; set; } = string.Empty;
        public int CVDocumentId { get; set; }
        public string CVDocumentName { get; set; } = string.Empty;
        public string Availability { get; set; } = string.Empty;
        public string InternalNotes { get; set; } = string.Empty;
        public string EmployerMessage { get; set; } = string.Empty;
        public bool ReceiveNotifications { get; set; }
    }
} 