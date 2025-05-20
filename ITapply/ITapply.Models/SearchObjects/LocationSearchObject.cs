using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.SearchObjects
{
    public class LocationSearchObject : BaseSearchObject
    {
        public string City { get; set; } = string.Empty;

        public string Country { get; set; } = string.Empty;
    }
}
