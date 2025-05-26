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
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Services.Services
{
    public class ApplicationService
        : BaseCRUDService<ApplicationResponse, ApplicationSearchObject, Application, ApplicationInsertRequest, ApplicationUpdateRequest>, IApplicationService
    {
        public ApplicationService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<ApplicationResponse> UpdateStatusAsync(int id, ApplicationStatus status)
        {
            var entity = await _context.Applications.FindAsync(id);
            if (entity == null)
            {
                throw new Exception($"Application with ID {id} not found");
            }

            entity.Status = status;
            await _context.SaveChangesAsync();

            return _mapper.Map<ApplicationResponse>(entity);
        }

        public async Task<bool> HasAppliedAsync(int candidateId, int jobPostingId)
        {
            return await _context.Applications
                .AnyAsync(a => a.CandidateId == candidateId && a.JobPostingId == jobPostingId);
        }

        public override async Task<PagedResult<ApplicationResponse>> GetAsync(ApplicationSearchObject search)
        {
            var result = await base.GetAsync(search);
            return result;
        }

        public override async Task<ApplicationResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Applications
                .Include(a => a.Candidate)
                    .ThenInclude(c => c.User)
                .Include(a => a.JobPosting)
                    .ThenInclude(jp => jp.Employer)
                .Include(a => a.CVDocument)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return _mapper.Map<ApplicationResponse>(entity);
        }

        protected override IQueryable<Application> ApplyFilter(IQueryable<Application> query, ApplicationSearchObject search)
        {
            query = query
                .Include(a => a.Candidate)
                    .ThenInclude(c => c.User)
                .Include(a => a.JobPosting)
                    .ThenInclude(jp => jp.Employer)
                .Include(a => a.CVDocument);

            if (search.CandidateId.HasValue)
            {
                query = query.Where(a => a.CandidateId == search.CandidateId);
            }

            if (search.JobPostingId.HasValue)
            {
                query = query.Where(a => a.JobPostingId == search.JobPostingId);
            }

            if (search.EmployerId.HasValue)
            {
                query = query.Where(a => a.JobPosting.EmployerId == search.EmployerId);
            }

            if (!string.IsNullOrEmpty(search.JobTitle))
            {
                query = query.Where(a => a.JobPosting.Title.Contains(search.JobTitle));
            }

            if (!string.IsNullOrEmpty(search.CandidateName))
            {
                query = query.Where(a => 
                    a.Candidate.FirstName.Contains(search.CandidateName) || 
                    a.Candidate.LastName.Contains(search.CandidateName));
            }

            if (search.Status.HasValue)
            {
                query = query.Where(a => a.Status == search.Status);
            }

            if (search.ApplicationDateFrom.HasValue)
            {
                query = query.Where(a => a.ApplicationDate >= search.ApplicationDateFrom);
            }

            if (search.ApplicationDateTo.HasValue)
            {
                query = query.Where(a => a.ApplicationDate <= search.ApplicationDateTo);
            }

            return query;
        }
        protected override async Task BeforeInsert(Application entity, ApplicationInsertRequest request)
        {
            var candidate = await _context.Candidates.FindAsync(request.CandidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {request.CandidateId} not found");
            }

            var jobPosting = await _context.JobPostings.FindAsync(request.JobPostingId);
            if (jobPosting == null)
            {
                throw new UserException($"Job posting with ID {request.JobPostingId} not found");
            }
            if (jobPosting.Status != JobPostingStatus.Active || jobPosting.ApplicationDeadline < DateTime.Now)
            {
                throw new UserException("This job posting is no longer accepting applications");
            }

            var cvDocument = await _context.CVDocuments
                .FirstOrDefaultAsync(cv => cv.Id == request.CVDocumentId && cv.CandidateId == request.CandidateId);
            if (cvDocument == null)
            {
                throw new UserException($"CV document with ID {request.CVDocumentId} not found or does not belong to the candidate");
            }

            var hasApplied = await HasAppliedAsync(request.CandidateId, request.JobPostingId);
            if (hasApplied)
            {
                throw new UserException("You have already applied to this job posting");
            }

            entity.ApplicationDate = DateTime.UtcNow;
            entity.Status = ApplicationStatus.Applied;

            await base.BeforeInsert(entity, request);
        }
    }
} 