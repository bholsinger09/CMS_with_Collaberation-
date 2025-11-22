FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .

# Create wwwroot and uploads directory
RUN mkdir -p /app/wwwroot/uploads

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "CMSCollaboration.dll"]
