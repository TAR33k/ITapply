# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["ITapply.WebAPI/ITapply.WebAPI.csproj", "ITapply.WebAPI/"]
COPY ["ITapply.Services/ITapply.Services.csproj", "ITapply.Services/"]
COPY ["ITapply.Models/ITapply.Models.csproj", "ITapply.Models/"]
RUN dotnet restore "ITapply.WebAPI/ITapply.WebAPI.csproj"

COPY . .
WORKDIR "/src/ITapply.WebAPI"
RUN dotnet build "ITapply.WebAPI.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "ITapply.WebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Final Runtime Image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ITapply.WebAPI.dll"]