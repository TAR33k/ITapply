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
    public interface IEmployerService : ICRUDService<EmployerResponse, EmployerSearchObject, EmployerInsertRequest, EmployerUpdateRequest>
    {
        Task<EmployerResponse> UpdateVerificationStatusAsync(int id, VerificationStatus status);
    }
} 