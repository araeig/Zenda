using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Runtime.CompilerServices;
using System.Text.Json;

namespace ZendaAPI.UniversalMethods
{
    public class RagClient
    {
        private readonly HttpClient _httpClient;
        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            PropertyNameCaseInsensitive = true
        };

        public RagClient(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task IndexAsync(int userId, string sourceType, int sourceId, string text)
        {
            var payload = new
            {
                user_id = userId,
                source_type = sourceType,
                source_id = sourceId,
                text
            };

            try
            {
                var response = await _httpClient.PostAsJsonAsync("/index", payload);
                response.EnsureSuccessStatusCode();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"RAG index error ({sourceType} {sourceId}): {ex.Message}");
            }
        }

        public async Task IndexFileAsync(int userId, int attachmentId, string title, string owner, string filePath)
        {
            try
            {
                await using var stream = File.OpenRead(filePath);
                using var content = new MultipartFormDataContent();
                content.Add(new StringContent(userId.ToString()), "user_id");
                content.Add(new StringContent(attachmentId.ToString()), "source_id");
                content.Add(new StringContent(title), "title");
                content.Add(new StringContent(owner), "owner");
                content.Add(new StreamContent(stream), "file", Path.GetFileName(filePath));

                var response = await _httpClient.PostAsync("/index/file", content);
                response.EnsureSuccessStatusCode();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"RAG file index error (attachment {attachmentId}): {ex.Message}");
            }
        }

        public async Task DeleteIndexAsync(int userId, string sourceType, int sourceId)
        {
            try
            {
                var response = await _httpClient.DeleteAsync(
                    $"/index?user_id={userId}&source_type={sourceType}&source_id={sourceId}");
                response.EnsureSuccessStatusCode();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"RAG delete error ({sourceType} {sourceId}): {ex.Message}");
            }
        }

        public async Task<RagAskResult?> AskAsync(int userId, string question, string facts, string today, List<object>? history, string language)
        {
            var payload = new { user_id = userId, question, facts, today, history = history ?? new List<object>(), language };

            var response = await _httpClient.PostAsJsonAsync("/ask", payload);
            response.EnsureSuccessStatusCode();

            var wrapper = await response.Content.ReadFromJsonAsync<RagResponseWrapper>(JsonOptions);
            return wrapper?.Data;
        }

        public async IAsyncEnumerable<RagStreamEvent> AskStreamAsync(
            int userId,
            string question,
            string facts,
            string today,
            List<object>? history,
            string language,
            [EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            var payload = new { user_id = userId, question, facts, today, history = history ?? new List<object>(), language };
            using var request = new HttpRequestMessage(HttpMethod.Post, "/ask/stream")
            {
                Content = JsonContent.Create(payload)
            };

            using var response = await _httpClient.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
            response.EnsureSuccessStatusCode();

            await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
            using var reader = new StreamReader(stream);

            string? line;
            while ((line = await reader.ReadLineAsync(cancellationToken)) != null)
            {
                if (string.IsNullOrWhiteSpace(line)) continue;
                var item = JsonSerializer.Deserialize<RagStreamEvent>(line, JsonOptions);
                if (item != null) yield return item;
            }
        }

        public async Task<string?> TranscribeAsync(Stream audio, string fileName, string? contentType, string language = "ru")
        {
            using var content = new MultipartFormDataContent();
            var fileContent = new StreamContent(audio);
            fileContent.Headers.ContentType = MediaTypeHeaderValue.TryParse(contentType, out var parsed)
                ? parsed
                : new MediaTypeHeaderValue("application/octet-stream");
            content.Add(fileContent, "file", fileName);
            content.Add(new StringContent(language), "language");

            var response = await _httpClient.PostAsync("/transcribe", content);
            response.EnsureSuccessStatusCode();

            var wrapper = await response.Content.ReadFromJsonAsync<RagTranscribeWrapper>(JsonOptions);
            return wrapper?.Data?.Text;
        }
    }

    public class RagResponseWrapper
    {
        public bool Status { get; set; }
        public string Message { get; set; }
        public RagAskResult Data { get; set; }
    }

    public class RagAskResult
    {
        public string Answer { get; set; }
        public List<RagSource> Sources { get; set; }
    }

    public class RagSource
    {
        public string Type { get; set; }
        public int Id { get; set; }
    }

    public class RagStreamEvent
    {
        public string Type { get; set; } = "";
        public string? Text { get; set; }
        public string? Message { get; set; }
        public List<RagSource>? Sources { get; set; }
    }

    public class RagTranscribeWrapper
    {
        public bool Status { get; set; }
        public string? Message { get; set; }
        public RagTranscribeResult? Data { get; set; }
    }

    public class RagTranscribeResult
    {
        public string Text { get; set; } = "";
    }
}