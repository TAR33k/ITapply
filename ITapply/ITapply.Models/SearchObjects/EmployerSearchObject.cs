using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.SearchObjects
{
    public class EmployerSearchObject : BaseSearchObject
    {
        public string CompanyName { get; set; } = string.Empty;
        public string Industry { get; set; } = string.Empty;
        public int? MinYearsInBusiness { get; set; }
        public int? MaxYearsInBusiness { get; set; }
        public int? LocationId { get; set; }
        public string ContactEmail { get; set; } = string.Empty;
        public VerificationStatus? VerificationStatus { get; set; }
        public string Email { get; set; } = string.Empty;
        public bool? IsActive { get; set; }
    }
} 