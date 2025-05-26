using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Services.Database
{
    public class ITapplyDbContext : DbContext
    {
        public ITapplyDbContext(DbContextOptions<ITapplyDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Candidate> Candidates { get; set; }
        public DbSet<Employer> Employers { get; set; }
        public DbSet<Application> Applications { get; set; }
        public DbSet<CandidateSkill> CandidateSkills { get; set; }
        public DbSet<CVDocument> CVDocuments { get; set; }
        public DbSet<Education> EducationEntries { get; set; }
        public DbSet<EmployerSkill> EmployerSkills { get; set; }
        public DbSet<JobPosting> JobPostings { get; set; }
        public DbSet<JobPostingSkill> JobPostingSkills { get; set; }
        public DbSet<Location> Locations { get; set; }
        public DbSet<Preferences> Preferences { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<Skill> Skills { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<WorkExperience> WorkExperiences { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ======== Enum conversions to strings for better readability ========
            modelBuilder.Entity<Application>()
                .Property(a => a.Status)
                .HasConversion<string>();

            modelBuilder.Entity<Candidate>()
                .Property(c => c.ExperienceLevel)
                .HasConversion<string>();

            modelBuilder.Entity<Employer>()
                .Property(e => e.VerificationStatus)
                .HasConversion<string>();

            modelBuilder.Entity<JobPosting>()
                .Property(j => j.EmploymentType)
                .HasConversion<string>();

            modelBuilder.Entity<JobPosting>()
                .Property(j => j.ExperienceLevel)
                .HasConversion<string>();

            modelBuilder.Entity<JobPosting>()
                .Property(j => j.Remote)
                .HasConversion<string>();

            modelBuilder.Entity<JobPosting>()
                .Property(j => j.Status)
                .HasConversion<string>();

            modelBuilder.Entity<Preferences>()
                .Property(p => p.EmploymentType)
                .HasConversion<string>();

            modelBuilder.Entity<Preferences>()
                .Property(p => p.Remote)
                .HasConversion<string>();

            modelBuilder.Entity<Review>()
                .Property(r => r.Relationship)
                .HasConversion<string>();

            modelBuilder.Entity<Review>()
                .Property(r => r.ModerationStatus)
                .HasConversion<string>();

            // ======== File size limitations ========
            modelBuilder.Entity<CVDocument>()
                .Property(c => c.FileContent)
                .HasMaxLength(5242880); // 5MB max size

            modelBuilder.Entity<Employer>()
                .Property(e => e.Logo)
                .HasMaxLength(5242880); // 5MB max size

            // ======== User entity configuration ========
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasIndex(u => u.Email).IsUnique();
                
                // User - Candidate relationship (1:1)
                entity.HasOne(u => u.Candidate)
                    .WithOne(c => c.User)
                    .HasForeignKey<Candidate>(c => c.Id)
                    .OnDelete(DeleteBehavior.Cascade)
                    .IsRequired(false);
                
                // User - Employer relationship (1:1)
                entity.HasOne(u => u.Employer)
                    .WithOne(e => e.User)
                    .HasForeignKey<Employer>(e => e.Id)
                    .OnDelete(DeleteBehavior.Cascade)
                    .IsRequired(false);

                // User - UserRole relationship (1:N)
                entity.HasMany(u => u.UserRoles)
                    .WithOne(ur => ur.User)
                    .HasForeignKey(ur => ur.UserId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ======== Role entity configuration ========
            modelBuilder.Entity<Role>(entity =>
            {
                entity.HasIndex(r => r.Name).IsUnique();
                
                // Role - UserRole relationship (1:N)
                entity.HasMany(r => r.UserRoles)
                    .WithOne(ur => ur.Role)
                    .HasForeignKey(ur => ur.RoleId)
                    .OnDelete(DeleteBehavior.NoAction);
            });

            // ======== Candidate entity configuration ========
            modelBuilder.Entity<Candidate>(entity =>
            {
                entity.HasIndex(c => c.LocationId);
                entity.HasIndex(c => new { c.FirstName, c.LastName });
                entity.HasIndex(c => c.ExperienceLevel);
                
                // Candidate - Preferences relationship (1:1)
                entity.HasOne(c => c.Preferences)
                    .WithOne(p => p.Candidate)
                    .HasForeignKey<Preferences>(p => p.CandidateId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                // Candidate - Location relationship (N:1)
                entity.HasOne(c => c.Location)
                    .WithMany(l => l.Candidates)
                    .HasForeignKey(c => c.LocationId)
                    .OnDelete(DeleteBehavior.NoAction)
                    .IsRequired(false);
                
                // Candidate - WorkExperience relationship (1:N)
                entity.HasMany(c => c.WorkExperiences)
                    .WithOne(w => w.Candidate)
                    .HasForeignKey(w => w.CandidateId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                // Candidate - Education relationship (1:N)
                entity.HasMany(c => c.EducationEntries)
                    .WithOne(e => e.Candidate)
                    .HasForeignKey(e => e.CandidateId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                // Candidate - CandidateSkill relationship (1:N)
                entity.HasMany(c => c.CandidateSkills)
                    .WithOne(cs => cs.Candidate)
                    .HasForeignKey(cs => cs.CandidateId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                // Candidate - CVDocument relationship (1:N)
                entity.HasMany(c => c.CVDocuments)
                    .WithOne(cv => cv.Candidate)
                    .HasForeignKey(cv => cv.CandidateId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                // Candidate - Application relationship (1:N)
                entity.HasMany(c => c.Applications)
                    .WithOne(a => a.Candidate)
                    .HasForeignKey(a => a.CandidateId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                // Candidate - Review relationship (1:N)
                entity.HasMany(c => c.Reviews)
                    .WithOne(r => r.Candidate)
                    .HasForeignKey(r => r.CandidateId)
                    .OnDelete(DeleteBehavior.NoAction);
            });

            // ======== Employer entity configuration ========
            modelBuilder.Entity<Employer>(entity =>
            {
                entity.HasIndex(e => e.CompanyName);
                entity.HasIndex(e => e.VerificationStatus);
                entity.HasIndex(e => e.Industry);
                entity.HasIndex(e => e.LocationId);
                
                // Employer - Location relationship (N:1)
                entity.HasOne(e => e.Location)
                    .WithMany(l => l.Employers)
                    .HasForeignKey(e => e.LocationId)
                    .OnDelete(DeleteBehavior.NoAction)
                    .IsRequired(false);
                
                // Employer - JobPosting relationship (1:N)
                entity.HasMany(e => e.JobPostings)
                    .WithOne(j => j.Employer)
                    .HasForeignKey(j => j.EmployerId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                // Employer - Review relationship (1:N)
                entity.HasMany(e => e.ReceivedReviews)
                    .WithOne(r => r.Employer)
                    .HasForeignKey(r => r.EmployerId)
                    .OnDelete(DeleteBehavior.NoAction);
                
                // Employer - EmployerSkill relationship (1:N)
                entity.HasMany(e => e.EmployerSkills)
                    .WithOne(es => es.Employer)
                    .HasForeignKey(es => es.EmployerId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            // ======== JobPosting entity configuration ========
            modelBuilder.Entity<JobPosting>(entity =>
            {
                entity.HasIndex(j => j.Status);
                entity.HasIndex(j => j.EmploymentType);
                entity.HasIndex(j => j.PostedDate);
                entity.HasIndex(j => j.ExperienceLevel);
                entity.HasIndex(j => j.LocationId);
                entity.HasIndex(j => j.ApplicationDeadline);
                entity.HasIndex(j => j.Title);
                entity.HasIndex(j => j.Remote);
                entity.HasIndex(j => new { j.MinSalary, j.MaxSalary });
                
                // JobPosting - Location relationship (N:1)
                entity.HasOne(j => j.Location)
                    .WithMany(l => l.JobPostings)
                    .HasForeignKey(j => j.LocationId)
                    .OnDelete(DeleteBehavior.NoAction)
                    .IsRequired(false);
                
                // JobPosting - JobPostingSkill relationship (1:N)
                entity.HasMany(j => j.JobPostingSkills)
                    .WithOne(jps => jps.JobPosting)
                    .HasForeignKey(jps => jps.JobPostingId)
                    .OnDelete(DeleteBehavior.Cascade);
                
                // JobPosting - Application relationship (1:N)
                entity.HasMany(j => j.Applications)
                    .WithOne(a => a.JobPosting)
                    .HasForeignKey(a => a.JobPostingId)
                    .OnDelete(DeleteBehavior.NoAction);
            });

            // ======== Application entity configuration ========
            modelBuilder.Entity<Application>(entity =>
            {
                entity.HasIndex(a => a.Status);
                entity.HasIndex(a => a.ApplicationDate);
                
                // Ensure each candidate can apply only once to the same job posting
                entity.HasIndex(a => new { a.CandidateId, a.JobPostingId }).IsUnique();
                
                // Application - Candidate relationship (N:1)
                entity.HasOne(a => a.Candidate)
                    .WithMany(c => c.Applications)
                    .HasForeignKey(a => a.CandidateId)
                    .OnDelete(DeleteBehavior.NoAction);

                // Application - JobPosting relationship (N:1)
                entity.HasOne(a => a.JobPosting)
                    .WithMany(j => j.Applications)
                    .HasForeignKey(a => a.JobPostingId)
                    .OnDelete(DeleteBehavior.NoAction);
                
                // Application - CVDocument relationship (N:1)
                entity.HasOne(a => a.CVDocument)
                    .WithMany()
                    .HasForeignKey(a => a.CVDocumentId)
                    .OnDelete(DeleteBehavior.NoAction);
            });

            // ======== Skill entity configuration ========
            modelBuilder.Entity<Skill>(entity =>
            {
                entity.HasIndex(s => s.Name).IsUnique();
                
                // Skill - CandidateSkill relationship (1:N)
                entity.HasMany(s => s.CandidateSkills)
                    .WithOne(cs => cs.Skill)
                    .HasForeignKey(cs => cs.SkillId)
                    .OnDelete(DeleteBehavior.NoAction);
                
                // Skill - JobPostingSkill relationship (1:N)
                entity.HasMany(s => s.JobPostingSkills)
                    .WithOne(jps => jps.Skill)
                    .HasForeignKey(jps => jps.SkillId)
                    .OnDelete(DeleteBehavior.NoAction);
                
                // Skill - EmployerSkill relationship (1:N)
                entity.HasMany(s => s.EmployerSkills)
                    .WithOne(es => es.Skill)
                    .HasForeignKey(es => es.SkillId)
                    .OnDelete(DeleteBehavior.NoAction);
            });

            // ======== CandidateSkill entity configuration ========
            modelBuilder.Entity<CandidateSkill>(entity =>
            {
                // Ensure each candidate has each skill only once
                entity.HasIndex(cs => new { cs.CandidateId, cs.SkillId }).IsUnique();
            });

            // ======== JobPostingSkill entity configuration ========
            modelBuilder.Entity<JobPostingSkill>(entity =>
            {
                // Ensure each job posting has each skill only once
                entity.HasIndex(jps => new { jps.JobPostingId, jps.SkillId }).IsUnique();
            });

            // ======== EmployerSkill entity configuration ========
            modelBuilder.Entity<EmployerSkill>(entity =>
            {
                // Ensure each employer has each skill only once
                entity.HasIndex(es => new { es.EmployerId, es.SkillId }).IsUnique();
            });

            // ======== CVDocument entity configuration ========
            modelBuilder.Entity<CVDocument>(entity =>
            {
                entity.HasIndex(cv => cv.UploadDate);
                entity.HasIndex(cv => cv.IsMain);
                entity.HasIndex(cv => new { cv.CandidateId, cv.IsMain });
            });

            // ======== Location entity configuration ========
            modelBuilder.Entity<Location>(entity =>
            {
                // Ensure each city-country combination is unique
                entity.HasIndex(l => new { l.City, l.Country }).IsUnique();
            });

            // ======== Review entity configuration ========
            modelBuilder.Entity<Review>(entity =>
            {
                // Prevent multiple reviews by same candidate for same employer
                entity.HasIndex(r => new { r.CandidateId, r.EmployerId }).IsUnique();
                
                entity.HasIndex(r => r.ModerationStatus);
                entity.HasIndex(r => r.ReviewDate);
                entity.HasIndex(r => r.Rating);

                // Review - Candidate relationship (N:1)
                entity.HasOne(r => r.Candidate)
                    .WithMany(c => c.Reviews)
                    .HasForeignKey(r => r.CandidateId)
                    .OnDelete(DeleteBehavior.NoAction);

                // Review - Employer relationship (N:1)
                entity.HasOne(r => r.Employer)
                    .WithMany(e => e.ReceivedReviews)
                    .HasForeignKey(r => r.EmployerId)
                    .OnDelete(DeleteBehavior.NoAction);
            });

            // ======== Preferences entity configuration ========
            modelBuilder.Entity<Preferences>(entity =>
            {
                entity.HasIndex(p => p.LocationId);
                entity.HasIndex(p => p.EmploymentType);
                entity.HasIndex(p => p.Remote);
                
                // Preferences - Location relationship (N:1)
                entity.HasOne(p => p.Location)
                    .WithMany()
                    .HasForeignKey(p => p.LocationId)
                    .OnDelete(DeleteBehavior.NoAction)
                    .IsRequired(false);
            });

            // ======== WorkExperience entity configuration ========
            modelBuilder.Entity<WorkExperience>(entity =>
            {
                entity.HasIndex(w => w.StartDate);
                entity.HasIndex(w => w.EndDate);
                entity.HasIndex(w => w.CompanyName);
                entity.HasIndex(w => w.Position);
            });

            // ======== Education entity configuration ========
            modelBuilder.Entity<Education>(entity =>
            {
                entity.HasIndex(e => e.StartDate);
                entity.HasIndex(e => e.EndDate);
                entity.HasIndex(e => e.Institution);
                entity.HasIndex(e => e.Degree);
                entity.HasIndex(e => e.FieldOfStudy);
            });
        }
    }
}
