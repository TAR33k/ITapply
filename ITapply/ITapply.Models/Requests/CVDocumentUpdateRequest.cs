using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Requests
{
    public class CVDocumentUpdateRequest
    {
        [StringLength(255)]
        public string FileName { get; set; }

        public byte[] FileContent { get; set; }

        public bool? IsMain { get; set; }
    }
} 