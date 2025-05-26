using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Responses
{
    public class EnumResponse
    {
        public enum ExperienceLevel
        {
            EntryLevel,
            Junior,
            Mid,
            Senior,
            Lead
        }

        public enum EmploymentType
        {
            FullTime,
            PartTime,
            Contract,
            Internship
        }

        public enum ApplicationStatus
        {
            Applied,
            InConsideration,
            InterviewScheduled,
            Accepted,
            Rejected
        }

        public enum ReviewRelationship
        {
            CurrentEmployee,
            FormerEmployee,
            Interviewee
        }

        public enum VerificationStatus
        {
            Pending,
            Approved,
            Rejected
        }

        public enum JobPostingStatus
        {
            Active,
            Closed
        }

        public enum ModerationStatus
        {
            Pending,
            Approved,
            Rejected
        }

        public enum Remote
        {
            Yes,
            No,
            Hybrid
        }
    }
}
