# Використовуємо .NET SDK для побудови
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-env 

# Set the working directory inside the container 
WORKDIR /app 

# Copy the project files to the container 
COPY *.csproj ./
RUN dotnet restore 

# Copy the rest of the application code to the container 
COPY . ./

# Build the application 
RUN dotnet publish -c Release -o out 

# Створюємо фінальний образ з .NET Core runtime
FROM mcr.microsoft.com/dotnet/aspnet:6.0 
WORKDIR /app 
COPY --from=build-env /app/out .

# Запускаємо додаток
ENTRYPOINT ["dotnet", "dotnetwebapp.dll", "--urls", "http://*:5000"] 

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
