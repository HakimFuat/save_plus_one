# Save+1 — Database Design

## 1. Overview

Save+1 V1 uses **Cloud Firestore** as its primary database.

The database is designed to support:

* User authentication and profiles
* Private shared saving pots
* Maximum two active participants per pot
* Shared contribution tracking
* Contribution adjustments
* Invitations
* Saving milestones
* Pot lifecycle management
* Realtime synchronization
* Server-side authorization
* Reliable monetary calculations

Save+1 does **not** store or transfer real money.

The database stores records of money that users manually report as saved.

---

## 2. Database Principles

The Firestore data model follows these principles:

1. **User-owned data must be protected by authorization.**
2. **Pot data is private by default.**
3. **Financial amounts are stored as integer sen.**
4. **Contribution history should remain traceable.**
5. **Derived values should not unnecessarily become sources of truth.**
6. **Security Rules must enforce authorization independently of the Flutter client.**
7. **The schema should support realtime synchronization.**
8. **V1 should avoid unnecessary denormalization and complexity.**

---

# 3. Firestore Structure

The proposed top-level structure is:

```text
firestore
│
├── users/
│   └── {userId}
│
├── pots/
│   └── {potId}
│       ├── participants/
│       │   └── {userId}
│       │
│       ├── contributions/
│       │   └── {contributionId}
│       │
│       ├── adjustments/
│       │   └── {adjustmentId}
│       │
│       ├── invitations/
│       │   └── {invitationId}
│       │
│       └── milestones/
│           └── {milestoneId}
```

The `pots` collection is the central aggregate.

Most data associated with a shared saving goal is scoped beneath its pot.

---

# 4. Users

Collection:

```text
users/{userId}
```

A user document represents an authenticated Save+1 user.

### Example

```json
{
  "displayName": "Person A",
  "email": "user@example.com",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### Fields

| Field         | Type      | Description           |
| ------------- | --------- | --------------------- |
| `displayName` | String    | User's display name   |
| `email`       | String    | User's email          |
| `createdAt`   | Timestamp | Account creation time |
| `updatedAt`   | Timestamp | Last profile update   |

The Firebase Authentication UID is used as the `{userId}`.

The application database should not store passwords.

Authentication credentials are managed by Firebase Authentication.

---

# 5. Pots

Collection:

```text
pots/{potId}
```

A pot represents a shared savings goal.

### Example

```json
{
  "name": "Vacation Fund",
  "targetAmountSen": 1000000,
  "deadline": "Timestamp",
  "ownerId": "user_123",
  "status": "active",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### Fields

| Field             | Type           | Description            |
| ----------------- | -------------- | ---------------------- |
| `name`            | String         | Pot name               |
| `targetAmountSen` | Integer        | Target amount in sen   |
| `deadline`        | Timestamp/null | Optional deadline      |
| `ownerId`         | String         | User ID of the owner   |
| `status`          | String         | Pot lifecycle status   |
| `createdAt`       | Timestamp      | Creation time          |
| `updatedAt`       | Timestamp      | Last modification time |

### Pot Status

V1 supports:

```text
active
completed
ended
deleted
```

#### `active`

The pot is currently available for contributions.

#### `completed`

The shared target has been reached.

#### `ended`

The goal has been intentionally ended without completion.

#### `deleted`

The pot is no longer accessible to users.

A deleted pot may be retained internally rather than physically removed from Firestore.

---

# 6. Pot Participants

Subcollection:

```text
pots/{potId}/participants/{userId}
```

Each participant is represented by a document whose ID is the user's Firebase UID.

### Example

```json
{
  "role": "owner",
  "joinedAt": "Timestamp",
  "status": "active"
}
```

### Fields

| Field      | Type      | Description                   |
| ---------- | --------- | ----------------------------- |
| `role`     | String    | `owner` or `participant`      |
| `joinedAt` | Timestamp | Time the user joined          |
| `status`   | String    | Participant membership status |

Possible statuses:

```text
active
left
```

### Why use the user ID as the document ID?

It allows direct authorization checks such as:

```text
pots/{potId}/participants/{request.auth.uid}
```

This makes it straightforward to determine whether an authenticated user belongs to the pot.

---

# 7. Pot Ownership

Every pot has exactly one owner.

The owner is represented in two places:

```text
pots/{potId}.ownerId
```

and:

```text
pots/{potId}/participants/{ownerId}.role = "owner"
```

This duplication is intentional.

`ownerId` provides a direct reference for pot-level operations.

The participant document provides membership and role information.

### Invariants

* Every pot must have exactly one owner.
* The owner must be an active participant.
* Ownership cannot be transferred.
* A participant cannot become owner.
* There can never be two owners.

---

# 8. Contributions

Subcollection:

```text
pots/{potId}/contributions/{contributionId}
```

A contribution represents money that a participant manually records as saved toward the pot.

### Example

```json
{
  "userId": "user_123",
  "amountSen": 5000,
  "date": "Timestamp",
  "note": "Weekly savings",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### Fields

| Field       | Type        | Description                    |
| ----------- | ----------- | ------------------------------ |
| `userId`    | String      | User who made the contribution |
| `amountSen` | Integer     | Positive amount in sen         |
| `date`      | Timestamp   | Saving date                    |
| `note`      | String/null | Optional note                  |
| `createdAt` | Timestamp   | Record creation time           |
| `updatedAt` | Timestamp   | Last modification time         |

### Contribution Rules

* `amountSen` must be greater than zero.
* `userId` must be an active participant of the pot.
* `date` cannot be in the future.
* Only the contribution owner can edit it.
* Only the contribution owner can delete it.
* Contributions are recorded manually.
* Contributions do not represent money transferred through Save+1.

---

# 9. Adjustments

Subcollection:

```text
pots/{potId}/adjustments/{adjustmentId}
```

An adjustment represents a reduction to previously recorded savings.

Save+1 uses adjustments instead of a financial "withdrawal" because the application does not hold user funds.

### Example

```json
{
  "userId": "user_123",
  "amountSen": 10000,
  "date": "Timestamp",
  "note": "Savings adjustment",
  "createdAt": "Timestamp"
}
```

`amountSen` is always stored as a positive value, while the adjustment itself represents a subtraction.

### Calculation

```text
Net Savings
=
Total Contributions
-
Total Adjustments
```

Example:

```text
Contributions = RM500
Adjustments   = RM100

Net Savings   = RM400
```

### Adjustment Rules

* Adjustment amount must be greater than zero.
* The resulting balance cannot become invalid.
* Only an authorized participant may create an adjustment.
* Adjustments do not count as saving days.
* Adjustment history remains visible.
* An adjustment does not represent an actual money transfer performed by Save+1.

---

# 10. Why Contributions and Adjustments Are Separate

Contributions and adjustments are intentionally represented as separate collections.

This makes the domain meaning explicit:

```text
Contribution = money manually recorded as saved

Adjustment = reduction to recorded savings
```

It also avoids storing financial activity as a single mutable balance.

The database therefore preserves the underlying records from which the current balance can be calculated.

---

# 11. Invitations

Subcollection:

```text
pots/{potId}/invitations/{invitationId}
```

An invitation represents an invitation from the pot owner to another user.

### Example

```json
{
  "invitedUserId": "user_456",
  "invitedBy": "user_123",
  "status": "pending",
  "createdAt": "Timestamp",
  "respondedAt": null
}
```

### Fields

| Field           | Type           | Description              |
| --------------- | -------------- | ------------------------ |
| `invitedUserId` | String         | User being invited       |
| `invitedBy`     | String         | Pot owner                |
| `status`        | String         | Invitation state         |
| `createdAt`     | Timestamp      | Invitation creation time |
| `respondedAt`   | Timestamp/null | Response time            |

### Invitation Status

```text
pending
accepted
declined
```

### Rules

* Only the pot owner can create an invitation.
* Only the invited user can accept or decline it.
* A pot cannot have more than two active participants.
* An invitation does not automatically create membership.
* Membership is created only after acceptance.

---

# 12. Milestones

Subcollection:

```text
pots/{potId}/milestones/{milestoneId}
```

Milestones record achievement of predefined progress thresholds.

V1 milestones:

```text
25%
50%
75%
100%
```

### Example

```json
{
  "percentage": 50,
  "achievedAt": "Timestamp"
}
```

### Fields

| Field        | Type      | Description                 |
| ------------ | --------- | --------------------------- |
| `percentage` | Integer   | Milestone percentage        |
| `achievedAt` | Timestamp | Time milestone was achieved |

### Rules

Each milestone should only be recorded once.

Example:

```text
25% → recorded
50% → recorded
75% → recorded
100% → recorded
```

If the user edits or deletes a contribution later, milestone history should not be blindly recreated as if the milestone never happened.

Milestone behavior should therefore be handled as a domain decision rather than simply recalculating the collection every time the UI loads.

---

# 13. Progress Calculation

The database should not treat `currentAmount` as the primary source of truth.

Instead:

```text
Total Contributions
-
Total Adjustments
=
Current Savings
```

Then:

```text
Progress %
=
Current Savings / Target Amount × 100
```

Example:

```text
Target          = RM10,000
Contributions   = RM6,000
Adjustments     = RM500

Current Savings = RM5,500

Progress        = 55%
```

The application may introduce cached or denormalized progress values later if performance requires it.

However, V1 should prioritize correctness and a clear source of truth.

---

# 14. Individual Contribution Totals

A user's total contribution can be calculated by filtering contributions by `userId`.

Example:

```text
Person A:
RM100 + RM50 + RM200 = RM350

Person B:
RM100 + RM150 = RM250

Shared contributions:
RM600
```

Adjustments are applied to the appropriate user's recorded savings.

The database should not require a manually maintained per-user balance unless future performance requirements justify it.

---

# 15. Streak Data

V1 does not require a dedicated streak collection.

A participant's streak can be derived from contribution dates.

A saving day exists when:

```text
At least one positive contribution
was recorded by the participant
on that calendar day.
```

Multiple contributions on the same day count as one saving day.

Adjustments do not count as saving days.

Example:

```text
Monday     → RM50  → saving day
Tuesday    → RM20  → saving day
Wednesday  → none
Thursday   → RM100 → saving day
```

The streak would be broken by Wednesday.

The exact streak calculation should remain a domain-level concern rather than a Firestore-specific concern.

---

# 16. Deadline

The pot document stores an optional deadline:

```text
pots/{potId}.deadline
```

The field may be:

```text
Timestamp
```

or:

```text
null
```

When the deadline is reached:

### If target is reached

```text
active → completed
```

### If target is not reached

The user chooses:

```text
1. Extend deadline
2. Continue without deadline
3. End goal
```

No automatic "failed" state is introduced in V1.

---

# 17. Pot Lifecycle

The expected lifecycle is:

```text
                ┌──────────────┐
                │    active    │
                └──────┬───────┘
                       │
             ┌─────────┴─────────┐
             ▼                   ▼
       Target reached       Goal ended
             │                   │
             ▼                   ▼
        completed              ended
```

Deletion/closure may additionally result in:

```text
active → deleted
```

for an owner leaving the pot.

### Owner Leaves

When the owner leaves:

* Ownership is not transferred.
* The pot becomes inaccessible to users.
* The pot is treated as deleted from the user perspective.
* The backend may retain the document using a soft-delete/closed state.

### Participant Leaves

When a non-owner leaves:

* The participant becomes inactive.
* Their contribution is removed from shared progress according to the domain rules.
* The pot remains active for the remaining participant.
* The participant no longer has access to the pot.

---

# 18. Removing a Participant's Contribution After Leaving

A participant's historical contribution should not simply be physically deleted when they leave.

Instead, the system should preserve the records internally while excluding the departed participant's contributions from active pot progress.

Conceptually:

```text
Active Participant Contributions
+
Active Participant Adjustments
=
Current Pot Progress
```

This preserves data integrity while ensuring the departed participant's savings no longer count toward the active shared goal.

The exact implementation may use participant status when calculating active progress.

---

# 19. Free Pot Limit

V1 free users can create a maximum of:

```text
2 owned active pots
```

The limit applies to pots the user **owns**, not pots they participate in.

Example:

```text
Person A owns:
Pot A
Pot B

Person A joins Person B's:
Pot C

Person A can still own only two pots,
but can participate in Pot C.
```

This prevents being invited into another user's pot from consuming the user's own creation quota.

The ownership limit must be enforced server-side.

---

# 20. Participant Limit

Each active pot supports:

```text
Maximum active participants = 2
```

This means:

```text
Owner + one participant
```

The owner is counted as one of the two participants.

A third active participant must never be allowed, even if a modified client attempts to bypass the UI.

---

# 21. Security Rules Model

Firestore Security Rules must enforce the application's authorization model.

At a high level:

```text
Authenticated user
       │
       ▼
Is user a member of the pot?
       │
   ┌───┴───┐
   │       │
  Yes      No
   │       │
   ▼       ▼
Access   Denied
```

### Pot Access

Only active participants should be able to read an active private pot.

### Owner Operations

Only the owner may:

* Update pot settings
* Create invitations
* Remove participants
* Close/delete the pot

### Contribution Operations

Only the contribution owner may:

* Update their contribution
* Delete their contribution

Active pot participants may create their own contributions.

### Invitation Operations

Only:

* The owner may create invitations.
* The invited user may accept/decline an invitation.

Security Rules must not rely on the Flutter application hiding buttons.

---

# 22. Server-Side Integrity

Some operations require more than simple Firestore field-level security.

Potential examples include:

* Enforcing the two-participant limit
* Creating membership after invitation acceptance
* Owner leaving and closing the pot
* Preventing invalid financial adjustments
* Processing reminders
* Recording milestones
* Deadline processing

These operations may use Firebase Cloud Functions or Firestore transactions where appropriate.

The goal is to ensure that important invariants cannot be bypassed by manipulating the client.

---

# 23. Atomic Operations

Operations that modify multiple related documents should be treated as atomic where necessary.

### Accept Invitation

Potential changes:

```text
Invitation
    ↓
status = accepted

Participant
    ↓
new active participant
```

These changes should be performed atomically where required.

### Owner Leaves

Potential changes:

```text
Owner membership
      ↓
inactive

Pot
      ↓
deleted/closed
```

These should be handled as one controlled backend operation.

### Milestone Achievement

Potential changes:

```text
Contribution
      ↓
Progress reaches threshold
      ↓
Milestone created
```

The system should prevent duplicate milestone records.

---

# 24. Timestamps

Firestore timestamps should be used for database timestamps.

Common fields:

```text
createdAt
updatedAt
joinedAt
respondedAt
achievedAt
```

Client-controlled timestamps should be validated where they affect business rules.

For system-generated timestamps, server timestamps should be preferred where appropriate.

---

# 25. Document IDs

Recommended identifiers:

* Firebase Authentication UID for users
* Auto-generated/random document IDs for pots
* User UID for participant documents
* Auto-generated/random IDs for contributions
* Auto-generated/random IDs for adjustments
* Auto-generated/random IDs for invitations
* Milestone percentage or another deterministic identifier for milestone documents

Using a deterministic milestone ID can make duplicate milestone creation easier to prevent.

Example:

```text
pots/{potId}/milestones/25
pots/{potId}/milestones/50
pots/{potId}/milestones/75
pots/{potId}/milestones/100
```

---

# 26. Realtime Data

Firestore realtime listeners should primarily be attached to data that needs to update the shared experience.

Examples:

```text
Pot details
Participants
Contributions
Adjustments
Milestones
```

Example flow:

```text
Person A adds RM50
       ↓
Firestore updates
       ↓
Person B's realtime listener receives update
       ↓
Repository emits new data
       ↓
Riverpod updates state
       ↓
UI displays updated progress
```

---

# 27. Query Considerations

The initial V1 queries should remain simple.

Expected queries include:

### User's Owned Pots

Find active pots where:

```text
ownerId == currentUserId
```

### User's Invitations

Find pending invitations addressed to:

```text
invitedUserId == currentUserId
```

### Pot Contributions

Read:

```text
pots/{potId}/contributions
```

### User's Contributions in a Pot

Filter contributions by:

```text
userId == currentUserId
```

### Saving Days

Retrieve the participant's contributions and derive unique calendar dates in the domain layer.

Indexes should be added only when required by actual Firestore queries.

---

# 28. Data Integrity Rules

The following invariants must always hold.

### User

* User document corresponds to an authenticated Firebase UID.

### Pot

* Pot has exactly one owner.
* Owner is an active participant.
* Pot has no more than two active participants.
* Ownership cannot be transferred.
* Target amount is greater than zero.
* Target currency is MYR in V1.
* Pot status must be valid.

### Participant

* A participant belongs to a specific pot.
* A user cannot have duplicate active membership in the same pot.

### Contribution

* Amount is greater than zero.
* Amount is stored in sen.
* Date cannot be in the future.
* Contributor must be an active participant.
* Only contributor can modify their contribution.

### Adjustment

* Amount is greater than zero.
* Adjustment cannot create an invalid balance.
* Adjustment does not count toward streaks.

### Invitation

* Only the owner can send invitations.
* Only the invited user can respond.
* Invitation status must be valid.
* A pot cannot exceed two active participants.

### Milestone

* Only supported milestone percentages are allowed.
* A milestone can only be achieved once.

---

# 29. Denormalization Policy

Firestore often benefits from denormalized data, but Save+1 V1 should avoid unnecessary duplication.

The initial source-of-truth data should be:

```text
Users
Pots
Participants
Contributions
Adjustments
Invitations
Milestones
```

Values such as:

```text
Current Savings
Progress %
Streak
Individual Contribution Total
```

should initially be derived where practical.

If future performance requirements make repeated calculations expensive, these values may be denormalized and maintained through trusted backend operations.

Any denormalized value must have a clearly defined source of truth.

---

# 30. Currency

Save+1 V1 supports:

```text
MYR
```

Amounts are stored as integer sen.

Example:

```text
RM1.00  → 100
RM10.50 → 1050
RM999.99 → 99999
```

The database should not use floating-point numbers for monetary amounts.

The UI should convert between user-facing RM values and the internal integer representation.

A future multi-currency version would require additional domain and database design.

---

# 31. V1 Database Boundary

The following are intentionally excluded from the database design:

* Bank account information
* E-wallet balances
* Payment card information
* Actual money transfers
* Payment transactions
* KYC information
* AML records
* Financial account credentials
* Public saving profiles
* Public pots

Save+1 V1 stores manually reported savings activity only.

---

# 32. Proposed Firestore Structure Summary

```text
firestore
│
├── users/
│   └── {userId}
│       ├── displayName
│       ├── email
│       ├── createdAt
│       └── updatedAt
│
└── pots/
    └── {potId}
        ├── name
        ├── targetAmountSen
        ├── deadline
        ├── ownerId
        ├── status
        ├── createdAt
        ├── updatedAt
        │
        ├── participants/
        │   └── {userId}
        │       ├── role
        │       ├── status
        │       └── joinedAt
        │
        ├── contributions/
        │   └── {contributionId}
        │       ├── userId
        │       ├── amountSen
        │       ├── date
        │       ├── note
        │       ├── createdAt
        │       └── updatedAt
        │
        ├── adjustments/
        │   └── {adjustmentId}
        │       ├── userId
        │       ├── amountSen
        │       ├── date
        │       ├── note
        │       └── createdAt
        │
        ├── invitations/
        │   └── {invitationId}
        │       ├── invitedUserId
        │       ├── invitedBy
        │       ├── status
        │       ├── createdAt
        │       └── respondedAt
        │
        └── milestones/
            └── {milestoneId}
                ├── percentage
                └── achievedAt
```

---

# 33. Final Database Decisions

| Area                | Decision                                                            |
| ------------------- | ------------------------------------------------------------------- |
| Database            | Cloud Firestore                                                     |
| Primary Aggregate   | Pot                                                                 |
| User ID             | Firebase Authentication UID                                         |
| Pot ID              | Auto-generated document ID                                          |
| Participant ID      | User UID                                                            |
| Monetary Storage    | Integer sen                                                         |
| Currency            | MYR                                                                 |
| Contributions       | Subcollection                                                       |
| Adjustments         | Subcollection                                                       |
| Invitations         | Subcollection                                                       |
| Milestones          | Subcollection                                                       |
| Streak              | Derived from contribution dates                                     |
| Progress            | Derived from contributions and adjustments                          |
| Pot Privacy         | Private                                                             |
| Active Participants | Maximum 2                                                           |
| Ownership           | Exactly 1 owner                                                     |
| Ownership Transfer  | Not supported                                                       |
| Free Owned Pots     | Maximum 2 active owned pots                                         |
| Realtime Sync       | Firestore listeners                                                 |
| Authorization       | Firebase Security Rules + trusted backend operations where required |
| V1 Money Handling   | Manual tracking only                                                |

---

# 34. Guiding Principle

> **Store the events that happened, derive the state that can be derived, and enforce the rules where the client cannot be trusted.**

The database should preserve the integrity of Save+1's saving history while keeping the V1 implementation simple enough to develop, test, and maintain.
