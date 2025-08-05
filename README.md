<div align="center">

  <img width="100" height="100" alt="logo" src="https://github.com/user-attachments/assets/e0630dc4-e99c-4c4c-afd8-057e37732d9d" />

  <h1>
    <font color="#FF9800" style="font-weight: bold;">IT</font><font color="#616161" style="font-weight: bold;">apply</font>
    <br>
    <font size="5">Job Application Platform</font>
  </h1>

  A modern, multi-platform solution connecting job seekers and employers, built with .NET and Flutter.

  <p>
    <img alt="Platform" src="https://img.shields.io/badge/Platform-Android%20%7C%20Windows-brightgreen.svg?style=for-the-badge&logo=android"/>
    <img alt="Backend" src="https://img.shields.io/badge/Backend-.NET%20Core-blueviolet.svg?style=for-the-badge&logo=dotnet"/>
    <img alt="Frontend" src="https://img.shields.io/badge/Frontend-Flutter-blue.svg?style=for-the-badge&logo=flutter"/>
    <img alt="Database" src="https://img.shields.io/badge/Database-SQL%20Server-red.svg?style=for-the-badge&logo=microsoftsqlserver"/>
    <img alt="Messaging" src="https://img.shields.io/badge/Messaging-RabbitMQ-orange.svg?style=for-the-badge&logo=rabbitmq"/>
  </p>

</div>

---

## About ITapply

**ITapply** is a comprehensive job application platform developed as part of university coursework. It bridges the gap between job seekers and employers through a sophisticated ecosystem featuring a feature-rich mobile app for candidates and a powerful desktop client for employers and administrators. The backend is built with **.NET**, and the frontend uses **Flutter** for cross-platform support.

### Key Features

| User Role       | Platform      | Core Functionality                                                                                                                                     |
| --------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Employer**    | Desktop | Manage job postings, review candidate applications, edit company profiles and more.                                       |
| **Administrator** | Desktop | Full control over users and platform data, content moderation, access to system-wide analytics and reporting tools.                        |
| **Candidate**   | Mobile | Search & filter jobs, explore company profiles & reviews, apply & manage applications, receive notifications, build a detailed profile with skills, experience, and CVs. |
| **Guest**        | Mobile | Browse jobs and companies without creating an account.                                                                                          |

> **Note:** While the applications can be compiled for iOS and Linux, the primary focus was on Android and Windows. You may encounter bugs or unexpected behavior on other platforms.

---

## System Architecture

The platform is built on a clean, multi-layered .NET architecture designed for maintainability and separation of concerns.

-   `ITapply.WebAPI`: **ASP.NET Core Web API** serves as the entry point, handling HTTP requests, authentication, and routing to the appropriate services.
-   `ITapply.Services`: The **business logic layer**, containing services that orchestrate data operations and interact with the database context.
-   `ITapply.Models`: A centralized library for **Data Transfer Objects (DTOs)**, including request models, response models, and search objects.
-   `ITapply.Notifier`: A **background service** that handles asynchronous email notifications using a **RabbitMQ** message queue.
-   `ITapply.UI`: The **Flutter projects** for the mobile and desktop applications, responsible for the user interface and user experience.

---

## Prerequisites

Before you begin, ensure you have the following software installed and running on your system.

| Tool                                                                    | Purpose                               |
| ----------------------------------------------------------------------- | ------------------------------------- |
| 🐳 **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** | To run the entire backend stack in containers. |
| 🐰 **[RabbitMQ](https://www.rabbitmq.com/download.html)**                | For the asynchronous message queue. Can be run via Docker. |
| 🐦 **[Flutter SDK](https://flutter.dev/docs/get-started/install)**        | To build and run the client applications. |
| 🤖 **[Android Studio](https://developer.android.com/studio)**             | For Android emulation and mobile app testing. |

---

## Setting Up the Project

Follow these steps to get the entire platform up and running locally.

### 1. Clone the Repository

First, clone the project from GitHub to your local machine.

```bash
git clone https://github.com/TAR33k/ITapply.git
cd ITapply
```

### 2. Backend Setup

The entire backend (API, Database, RabbitMQ) is containerized with Docker for a seamless setup.

#### Step 1: Start the Backend Services
Navigate to the project root and run Docker Compose.

```bash
docker-compose up --build
```

This single command will:
-   Start a **SQL Server** database instance.
-   Start the **RabbitMQ** message broker.
-   Build and run the **.NET Web API** and the **Notifier Service**.
-   Set up all necessary database tables and **seed initial data**.

> **Note:** The initial setup can take **3-4 minutes** as Docker downloads the required images and initializes the database.

#### Step 2: Verify the API
Once Docker Compose finishes, you can verify that the API is running correctly by visiting the Swagger UI documentation in your browser:

**[http://localhost:8080/swagger](http://localhost:8080/swagger)**

### 3. Desktop Application Setup (Windows)

#### Step 1: Enable Windows Developer Mode
-   Go to `Settings` → `Update & Security` → `For developers`.
-   Enable the **"Developer mode"** toggle.

#### Step 2: Navigate and Install Dependencies
```bash
cd ITapply.UI/itapply_desktop
flutter pub get
```

#### Step 3: Run the Application
```bash
flutter run -d windows
```

### 4. Mobile Application Setup (Android)

#### Step 1: Navigate and Install Dependencies
```bash
cd ITapply.UI/itapply_mobile
flutter pub get
```

#### Step 2: Start an Android Emulator
-   Open **Android Studio**.
-   Go to `Tools` → `AVD Manager` and start an Android Virtual Device (AVD).

#### Step 3: Run the Application
```bash
flutter run
```
> Flutter will automatically detect the running emulator and launch the app on it.

---

## Login Credentials

Use the following pre-seeded accounts to explore the platform.

### Desktop Application
| Role            | Email                  | Password |
| --------------- | ---------------------- | -------- |
| **Employer**    | `employer1@itapply.com`| `test`   |
| **Administrator** | `admin@itapply.com`    | `test`   |

### Mobile Application
| Role            | Email                  | Password |
| --------------- | ---------------------- | -------- |
| **Candidate**   | `candidate1@itapply.com`| `test`   |

---

## API Configuration

The applications are configured to connect to the local API by default.

-   **Desktop App Base URL:** `http://localhost:8080/`
-   **Mobile App Base URL:** `http://10.0.2.2:8080/`

If you need to run the API on a different URL, you can override the default using the `--dart-define` flag.

**Example (Running Mobile App on Windows for direct localhost access):**
```bash
flutter run -d windows --dart-define=baseUrl=http://localhost:8080/
```

---

## Performance Notes

-   **Initial Docker Setup:** Can take up to 4 minutes on the first run.
-   **Flutter Builds:** The first build for mobile or desktop may take 2-3 minutes on slower machines. Subsequent builds will be much faster thanks to hot reload/restart.
