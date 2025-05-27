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
using static ITapply.Models.Responses.EnumResponse;

namespace ITapply.WebAPI.Controllers
{
    public class ReviewController : BaseCRUDController<ReviewResponse, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        private readonly IReviewService _service;

        public ReviewController(IReviewService service) : base(service)
        {
            _service = service;
        }

        [HttpPut("{id}/moderation/{status}")]
        public async Task<ActionResult<ReviewResponse>> UpdateModerationStatus(int id, ModerationStatus status)
        {
            return await _service.UpdateModerationStatusAsync(id, status);
        }

        [HttpGet("candidate/{candidateId}")]
        public async Task<ActionResult<List<ReviewResponse>>> GetByCandidateId(int candidateId)
        {
            return await _service.GetByCandidateIdAsync(candidateId);
        }

        [HttpGet("employer/{employerId}")]
        public async Task<ActionResult<List<ReviewResponse>>> GetByEmployerId(int employerId)
        {
            return await _service.GetByEmployerIdAsync(employerId);
        }

        [HttpGet("employer/{employerId}/rating")]
        public async Task<ActionResult<double>> GetAverageRatingForEmployer(int employerId)
        {
            return await _service.GetAverageRatingForEmployerAsync(employerId);
        }
    }
} 