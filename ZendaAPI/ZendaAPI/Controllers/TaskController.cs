using Microsoft.AspNetCore.Mvc;
using ZendaAPI.CustomAttributes;
using ZendaAPI.Interfaces;
using ZendaAPI.Requests.Task;

namespace ZendaAPI.Controllers
{
    [ApiController]
    [Route("tasks")]
    [SessionAuthorize]
    public class TaskController : BaseController
    {
        private readonly ITaskService _taskService;

        public TaskController(ITaskService taskService)
        {
            _taskService = taskService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll() => await _taskService.GetAll(CurrentUserId);

        [HttpGet("overdue")]
        public async Task<IActionResult> GetOverdue([FromQuery] DateTime before) => await _taskService.GetOverdue(CurrentUserId, before);

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateTaskModel model) => await _taskService.Create(CurrentUserId, model);

        [HttpPut("{taskId}")]
        public async Task<IActionResult> Update(int taskId, [FromBody] UpdateTaskModel model) => await _taskService.Update(CurrentUserId, taskId, model);

        [HttpPost("{taskId}/complete")]
        public async Task<IActionResult> Complete(int taskId) => await _taskService.Complete(CurrentUserId, taskId);

        [HttpDelete("{taskId}")]
        public async Task<IActionResult> Delete(int taskId) => await _taskService.Delete(CurrentUserId, taskId);
    }
}