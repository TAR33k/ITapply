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
    public interface IReviewService : ICRUDService<ReviewResponse, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        Task<ReviewResponse> UpdateModerationStatusAsync(int id, ModerationStatus status);
        Task<List<ReviewResponse>> GetByCandidateIdAsync(int candidateId);
        Task<List<ReviewResponse>> GetByEmployerIdAsync(int employerId);
        Task<double> GetAverageRatingForEmployerAsync(int employerId);
    }
} 