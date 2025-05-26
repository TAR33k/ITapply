using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Responses
{
    public class EmployerResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Email { get; set; } = string.Empty;
        public string CompanyName { get; set; } = string.Empty;
        public string Industry { get; set; } = string.Empty;
        public int YearsInBusiness { get; set; }
        public string Description { get; set; } = string.Empty;
        public string Benefits { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string Size { get; set; } = string.Empty;
        public string Website { get; set; } = string.Empty;
        public string ContactEmail { get; set; } = string.Empty;
        public string ContactPhone { get; set; } = string.Empty;
        public VerificationStatus VerificationStatus { get; set; }
        public int? LocationId { get; set; }
        public string LocationName { get; set; } = string.Empty;
        public byte[]? Logo { get; set; }
        public DateTime RegistrationDate { get; set; }
        public bool IsActive { get; set; }
    }
} 