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
            SeedCandidateSkills(dbContext);
            SeedEmployerSkills(dbContext);
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
                    "Node.js", ".NET Core", "ASP.NET", "SQL", "NoSQL", "MongoDB", "PostgreSQL", "MySQL", "GraphQL",
                    "Docker", "Kubernetes", "Terraform", "Ansible", "Jenkins", "GitLab CI", "GitHub Actions",
                    "AWS", "Azure", "Google Cloud Platform (GCP)", "Oracle Cloud Infrastructure (OCI)",
                    "DevOps", "CI/CD", "Git", "Agile", "Scrum", "Kanban", "Project Management", "Product Management",
                    "UI/UX Design", "Figma", "Adobe XD", "Sketch", "Mobile Development", "iOS", "Android", "Swift", "Kotlin", "Flutter", "React Native",
                    "Machine Learning", "Deep Learning", "Natural Language Processing (NLP)", "Computer Vision", "Data Science", "Big Data", "Apache Spark", "Hadoop",
                    "Cloud Computing", "Serverless Architecture", "Microservices", "Cybersecurity", "Penetration Testing", "Ethical Hacking",
                    "Blockchain", "Web3", "Unity", "Unreal Engine", "Game Development", "AR/VR Development"
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
                    new Location { City = "Banja Luka", Country = "Bosnia and Herzegovina" },
                    new Location { City = "Tuzla", Country = "Bosnia and Herzegovina" },
                    new Location { City = "Belgrade", Country = "Serbia" },
                    new Location { City = "Novi Sad", Country = "Serbia" },
                    new Location { City = "Zagreb", Country = "Croatia" },
                    new Location { City = "Split", Country = "Croatia" },
                    new Location { City = "New York", Country = "USA" },
                    new Location { City = "San Francisco", Country = "USA" },
                    new Location { City = "London", Country = "UK" },
                    new Location { City = "Manchester", Country = "UK" },
                    new Location { City = "Berlin", Country = "Germany" },
                    new Location { City = "Munich", Country = "Germany" },
                    new Location { City = "Paris", Country = "France" },
                    new Location { City = "Lyon", Country = "France" },
                    new Location { City = "Tokyo", Country = "Japan" },
                    new Location { City = "Osaka", Country = "Japan" },
                    new Location { City = "Sydney", Country = "Australia" },
                    new Location { City = "Melbourne", Country = "Australia" },
                    new Location { City = "Toronto", Country = "Canada"},
                    new Location { City = "Vancouver", Country = "Canada"},
                    new Location { City = "Singapore", Country = "Singapore"},
                    new Location { City = "Dubai", Country = "UAE"},
                    new Location { City = "Amsterdam", Country = "Netherlands"},
                    new Location { City = "Dublin", Country = "Ireland"}
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
                var logo1 = Convert.FromBase64String("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kAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIEVAAgCQIiABAEgRkAAApAhIAABSBCQAACkCEgCAFAEJAECKgAQAIOHfd/8P9tVh7TE090IAAAAASUVORK5CYII=");
                var logo2 = Convert.FromBase64String("iVBORw0KGgoAAAANSUhEUgAAApAAAAKQCAYAAAAotUpQAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAD3dSURBVHhe7d0LrDxVYT9wfGCDBANGDNSgRiSgtJGkCppi1aD1ESMiaq1JhWipD9CGVtSokRgLigFbNfaPDU01PjAipT6CQUOp0mKhRjGo8QlUrGgVESSaKGH+frc7OHd/c+/ds3tm7+7ezyc5gd+9uzNnZufOfPecM2f2agAAoIAACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESoMc//dM/NSeffHLzxCc+sXnoQx86Kvn/lPzuhhtuGL8SYPcRIAE6Eg4TFvfaa69tS8KkIAnsRgIkwG8kCCYQ9gXFtqRFMgHziiuuGL0+/23/H2A3ESCBXS8hsC8wtiWhsSuB8cwzzxyVbhd3282dn2eZAOtKgAR2pYTCBL0rr7yyNzSmpMWxK8ExP+t7bV9JoMw6ANaNAAnsKm1XdcJdWgnz377wN9mCmCDY97ppStahmxtYJwIksGu0XdVteNwsFHbDYxs4+15XUtp1AqwDARLYFbphsR3T2A14bZkMeTXCY1uESGBdCJDA2ksrYjfETf6sLZM3y/SFx7w/4yATSLt3ZLcl/87P2zkk+96f1wGsMgESWHvdINfe1DLZfT15w0z39wl9+fcsrYcJi5PrakMswKoSIIG1Nhne2ta/bqjsC3Tt7/L+GiaDpK5sYJUJkMBa2ywo5v/bn0+GxPw7ZYiu5iwz69YKCawyARJYa21I3CxA9gW5IYJjVxsitUICq0qABNZWglo3QKY1stUGyFpd1KVSt51aN8C8BEhgbaWFb7MA2XZt72QroBZIYFUJkMDa2ipApvWvr/u6a3Jan9qG7ioHGIoACay1tqt6MkAmXG7WhZxg131tgmS7jCyvVvDLcrRCAqtIgATWVsJZ21Xdlm742yy8ZU7I9ndt0Gzfl//WbJkUIIFVJEACa6l9SkzCYDdAbhX+2jA3Oan4kNxIA6wiARJYSwmBCYtpMex2Y28VDtswV7OFcTtaIIFVJEACayld121YTDDstkJuJq/bLtAlkOZ1WXaN8LfIsApQiwAJrKW0OnZveOmOhdwstLXhsH3PZtrXZVnzdncLkMAqEiCBtdR2W3cDXvuzbrCcRxsi899ZCZDAKhIggbWU4NiGxW5Xc8JefjZP6GslhKZlM8ublTGQwCoSIIG1lGCWANnX4pjfzdv13GrXMystkMAqEiCBtZTA2AbINkTWau3rhr52PbOq0RIKsGgCJLC2EvQmQ2SNwJZu624Ynac1s1aoBVgkARJYawmM3RBZI0gmMCZERgLgrCEw76txMw/AogmQwNrrC5FtkEwYTEtlSQjM+1LmZfwjsKoESGBXSEvfZkEyJYFws0A32UXdvmdeuq+BVSVAArtGQuSVV145Cm4JiylbdWXn9emq7r4m72kD5zyyHN3XwKoSIIFdI4EtrYnbBbcEzLyuLyjm3/n5ZKtkqc1aOwFWgQAJ7CptN3bbsjjZGpmf5/dt6XYzt++t0foIsMoESGDXaYPgdqUvPE7+fBbzvh9gpwmQwK6UEJfWxrZLulvSPZ3fp6u72yo5Tff3drQ+AutAgAR2tQTFtkyGu4TFNkjWkuUBrDoBEmBBtD4C60KABFgQARJYFwIkwALougbWiQAJsAACJLBOBEiAgem6BtaNAAkwMK2PwLoRIAEGpPURWEcCJMCABEhgHQmQAAMRHoF1JUACDMTYR2BdCZAAAxEggXUlQAIMRBc2sK4ESIAB3HDDDaMCsI4ESIABpPVRgATWlQAJMADd18A6EyABBuAGGmCdCZAAA9ACCawzARKgMuMfgXUnQAL8RnvXdI1y5plnjpcKsJ4ESGDXS+g7+eSTq5UsD2CdCZAAv/Hnf/7nzf7779/stddeo3LEEUdMXdr3POhBD9L6COwKAiSw633jG9+4OwTOWw444IDxUgHWlwAJ8BuXX35587d/+7fNO97xjrnKddddN14iwPoSIAF+441vfGNz5JFHjloRn/zkJxeXvO/oo49u3vOe94yXCLC+BEhg1/vqV7+6oRt6nrLPPvuMlwqwvgRIgN/48Ic/3JxxxhlzlVNOOWXUFQ6w7gRIgN+4+OKLm+c+97mjEDhrOemkk5ovfOEL4yUCrC8BEuA37nWve/V2SZeWo446arxEgPUlQAL8xkc+8pHmWc961qgVcdbyp3/6p82VV145XiLA+hIgAcYyCXjfk2WmLXkGNsBuIEACjPV1SZeUhz70oeMlAaw3ARJgLC2IaYWctXgGNrBbCJAAHVdcccUoDPZ1UW9VhEdgNxEgATrSCtnXPb1VSdd1gifAbiFAAmzik5/8ZPOJT3xi0/K5z31u/EqA3UWABNjE0572tOa+971v86QnPWlDSavjgQce2Jx44onjVwLsLgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJBL5K677lIURVEUZZvCzhMgl8j//u//NnvttZeiKIqiKJuUv/mbvxlfNdlJAuQSESAVRVEUZesiQC4HAXKJJED+3u/9nqIoiqIomxQBcjkIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgYQ4XXHBBc8opp8xd3vSmNzUXXXTR3eW6665rbr311vFa6vr1r3/dfO5zn9uwvmnLhRde2Hz3u98dL2kYd955Z/OjH/2oueKKK+5e7wc/+MHRutt/53c/+MEPmp///Ofjd82m5r745S9/2bz97W/v/XwXXS699NJxreq45ppr9ljHe9/73uauu+4av2IYy36swm4mQMIc3vOe9zSHH354c8ABBzR77bXXpuUpT3nKHhfgyfKiF71otKx999337vftvffezXHHHTcKqj/5yU/Ga53f6aef3hxyyCGj5XfruVnJ9uX1qcuXv/zl8VLq+d73vtecc845zZFHHnn3Og888MDm+OOP37CPnv/85zcPfvCDN9Ttnve8Z/Pwhz+8efGLX9y8733va77zne+MQui0au2L22+/vTn22GN737Po8ra3vW1cq/klJJ566ql7rOMhD3lI8/3vf3/8quEs27EK/B8BEipKy+HBBx+8x0XtE5/4xPgV00nL2qc//enmaU972oblPOYxj2kuv/zyooA0jX//939v7nvf+25YV0ppvUtkGz71qU+NtqldX7Y3253WvK386le/ar7whS+MQncCZLfOKfnZa1/72playGbdF2kRTbh99KMf3fz0pz8d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O02p9dzyWts47+dToyzqqT2wagRIYCkkLKQFLOFhs6IlCGA5CJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJOwid911V/OTn/yk+cEPfjAqP/zhD5tf/epX49/CenLcQ30C5Ar61re+1Vx00UUzlcsvv3y8lI0uvfTS5pRTTtm2vOMd76h+4v3+97/fW9ftyj//8z83P//5z8dL+a0bbrihedWrXtVb/245/fTTm5tuumn8rjp+8YtfjPZlX323KhdeeGHz3e9+d7yUOnLRzL4499xzm2OOOabZd999m7322mvTcuCBBzbHH398c/7554/el/eXuOWWW5p/+Zd/6d2+7cqnP/3p5pe//OV4SbObdf+nbPa3sZVrrrlmj+Pqve99b/G+28q0x/PQJXVIXSYNcT6ax6KP+83ceuutzWtf+9refdktL3/5y5uvfOUr43fV8etf/7q54oorevf5duW//uu/xkuZXa4RX/3qV5sPfvCDzStf+cre7T7jjDNG571PfOITzY033jjaX6wWAXIFffazn20OOeSQ5oADDug9IU6Wvffee/T6Rz3qUaOTZJ/3vOc9zeGHHz46mfYtoy33vOc9m8985jPjd9Vx9dVXj9b9oAc9aLT8vvV2Sy4I2Z4Xv/jFvSedL3/5y6MLxzTL+8u//MuqF/uf/exnzTOf+cxR/ba7cKWkfqln6pt615AQ9f73v7859NBDN6zr0Y9+dPOmN71pjwvGOeec0zz/+c9vHvjAB254fY6FvD4tN9PIReDoo49uDj744A3L2apkHQ972MNGF9EaF5Du/s9x37fObmn3f46//A2UyHFz6qmn7rHMhzzkIaMvRbUkpO6zzz57rGfR5b73vW/zxS9+cVyr3xrifDSLnTruN5Mw+qxnPWuqYzHHbOpfSwLkS1/60qLPJX+3+Uw++clPjpdS5s4772w+9alPNY997GN7l99+7ludl/Pzhz/84c1f/MVfjILlvJ8BwxIg10Bafo499tg9/hhf9KIXjV9RLq0KubDf4x732GO5j3nMYwb/w06YSFfTtdde2zzucY8brTffVmcJezkxn3TSSaNl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ESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACgiQAIAUESABACgiAAJAEARARIAgCICJAAARQRIAACKCJAAABQRIAEAKCJAAgBQRIAEAKCIAAkAQBEBEgCAIgIkAABFBEgAAIoIkAAAFBEgAQAoIkACAFBEgAQAoIgACQBAEQESAIAiAiQAAEUESAAAigiQAAAUESABACjQNP8fDvnsOptm1UQAAAAASUVORK5CYII=");
                var logo3 = Convert.FromBase64String("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gG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBuIhIAgG4iEgCAbiISAIBOP7b6/wEfuLEFA+apDAAAAABJRU5ErkJggg==");

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
                        Logo = logo1
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
                        Logo = logo2
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
                        Logo = logo3
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
                        Description = "Looking for an experienced software engineer to join our team. Responsibilities include designing, developing, and maintaining software applications.",
                        Requirements = "5+ years of experience in software development, strong proficiency in C# and .NET Core. Experience with microservices architecture and cloud platforms (Azure/AWS) is a plus.",
                        Benefits = "Competitive salary, health insurance, paid time off, flexible work hours, professional development opportunities.",
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
                        Description = "Join our frontend team to build amazing user experiences. You will be responsible for developing and implementing user interface components using React.js concepts and workflows.",
                        Requirements = "3+ years of experience in frontend development, proficiency in JavaScript, HTML, CSS, and React. Experience with state management libraries like Redux or Zustand.",
                        Benefits = "Stock options, annual bonus, gym membership, team building events.",
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
                    },
                    new JobPosting
                    {
                        Title = "DevOps Engineer",
                        Description = "We are seeking a skilled DevOps Engineer to manage our CI/CD pipelines and cloud infrastructure. You will work closely with development teams to automate and streamline our operations and processes.",
                        Requirements = "4+ years of experience in DevOps, strong knowledge of Docker, Kubernetes, and CI/CD tools like Jenkins or GitLab CI. Experience with scripting languages (Python/Bash) and infrastructure as code (Terraform/Ansible).",
                        Benefits = "Remote work options, learning budget, modern tech stack.",
                        EmploymentType = EmploymentType.FullTime,
                        ExperienceLevel = ExperienceLevel.Mid,
                        Remote = Remote.Yes,
                        Status = JobPostingStatus.Active,
                        MinSalary = 75000,
                        MaxSalary = 110000,
                        PostedDate = DateTime.Now.AddDays(-15),
                        ApplicationDeadline = DateTime.Now.AddDays(15),
                        EmployerId = 6,
                        LocationId = 3
                    },
                    new JobPosting
                    {
                        Title = "UX/UI Designer",
                        Description = "We are looking for a talented UX/UI Designer to create intuitive and visually appealing interfaces for our web and mobile applications. You will be involved in the entire design process from concept to final hand-off to engineering.",
                        Requirements = "2+ years of experience in UX/UI design, a strong portfolio showcasing your design skills. Proficiency in design tools like Figma, Sketch, or Adobe XD. Understanding of user-centered design principles.",
                        Benefits = "Creative work environment, opportunities for growth, flexible working arrangements.",
                        EmploymentType = EmploymentType.PartTime,
                        ExperienceLevel = ExperienceLevel.Junior,
                        Remote = Remote.No,
                        Status = JobPostingStatus.Active,
                        MinSalary = 40000,
                        MaxSalary = 60000,
                        PostedDate = DateTime.Now.AddDays(-3),
                        ApplicationDeadline = DateTime.Now.AddDays(30),
                        EmployerId = 4,
                        LocationId = 4 
                    },
                     new JobPosting
                    {
                        Title = "Data Scientist",
                        Description = "Join our data science team to analyze large datasets, build predictive models, and extract actionable insights. You will contribute to data-driven decision-making across the company.",
                        Requirements = "PhD or Master's degree in Data Science, Statistics, Computer Science, or a related field. 3+ years of experience in data analysis and machine learning. Proficiency in Python or R and machine learning libraries (e.g., scikit-learn, TensorFlow, PyTorch).",
                        Benefits = "Access to cutting-edge technology, collaborative research opportunities, conference attendance.",
                        EmploymentType = EmploymentType.FullTime,
                        ExperienceLevel = ExperienceLevel.Senior,
                        Remote = Remote.Hybrid,
                        Status = JobPostingStatus.Closed,
                        MinSalary = 90000,
                        MaxSalary = 130000,
                        PostedDate = DateTime.Now.AddDays(-45),
                        ApplicationDeadline = DateTime.Now.AddDays(-15),
                        EmployerId = 5,
                        LocationId = 5
                    }
                };

                dbContext.JobPostings.AddRange(jobPostings);
                dbContext.SaveChanges();

                var skills = dbContext.Skills.ToList();
                var random = new Random();

                foreach (var jobPosting in dbContext.JobPostings)
                {
                    var numberOfSkills = random.Next(3, 6);
                    var jobSkills = skills.OrderBy(s => random.Next()).Take(numberOfSkills).Select(s => new JobPostingSkill
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
                var cvFile = Convert.FromBase64String("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ZSB0cnVlCj4+CmVuZG9iagoyIDAgb2JqCjw8Ci9UeXBlIC9QYWdlcwovS2lkcyBbNCAwIFJdCi9Db3VudCAxCj4+CmVuZG9iagoxIDAgb2JqCjw8Ci9UeXBlIC9DYXRhbG9nCi9QYWdlcyAyIDAgUgovTGFuZyAoaHIpCi9WaWV3ZXJQcmVmZXJlbmNlcyAyMCAwIFIKPj4KZW5kb2JqCjMgMCBvYmoKPDwKL0F1dGhvciAoVGFyaWsgS3VrdWxqYWMpCi9DcmVhdG9yIDxGRUZGMDA0RDAwNjkwMDYzMDA3MjAwNkYwMDczMDA2RjAwNjYwMDc0MDBBRTAwMjAwMDU3MDA2RjAwNzIwMDY0MDAyMDAwNjYwMDZGMDA3MjAwMjAwMDREMDA2OTAwNjMwMDcyMDA2RjAwNzMwMDZGMDA2NjAwNzQwMDIwMDAzMzAwMzYwMDM1PgovQ3JlYXRpb25EYXRlIChEOjIwMjUwNTI5MTY1NzU0KzAyJzAwJykKL1Byb2R1Y2VyIChpTG92ZVBERikKL01vZERhdGUgKEQ6MjAyNTA1MjkxNDU4NTNaKQo+PgplbmRvYmoKMjEgMCBvYmoKPDwKL1NpemUgMjIKL1Jvb3QgMSAwIFIKL0luZm8gMyAwIFIKL0lEIFs8MjREQ0I3OTM1RDk2MjE0NTg2Mzg5OTY1MjI4NEE0NzM+IDxEQkQ5NTZGOEYxQ0NEMTg4MTQ3QzE5QkU4RjdGMTBBRD5dCi9UeXBlIC9YUmVmCi9XIFsxIDIgMl0KL0ZpbHRlciAvRmxhdGVEZWNvZGUKL0luZGV4IFswIDIyXQovTGVuZ3RoIDg2Cj4+CnN0cmVhbQp4nGNgYPj/n9FLjoGB0fMpkPAqARIeR4GE+00goWkFJNQ3gwhuIMHADyRUJ4BYkUBCrRckcQqk7giI+AvSpgck3KSBhJYZiCsBMnknkPAGagMA4WYQSgplbmRzdHJlYW0KZW5kb2JqCnN0YXJ0eHJlZgoxOTM0NAolJUVPRgo=");
                var cvDocuments = new[]
                {
                    new CVDocument
                    {
                        CandidateId = 2,
                        FileName = "JohnDoe_CV.pdf",
                        UploadDate = DateTime.Now.AddDays(-30),
                        FileContent = cvFile,
                        IsMain = true
                    },
                    new CVDocument
                    {
                        CandidateId = 3,
                        FileName = "JaneSmith_CV.pdf",
                        UploadDate = DateTime.Now.AddDays(-20),
                        FileContent = cvFile,
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
                        CoverLetter = "I am excited to apply for the Senior Software Engineer position. My experience in C# and .NET Core aligns well with the job requirements.",
                        Availability = "Immediately"
                    },
                    new Application
                    {
                        CandidateId = 3,
                        JobPostingId = 2,
                        CVDocumentId = 2,
                        Status = ApplicationStatus.InConsideration,
                        ApplicationDate = DateTime.Now.AddDays(-3),
                        CoverLetter = "I believe my skills in React and frontend development make me a strong candidate for the Frontend Developer role. I am eager to contribute to your team.",
                        Availability = "Within 2 weeks"
                    },
                    new Application
                    {
                        CandidateId = 2,
                        JobPostingId = 3,
                        CVDocumentId = 1,
                        Status = ApplicationStatus.InterviewScheduled,
                        ApplicationDate = DateTime.Now.AddDays(-7),
                        CoverLetter = "My background in CI/CD and cloud infrastructure is a great fit for the DevOps Engineer position. I look forward to discussing my qualifications further.",
                        Availability = "Immediately"
                    },
                    new Application
                    {
                        CandidateId = 3,
                        JobPostingId = 1,
                        CVDocumentId = 2,
                        Status = ApplicationStatus.Rejected,
                        ApplicationDate = DateTime.Now.AddDays(-8),
                        CoverLetter = "I am writing to express my interest in the Senior Software Engineer role. My full-stack development experience would be a valuable asset.",
                        Availability = "Within 1 month"
                    },
                     new Application
                    {
                        CandidateId = 2,
                        JobPostingId = 4,
                        CVDocumentId = 1,
                        Status = ApplicationStatus.InterviewScheduled,
                        ApplicationDate = DateTime.Now.AddDays(-2),
                        CoverLetter = "I am very interested in the UX/UI Designer position and believe my portfolio demonstrates my capabilities in creating user-centered designs.",
                        Availability = "Immediately"
                    },
                    new Application
                    {
                        CandidateId = 3,
                        JobPostingId = 5,
                        CVDocumentId = 2,
                        Status = ApplicationStatus.Accepted,
                        ApplicationDate = DateTime.Now.AddDays(-50),
                        CoverLetter = "My expertise in machine learning and data analysis aligns perfectly with the Data Scientist role. I am excited about the opportunity to contribute to your data-driven initiatives.",
                        Availability = "Started last month"
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
                        Comment = "Great company to work for! Excellent culture and supportive management. Plenty of opportunities for growth.",
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
                        Comment = "Good work environment and culture. Interesting projects and a talented team. Work-life balance could be improved slightly.",
                        Position = "Software Developer",
                        Relationship = ReviewRelationship.CurrentEmployee,
                        ModerationStatus = ModerationStatus.Approved,
                        ReviewDate = DateTime.Now.AddDays(-15)
                    },
                    new Review
                    {
                        CandidateId = 2,
                        EmployerId = 6,
                        Rating = 3,
                        Comment = "Average experience. The company is large and has some bureaucratic processes. Pay is competitive, but career progression is slow.",
                        Position = "DevOps Engineer",
                        Relationship = ReviewRelationship.Interviewee,
                        ModerationStatus = ModerationStatus.Pending,
                        ReviewDate = DateTime.Now.AddDays(-5)
                    },
                    new Review
                    {
                        CandidateId = 3,
                        EmployerId = 4,
                        Rating = 5,
                        Comment = "Had a very positive interview experience. The recruitment team was professional and communicative. The role seemed challenging and rewarding.",
                        Position = "Senior Software Engineer",
                        Relationship = ReviewRelationship.Interviewee,
                        ModerationStatus = ModerationStatus.Approved,
                        ReviewDate = DateTime.Now.AddDays(-40)
                    },
                    new Review
                    {
                        CandidateId = 2,
                        EmployerId = 5,
                        Rating = 2,
                        Comment = "Not a great fit for me. The company culture was not as described, and I found the management style to be too micromanaging.",
                        Position = "Frontend Developer",
                        Relationship = ReviewRelationship.FormerEmployee,
                        ModerationStatus = ModerationStatus.Rejected,
                        ReviewDate = DateTime.Now.AddDays(-60)
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

        private static void SeedCandidateSkills(ITapplyDbContext dbContext)
        {
            if (!dbContext.CandidateSkills.Any())
            {
                var candidates = dbContext.Candidates.ToList();
                var skills = dbContext.Skills.ToList();
                var random = new Random();
                var candidateSkills = new List<CandidateSkill>();

                foreach (var candidate in candidates)
                {
                    var numberOfSkills = random.Next(5, 11);
                    var selectedSkills = skills.OrderBy(s => random.Next()).Take(numberOfSkills);

                    foreach (var skill in selectedSkills)
                    {
                        candidateSkills.Add(new CandidateSkill
                        {
                            CandidateId = candidate.Id,
                            SkillId = skill.Id,
                            Level = random.Next(1, 5)
                        });
                    }
                }

                dbContext.CandidateSkills.AddRange(candidateSkills);
                dbContext.SaveChanges();
            }
        }

        private static void SeedEmployerSkills(ITapplyDbContext dbContext)
        {
            if (!dbContext.EmployerSkills.Any())
            {
                var employers = dbContext.Employers.ToList();
                var skills = dbContext.Skills.ToList();
                var random = new Random();
                var employerSkills = new List<EmployerSkill>();

                foreach (var employer in employers)
                {
                    var numberOfSkills = random.Next(3, 8);
                    var selectedSkills = skills.OrderBy(s => random.Next()).Take(numberOfSkills);

                    foreach (var skill in selectedSkills)
                    {
                        employerSkills.Add(new EmployerSkill
                        {
                            EmployerId = employer.Id,
                            SkillId = skill.Id
                        });
                    }
                }

                dbContext.EmployerSkills.AddRange(employerSkills);
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