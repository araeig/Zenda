using Microsoft.AspNetCore.Mvc;
using ZendaAPI.Requests.Task;

namespace ZendaAPI.Interfaces
{
    public interface ITaskService
    {
        Task<IActionResult> GetAll(int userId);
        Task<IActionResult> GetOverdue(int userId, DateTime before);
        Task<IActionResult> Create(int userId, CreateTaskModel model);
        Task<IActionResult> Update(int userId, int taskId, UpdateTaskModel model);
        Task<IActionResult> Complete(int userId, int taskId);
        Task<IActionResult> Delete(int userId, int taskId);
    }
}