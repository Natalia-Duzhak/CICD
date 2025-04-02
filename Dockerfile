# Використовуємо образ .NET SDK для збірки
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env

# Встановлюємо робочу директорію
WORKDIR /app

# Копіюємо файли проекту і відновлюємо залежності
COPY *.csproj ./
RUN dotnet restore

# Копіюємо решту коду та будуємо застосунок
COPY . ./
RUN dotnet publish -c Release -o out

# Створюємо фінальний образ на основі .NET Core runtime
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build-env /app/out .

# Запускаємо застосунок
ENTRYPOINT ["dotnet", "dotnetwebapp.dll", "--urls", "http://0.0.0.0:5000"]

# Використовуємо офіційний образ Alpine Linux для Nginx
FROM alpine:latest AS nginx

# Оновлюємо індекс пакетів і встановлюємо Nginx
RUN apk update && apk add nginx

# Видаляємо стандартну сторінку Nginx
RUN rm -rf /usr/share/nginx/html/*

# Копіюємо файли додатку у каталог Nginx
COPY --from=runtime /app /usr/share/nginx/html

# Видаляємо попередню конфігурацію Nginx
RUN rm -f /etc/nginx/http.d/default.conf
