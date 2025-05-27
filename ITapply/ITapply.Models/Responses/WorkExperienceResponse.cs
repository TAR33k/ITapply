using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Responses
{
    public class WorkExperienceResponse
    {
        public int Id { get; set; }
        public int CandidateId { get; set; }
        public string CandidateName { get; set; } = string.Empty;
        public string CompanyName { get; set; } = string.Empty;
        public string Position { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string Description { get; set; } = string.Empty;
        public bool IsCurrent => !EndDate.HasValue;
        public string Duration => CalculateDuration();

        private string CalculateDuration()
        {
            var end = EndDate ?? DateTime.Now;
            var timeSpan = end - StartDate;
            var years = (int)(timeSpan.Days / 365.25);
            var months = (int)((timeSpan.Days % 365.25) / 30.44);

            if (years > 0 && months > 0)
                return $"{years} year{(years == 1 ? "" : "s")} {months} month{(months == 1 ? "" : "s")}";
            else if (years > 0)
                return $"{years} year{(years == 1 ? "" : "s")}";
            else if (months > 0)
                return $"{months} month{(months == 1 ? "" : "s")}";
            else
                return "Less than a month";
        }
    }
} 