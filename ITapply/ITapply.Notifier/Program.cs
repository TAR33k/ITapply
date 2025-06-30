using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using ITapply.Notifier;
using Microsoft.Extensions.Configuration;
using EasyNetQ;
using EasyNetQ.DI;
using EasyNetQ.Serialization.SystemTextJson;

public class Program
{
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureServices((hostContext, services) =>
            {
                services.RegisterEasyNetQ(hostContext.Configuration["EasyNetQ_ConnectionString"], services =>
                {
                    services.Register<ISerializer, SystemTextJsonSerializer>();
                });

                services.AddSingleton<IEmailService, EmailService>();

                services.AddHostedService<NotificationConsumer>();
            });
}