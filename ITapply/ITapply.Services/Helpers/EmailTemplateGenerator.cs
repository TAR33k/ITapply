using ITapply.Services.Database;
using System.Text;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Services.Helpers
{
    public static class EmailTemplateGenerator
    {
        public static string GenerateApplicationStatusUpdateEmail(Application application)
        {
            var candidateName = application.Candidate.FirstName;
            var jobTitle = application.JobPosting.Title;
            var companyName = application.JobPosting.Employer.CompanyName;
            var status = application.Status;
            var employerMessage = application.EmployerMessage;

            (string statusText, string statusColor, string message) statusContent;

            switch (status)
            {
                case ApplicationStatus.InConsideration:
                    statusContent = ("In Consideration", "#007bff", "The hiring team is currently reviewing your profile. We appreciate your patience.");
                    break;
                case ApplicationStatus.InterviewScheduled:
                    statusContent = ("Interview Scheduled", "#17a2b8", "Congratulations! The employer would like to schedule an interview. Please check the message from them for details.");
                    break;
                case ApplicationStatus.Accepted:
                    statusContent = ("Accepted", "#28a745", "Fantastic news! The employer has extended an offer for this position. Please see their message for the next steps.");
                    break;
                case ApplicationStatus.Rejected:
                    statusContent = ("Rejected", "#dc3545", "Thank you for your interest. The company has decided to move forward with other candidates at this time. We wish you the best of luck in your job search.");
                    break;
                default:
                    statusContent = ("Received", "#6c757d", "We have successfully received your application. The employer will review it shortly.");
                    break;
            }

            var sb = new StringBuilder();

            sb.Append(@"
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Application Status Update</title>
</head>
<body style='margin: 0; padding: 0; font-family: Poppins, Segoe UI; background-color: #f4f4f7; color: #333;'>
    <table width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color: #f4f4f7;'>
        <tr>
            <td align='center' style='padding: 20px 0;'>
                <table width='600' border='0' cellspacing='0' cellpadding='0' style='background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);'>
                    <tr>
                        <td align='center' style='padding: 30px 20px; border-bottom: 1px solid #eeeeee;'>
                            <h1 style='margin: 0; color: #ff7300; font-size: 28px;'>ITapply</h1>
                        </td>
                    </tr>

                    <tr>
                        <td style='padding: 40px 30px;'>
                            <h2 style='margin: 0 0 20px 0; font-size: 22px; color: #333;'>Hi " + candidateName + @",</h2>
                            <p style='margin: 0 0 25px 0; font-size: 16px; line-height: 1.6;'>
                                There's an update on your application for the <strong>" + jobTitle + @"</strong> position at <strong>" + companyName + @"</strong>.
                            </p>

                            <table width='100%' border='0' cellspacing='0' cellpadding='0' style='background-color: #f9f9f9; border-left: 5px solid " + statusContent.statusColor + @"; margin-bottom: 25px;'>
                                <tr>
                                    <td style='padding: 20px;'>
                                        <p style='margin: 0 0 10px 0; font-size: 14px; color: #555;'>New Status:</p>
                                        <p style='margin: 0; font-size: 20px; font-weight: bold; color: " + statusContent.statusColor + @";'>" + statusContent.statusText + @"</p>
                                    </td>
                                </tr>
                            </table>");

            if (!string.IsNullOrWhiteSpace(employerMessage))
            {
                sb.Append(@"
                            <h3 style='font-size: 18px; color: #333; margin-top: 30px; margin-bottom: 15px; border-bottom: 2px solid #eee; padding-bottom: 10px;'>A Message from the Employer:</h3>
                            <div style='background-color: #ffc799; border-radius: 6px; padding: 20px; font-size: 15px; line-height: 1.6;'>
                                " + employerMessage + @"
                            </div>");
            }
            else
            {
                sb.Append(@"<p style='font-size: 16px; line-height: 1.6;'>" + statusContent.message + "</p>");
            }

            sb.Append(@"
                        </td>
                    </tr>

                    <tr>
                        <td align='center' style='padding: 20px 30px; background-color: #f1f1f1; border-top: 1px solid #dddddd; border-bottom-left-radius: 8px; border-bottom-right-radius: 8px;'>
                            <p style='margin: 0; font-size: 12px; color: #888;'>
                                You are receiving this email because you applied for a job through ITapply.
                                <br>© " + DateTime.Now.Year + @" ITapply. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>");

            return sb.ToString();
        }
    }
}