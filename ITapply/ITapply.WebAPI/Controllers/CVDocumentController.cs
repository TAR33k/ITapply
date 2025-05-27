using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.WebAPI.Controllers
{
    public class CVDocumentController : BaseCRUDController<CVDocumentResponse, CVDocumentSearchObject, CVDocumentInsertRequest, CVDocumentUpdateRequest>
    {
        private readonly ICVDocumentService _service;

        public CVDocumentController(ICVDocumentService service) : base(service)
        {
            _service = service;
        }

        [HttpPut("{id}/main")]
        public async Task<ActionResult<CVDocumentResponse>> SetAsMain(int id)
        {
            return await _service.SetAsMainAsync(id);
        }

        [HttpGet("candidate/{candidateId}")]
        public async Task<ActionResult<List<CVDocumentResponse>>> GetByCandidateId(int candidateId)
        {
            return await _service.GetByCandidateIdAsync(candidateId);
        }
    }
} 