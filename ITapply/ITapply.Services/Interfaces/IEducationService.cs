using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Services.Interfaces
{
    public interface IEducationService : ICRUDService<EducationResponse, EducationSearchObject, EducationInsertRequest, EducationUpdateRequest>
    {
        Task<List<EducationResponse>> GetByCandidateIdAsync(int candidateId);
        Task<string> GetHighestDegreeAsync(int candidateId);
    }
} 