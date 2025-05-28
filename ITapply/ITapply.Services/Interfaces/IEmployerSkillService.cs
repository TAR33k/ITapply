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
    public interface IEmployerSkillService : ICRUDService<EmployerSkillResponse, EmployerSkillSearchObject, EmployerSkillInsertRequest, EmployerSkillUpdateRequest>
    {
    }
} 