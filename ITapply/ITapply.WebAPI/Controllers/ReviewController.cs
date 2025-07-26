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
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.WebAPI.Controllers
{
    public class ReviewController : BaseCRUDController<ReviewResponse, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        private readonly IReviewService _reviewService;

        public ReviewController(IReviewService service) : base(service)
        {
            _reviewService = service;
        }

        [AllowAnonymous] 
        public override async Task<PagedResult<ReviewResponse>> Get([FromQuery] ReviewSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<ReviewResponse> GetById(int id)
        {
            return await base.GetById(id);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<ReviewResponse> Create([FromBody] ReviewInsertRequest request)
        {
            return await base.Create(request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<ReviewResponse> Update(int id, [FromBody] ReviewUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [Authorize(Roles = "Administrator,Candidate")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpPut("{id}/moderation/{status}")]
        [Authorize(Roles = "Administrator")]
        public async Task<ActionResult<ReviewResponse>> UpdateModerationStatus(int id, ModerationStatus status)
        {
            var result = await _reviewService.UpdateModerationStatusAsync(id, status);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpGet("candidate/{candidateId}")]
        [Authorize(Roles = "Administrator,Candidate")]
        public async Task<ActionResult<List<ReviewResponse>>> GetByCandidateId(int candidateId)
        {
            var result = await _reviewService.GetByCandidateIdAsync(candidateId);
            return Ok(result);
        }

        [HttpGet("employer/{employerId}")]
        [AllowAnonymous] 
        public async Task<ActionResult<List<ReviewResponse>>> GetByEmployerId(int employerId)
        {
            var result = await _reviewService.GetByEmployerIdAsync(employerId);
            return Ok(result);
        }

        [HttpGet("employer/{employerId}/rating")]
        [AllowAnonymous] 
        public async Task<ActionResult<double>> GetAverageRatingForEmployer(int employerId)
        {
            var result = await _reviewService.GetAverageRatingForEmployerAsync(employerId);
            return Ok(result);
        }
    }
} 