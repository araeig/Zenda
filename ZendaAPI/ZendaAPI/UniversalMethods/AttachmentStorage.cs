namespace ZendaAPI.UniversalMethods
{
    public static class AttachmentStorage
    {
        public const string UrlPrefix = "/attachments/";
        public const int TypeVideo = 1;
        public const int TypeDocument = 2;
        public const int TypeFile = 3;
        public const int TypeLink = 4;

        private static readonly string[] VideoExtensions = { ".mp4", ".mov", ".webm", ".avi", ".mkv", ".m4v" };
        private static readonly string[] DocumentExtensions =
            { ".pdf", ".doc", ".docx", ".txt", ".rtf", ".odt", ".xls", ".xlsx", ".csv", ".ppt", ".pptx", ".md" };
        private static readonly string[] BlockedExtensions =
            { ".exe", ".bat", ".cmd", ".sh", ".ps1", ".msi", ".dll", ".js", ".html", ".htm", ".svg" };
        private static readonly string[] VideoHosts =
            { "youtube.com", "youtu.be", "rutube.ru", "vk.com/video", "vkvideo.ru", "vimeo.com" };

        public static string Folder(string contentRoot) => Path.Combine(contentRoot, "wwwroot", "attachments");

        public static bool IsBlocked(string extension) => BlockedExtensions.Contains(extension);

        public static int TypeForExtension(string extension)
        {
            if (VideoExtensions.Contains(extension)) return TypeVideo;
            if (DocumentExtensions.Contains(extension)) return TypeDocument;
            return TypeFile;
        }

        public static int TypeForLink(Uri uri)
        {
            var address = uri.Host + uri.AbsolutePath;
            return VideoHosts.Any(h => address.Contains(h, StringComparison.OrdinalIgnoreCase)) ? TypeVideo : TypeLink;
        }

        public static void DeleteFile(string contentRoot, string? url)
        {
            if (string.IsNullOrEmpty(url) || !url.StartsWith(UrlPrefix)) return;
            try
            {
                var path = Path.Combine(Folder(contentRoot), Path.GetFileName(url));
                if (File.Exists(path)) File.Delete(path);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Attachment delete error: {ex.Message}");
            }
        }
    }
}