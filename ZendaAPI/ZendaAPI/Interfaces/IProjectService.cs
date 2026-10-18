using Microsoft.AspNetCore.Mvc;
using ZendaAPI.Requests.Project;

namespace ZendaAPI.Interfaces
{
    public interface IProjectService
    {
        Task<IActionResult> GetHome(int userId);
        Task<IActionResult> GetArchive(int userId);
        Task<IActionResult> Create(int userId, CreateProjectModel model);
        Task<IActionResult> Update(int userId, int projectId, UpdateProjectModel model);
        Task<IActionResult> Restore(int userId, int projectId);
    }
}