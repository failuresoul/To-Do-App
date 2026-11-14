# 📱 TodoFirebaseApp — iOS SwiftUI & Firebase Task Manager

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017.0%2B-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 17.0+" />
  <img src="https://img.shields.io/badge/Language-Swift%205.9%2B-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/UI-SwiftUI-0071E3?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Backend-Firebase%20Auth%20%26%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/IDE-Xcode%2016-147EFB?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode 16" />
</p>

**TodoFirebaseApp** is a native iOS task management application built with **SwiftUI** and **Google Firebase** (`FirebaseAuth` and `FirebaseFirestore`). It follows the **MVVM (Model–View–ViewModel)** pattern using modern Swift Concurrency (`async`/`await` and `@MainActor`) and enforces strict **per-user data isolation** both on the client and via Cloud Firestore Security Rules.

---

## ✨ Key Features

- 🔐 **Email & Password Authentication (`FirebaseAuth`)**
  - User registration with Full Name, Email, and Password validation.
  - Persistent session state listener (`addStateDidChangeListener`) that automatically routes between `LoginView` and `TaskListView`.
  - Built-in **Forgot Password?** email reset flow.
- ☁️ **Real-Time Cloud Sync (`FirebaseFirestore`)**
  - Live Firestore snapshot listener (`addSnapshotListener`) updates the UI immediately whenever tasks are added, edited, completed, or deleted.
  - Automatic user profile creation under `/users/{uid}` upon sign-up.
- 🛡️ **Strict Per-User Data Isolation**
  - Every task document stores its owner's `userId`.
  - Client-side queries filter strictly by `.whereField("userId", isEqualTo: uid)`, and server-side `firestore.rules` verify `request.auth.uid == resource.data.userId`.
- ✅ **Rich Task Management UI**
  - Create and edit tasks with **Title**, **Notes**, **Priority** (`Low`, `Medium`, `High`), and optional **Due Date**.
  - Segmented filter bar (**All**, **Active**, **Completed**) and real-time search bar (`.searchable`).
  - One-tap completion toggle with strikethrough styling, color-coded priority pills, overdue date highlighting, and swipe-to-delete / swipe-to-edit actions.

---

## 📸 App Screenshots

### Authentication & Task Creation
| Sign In Screen (`LoginView`) | Create / Edit Task Sheet (`AddEditTaskView`) |
| :---: | :---: |
| <img src="docs/images/login-screen.jpg" width="300" alt="Login Screen" /> | <img src="docs/images/new-task-sheet.jpg" width="300" alt="New Task Sheet" /> |

### Real-Time Task List & Filtering (`All` • `Active` • `Completed`)
| All Tasks | Active Tasks | Completed Tasks |
| :---: | :---: | :---: |
| <img src="docs/images/tasks-all.jpg" width="260" alt="All Tasks" /> | <img src="docs/images/tasks-active.jpg" width="260" alt="Active Tasks" /> | <img src="docs/images/tasks-completed.jpg" width="260" alt="Completed Tasks" /> |

### Cloud Firestore Backend Verification
| `/users/{userId}` Collection | `/tasks/{taskId}` Collection (User-Scoped) |
| :---: | :---: |
| <img src="docs/images/firestore-users.png" width="450" alt="Firestore Users Collection" /> | <img src="docs/images/firestore-tasks.png" width="450" alt="Firestore Tasks Collection" /> |

---

## 🏗️ System Architecture

<p align="center">
  <img src="docs/images/architecture-banner.jpg" width="100%" alt="TodoFirebaseApp System Architecture Banner" />
</p>

<details>
<summary><b>🔍 View Vector SVG Architecture Diagram</b></summary>
<br />
<p align="center">
  <img src="docs/images/architecture-diagram.svg" width="100%" alt="TodoFirebaseApp Vector Architecture Diagram" />
</p>
</details>

### Architectural Flow (Mermaid Diagram)

```mermaid
flowchart LR
    subgraph UI["1. View Layer (SwiftUI)"]
        App["TodoFirebaseAppApp\n(@main + AppDelegate)"]
        Content["ContentView\n(Session Router)"]
        AuthUI["LoginView & SignUpView"]
        TaskUI["TaskListView\nTaskRowView\nAddEditTaskView"]
    end

    subgraph VM["2. ViewModel Layer (@MainActor)"]
        AuthVM["AuthViewModel\n(userSession, signIn, signUp,\nsignOut, resetPassword)"]
        TaskVM["TaskViewModel\n(tasks, filter, searchText,\nfilteredTasks, CRUD)"]
    end

    subgraph Data["3. Service & Model Layer"]
        Service["TaskService.shared\n(ListenerRegistration & CRUD)"]
        Model["TodoItem & Priority\n(@DocumentID, Codable)"]
    end

    subgraph Cloud["4. Firebase Backend"]
        FAuth["Firebase Authentication\n(Email / Password)"]
        FS["Cloud Firestore\n(/users/{uid} & /tasks/{taskId})"]
        Rules["Firestore Security Rules\n(request.auth.uid == userId)"]
    end

    App --> Content
    Content -->|Unauthenticated| AuthUI
    Content -->|Authenticated| TaskUI
    AuthUI <--> AuthVM
    TaskUI <--> TaskVM
    AuthVM <--> FAuth
    AuthVM -->|Save Profile| FS
    TaskVM <--> Service
    Service --> Model
    Service <-->|Snapshot + CRUD| FS
    FS --- Rules
```

### Authentication & Real-Time Firestore Sequence

```mermaid
sequenceDiagram
    actor User
    participant View as SwiftUI Views
    participant AuthVM as AuthViewModel
    participant TaskVM as TaskViewModel
    participant Service as TaskService
    participant Firebase as Firebase Auth & Firestore

    User->>View: Enter Email & Password
    View->>AuthVM: signIn(email, password)
    AuthVM->>Firebase: Auth.auth().signIn(...)
    Firebase-->>AuthVM: AuthStateDidChangeListener fires (userSession != nil)
    AuthVM-->>View: ContentView routes to TaskListView
    View->>TaskVM: onAppear -> startListening()
    TaskVM->>Service: listenToTasks()
    Service->>Firebase: db.collection("tasks").whereField("userId", isEqualTo: uid)
    Firebase-->>Service: Real-time QuerySnapshot
    Service-->>TaskVM: Decoded [TodoItem] sorted by createdAt
    TaskVM-->>View: Re-renders filteredTasks list
```

---

## 📂 Project Directory Structure

```text
To-Do-App/
├── .gitattributes                         # Enforces Unix LF line endings across Windows & macOS
├── .gitignore                             # Standard Xcode & SwiftPM ignore rules
├── firestore.rules                        # Production per-user Cloud Firestore security rules
├── docs/
│   └── images/                            # App screenshots & architecture diagrams
├── TodoFirebaseApp.xcodeproj/             # Native Xcode 16 project bundle
│   ├── project.pbxproj
│   └── project.xcworkspace/
└── TodoFirebaseApp/
    ├── App/
    │   └── TodoFirebaseAppApp.swift       # @main entry point & FirebaseApp.configure()
    ├── ContentView.swift                  # Root view switching between LoginView & TaskListView
    ├── Models/
    │   └── TodoItem.swift                 # TodoItem struct (@DocumentID) & Priority enum
    ├── ViewModels/
    │   ├── AuthViewModel.swift            # Firebase Auth state & user session management
    │   └── TaskViewModel.swift            # Task state, search, filtering & CRUD actions
    ├── Views/
    │   ├── Auth/
    │   │   ├── LoginView.swift            # Email/Password login & password reset alert
    │   │   └── SignUpView.swift           # Account creation with form validation
    │   └── Tasks/
    │       ├── TaskListView.swift         # Main task list, filter picker, search & sheets
    │       ├── TaskRowView.swift          # Task row with checkbox, priority badge & due date
    │       └── AddEditTaskView.swift      # Form sheet for adding and editing tasks
    ├── Services/
    │   └── TaskService.swift              # User-scoped Firestore listener & CRUD operations
    ├── Assets.xcassets/                   # AppIcon and AccentColor catalogs
    ├── Preview Content/                   # Preview Assets catalog
    └── GoogleService-Info.plist           # Firebase iOS configuration file
```

---

## 🔒 Data Model & Security Rules

### `TodoItem` Schema (`tasks` Collection)

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String?` (`@DocumentID`) | Auto-generated Firestore document ID |
| `userId` | `String` | Firebase Auth `uid` of the task owner |
| `title` | `String` | Task title (required) |
| `notes` | `String` | Optional multi-line description |
| `isCompleted` | `Bool` | Completion status (`true` / `false`) |
| `priority` | `String` (`Priority`) | `"Low"`, `"Medium"`, or `"High"` |
| `dueDate` | `Timestamp?` (`Date?`) | Optional scheduled due date |
| `createdAt` | `Timestamp` (`Date`) | Creation timestamp used for sorting |

### Firestore Security Rules ([firestore.rules](firestore.rules))

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /tasks/{taskId} {
      allow read, update, delete: if request.auth != null
                                  && request.auth.uid == resource.data.userId;

      allow create: if request.auth != null
                    && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

---

## 🚀 Getting Started

### Prerequisites
- **macOS** with **Xcode 16.0+** (or Xcode 15.2+)
- **iOS 17.0+** Simulator or physical iPhone
- A **Firebase project** with **Email/Password Authentication** and **Cloud Firestore** enabled

### Installation & Running in Xcode

1. **Clone the repository:**
   ```bash
   git clone https://github.com/failuresoul/To-Do-App.git
   cd To-Do-App
   ```

2. **Configure Firebase (`GoogleService-Info.plist`):**
   - In the [Firebase Console](https://console.firebase.google.com/), register an iOS app with Bundle ID **`com.example.TodoFirebaseApp`**.
   - Download `GoogleService-Info.plist` and place it at `TodoFirebaseApp/GoogleService-Info.plist`.
   - Enable **Authentication → Sign-in method → Email/Password**.
   - Create a **Cloud Firestore** database and publish the rules from [`firestore.rules`](firestore.rules).

3. **Open and Run in Xcode:**
   ```bash
   open TodoFirebaseApp.xcodeproj
   ```
   - Wait for Xcode to finish resolving Swift Package Manager dependencies (`firebase-ios-sdk`).
   - Select an iPhone simulator (e.g., **iPhone 16**) and press **`Cmd + R`**.

> 💡 **Lab Mac Tip:** If Xcode shows `Could not create workspace arena folder`, go to **Xcode → Settings → Locations → Derived Data → Advanced…** and select **Relative to Workspace** (or a custom folder in `/tmp/DerivedData`).

---

## 👤 Author

**Nurul Absar Shadik**  
GitHub: [@failuresoul](https://github.com/failuresoul)
