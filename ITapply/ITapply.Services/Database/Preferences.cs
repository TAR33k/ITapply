using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using static ITapply.Services.Database.Enums;

namespace ITapply.Services.Database
{
    public class Preferences
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int CandidateId { get; set; }
        [ForeignKey("CandidateId")]
        public Candidate Candidate { get; set; }

        public int? LocationId { get; set; }
        [ForeignKey("LocationId")]
        public Location? Location { get; set; }

        public EmploymentType? EmploymentType { get; set; }

        public Remote? Remote { get; set; }
    }
}
