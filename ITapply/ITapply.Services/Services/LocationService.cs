﻿using ITapply.Models.Exceptions;
using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Database;
using ITapply.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Services.Services
{
    public class LocationService 
        : BaseCRUDService<LocationResponse, LocationSearchObject, Location, LocationInsertRequest, LocationUpdateRequest>, ILocationService
    {
        public LocationService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Location> ApplyFilter(IQueryable<Location> query, LocationSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Country))
            {
                query = query.Where(l => l.Country.Contains(search.Country));
            }
            if (!string.IsNullOrEmpty(search.City))
            {
                query = query.Where(l => l.City.Contains(search.City));
            }

            return query;
        }

        protected override async Task BeforeInsert(Location entity, LocationInsertRequest request)
        {
            var existingLocation = await _context.Locations
                .FirstOrDefaultAsync(l => 
                    l.Country.ToLower() == request.Country.ToLower() && 
                    l.City.ToLower() == request.City.ToLower());
            
            if (existingLocation != null)
            {
                throw new UserException($"Location '{request.City}, {request.Country}' already exists");
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Location entity, LocationUpdateRequest request)
        {
            var existingLocation = await _context.Locations
                .FirstOrDefaultAsync(l => 
                    l.Id != entity.Id && 
                    l.Country.ToLower() == request.Country.ToLower() && 
                    l.City.ToLower() == request.City.ToLower());
            
            if (existingLocation != null)
            {
                throw new UserException($"Location '{request.City}, {request.Country}' already exists");
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeDelete(Location entity)
        {
            var isUsedByCandidates = await _context.Candidates.AnyAsync(c => c.LocationId == entity.Id);
            if (isUsedByCandidates)
            {
                throw new UserException("This location cannot be deleted because it is assigned to one or more candidates. Reassign them before deleting.");
            }

            var isUsedByEmployers = await _context.Employers.AnyAsync(e => e.LocationId == entity.Id);
            if (isUsedByEmployers)
            {
                throw new UserException("This location cannot be deleted because it is assigned to one or more employers. Reassign them before deleting.");
            }

            var isUsedByJobPostings = await _context.JobPostings.AnyAsync(jp => jp.LocationId == entity.Id);
            if (isUsedByJobPostings)
            {
                throw new UserException("This location cannot be deleted because it is used in one or more job postings. Reassign them before deleting.");
            }

            var isUsedByPreferences = await _context.Preferences.AnyAsync(jp => jp.LocationId == entity.Id);
            if (isUsedByPreferences)
            {
                throw new UserException("This location cannot be deleted because it is used in one or more preferences. Reassign them before deleting.");
            }

            await base.BeforeDelete(entity);
        }
    }
}
