# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["ITapply.Notifier/ITapply.Notifier.csproj", "ITapply.Notifier/"]
COPY ["ITapply.Models/ITapply.Models.csproj", "ITapply.Models/"]
RUN dotnet restore "ITapply.Notifier/ITapply.Notifier.csproj"

COPY . .
WORKDIR "/src/ITapply.Notifier"
RUN dotnet build "ITapply.Notifier.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "ITapply.Notifier.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Final Runtime Image
FROM mcr.microsoft.com/dotnet/runtime:9.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ITapply.Notifier.dll"]