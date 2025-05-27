using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.SearchObjects
{
    public class CVDocumentSearchObject : BaseSearchObject
    {
        public int? CandidateId { get; set; }
        public string FileName { get; set; } = string.Empty;
        public bool? IsMain { get; set; }
        public DateTime? UploadDateFrom { get; set; }
        public DateTime? UploadDateTo { get; set; }
    }
} 