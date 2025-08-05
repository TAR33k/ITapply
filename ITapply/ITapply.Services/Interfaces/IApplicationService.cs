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
    public interface IApplicationService : ICRUDService<ApplicationResponse, ApplicationSearchObject, ApplicationInsertRequest, ApplicationUpdateRequest>
    {
        Task<ApplicationResponse> UpdateStatusAsync(int id, ApplicationStatus status);
        Task<ApplicationResponse> ToggleNotificationsAsync(int id);
        Task<bool> HasAppliedAsync(int candidateId, int jobPostingId);
    }
} 