using System.Text.Json;
using System.Text.Json.Nodes;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using ZendaAPI.UniversalMethods;

namespace ZendaAPI.CustomAttributes
{
    public class TranslateMessageFilter : IAsyncResultFilter
    {
        private static readonly JsonSerializerOptions WebOptions = new(JsonSerializerDefaults.Web);

        public async Task OnResultExecutionAsync(ResultExecutingContext context, ResultExecutionDelegate next)
        {
            if (Messages.CurrentLanguage != "ru"
                && context.Result is ObjectResult result
                && result.Value != null
                && result.Value is not JsonNode)
            {
                var node = JsonSerializer.SerializeToNode(result.Value, result.Value.GetType(), WebOptions);
                if (node is JsonObject obj
                    && obj["message"] is JsonValue value
                    && value.TryGetValue<string>(out var message))
                {
                    obj["message"] = Messages.Translate(message);
                    result.Value = obj;
                }
            }

            await next();
        }
    }
}