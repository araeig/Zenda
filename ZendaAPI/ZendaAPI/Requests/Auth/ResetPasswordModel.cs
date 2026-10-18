namespace ZendaAPI.Requests.Auth
{
    public class ResetPasswordModel
    {
        public string Token { get; set; }
        public string Password { get; set; }
        public string ConfirmPassword { get; set; }
        public string? Lang { get; set; }
    }
}