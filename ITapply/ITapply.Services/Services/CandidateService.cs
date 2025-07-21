using ITapply.Models.Exceptions;
using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Database;
using ITapply.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace ITapply.Services.Services
{
    public class CandidateService
        : BaseCRUDService<CandidateResponse, CandidateSearchObject, Candidate, CandidateInsertRequest, CandidateUpdateRequest>, ICandidateService
    {
        public CandidateService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Candidate> AddInclude(IQueryable<Candidate> query, CandidateSearchObject? search = null)
        {
            return query = query.Include(c => c.User).Include(c => c.Location);
        }

        public override async Task<CandidateResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Candidates
                .Include(a => a.User)
                .Include(a => a.Location)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<Candidate> ApplyFilter(IQueryable<Candidate> query, CandidateSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.FirstName))
            {
                query = query.Where(c => c.FirstName.Contains(search.FirstName));
            }

            if (!string.IsNullOrEmpty(search.LastName))
            {
                query = query.Where(c => c.LastName.Contains(search.LastName));
            }

            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(c => c.Title.Contains(search.Title));
            }

            if (search.LocationId.HasValue)
            {
                query = query.Where(c => c.LocationId == search.LocationId);
            }

            if (search.MinExperienceYears.HasValue)
            {
                query = query.Where(c => c.ExperienceYears >= search.MinExperienceYears.Value);
            }

            if (search.MaxExperienceYears.HasValue)
            {
                query = query.Where(c => c.ExperienceYears <= search.MaxExperienceYears.Value);
            }

            if (search.ExperienceLevel.HasValue)
            {
                query = query.Where(c => c.ExperienceLevel == search.ExperienceLevel.Value);
            }

            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(c => c.User.Email.Contains(search.Email));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(c => c.User.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Candidate entity, CandidateInsertRequest request)
        {
            var user = await _context.Users.FindAsync(request.UserId);
            if (user == null)
            {
                throw new UserException($"User with ID {request.UserId} not found");
            }

            var existingCandidate = await _context.Candidates
                .FirstOrDefaultAsync(c => c.User.Id == request.UserId);
            if (existingCandidate != null)
            {
                throw new UserException($"User with ID {request.UserId} is already assigned to another candidate");
            }
            
            var userHasCandidateRole = await _context.UserRoles
                .Include(ur => ur.Role)
                .AnyAsync(ur => ur.UserId == request.UserId && ur.Role.Name == "Candidate");
            
            if (!userHasCandidateRole)
            {
                throw new UserException("User must have the Candidate role to be assigned to a candidate profile");
            }

            if (request.LocationId.HasValue)
            {
                var location = await _context.Locations.FindAsync(request.LocationId.Value);
                if (location == null)
                {
                    throw new UserException($"Location with ID {request.LocationId.Value} not found");
                }
            }

            entity.User = user;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Candidate entity, CandidateUpdateRequest request)
        {
            if (request.LocationId.HasValue)
            {
                var location = await _context.Locations.FindAsync(request.LocationId.Value);
                if (location == null)
                {
                    throw new UserException($"Location with ID {request.LocationId.Value} not found");
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeDelete(Candidate entity)
        {
            var applications = await _context.Applications.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var app in applications)
            {
                _context.Applications.Remove(app);

                await _context.SaveChangesAsync();
            }

            var candidateSkills = await _context.CandidateSkills.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var skill in candidateSkills)
            {
                _context.CandidateSkills.Remove(skill);

                await _context.SaveChangesAsync();
            }

            var cvDocuments = await _context.CVDocuments.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var cv in cvDocuments)
            {
                _context.CVDocuments.Remove(cv);

                await _context.SaveChangesAsync();
            }

            var educations = await _context.Educations.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var ed in educations)
            {
                _context.Educations.Remove(ed);

                await _context.SaveChangesAsync();
            }

            var preferences = await _context.Preferences.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var pref in preferences)
            {
                _context.Preferences.Remove(pref);

                await _context.SaveChangesAsync();
            }

            var reviews = await _context.Reviews.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var rev in reviews)
            {
                _context.Reviews.Remove(rev);

                await _context.SaveChangesAsync();
            }

            var works = await _context.WorkExperiences.Where(x => x.CandidateId == entity.Id).ToListAsync();

            foreach (var w in works)
            {
                _context.WorkExperiences.Remove(w);

                await _context.SaveChangesAsync();
            }

            var roles = await _context.UserRoles.Where(x => x.UserId == entity.Id).ToListAsync();

            foreach (var r in roles)
            {
                _context.UserRoles.Remove(r);

                await _context.SaveChangesAsync();
            }

            var user = await _context.Users.Where(x => x.Id == entity.Id).ToListAsync();

            foreach (var u in user)
            {
                _context.Users.Remove(u);

                await _context.SaveChangesAsync();
            }

            await base.BeforeDelete(entity);
        }

        protected override CandidateResponse MapToResponse(Candidate entity)
        {
            var response = _mapper.Map<CandidateResponse>(entity);

            if (entity.User != null)
            {
                response.Email = entity.User.Email;
                response.RegistrationDate = entity.User.RegistrationDate;
                response.IsActive = entity.User.IsActive;
            }

            if (entity.Location != null)
            {
                response.LocationName = $"{entity.Location.City}, {entity.Location.Country}";
            }

            return response;
        }
    }
} 