namespace ZendaAPI.Interfaces
{
    public interface IEmailService
    {
        Task SendAsync(string to, string subject, string html, IDictionary<string, string>? inlineImages = null);
    }
}