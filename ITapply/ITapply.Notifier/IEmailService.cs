using ITapply.Models.Messages;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Notifier
{
    public interface IEmailService 
    { 
        Task SendEmailAsync(NotificationPayload payload); 
    }
}
