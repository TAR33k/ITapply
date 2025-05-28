using ITapply.Models.Requests;
using ITapply.Models.Responses;
using ITapply.Models.SearchObjects;
using ITapply.Services.Interfaces;

namespace ITapply.WebAPI.Controllers
{
    public class PreferencesController : BaseCRUDController<PreferencesResponse, PreferencesSearchObject, PreferencesInsertRequest, PreferencesUpdateRequest>
    {
        public PreferencesController(IPreferencesService preferencesService) : base(preferencesService)
        {
        }
    }
} 