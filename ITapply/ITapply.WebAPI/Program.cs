using Azure.Core;
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

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<ITapplyDbContext>();
    if (dbContext.Database.EnsureCreated())
    {
        dbContext.Database.Migrate();

        if (!dbContext.Roles.Any())
        {
            dbContext.Roles.AddRange(
                new Role { Name = "Administrator" },
                new Role { Name = "Candidate" },
                new Role { Name = "Employer" }
            );
            dbContext.SaveChanges();
        }

        if (!dbContext.Users.Any())
        {
            dbContext.Users.Add(CreateUser("admin@example.com", "admin"));
            dbContext.Users.Add(CreateUser("candidate@example.com", "candidate"));
            dbContext.Users.Add(CreateUser("employer@example.com", "employer"));
            dbContext.SaveChanges();
        }

        if (!dbContext.UserRoles.Any())
        {
            dbContext.UserRoles.AddRange(
                new UserRole { UserId = 1, RoleId = 1 },
                new UserRole { UserId = 2, RoleId = 2 },
                new UserRole { UserId = 3, RoleId = 3 }
            );
            dbContext.SaveChanges();
        }
    }
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

static User CreateUser(string email, string password)
{
    byte[] salt;
    string userHashedPassword = HashPassword(password, out salt);
    string userSalt = Convert.ToBase64String(salt);

    return new User
    {
        Email = email,
        PasswordHash = userHashedPassword,
        PasswordSalt = userSalt,
        RegistrationDate = DateTime.UtcNow,
        IsActive = true
    };
}

static string HashPassword(string password, out byte[] salt)
{
    salt = new byte[16];
    using (var rng = new RNGCryptoServiceProvider())
    {
        rng.GetBytes(salt);
    }

    using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 10000))
    {
        return Convert.ToBase64String(pbkdf2.GetBytes(32));
    }
}