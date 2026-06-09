using Azure.Identity;
using Azure.Monitor.OpenTelemetry.AspNetCore;
using InventoryApi.DependencyInjection;
using InventoryApi.Models;
using InventoryApi.Repositories;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// Wire in Azure App Configuration using Managed Identity (passwordless)
var appConfigEndpoint = builder.Configuration["APP_CONFIG_ENDPOINT"];
if (!string.IsNullOrEmpty(appConfigEndpoint))
{
    builder.Configuration.AddAzureAppConfiguration(options =>
        options.Connect(new Uri(appConfigEndpoint), new DefaultAzureCredential())
               .Select("InventoryApi:*"));
}

builder.Services.AddOpenApi();
builder.Services.AddOpenTelemetry().UseAzureMonitor();
builder.Services.AddInventoryApiServices(builder.Configuration);

var app = builder.Build();

app.MapOpenApi();
app.MapScalarApiReference();

app.MapGet("/health", () => Results.Ok(new { status = "Healthy" }))
    .WithName("HealthCheck");

app.MapGet("/api/items", async (IInventoryRepository repository, CancellationToken cancellationToken) =>
{
    var items = await repository.GetAllAsync(cancellationToken);
    return Results.Ok(items);
});

app.MapGet("/api/items/{id}", async (string id, IInventoryRepository repository, CancellationToken cancellationToken) =>
{
    var item = await repository.GetByIdAsync(id, cancellationToken);
    return item is null ? Results.NotFound() : Results.Ok(item);
});

app.MapPost("/api/items", async (InventoryItem item, IInventoryRepository repository, ILogger<Program> logger, CancellationToken cancellationToken) =>
{
    logger.LogInformation("Creating inventory item: {Name}", item.Name);
    var created = await repository.CreateAsync(item, cancellationToken);
    logger.LogInformation("Created inventory item: {Id} {Name}", created.Id, created.Name);
    return Results.Created($"/api/items/{created.Id}", created);
});

app.MapPut("/api/items/{id}", async (string id, InventoryItem item, IInventoryRepository repository, CancellationToken cancellationToken) =>
{
    var updated = await repository.UpdateAsync(id, item, cancellationToken);
    return updated ? Results.NoContent() : Results.NotFound();
});

app.MapDelete("/api/items/{id}", async (string id, IInventoryRepository repository, CancellationToken cancellationToken) =>
{
    var deleted = await repository.DeleteAsync(id, cancellationToken);
    return deleted ? Results.NoContent() : Results.NotFound();
});

app.Run();
