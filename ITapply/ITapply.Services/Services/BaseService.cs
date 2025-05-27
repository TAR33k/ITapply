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
    public abstract class BaseService<T, TSearch, TEntity> 
        : IService<T, TSearch> where T : class where TSearch : BaseSearchObject where TEntity : class
    {
        protected readonly ITapplyDbContext _context;
        protected readonly IMapper _mapper;

        public BaseService(ITapplyDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<PagedResult<T>> GetAsync(TSearch search)
        {
            var query = _context.Set<TEntity>().AsQueryable();

            query = ApplyFilter(query, search);

            query = AddInclude(query, search);

            int? totalCount = null;

            if (search.IncludeTotalCount)
                totalCount = await query.CountAsync();

            if (!search.RetrieveAll && search.Page.HasValue && search.PageSize.HasValue)
            {
                query = query.Order().Skip(search.Page.Value * search.PageSize.Value);
                query = query.Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            return new PagedResult<T>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public virtual async Task<T?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);

            return entity != null ? MapToResponse(entity) : null;
        }

        public virtual IQueryable<TEntity> AddInclude(IQueryable<TEntity> query, TSearch? search = null)
        {
            return query;
        }

        protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search)
        {
            return query;
        }

        protected virtual T MapToResponse(TEntity entity)
        {
            return _mapper.Map<T>(entity);
        }
    }
}
