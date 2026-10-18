using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using ZendaAPI.Interfaces;

namespace ZendaAPI.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendAsync(string to, string subject, string html, IDictionary<string, string>? inlineImages = null)
        {
            var smtp = _configuration.GetSection("Smtp");

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(smtp["FromName"], smtp["User"]));
            message.To.Add(MailboxAddress.Parse(to));
            message.Subject = subject;

            var builder = new BodyBuilder { HtmlBody = html };
            if (inlineImages != null)
            {
                foreach (var image in inlineImages)
                {
                    if (!File.Exists(image.Value)) continue;
                    var resource = builder.LinkedResources.Add(image.Value);
                    resource.ContentId = image.Key;
                }
            }
            message.Body = builder.ToMessageBody();

            using var client = new SmtpClient();
            await client.ConnectAsync(smtp["Host"], int.Parse(smtp["Port"]), SecureSocketOptions.SslOnConnect);
            await client.AuthenticateAsync(smtp["User"], smtp["Password"]);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
    }
}