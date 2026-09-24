# Save+1 — Architecture

## 1. Overview

Save+1 is a Flutter mobile application that allows two people to work toward a shared savings goal by manually recording contributions, tracking progress, maintaining saving streaks, receiving reminders, and celebrating milestones.

Save+1 V1 does **not** hold or transfer real money. It is a savings tracking and accountability application.

The architecture is designed around:

* Clear separation of responsibilities
* Testability through Test-Driven Development (TDD)
* Simple and maintainable Flutter code
* Firebase for backend services
* Riverpod for state management and dependency injection
* Strong authorization and business-rule boundaries

------------------------------------------------------------------------------------------

## 2. Architecture Pattern

Save+1 uses a **Clean-ish Architecture** approach consisting of three main layers:

Presentation
     ↓
Domain
     ↓
Data

### Presentation Layer

Responsible for:

* Flutter UI
* User interactions
* UI state
* Riverpod providers/notifiers
* Displaying loading, success, and error states

The presentation layer must not contain core business rules or directly access Firebase.

### Domain Layer

Responsible for:

* Entities
* Business rules
* Use cases
* Domain validation
* Application behavior

The domain layer should be independent of Flutter UI and Firebase wherever practical.

Examples:

* Creating a pot
* Adding a contribution
* Calculating saving progress
* Validating contribution dates
* Determining streaks
* Determining milestone achievements
* Handling pot ownership rules

### Data Layer

Responsible for:

* Repository implementations
* Firebase data sources
* Mapping Firebase data to domain models
* Persisting and retrieving application data
* Synchronizing remote data

The data layer is the only layer that should directly communicate with Firebase services.

------------------------------------------------------------------------------------------
## 3. High-Level Architecture

┌──────────────────────────────────────┐
│            Presentation              │
│                                      │
│ Flutter UI                           │
│ Riverpod Providers / Notifiers       │
│ UI State                             │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│               Domain                 │
│                                      │
│ Entities                             │
│ Use Cases                            │
│ Business Rules                       │
│ Domain Validation                    │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│                Data                  │
│                                      │
│ Repository Implementations           │
│ Firebase Data Sources                │
│ Data ↔ Domain Mapping                │
└──────────────────┬───────────────────┘
                   │
                   ▼
┌──────────────────────────────────────┐
│               Firebase               │
│                                      │
│ Firebase Authentication              │
│ Cloud Firestore                      │
│ Cloud Functions                      │
│ Firebase Cloud Messaging             │
└──────────────────────────────────────┘

------------------------------------------------------------------------------------------

## 4. State Management

Save+1 uses **Riverpod** for state management and dependency injection.

Riverpod is responsible for:

* Exposing application state to the UI
* Managing asynchronous operations
* Connecting UI to use cases and repositories
* Managing dependencies
* Reacting to Firebase data changes
* Representing loading, success, and error states

Riverpod must not become the location for core business logic.

For example:

UI
 ↓
Riverpod
 ↓
Use Case
 ↓
Domain Rules
 ↓
Repository
 ↓
Firebase

This keeps the business logic testable without requiring Flutter widgets or Firebase.

------------------------------------------------------------------------------------------

## 5. Backend

Save+1 uses **Firebase** as its backend platform.

### Firebase Authentication

Responsible for:

* User registration
* User sign-in
* User identity
* Authentication state
* Associating application data with authenticated users

### Cloud Firestore

Responsible for:

* Users
* Pots
* Participants
* Contributions
* Adjustments
* Invitations
* Milestones
* Other persistent application data

Firestore also provides realtime synchronization so that changes made by one participant can be reflected for the other participant.

### Firebase Cloud Functions

Used for backend operations that should not rely solely on the client.

Potential V1 responsibilities include:

* Reminder processing
* Server-side workflows
* Backend-triggered events
* Operations requiring trusted server execution

Cloud Functions should be introduced only where necessary rather than moving every operation into server-side functions.

### Firebase Cloud Messaging

Responsible for push notifications.

Potential uses include:

* Shared saving reminders
* Pot invitations
* Milestone notifications
* Goal completion notifications

------------------------------------------------------------------------------------------

## 6. Data Flow

A typical write operation should follow this flow:

User Interaction
      ↓
Flutter UI
      ↓
Riverpod
      ↓
Use Case
      ↓
Domain Validation
      ↓
Repository Interface
      ↓
Firebase Repository Implementation
      ↓
Cloud Firestore

A typical read/update flow:

Cloud Firestore
      ↓
Firebase Data Source
      ↓
Repository
      ↓
Domain Model
      ↓
Riverpod State
      ↓
Flutter UI

The UI should never directly call Firestore.

------------------------------------------------------------------------------------------

## 7. Repository Pattern

The domain layer defines repository interfaces.

Example:

```dart
abstract class ContributionRepository {
  Future<void> addContribution(Contribution contribution);

  Future<void> updateContribution(Contribution contribution);

  Future<void> deleteContribution(String contributionId);

  Stream<List<Contribution>> watchContributions(String potId);
}
```

The data layer provides the implementation:

ContributionRepository
        ↑
        │ implements
        │
FirebaseContributionRepository

This allows domain and application logic to be tested using fake or mock repositories without requiring Firebase.

------------------------------------------------------------------------------------------

## 8. Business Rule Boundary

Business rules should be enforced at the appropriate layer.

### Client / Domain

Used for:

* Immediate validation
* User feedback
* Application behavior
* Domain calculations

Examples:

* Contribution amount must be positive
* Contribution date cannot be in the future
* Adjustment cannot create an invalid balance
* Multiple contributions on the same day count as one saving day
* Adjustments do not increase streaks
* Milestone thresholds

### Firebase Security / Backend

Used for:

* Authentication
* Authorization
* Data access control
* Protection against malicious or modified clients
* Server-trusted operations

Examples:

* Only authenticated users can access their data
* Only pot members can access a private pot
* Only the owner can modify pot settings
* A participant cannot modify another participant's contribution
* Only the invited user can accept an invitation
* Users cannot bypass the maximum participant limit

Client-side validation is **not** considered sufficient security.

------------------------------------------------------------------------------------------

## 9. Financial Data Representation

Save+1 does not process real money in V1.

However, monetary values should still be represented safely.

Amounts should use **integer sen** rather than floating-point values.

Example:

RM10.50 → 1050 sen
RM100.00 → 10000 sen

This avoids floating-point precision problems when performing financial calculations.

The UI is responsible for converting between user-facing RM values and the internal integer representation.

------------------------------------------------------------------------------------------

## 10. Authorization Model

Save+1 has two main roles within a pot:

### Owner

The pot creator.

Owner permissions include:

* Edit pot name
* Edit target
* Edit deadline
* Invite a participant
* Remove a participant
* Close/delete the pot

The owner cannot:

* Edit another user's contribution
* Delete another user's contribution
* Transfer ownership

### Participant

A user participating in the pot.

Participant permissions include:

* View the pot
* Add contributions
* Edit their own contributions
* Delete their own contributions
* View the other participant's contributions
* Leave the pot

A participant cannot:

* Edit pot settings
* Invite another participant
* Modify another user's contribution
* Transfer ownership

Authorization must be enforced server-side as well as in the client application.

------------------------------------------------------------------------------------------

## 11. Pot Privacy

Pots are private by default.

A pot should only be accessible to:

* The owner
* The active participant

Save+1 V1 does not provide:

* Public saving profiles
* Public pots
* Searchable pots
* Public financial progress

Social sharing is explicitly user-triggered.

------------------------------------------------------------------------------------------

## 12. Project Structure

The project should follow feature-oriented organization while maintaining the Presentation, Domain, and Data boundaries.

A proposed structure:

lib/
├── core/
│   ├── errors/
│   ├── utils/
│   ├── constants/
│   └── services/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── pots/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── contributions/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── invitations/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── milestones/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── streaks/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── reminders/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart

Not every feature must contain every layer. For example, a purely calculated domain concept may not require its own data layer.

The structure should evolve as the application grows rather than creating unnecessary files prematurely.

------------------------------------------------------------------------------------------

## 13. Dependency Direction

Dependencies should flow inward:

Presentation → Domain ← Data

More specifically:

Presentation
     ↓
Domain
     ↑
Data

The Domain layer should not depend on:

* Flutter widgets
* Firebase SDKs
* Firestore implementation details
* Riverpod-specific UI behavior

The Data layer may depend on Domain abstractions.

The Presentation layer may depend on Domain use cases and Riverpod.

------------------------------------------------------------------------------------------

## 14. TDD Strategy

Save+1 will use Test-Driven Development.

The primary focus of TDD will be the domain and application behavior.

The development cycle is:

RED
 ↓
Write a failing test
 ↓
GREEN
 ↓
Implement the minimum required behavior
 ↓
REFACTOR
 ↓
Improve the implementation without changing behavior

Priority for testing:

1. Domain business rules
2. Use cases
3. Repository behavior
4. Riverpod state behavior
5. Firebase integration
6. Widget/UI behavior

Examples of important domain tests:

* A positive contribution can be created
* A zero contribution is rejected
* A negative contribution is rejected
* A future contribution date is rejected
* Only the contribution owner can edit it
* An adjustment cannot create an invalid balance
* Multiple contributions on one day produce one saving day
* An adjustment does not increase a streak
* A pot cannot have more than two active participants
* Ownership cannot be transferred
* Owner leaving closes the pot
* Participant leaving does not close the pot
* Milestones trigger only when newly reached

------------------------------------------------------------------------------------------

## 15. Realtime Synchronization

Because Save+1 is a shared experience, changes made by one participant should be reflected for the other participant.

Example:

Hakim adds RM50
       ↓
Firestore
       ↓
Realtime update
       ↓
Jannah's device
       ↓
Riverpod state update
       ↓
UI displays updated progress

Realtime synchronization should be handled by the data/repository layer rather than directly inside UI widgets.

------------------------------------------------------------------------------------------

## 16. Architectural Principles

Save+1 follows these principles:

### Keep the domain independent

Business rules should remain testable without Firebase or Flutter.

### Keep Firebase behind repositories

Application code should not become tightly coupled to Firestore APIs.

### Keep Riverpod focused on state

Riverpod manages application state and dependencies; it should not become a dumping ground for business rules.

### Validate at multiple boundaries

Client-side validation improves UX.

Server-side validation and authorization protect application integrity.

### Prefer derived data where practical

Values such as progress and streaks should not unnecessarily become duplicated sources of truth.

### Avoid premature complexity

V1 should solve the core shared-saving experience before introducing advanced infrastructure or monetization.

### Preserve financial integrity

Although Save+1 does not hold money, savings records should remain consistent, auditable, and mathematically reliable.

------------------------------------------------------------------------------------------

## 17. V1 Architectural Boundary

The following are intentionally outside the V1 architecture:

* Bank integrations
* E-wallet integrations
* Actual money transfers
* Money custody
* KYC/AML systems
* Payment processing
* Public saving profiles
* Public pots
* Complex premium infrastructure
* Advanced analytics
* Recurring contribution automation

These may be considered in future versions if required.

------------------------------------------------------------------------------------------

## 18. Architecture Decision Summary

| Area                        | Decision                 |
| --------------------------- | ------------------------ |
| Framework                   | Flutter                  |
| Language                    | Dart                     |
| Architecture                | Clean-ish Architecture   |
| State Management            | Riverpod                 |
| Backend                     | Firebase                 |
| Authentication              | Firebase Authentication  |
| Database                    | Cloud Firestore          |
| Server-side Logic           | Cloud Functions          |
| Push Notifications          | Firebase Cloud Messaging |
| Testing Approach            | TDD                      |
| Monetary Representation     | Integer sen              |
| V1 Money Handling           | Manual tracking only     |
| Pot Visibility              | Private                  |
| Maximum Active Participants | 2                        |
| Ownership Transfer          | Not supported            |

------------------------------------------------------------------------------------------

## 19. Guiding Principle

> **Save+1 tracks savings; it does not hold savings.**

The architecture should support a reliable, testable, private, and realtime shared-saving experience while keeping V1 simple enough to build, understand, and maintain.
