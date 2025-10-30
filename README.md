# Animal Fostering Mobile App

A complete animal fostering and adoption management system built with Flutter mobile app and ASP.NET Core Web API.

## Project Structure
AnimalFosteringApp/
├── AnimalFostering.API/ # ASP.NET Core Web API Backend
│ ├── Controllers/
│ ├── Models/
│ ├── Data/
│ ├── Migrations/
│ └── Program.cs
└── animal_fostering_app/ # Flutter Mobile App
├── lib/
│ ├── screens/
│ ├── models/
│ └── services/
├── pubspec.yaml
└── main.dart


## Features

- **Mobile App (Flutter)**
  - Dashboard with animal statistics
  - Animal listing and management
  - Add new animals
  - Responsive design

- **Backend (ASP.NET Core)**
  - RESTful API
  - PostgreSQL database
  - Entity Framework Core
  - CRUD operations for animals

## Technology Stack

- **Frontend**: Flutter, Dart
- **Backend**: ASP.NET Core, C#
- **Database**: PostgreSQL
- **ORM**: Entity Framework Core

## Setup Instructions

### Backend Setup
1. Navigate to `AnimalFostering.API/`
2. Update connection string in `appsettings.json`
3. Run `dotnet ef database update`
4. Run `dotnet run`

### Mobile App Setup
1. Navigate to `animal_fostering_app/`
2. Run `flutter pub get`
3. Run `flutter run`

## API Endpoints

- `GET /api/animals` - Get all animals
- `GET /api/animals/{id}` - Get animal by ID
- `POST /api/animals` - Create new animal
- `PUT /api/animals/{id}` - Update animal
- `DELETE /api/animals/{id}` - Delete animal