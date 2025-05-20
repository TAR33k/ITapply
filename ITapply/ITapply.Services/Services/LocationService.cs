using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Database;
using ITapply.Services.Interfaces;
using MapsterMapper;
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
    }
}
