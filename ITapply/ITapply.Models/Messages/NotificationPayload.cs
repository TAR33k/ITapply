using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Messages;

public class NotificationPayload
{
    public string ToEmail { get; set; }
    public string Subject { get; set; }
    public string Body { get; set; }
}