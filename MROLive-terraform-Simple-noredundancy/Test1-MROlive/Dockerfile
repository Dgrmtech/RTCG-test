# Use official Python base image
FROM python:3.11

# Set the working directory
WORKDIR /app

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Run Django migrations and collect static files
RUN python manage.py migrate && python manage.py collectstatic --noinput

# Expose the port Django will run on
EXPOSE 8000

# Run the Django server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
