import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:itapply_desktop/models/enums.dart';

String formatNumber(dynamic number) {
  var f = NumberFormat("#,##0.00", "en_US");
  
  if (number == null) {
    return "0.00";
  } else if (number is int || number is double) {
    return f.format(number);
  } else if (number is String) {
    try {
      var parsedNumber = double.parse(number);
      return f.format(parsedNumber);
    } catch (e) {
      return "0.00";
    }
  } else {
    return "0.00";
  }
}

String experienceLevelToString(ExperienceLevel level) {
  switch (level) {
    case ExperienceLevel.entryLevel:
      return 'Entry Level';
    case ExperienceLevel.junior:
      return 'Junior';
    case ExperienceLevel.mid:
      return 'Mid';
    case ExperienceLevel.senior:
      return 'Senior';
    case ExperienceLevel.lead:
      return 'Lead';
  }
}

String employmentTypeToString(EmploymentType type) {
  switch (type) {
    case EmploymentType.fullTime:
      return 'Full-Time';
    case EmploymentType.partTime:
      return 'Part-Time';
    case EmploymentType.contract:
      return 'Contract';
    case EmploymentType.internship:
      return 'Internship';
  }
}

String applicationStatusToString(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.applied:
      return 'Applied';
    case ApplicationStatus.inConsideration:
      return 'In Consideration';
    case ApplicationStatus.interviewScheduled:
      return 'Interview Scheduled';
    case ApplicationStatus.accepted:
      return 'Accepted';
    case ApplicationStatus.rejected:
      return 'Rejected';
  }
}

String reviewRelationshipToString(ReviewRelationship relation) {
  switch (relation) {
    case ReviewRelationship.currentEmployee:
      return 'Current Employee';
    case ReviewRelationship.formerEmployee:
      return 'Former Employee';
    case ReviewRelationship.interviewee:
      return 'Interviewee';
  }
}

String verificationStatusToString(VerificationStatus status) {
  switch (status) {
    case VerificationStatus.pending:
      return 'Pending';
    case VerificationStatus.approved:
      return 'Approved';
    case VerificationStatus.rejected:
      return 'Rejected';
  }
}

String jobPostingStatusToString(JobPostingStatus status) {
  switch (status) {
    case JobPostingStatus.active:
      return 'Active';
    case JobPostingStatus.closed:
      return 'Closed';
  }
}

String moderationStatusToString(ModerationStatus status) {
  switch (status) {
    case ModerationStatus.pending:
      return 'Pending';
    case ModerationStatus.approved:
      return 'Approved';
    case ModerationStatus.rejected:
      return 'Rejected';
  }
}

String remoteToString(Remote remote) {
  switch (remote) {
    case Remote.yes:
      return 'Yes';
    case Remote.no:
      return 'No';
    case Remote.hybrid:
      return 'Hybrid';
  }
}

Color experienceLevelColor(ExperienceLevel level) {
  switch (level) {
    case ExperienceLevel.entryLevel:
      return Colors.lightGreen;
    case ExperienceLevel.junior:
      return Colors.green;
    case ExperienceLevel.mid:
      return Colors.teal;
    case ExperienceLevel.senior:
      return Colors.indigo;
    case ExperienceLevel.lead:
      return Colors.deepPurple;
  }
}

Color employmentTypeColor(EmploymentType type) {
  switch (type) {
    case EmploymentType.fullTime:
      return Colors.blue;
    case EmploymentType.partTime:
      return Colors.orange;
    case EmploymentType.contract:
      return Colors.cyan;
    case EmploymentType.internship:
      return Colors.purple;
  }
}

Color applicationStatusColor(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.applied:
      return Colors.blueGrey;
    case ApplicationStatus.inConsideration:
      return Colors.orange;
    case ApplicationStatus.interviewScheduled:
      return Colors.blue;
    case ApplicationStatus.accepted:
      return Colors.green;
    case ApplicationStatus.rejected:
      return Colors.red;
  }
}

Color reviewRelationshipColor(ReviewRelationship relation) {
  switch (relation) {
    case ReviewRelationship.currentEmployee:
      return Colors.green;
    case ReviewRelationship.formerEmployee:
      return Colors.grey;
    case ReviewRelationship.interviewee:
      return Colors.amber;
  }
}

Color verificationStatusColor(VerificationStatus status) {
  switch (status) {
    case VerificationStatus.pending:
      return Colors.orange;
    case VerificationStatus.approved:
      return Colors.green;
    case VerificationStatus.rejected:
      return Colors.red;
  }
}

Color jobPostingStatusColor(JobPostingStatus status) {
  switch (status) {
    case JobPostingStatus.active:
      return Colors.green;
    case JobPostingStatus.closed:
      return Colors.red;
  }
}

Color moderationStatusColor(ModerationStatus status) {
  switch (status) {
    case ModerationStatus.pending:
      return Colors.orange;
    case ModerationStatus.approved:
      return Colors.green;
    case ModerationStatus.rejected:
      return Colors.red;
  }
}

Color remoteColor(Remote remote) {
  switch (remote) {
    case Remote.yes:
      return Colors.green;
    case Remote.no:
      return Colors.red;
    case Remote.hybrid:
      return Colors.blue;
  }
}