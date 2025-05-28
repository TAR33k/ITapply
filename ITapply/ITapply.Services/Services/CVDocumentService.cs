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
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Services.Services
{
    public class CVDocumentService 
        : BaseCRUDService<CVDocumentResponse, CVDocumentSearchObject, CVDocument, CVDocumentInsertRequest, CVDocumentUpdateRequest>, ICVDocumentService
    {
        public CVDocumentService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<CVDocument> AddInclude(IQueryable<CVDocument> query, CVDocumentSearchObject? search = null)
        {
            return query = query.Include(x => x.Candidate);
        }

        public override async Task<CVDocumentResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.CVDocuments
                .Include(a => a.Candidate)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
            {
                return null;
            }

            return MapToResponse(entity);
        }

        protected override IQueryable<CVDocument> ApplyFilter(IQueryable<CVDocument> query, CVDocumentSearchObject search)
        {
            if (search.CandidateId.HasValue)
                query = query.Where(x => x.CandidateId == search.CandidateId);

            if (!string.IsNullOrEmpty(search.FileName))
                query = query.Where(x => x.FileName.Contains(search.FileName));

            if (search.IsMain.HasValue)
                query = query.Where(x => x.IsMain == search.IsMain);

            if (search.UploadDateFrom.HasValue)
                query = query.Where(x => x.UploadDate >= search.UploadDateFrom);

            if (search.UploadDateTo.HasValue)
                query = query.Where(x => x.UploadDate <= search.UploadDateTo);

            return query;
        }

        protected override async Task BeforeInsert(CVDocument entity, CVDocumentInsertRequest request)
        {
            var candidate = await _context.Candidates.FindAsync(request.CandidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {request.CandidateId} not found");
            }

            var existingDocs = await _context.CVDocuments
                    .Where(x => x.CandidateId == request.CandidateId)
                    .ToListAsync();

            if (request.IsMain)
            {
                foreach (var doc in existingDocs)
                {
                    doc.IsMain = false;
                }
            }

            if (existingDocs.Count == 0)
                request.IsMain = true;

            entity.UploadDate = DateTime.Now;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(CVDocument entity, CVDocumentUpdateRequest request)
        {
            if (request.IsMain.HasValue && request.IsMain.Value && !entity.IsMain)
            {
                var candidateDocs = await _context.CVDocuments
                    .Where(x => x.CandidateId == entity.CandidateId)
                    .ToListAsync();

                foreach (var doc in candidateDocs)
                {
                    if (doc.Id != entity.Id)
                    {
                        doc.IsMain = false;
                    }
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        public async Task<List<CVDocumentResponse>> GetByCandidateIdAsync(int candidateId)
        {
            var candidate = await _context.Candidates.FindAsync(candidateId);
            if (candidate == null)
            {
                throw new UserException($"Candidate with ID {candidateId} not found");
            }

            var entities = await _context.CVDocuments
                .Include(x => x.Candidate)
                .Where(x => x.CandidateId == candidateId)
                .OrderByDescending(x => x.IsMain)
                .ThenByDescending(x => x.UploadDate)
                .ToListAsync();

            return entities.Select(MapToResponse).ToList();
        }

        public async Task<CVDocumentResponse> SetAsMainAsync(int id)
        {
            var document = await _context.CVDocuments.FindAsync(id);
            if (document == null)
                throw new UserException($"CVDocument with ID {id} not found");

            if (document.IsMain)
                return MapToResponse(document);

            var candidateDocs = await _context.CVDocuments
                .Where(x => x.CandidateId == document.CandidateId)
                .ToListAsync();

            foreach (var doc in candidateDocs)
            {
                doc.IsMain = false;
            }

            document.IsMain = true;
            await _context.SaveChangesAsync();

            return MapToResponse(document);
        }

        protected override async Task BeforeDelete(CVDocument entity)
        {
            if (entity.IsMain)
            {
                var otherDocs = await _context.CVDocuments
                    .Where(x => x.CandidateId == entity.CandidateId && x.Id != entity.Id)
                    .OrderByDescending(x => x.UploadDate)
                    .ToListAsync();
                
                if (otherDocs.Any())
                {
                    otherDocs.First().IsMain = true;
                }
            }

            var activeApplications = await _context.Applications
                .Where(a => a.CVDocumentId == entity.Id && 
                           (a.Status == EnumResponse.ApplicationStatus.Applied || 
                            a.Status == EnumResponse.ApplicationStatus.InConsideration || 
                            a.Status == EnumResponse.ApplicationStatus.InterviewScheduled))
                .CountAsync();
            
            if (activeApplications > 0)
            {
                throw new UserException("Cannot delete CV document that is being used in active job applications");
            }

            await base.BeforeDelete(entity);
        }

        protected override CVDocumentResponse MapToResponse(CVDocument entity)
        {
            var response = _mapper.Map<CVDocumentResponse>(entity);
            if (entity.Candidate != null)
            {
                response.CandidateName = $"{entity.Candidate.FirstName} {entity.Candidate.LastName}";
            }
            return response;
        }
    }
} 