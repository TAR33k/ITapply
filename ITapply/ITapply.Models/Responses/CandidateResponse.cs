using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Responses
{
    public class CandidateResponse
    {
        public int Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Bio { get; set; } = string.Empty;
        public int? LocationId { get; set; }
        public string LocationName { get; set; } = string.Empty;
        public int ExperienceYears { get; set; }
        public ExperienceLevel ExperienceLevel { get; set; }
        public DateTime RegistrationDate { get; set; }
        public bool IsActive { get; set; }
    }
}