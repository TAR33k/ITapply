using ITapply.Models.Exceptions;
using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Database;
using ITapply.Services.Interfaces;
using Mapster;
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
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        public ReviewService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Review> AddInclude(IQueryable<Review> query, ReviewSearchObject? search = null)
        {
            return query = query.Include(x => x.Candidate).Include(x => x.Employer);
        }

        public override async Task<ReviewResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Reviews
                .Include(jp => jp.Candidate)
                .Include(jp => jp.Employer)
                .FirstOrDefaultAsync(jp => jp.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            if (search.CandidateId.HasValue)
                query = query.Where(x => x.CandidateId == search.CandidateId);

            if (search.EmployerId.HasValue)
                query = query.Where(x => x.EmployerId == search.EmployerId);

            if (!string.IsNullOrEmpty(search.CandidateName))
                query = query.Where(x => 
                    (x.Candidate.FirstName + " " + x.Candidate.LastName).Contains(search.CandidateName));

            if (!string.IsNullOrEmpty(search.CompanyName))
                query = query.Where(x => x.Employer.CompanyName.Contains(search.CompanyName));

            if (search.MinRating.HasValue)
                query = query.Where(x => x.Rating >= search.MinRating);

            if (search.MaxRating.HasValue)
                query = query.Where(x => x.Rating <= search.MaxRating);

            if (search.Relationship.HasValue)
                query = query.Where(x => x.Relationship == search.Relationship);

            if (search.ModerationStatus.HasValue)
                query = query.Where(x => x.ModerationStatus == search.ModerationStatus);

            if (search.ReviewDateFrom.HasValue)
                query = query.Where(x => x.ReviewDate >= search.ReviewDateFrom);

            if (search.ReviewDateTo.HasValue)
                query = query.Where(x => x.ReviewDate <= search.ReviewDateTo);

            return query;
        }

        public async Task<double> GetAverageRatingForEmployerAsync(int employerId)
        {
            var employer = await _context.Employers.FindAsync(employerId);
            if (employer == null)
            {
                throw new UserException($"Employer with ID {employerId} not found");
            }

            var reviews = await _context.Reviews
                .Where(x => x.EmployerId == employerId && x.ModerationStatus == ModerationStatus.Approved)
                .ToListAsync();

            if (!reviews.Any())
                return 0;

            return reviews.Average(x => x.Rating);
        }

        public async Task<List<ReviewResponse>> GetByCandidateIdAsync(int candidateId)
        {
            var candidate = await _context.Candidates.FindAsync(candidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {candidateId} not found");
            }

            var entities = await _context.Reviews
                .Include(x => x.Candidate)
                .Include(x => x.Employer)
                .Where(x => x.CandidateId == candidateId)
                .OrderByDescending(x => x.ReviewDate)
                .ToListAsync();

            return entities.Select(MapToResponse).ToList();
        }

        public async Task<List<ReviewResponse>> GetByEmployerIdAsync(int employerId)
        {
            var employer = await _context.Employers.FindAsync(employerId);
            if (employer == null)
            {
                throw new UserException($"Employer with ID {employerId} not found");
            }

            var entities = await _context.Reviews
                .Include(x => x.Candidate)
                .Include(x => x.Employer)
                .Where(x => x.EmployerId == employerId)
                .OrderByDescending(x => x.ReviewDate)
                .ToListAsync();

            return entities.Select(MapToResponse).ToList();
        }

        public async Task<ReviewResponse> UpdateModerationStatusAsync(int id, ModerationStatus status)
        {
            var entity = await _context.Reviews.FindAsync(id);
            if (entity == null)
                throw new UserException($"Review with ID {id} not found");

            entity.ModerationStatus = status;
            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(Review entity, ReviewInsertRequest request)
        {
            var candidate = await _context.Candidates.FindAsync(request.CandidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {request.CandidateId} not found");
            }

            var employer = await _context.Employers.FindAsync(request.EmployerId);
            if (employer == null)
            {
                throw new UserException($"Employer with ID {request.EmployerId} not found");
            }

            entity.ReviewDate = DateTime.Now;
            entity.ModerationStatus = ModerationStatus.Pending;

            await base.BeforeInsert(entity, request);
        }

        protected override ReviewResponse MapToResponse(Review entity)
        {
            var response = _mapper.Map<ReviewResponse>(entity);

            if (entity.Candidate != null)
            {
                response.CandidateName = $"{entity.Candidate.FirstName} {entity.Candidate.LastName}";
            }

            if (entity.Employer != null)
            {
                response.CompanyName = entity.Employer.CompanyName;
            }
            
            return response;
        }
    }
} 