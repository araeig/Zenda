using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace ZendaAPI.UniversalMethods
{
    public static class JwtGenerator
    {
        private const string SecretKey = "zenda-super-secret-key-change-me-32chars-minimum";

        public static string GenerateToken(int userId, TimeSpan lifetime)
        {
            var claims = new[] { new Claim("userId", userId.ToString()) };
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(SecretKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.UtcNow.Add(lifetime),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}