# Створення образу для збирання додатка
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env

# Встановлюємо робочу директорію всередині контейнера
WORKDIR /app

# Копіюємо файли проекту
COPY *.csproj ./
RUN dotnet restore

# Копіюємо решту файлів додатка
COPY . ./

# Створюємо додаток
RUN dotnet publish -c Release -o out

# Створюємо фінальний образ з використанням ASP.NET Core
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app

# Копіюємо зібраний додаток з попереднього етапу
COPY --from=build-env /app/out ./

# Вказуємо точку входу для додатка
ENTRYPOINT ["dotnet", "dotnetwebapp.dll", "--urls", "http://*:5000"]
