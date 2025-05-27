using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Models.Requests
{
    public class ReviewUpdateRequest
    {
        [Range(1, 5)]
        public int? Rating { get; set; }

        [StringLength(3000)]
        public string Comment { get; set; }

        public ReviewRelationship? Relationship { get; set; }

        [StringLength(100)]
        public string Position { get; set; }

        public ModerationStatus? ModerationStatus { get; set; }
    }
} 