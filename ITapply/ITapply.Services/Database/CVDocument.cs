using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace ITapply.Services.Database
{
    public class CVDocument
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int CandidateId { get; set; }
        [ForeignKey("CandidateId")]
        public Candidate Candidate { get; set; }

        [Required]
        [StringLength(255)]
        public string FileName { get; set; }

        [Required]
        // Max file size is configured in DbContext (5MB)
        public byte[] FileContent { get; set; }

        public bool IsMain { get; set; } = false;

        [Required]
        public DateTime UploadDate { get; set; } = DateTime.Now;
    }
}
