using ITapply.Models.Messages;
using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;
using MimeKit;

namespace ITapply.Notifier;

public class EmailService : IEmailService
{
    private readonly IConfiguration _config;
    public EmailService(IConfiguration config) 
    { 
        _config = config; 
    }

    public async Task SendEmailAsync(NotificationPayload payload)
    {
        var smtpSettings = _config.GetSection("SmtpSettings");

        var email = new MimeMessage();
        email.From.Add(new MailboxAddress("ITapply Notifications", smtpSettings["FromEmail"]));
        email.To.Add(MailboxAddress.Parse(payload.ToEmail));
        email.Subject = payload.Subject;
        email.Body = new TextPart("html") { Text = payload.Body };

        using var smtp = new SmtpClient();
        try
        {
            await smtp.ConnectAsync(smtpSettings["Server"], int.Parse(smtpSettings["Port"]), MailKit.Security.SecureSocketOptions.StartTls);

            await smtp.AuthenticateAsync(smtpSettings["Username"], smtpSettings["Password"]);

            await smtp.SendAsync(email);

            Console.WriteLine($"[SUCCESS] Email sent to {payload.ToEmail}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[ERROR] Failed to send email to {payload.ToEmail}. Details: {ex}");
        }
        finally
        {
            await smtp.DisconnectAsync(true);
        }
    }
}