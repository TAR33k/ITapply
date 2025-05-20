using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Responses
{
    public class LocationResponse
    {
        public int Id { get; set; }

        public string City { get; set; } = string.Empty;

        public string Country { get; set; } = string.Empty;
    }
}
