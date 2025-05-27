using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using ITapply.Models.Responses;
using Microsoft.EntityFrameworkCore;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Services.Database
{
    public static class DataSeeder
    {
        public static void SeedData(ITapplyDbContext dbContext)
        {
            dbContext.Database.EnsureCreated();
            dbContext.Database.Migrate();

            SeedRoles(dbContext);
            SeedSkills(dbContext);
            SeedLocations(dbContext);
            SeedUsers(dbContext);
            SeedUserRoles(dbContext);
            SeedJobPostings(dbContext);
            SeedCVDocuments(dbContext);
            SeedApplications(dbContext);
            SeedReviews(dbContext);
            SeedWorkExperiences(dbContext);
            SeedEducation(dbContext);
            SeedPreferences(dbContext);
        }

        private static void SeedRoles(ITapplyDbContext dbContext)
        {
            if (!dbContext.Roles.Any())
            {
                dbContext.Roles.AddRange(
                    new Role { Name = "Administrator" },
                    new Role { Name = "Candidate" },
                    new Role { Name = "Employer" }
                );
                dbContext.SaveChanges();
            }
        }

        private static void SeedSkills(ITapplyDbContext dbContext)
        {
            if (!dbContext.Skills.Any())
            {
                var skills = new[]
                {
                    "C#", "Java", "Python", "JavaScript", "TypeScript", "React", "Angular", "Vue.js",
                    "Node.js", ".NET Core", "ASP.NET", "SQL", "MongoDB", "Docker", "Kubernetes",
                    "AWS", "Azure", "DevOps", "CI/CD", "Git", "Agile", "Scrum", "Project Management",
                    "UI/UX Design", "Mobile Development", "iOS", "Android", "Flutter", "React Native",
                    "Machine Learning", "Data Science", "Big Data", "Cloud Computing", "Cybersecurity"
                };

                dbContext.Skills.AddRange(skills.Select(s => new Skill { Name = s }));
                dbContext.SaveChanges();
            }
        }

        private static void SeedLocations(ITapplyDbContext dbContext)
        {
            if (!dbContext.Locations.Any())
            {
                var locations = new[]
                {
                    new Location { City = "Sarajevo", Country = "Bosnia and Herzegovina" },
                    new Location { City = "Mostar", Country = "Bosnia and Herzegovina" },
                    new Location { City = "Belgrade", Country = "Serbia" },
                    new Location { City = "Zagreb", Country = "Croatia" },
                    new Location { City = "New York", Country = "USA" },
                    new Location { City = "London", Country = "UK" },
                    new Location { City = "Berlin", Country = "Germany" },
                    new Location { City = "Paris", Country = "France" },
                    new Location { City = "Tokyo", Country = "Japan" },
                    new Location { City = "Sydney", Country = "Australia" },
                    new Location { City = "Toronto", Country = "Canada"},
                    new Location { City = "Singapore", Country = "Singapore"}
                };

                dbContext.Locations.AddRange(locations);
                dbContext.SaveChanges();
            }
        }

        private static void SeedUsers(ITapplyDbContext dbContext)
        {
            if (!dbContext.Users.Any())
            {
                var newUsers = new[]
                {
                    CreateUser("admin@itapply.com", "admin"),
                    CreateUser("candidate1@itapply.com", "candidate"),
                    CreateUser("candidate2@itapply.com", "candidate"),
                    CreateUser("employer1@itapply.com", "employer"),
                    CreateUser("employer2@itapply.com", "employer"),
                    CreateUser("employer3@itapply.com", "employer")
                };

                dbContext.Users.AddRange(newUsers);
                dbContext.SaveChanges();
            }

            var users = dbContext.Users;

            if (!dbContext.Candidates.Any())
            {
                var candidates = new[]
                {
                    new Candidate
                    {
                        Id = 2,
                        User = users.Find(2),
                        FirstName = "John",
                        LastName = "Doe",
                        PhoneNumber = "+1234567890",
                        Title = "Software Developer",
                        ExperienceLevel = ExperienceLevel.Mid,
                        ExperienceYears = 4,
                        LocationId = 1,
                        Bio = "Experienced software developer with a passion for clean code and innovative solutions."
                    },
                    new Candidate
                    {
                        Id = 3,
                        User = users.Find(3),
                        FirstName = "Jane",
                        LastName = "Smith",
                        PhoneNumber = "+1987654321",
                        Title = "Software Developer",
                        ExperienceLevel = ExperienceLevel.Senior,
                        ExperienceYears = 7,
                        LocationId = 2,
                        Bio = "Full-stack developer with expertise in modern web technologies and cloud architecture."
                    }
                };

                dbContext.Candidates.AddRange(candidates);
                dbContext.SaveChanges();
            }

            if (!dbContext.Employers.Any())
            {
                var employers = new[]
                {
                    new Employer
                    {
                        Id = 4,
                        User = users.Find(4),
                        CompanyName = "TechCorp Solutions",
                        Industry = "Information Technology",
                        YearsInBusiness = 10,
                        Size = "100-500",
                        Website = "https://techcorp.example.com",
                        ContactEmail = "employer1@itapply.com",
                        ContactPhone = "+1234567890",
                        Description = "Leading technology solutions provider",
                        Address = "Address 1",
                        Benefits = "Benefits",
                        VerificationStatus = VerificationStatus.Approved,
                        LocationId = 1,
                        Logo = new byte[0]
                    },
                    new Employer
                    {
                        Id = 5,
                        User = users.Find(5),
                        CompanyName = "Digital Innovations",
                        Industry = "Software Development",
                        YearsInBusiness = 20,
                        Size = "50-100",
                        Website = "https://digitalinnovations.example.com",
                        ContactEmail = "employer2@itapply.com",
                        ContactPhone = "+1234567890",
                        Description = "Innovative software development company",
                        Address = "Address 2",
                        Benefits = "Benefits",
                        VerificationStatus = VerificationStatus.Approved,
                        LocationId = 2,
                        Logo = new byte[0]
                    },
                    new Employer
                    {
                        Id = 6,
                        User = users.Find(6),
                        CompanyName = "Global Systems",
                        Industry = "Enterprise Software",
                        YearsInBusiness = 30,
                        Size = "500+",
                        Website = "https://globalsystems.example.com",
                        ContactEmail = "employer3@itapply.com",
                        ContactPhone = "+1234567890",
                        Description = "Enterprise software solutions provider",
                        Address = "Address 3",
                        Benefits = "Benefits",
                        VerificationStatus = VerificationStatus.Pending,
                        LocationId = 3,
                        Logo = new byte[0]
                    }
                };

                dbContext.Employers.AddRange(employers);
                dbContext.SaveChanges();
            }
        }

        private static void SeedUserRoles(ITapplyDbContext dbContext)
        {
            if (!dbContext.UserRoles.Any())
            {
                var adminRole = dbContext.Roles.First(r => r.Name == "Administrator");
                var candidateRole = dbContext.Roles.First(r => r.Name == "Candidate");
                var employerRole = dbContext.Roles.First(r => r.Name == "Employer");

                var userRoles = new[]
                {
                    new UserRole { UserId = 1, RoleId = adminRole.Id },
                    new UserRole { UserId = 2, RoleId = candidateRole.Id },
                    new UserRole { UserId = 3, RoleId = candidateRole.Id },
                    new UserRole { UserId = 4, RoleId = employerRole.Id },
                    new UserRole { UserId = 5, RoleId = employerRole.Id },
                    new UserRole { UserId = 6, RoleId = employerRole.Id }
                };

                dbContext.UserRoles.AddRange(userRoles);
                dbContext.SaveChanges();
            }
        }

        private static void SeedJobPostings(ITapplyDbContext dbContext)
        {
            if (!dbContext.JobPostings.Any())
            {
                var jobPostings = new[]
                {
                    new JobPosting
                    {
                        Title = "Senior Software Engineer",
                        Description = "Looking for an experienced software engineer to join our team",
                        Requirements = "5+ years of experience, strong C# skills",
                        Benefits = "Benefits",
                        EmploymentType = EmploymentType.FullTime,
                        ExperienceLevel = ExperienceLevel.Senior,
                        Remote = Remote.Hybrid,
                        Status = JobPostingStatus.Active,
                        MinSalary = 80000,
                        MaxSalary = 120000,
                        PostedDate = DateTime.Now.AddDays(-10),
                        ApplicationDeadline = DateTime.Now.AddDays(20),
                        EmployerId = 4,
                        LocationId = 1
                    },
                    new JobPosting
                    {
                        Title = "Frontend Developer",
                        Description = "Join our frontend team to build amazing user experiences",
                        Requirements = "3+ years of React experience",
                        Benefits = "Benefits",
                        EmploymentType = EmploymentType.FullTime,
                        ExperienceLevel = ExperienceLevel.Mid,
                        Remote = Remote.Yes,
                        Status = JobPostingStatus.Active,
                        MinSalary = 70000,
                        MaxSalary = 90000,
                        PostedDate = DateTime.Now.AddDays(-5),
                        ApplicationDeadline = DateTime.Now.AddDays(25),
                        EmployerId = 5,
                        LocationId = 2
                    }
                };

                dbContext.JobPostings.AddRange(jobPostings);
                dbContext.SaveChanges();

                var skills = dbContext.Skills.ToList();
                foreach (var jobPosting in jobPostings)
                {
                    var jobSkills = skills.Take(3).Select(s => new JobPostingSkill
                    {
                        JobPostingId = jobPosting.Id,
                        SkillId = s.Id
                    });
                    dbContext.JobPostingSkills.AddRange(jobSkills);
                }
                dbContext.SaveChanges();
            }
        }

        private static void SeedCVDocuments(ITapplyDbContext dbContext)
        {
            if (!dbContext.CVDocuments.Any())
            {
                var cvDocuments = new[]
                {
                    new CVDocument
                    {
                        CandidateId = 2,
                        FileName = "JohnDoe_CV.pdf",
                        UploadDate = DateTime.Now.AddDays(-30),
                        FileContent = new byte[0],
                        IsMain = true
                    },
                    new CVDocument
                    {
                        CandidateId = 3,
                        FileName = "JaneSmith_CV.pdf",
                        UploadDate = DateTime.Now.AddDays(-20),
                        FileContent = new byte[0],
                        IsMain = true
                    }
                };

                dbContext.CVDocuments.AddRange(cvDocuments);
                dbContext.SaveChanges();
            }
        }

        private static void SeedApplications(ITapplyDbContext dbContext)
        {
            if (!dbContext.Applications.Any())
            {
                var applications = new[]
                {
                    new Application
                    {
                        CandidateId = 2,
                        JobPostingId = 1,
                        CVDocumentId = 1,
                        Status = ApplicationStatus.Applied,
                        ApplicationDate = DateTime.Now.AddDays(-5),
                        CoverLetter = "I am excited to apply for this position...",
                        Availability = "Now"
                    },
                    new Application
                    {
                        CandidateId = 3,
                        JobPostingId = 2,
                        CVDocumentId = 2,
                        Status = ApplicationStatus.InConsideration,
                        ApplicationDate = DateTime.Now.AddDays(-3),
                        CoverLetter = "I believe my skills align perfectly with your requirements...",
                        Availability = "Now"
                    }
                };

                dbContext.Applications.AddRange(applications);
                dbContext.SaveChanges();
            }
        }

        private static void SeedReviews(ITapplyDbContext dbContext)
        {
            if (!dbContext.Reviews.Any())
            {
                var reviews = new[]
                {
                    new Review
                    {
                        CandidateId = 2,
                        EmployerId = 4,
                        Rating = 5,
                        Comment = "Great company to work for!",
                        Position = "Software Developer",
                        Relationship = ReviewRelationship.FormerEmployee,
                        ModerationStatus = ModerationStatus.Approved,
                        ReviewDate = DateTime.Now.AddDays(-30)
                    },
                    new Review
                    {
                        CandidateId = 3,
                        EmployerId = 5,
                        Rating = 4,
                        Comment = "Good work environment and culture",
                        Position = "Software Developer",
                        Relationship = ReviewRelationship.CurrentEmployee,
                        ModerationStatus = ModerationStatus.Approved,
                        ReviewDate = DateTime.Now.AddDays(-15)
                    }
                };

                dbContext.Reviews.AddRange(reviews);
                dbContext.SaveChanges();
            }
        }

        private static void SeedWorkExperiences(ITapplyDbContext dbContext)
        {
            if (!dbContext.WorkExperiences.Any())
            {
                var workExperiences = new[]
                {
                    new WorkExperience
                    {
                        CandidateId = 2,
                        CompanyName = "Previous Tech",
                        Position = "Software Developer",
                        StartDate = DateTime.Now.AddYears(-3),
                        EndDate = DateTime.Now.AddYears(-1),
                        Description = "Developed and maintained web applications"
                    },
                    new WorkExperience
                    {
                        CandidateId = 3,
                        CompanyName = "Tech Solutions",
                        Position = "Senior Developer",
                        StartDate = DateTime.Now.AddYears(-5),
                        EndDate = null,
                        Description = "Leading development team and implementing best practices"
                    }
                };

                dbContext.WorkExperiences.AddRange(workExperiences);
                dbContext.SaveChanges();
            }
        }

        private static void SeedEducation(ITapplyDbContext dbContext)
        {
            if (!dbContext.Educations.Any())
            {
                var educations = new[]
                {
                    new Education
                    {
                        CandidateId = 2,
                        Institution = "University of Technology",
                        Degree = "Bachelor of Science",
                        FieldOfStudy = "Computer Science",
                        StartDate = DateTime.Now.AddYears(-7),
                        EndDate = DateTime.Now.AddYears(-3),
                        Description = "Focused on software engineering and algorithms"
                    },
                    new Education
                    {
                        CandidateId = 3,
                        Institution = "Tech University",
                        Degree = "Master of Science",
                        FieldOfStudy = "Software Engineering",
                        StartDate = DateTime.Now.AddYears(-4),
                        EndDate = DateTime.Now.AddYears(-2),
                        Description = "Specialized in distributed systems and cloud computing"
                    }
                };

                dbContext.Educations.AddRange(educations);
                dbContext.SaveChanges();
            }
        }

        private static void SeedPreferences(ITapplyDbContext dbContext)
        {
            if (!dbContext.Preferences.Any())
            {
                var preferences = new[]
                {
                    new Preferences
                    {
                        CandidateId = 2,
                        LocationId = 1,
                        EmploymentType = EmploymentType.FullTime,
                        Remote = Remote.Hybrid
                    },
                    new Preferences
                    {
                        CandidateId = 3,
                        EmploymentType = EmploymentType.FullTime,
                        Remote = Remote.Yes
                    }
                };

                dbContext.Preferences.AddRange(preferences);
                dbContext.SaveChanges();
            }
        }

        private static User CreateUser(string email, string password)
        {
            byte[] salt;
            string userHashedPassword = HashPassword(password, out salt);
            string userSalt = Convert.ToBase64String(salt);

            return new User
            {
                Email = email,
                PasswordHash = userHashedPassword,
                PasswordSalt = userSalt,
                RegistrationDate = DateTime.Now,
                IsActive = true
            };
        }

        private static string HashPassword(string password, out byte[] salt)
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
    }
} 