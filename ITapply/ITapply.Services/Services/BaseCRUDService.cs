using ITapply.Models.SearchObjects;
using ITapply.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Services.Services
{
    public abstract class BaseCRUDService<T, TSearch, TEntity, TInsert, TUpdate> 
        : BaseService<T, TSearch, TEntity> where T : class where TSearch : BaseSearchObject where TEntity : class, new() where TInsert : class where TUpdate : class
    {
        protected readonly ITapplyDbContext _context;
        protected readonly IMapper _mapper;

        public BaseCRUDService(ITapplyDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<T> CreateAsync(TInsert request)
        {
            var entity = new TEntity();
            MapToEntity(entity, request);
            _context.Set<TEntity>().Add(entity);

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        protected virtual async Task BeforeInsert(TEntity entity, TInsert request)
        {

        }

        protected virtual TEntity MapToEntity(TEntity entity, TInsert request)
        {
            return _mapper.Map(request, entity);
        }

        public virtual async Task<T?> UpdateAsync(int id, TUpdate request)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);

            if (entity == null)
                return null;

            await BeforeUpdate(entity, request);

            MapToEntity(entity, request);

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        protected virtual async Task BeforeUpdate(TEntity entity, TUpdate request)
        {

        }

        protected virtual void MapToEntity(TEntity entity, TUpdate request)
        {
            _mapper.Map(request, entity);
        }

        public virtual async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return false;

            await BeforeDelete(entity);

            _context.Set<TEntity>().Remove(entity);
            await _context.SaveChangesAsync();

            return true;
        }

        protected virtual async Task BeforeDelete(TEntity entity)
        {

        }
    }
}
