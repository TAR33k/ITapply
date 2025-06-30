using Azure.Core;
using EasyNetQ;
using EasyNetQ.DI;
using EasyNetQ.Serialization.SystemTextJson;
using ITapply.Services.Database;
using ITapply.Services.Interfaces;
using ITapply.Services.Services;
using ITapply.WebAPI.Authentication;
using ITapply.WebAPI.Filters;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.ComponentModel.DataAnnotations;
using System.Numerics;
using System.Reflection.Emit;
using System.Security.Cryptography;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddTransient<ILocationService, LocationService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IUserRoleService, UserRoleService>();
builder.Services.AddTransient<ISkillService, SkillService>();
builder.Services.AddTransient<ICandidateService, CandidateService>();
builder.Services.AddTransient<IEmployerService, EmployerService>();
builder.Services.AddTransient<IJobPostingService, JobPostingService>();
builder.Services.AddTransient<IApplicationService, ApplicationService>();
builder.Services.AddTransient<ICVDocumentService, CVDocumentService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IWorkExperienceService, WorkExperienceService>();
builder.Services.AddTransient<IEducationService, EducationService>();
builder.Services.AddTransient<IPreferencesService, PreferencesService>();
builder.Services.AddTransient<IEmployerSkillService, EmployerSkillService>();
builder.Services.AddTransient<IJobPostingSkillService, JobPostingSkillService>();
builder.Services.AddTransient<ICandidateSkillService, CandidateSkillService>();

builder.Services.AddMapster();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ITapplyDbContext>(options => 
        options.UseSqlServer(connectionString));

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddControllers(c =>
{
    c.Filters.Add<ExceptionFilter>();
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("BasicAuthentication", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        In = ParameterLocation.Header,
        Description = "Basic Authorization header using the Bearer scheme."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "BasicAuthentication" } },
            new string[] { }
        }
    });
});

builder.Services.RegisterEasyNetQ(builder.Configuration["EasyNetQ_ConnectionString"], services =>
{
    services.Register<ISerializer, SystemTextJsonSerializer>();
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<ITapplyDbContext>();
    DataSeeder.SeedData(dbContext);
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();