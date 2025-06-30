using EasyNetQ;
using Microsoft.Extensions.Hosting;
using ITapply.Models.Messages;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace ITapply.Notifier;

public class NotificationConsumer : IHostedService, IDisposable
{
    private readonly IBus _bus;
    private readonly IEmailService _emailService;
    private IDisposable _subscription;

    public NotificationConsumer(IBus bus, IEmailService emailService)
    {
        _bus = bus;
        _emailService = emailService;
    }

    public Task StartAsync(CancellationToken cancellationToken)
    {
        _subscription = _bus.PubSub.Subscribe<NotificationPayload>(
            "itapply-notification-service",
            HandleNotification,
            cancellationToken
        );

        Console.WriteLine("--> Listening for notification messages. To exit press CTRL+C");

        return Task.CompletedTask;
    }

    private async Task HandleNotification(NotificationPayload payload)
    {
        Console.WriteLine($"[RECEIVED] Notification for: {payload.ToEmail}");
        try
        {
            await _emailService.SendEmailAsync(payload);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[ERROR] Failed to handle notification for {payload.ToEmail}. Error: {ex}");
        }
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        _subscription?.Dispose();
        Console.WriteLine("--> Subscription stopped.");
        return Task.CompletedTask;
    }

    public void Dispose()
    {
        _subscription?.Dispose();
    }
}