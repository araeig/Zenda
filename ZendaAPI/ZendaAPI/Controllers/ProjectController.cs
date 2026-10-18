using Microsoft.AspNetCore.Mvc;
using ZendaAPI.CustomAttributes;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Project;

namespace ZendaAPI.Controllers
{
    [ApiController]
    [Route("projects")]
    [SessionAuthorize]
    public class ProjectController : BaseController
    {
        private readonly IProjectService _projectService;

        public ProjectController(IProjectService projectService)
        {
            _projectService = projectService;
        }

        [HttpGet("home")]
        public async Task<IActionResult> GetHome() => await _projectService.GetHome(CurrentUserId);

        [HttpGet("archive")]
        public async Task<IActionResult> GetArchive() => await _projectService.GetArchive(CurrentUserId);

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateProjectModel model) => await _projectService.Create(CurrentUserId, model);

        [HttpPut("{projectId}")]
        public async Task<IActionResult> Update(int projectId, [FromBody] UpdateProjectModel model) => await _projectService.Update(CurrentUserId, projectId, model);

        [HttpPost("{projectId}/restore")]
        public async Task<IActionResult> Restore(int projectId) => await _projectService.Restore(CurrentUserId, projectId);
    }
}