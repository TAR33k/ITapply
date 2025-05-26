using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.Services.Interfaces
{
    public interface IJobPostingService : ICRUDService<JobPostingResponse, JobPostingSearchObject, JobPostingInsertRequest, JobPostingUpdateRequest>
    {
        Task<List<JobPostingResponse>> GetRecommendedJobsForCandidateAsync(int candidateId, int count = 5);
        Task<JobPostingResponse> UpdateStatusAsync(int id, JobPostingStatus status);
    }
} 