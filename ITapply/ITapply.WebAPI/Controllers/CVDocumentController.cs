using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
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
        private readonly ICVDocumentService _cvDocumentService;

        public CVDocumentController(ICVDocumentService service) : base(service)
        {
            _cvDocumentService = service;
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<PagedResult<CVDocumentResponse>> Get([FromQuery] CVDocumentSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [Authorize(Roles = "Administrator,Candidate,Employer")] 
        public override async Task<CVDocumentResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<CVDocumentResponse> Create([FromBody] CVDocumentInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<CVDocumentResponse> Update(int id, [FromBody] CVDocumentUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpPut("{id}/main")]
        [Authorize(Roles = "Administrator,Candidate")]
        public async Task<ActionResult<CVDocumentResponse>> SetAsMain(int id)
        {
            var result = await _cvDocumentService.SetAsMainAsync(id);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpGet("candidate/{candidateId}")]
        [Authorize(Roles = "Administrator,Candidate,Employer")] 
        public async Task<ActionResult<List<CVDocumentResponse>>> GetByCandidateId(int candidateId)
        {
            var result = await _cvDocumentService.GetByCandidateIdAsync(candidateId);
            return Ok(result);
        }
    }
} 