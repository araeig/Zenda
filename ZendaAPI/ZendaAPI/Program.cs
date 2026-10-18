using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using ZendaAPI.Connection;
using ZendaAPI.CustomAttributes;
using ZendaAPI.Hubs;
using ZendaAPI.Interfaces;
using ZendaAPI.Services;
using ZendaAPI.UniversalMethods;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers(options =>
{
    options.Filters.Add<TranslateMessageFilter>();
});

builder.Services.Configure<Microsoft.AspNetCore.Mvc.ApiBehaviorOptions>(options =>
{
    options.InvalidModelStateResponseFactory = context =>
    {
        var errors = context.ModelState
            .Where(e => e.Value.Errors.Count > 0)
            .Select(e => Messages.Translate(e.Value.Errors.First().ErrorMessage))
            .ToList();

        return new BadRequestObjectResult(new { status = false, message = string.Join("; ", errors), data = (object)null });
    };
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "Вставь: Bearer {токен}",
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey
    });
    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference { Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            new string[] {}
        }
    });
});

builder.Services.AddHttpClient<RagClient>(client =>
{
    client.BaseAddress = new Uri(builder.Configuration["RagService:BaseUrl"]);
});

builder.Services.AddDbContext<ContextDb>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IProjectService, ProjectService>();
builder.Services.AddScoped<ITaskService, TaskService>();
builder.Services.AddScoped<IEventService, EventService>();
builder.Services.AddScoped<INoteService, NoteService>();
builder.Services.AddScoped<IAssistantService, AssistantService>();
builder.Services.AddScoped<IProfileService, ProfileService>();
builder.Services.AddScoped<IAttachmentService, AttachmentService>();

builder.Services.AddSignalR();

builder.Services.AddCors(options =>
{
    options.AddPolicy("ZendaApp", policy =>
        policy.SetIsOriginAllowed(_ => true)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials());
});

var avatarsPath = Path.Combine(builder.Environment.ContentRootPath, "wwwroot", "avatars");
Directory.CreateDirectory(avatarsPath);
var attachmentsPath = AttachmentStorage.Folder(builder.Environment.ContentRootPath);
Directory.CreateDirectory(attachmentsPath);

var app = builder.Build();

app.UseRequestLocalization(new RequestLocalizationOptions()
    .SetDefaultCulture("ru")
    .AddSupportedCultures("ru")
    .AddSupportedUICultures("ru", "en", "zh", "ar"));

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("ZendaApp");
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(avatarsPath),
    RequestPath = "/avatars"
});
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(attachmentsPath),
    RequestPath = "/attachments",
    ServeUnknownFileTypes = true,
    DefaultContentType = "application/octet-stream"
});
app.UseRouting();
app.UseAuthorization();
app.MapControllers();
app.MapHub<ChatHub>("/hubs/chat");

app.Run();