using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ITapply.WebAPI.Controllers
{
    public class CandidateController : BaseCRUDController<CandidateResponse, CandidateSearchObject, CandidateInsertRequest, CandidateUpdateRequest>
    {
        public CandidateController(ICandidateService candidateService) : base(candidateService)
        {
        }
    }
} 