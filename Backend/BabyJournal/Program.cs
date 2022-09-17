using System.Text;
using BabyJournal.Database;
using BabyJournal.Services.Sftp;
using ChatBackend.Filters;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();

builder
    .Services
    .AddHttpContextAccessor()
    .AddScoped<IAuthorizationHandler, AuthHandler>()
    .AddSingleton<ISftpService, SftpService>()
    .AddAutoMapper(typeof(AppDbContext).Assembly)
    .AddScoped<IAppDbContext>(provider => provider.GetService<AppDbContext>())
    .AddAuthorization(config =>
    {
        config.DefaultPolicy = new AuthorizationPolicy(new List<IAuthorizationRequirement> {
            new AuthRequirement()
        }, new List<string>());
    })
    ;

builder
    .Services
    .AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = "JwtBearer";
        options.DefaultChallengeScheme = "JwtBearer";
    })
    .AddJwtBearer("JwtBearer", jwtBearerOptions =>
    {
        jwtBearerOptions.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["JWT:Key"])),
            ValidateIssuer = false,
            ValidateAudience = false,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(5)
        };
    });

builder.Services.AddSignalR();

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("Database"));
});

var app = builder.Build();
InitializeDatabase();

app.UseCors(x => x
    .AllowAnyOrigin()
    .AllowAnyMethod()
    .AllowAnyHeader());

app.UseRouting();
app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();



void InitializeDatabase()
{
    using var scope = app.Services.CreateScope();
    var services = scope.ServiceProvider;
    var context = services.GetRequiredService<AppDbContext>();
    context.Database.Migrate();
}