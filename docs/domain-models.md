# Save+1 — Domain Model & Business Rules

**Version:** 1.0
**Status:** Working Specification
**Last Updated:** 2026-09-24

> This document defines the core domain concepts, relationships, business rules, and invariants for the Save+1 V1 application.

---

## 1. Domain Overview

Save+1 is a social savings tracker that allows two people to work toward a shared financial goal.

Save+1 **tracks savings but does not hold, transfer, or manage actual money**.

Users manually record money they have saved, and the application calculates shared progress based on those records.

### Core Domain Concepts

* **User** — A person with a Save+1 account.
* **Pot** — A shared savings goal.
* **Contribution** — A positive amount manually recorded by a participant.
* **Adjustment** — A negative financial record used to represent money previously recorded as saved that is no longer part of the goal.
* **Invitation** — A request from a pot owner for another user to join the pot.
* **Milestone** — A progress threshold reached by a pot.
* **Streak** — A participant's consecutive calendar days with at least one positive contribution.

---

# 2. User

## Domain Meaning

A User represents a person who has an account in Save+1 and can create savings pots, participate in other users' pots, and record contributions toward shared goals.

## Attributes

* `id`
* `name`
* `email`
* `createdAt`

## Responsibilities

A User can:

* Own savings pots.
* Participate in savings pots.
* Accept or decline invitations.
* Record contributions.
* Manage their own contributions.
* Leave pots.

## Business Rules

* Each user represents one unique Save+1 account.
* A free user can own a maximum of 2 active pots.
* The 2-pot limit applies to pots the user owns, not pots they participate in.
* A user can participate in multiple pots.
* A user cannot access pots they are not authorized to access.

---

# 3. Pot

## Domain Meaning

A Pot represents a shared savings pocket where participants can track money they have saved toward a common financial goal.

## Attributes

* `id`
* `name`
* `targetAmount`
* `deadline` (optional)
* `ownerId`
* `createdAt`
* `status`

## Status

A Pot can have the following user-facing states:

- Active
- Completed
- Ended

A backend implementation may additionally use a soft-deleted or closed state for data integrity.

## Responsibilities

A Pot is responsible for:

* Maintaining its shared savings goal.
* Tracking participants.
* Tracking contributions and adjustments.
* Calculating current progress.
* Determining milestone progress.
* Managing its deadline lifecycle.

## Business Rules

* A Pot has exactly one owner.
* A Pot must have at least one participant: its owner.
* A Pot can have a maximum of 2 active participants.
* The owner is automatically the first participant.
* Only the owner can edit the pot's name, target, and deadline.
* Ownership cannot be transferred.
* Participants can view the pot's shared progress.
* Only authorized participants can access a private pot.
* A completed pot has reached its target amount.
* An ended pot is no longer an active savings goal.
* A completed or ended pot is archived from the user's active pot view.

---

# 4. Contribution

## Domain Meaning

A Contribution represents money that a participant manually records as saved toward a Pot.

A Contribution does **not** represent an actual transfer of money through Save+1.

## Attributes

* `id`
* `potId`
* `userId`
* `amount`
* `date`
* `note` (optional)
* `createdAt`
* `updatedAt`

## Responsibilities

A Contribution:

* Increases the participant's contribution total.
* Increases the Pot's shared progress.
* Can contribute toward milestone progress.
* Can contribute toward a saving streak.

## Business Rules

* Only participants of a Pot can create contributions.
* Contribution amount must be positive.
* Contribution date cannot be in the future.
* A participant can edit only their own contributions.
* A participant can delete only their own contributions.
* A contribution is denominated in MYR for V1.
* Multiple contributions on the same day count as one saving day for streak purposes.
* A positive contribution can trigger a milestone.
* A contribution can cause a Pot to reach its target.

---

# 5. Adjustment

## Domain Meaning

An Adjustment represents a negative change to money previously recorded as saved toward a Pot.

Save+1 uses adjustments instead of financial withdrawals because Save+1 does not hold or transfer actual money.

Example:

=============================
| Contribution     | +RM500 |
| Adjustment       | -RM100 |
|------------------|--------|
| Net contribution | RM400  |
=============================

## Attributes

* `id`
* `potId`
* `userId`
* `amount`
* `date`
* `note` (optional)
* `createdAt`

The amount is represented as a negative value or through an explicit adjustment type, depending on the eventual implementation.

## Responsibilities

An Adjustment:

* Decreases the participant's net contribution.
* Decreases the Pot's shared progress.
* Preserves transaction history.

## Business Rules

* Only participants can create adjustments.
* An adjustment must decrease the participant's valid net contribution.
* An adjustment cannot create an invalid negative balance.
* An adjustment decreases shared Pot progress.
* An adjustment does not count as a saving day.
* An adjustment does not increase a saving streak.
* Adjustment history remains visible.

---

# 6. Transaction Record

Contribution and Adjustment are both financial records representing changes to a participant's tracked savings.

Conceptually:

Transaction
├── Contribution  (+)
└── Adjustment    (-)

The implementation may represent these as:

1. Separate domain types, or
2. A single transaction model with a transaction type.

The final implementation decision will be made during architecture and database design.

The important domain rule is:

> Save+1 maintains an auditable history of positive and negative changes rather than silently changing historical contribution records.

---

# 7. Invitation

## Domain Meaning

An Invitation represents a request from a Pot owner for another Save+1 user to join their Pot.

## Attributes

* `id`
* `potId`
* `invitedUserId`
* `invitedByUserId`
* `status`
* `createdAt`

## Status

Pending
│
├── Accept → Accepted
│
└── Decline → Declined

## Responsibilities

An Invitation:

* Identifies the Pot being joined.
* Identifies the invited user.
* Tracks whether the invitation is pending, accepted, or declined.

## Business Rules

* Only the Pot owner can send an invitation.
* A Pot cannot exceed 2 active participants.
* Only the invited user can accept or decline their invitation.
* An invitation belongs to exactly one Pot.
* An invitation targets exactly one user.
* Accepting an invitation adds the invited user as a participant.
* Declining an invitation does not add the user to the Pot.
* A user cannot accept an invitation if the Pot no longer has an available participant slot.

---

# 8. Participant

A participant represents a User's membership in a Pot.

For V1, a participant relationship has two roles:

- Owner
- Participant

## Owner

The owner:

* Created the Pot.
* Is automatically the first participant.
* Can edit Pot details.
* Can invite another user.
* Can remove a participant.
* Can close/delete the Pot.
* Cannot edit or delete another participant's contributions.
* Cannot transfer ownership.

## Participant

A participant:

* Can view the Pot.
* Can add contributions.
* Can edit their own contributions.
* Can delete their own contributions.
* Can create adjustments.
* Can view shared contribution activity.
* Can leave the Pot.

## Business Rules

* A Pot has exactly one owner.
* A Pot can have a maximum of two active participants.
* The owner is also a participant.
* A user cannot have duplicate active membership in the same Pot.
* Ownership cannot be transferred.

---

# 9. Milestone

## Domain Meaning

A Milestone represents a predefined progress threshold reached by a Pot.

## V1 Milestones

25%
50%
75%
100%

## Responsibilities

A Milestone:

* Represents a progress achievement.
* Can trigger a celebration.
* Records that a threshold has already been achieved.

## Business Rules

* A milestone is reached when Pot progress reaches or exceeds its threshold.
* Each milestone should only be newly triggered once.
* Reaching a higher milestone does not reset previous milestones.
* The 100% milestone marks the Pot as completed.
* Milestones are based on shared Pot progress.

Example:

Target: RM10,000

RM2,500 → 25%
RM5,000 → 50%
RM7,500 → 75%
RM10,000 → 100%

---

# 10. Streak

## Domain Meaning

A Streak represents the number of consecutive calendar days in which a participant makes at least one positive contribution.

## Business Rules

A saving day is created when:

At least one positive contribution
+
The contribution occurs on that calendar day

Multiple contributions on the same day count as one saving day.

Example:

Monday:
RM10
RM20
RM30

= 1 saving day

An adjustment alone does not count as a saving day.

-RM20

= 0 saving days

## Streak Behavior

A participant's streak:

* Increases when they contribute on the next consecutive saving day.
* Remains unchanged by additional contributions on the same day.
* Does not increase from adjustments.
* Resets when the participant misses a required saving day according to the defined streak calculation.

The exact reset calculation will be finalized during implementation and testing.

---

# 11. Deadline

A Pot may optionally have a deadline.

## Business Rules

* A deadline is optional.
* A contribution cannot be dated in the future.
* When the deadline arrives and the target has not been reached, the Pot does not automatically fail.
* Participants are given three options:

1. Extend deadline
2. Continue without deadline
3. End goal

## Deadline Outcomes

### Target Reached

Target reached
   ↓
Completed

### Target Not Reached

Deadline reached
      ↓
Choose:
├── Extend deadline
├── Remove deadline
└── End goal

If the goal is ended:

Active
  ↓
Ended / Archived

---

# 12. Pot Lifecycle

The primary Pot lifecycle is:

                 ┌─────────────┐
                 │    Active   │
                 └──────┬──────┘
                        │
              ┌─────────┴─────────┐
              │                   │
         Target reached       Goal ended
              │                   │
              ▼                   ▼
        ┌───────────┐       ┌───────────┐
        │ Completed │       │   Ended   │
        └───────────┘       └───────────┘


A deadline does not automatically transition an incomplete Pot to `Ended`.

The participants must choose what happens next.

---

# 13. Leaving a Pot

## Participant Leaving

When a non-owner participant leaves:

1. The participant confirms the action.
2. Their membership is removed.
3. Their net contributed amount is removed from shared Pot progress.
4. The Pot remains active for the owner.
5. The participant can no longer access the Pot.

The user's previous financial records may be retained internally for data integrity, but they no longer contribute to the active Pot's shared progress.

## Owner Leaving

Ownership cannot be transferred.

When the owner leaves:

1. The owner receives a warning.
2. The owner confirms deletion.
3. The Pot becomes inaccessible to all participants.
4. The Pot is removed from active user views.
5. The Pot's saving history is no longer accessible to participants.

The backend may implement this as a soft delete or closed state rather than physically deleting the data.

---

# 14. Progress Calculation

A Pot's current progress is based on the net value of valid financial records belonging to its active participants.

Conceptually:

Pot Progress
=
Sum(Contributions)
-
Sum(Adjustments)

Example:

Hakim:
+RM500
+RM200
-RM100

Jannah:
+RM300
+RM150

Total:
500 + 200 - 100 + 300 + 150
= RM1,050

Progress percentage:

Progress %
=
(Current Progress / Target Amount) × 100

The implementation must define how progress behaves if adjustments cause the calculated value to decrease.

---

# 15. Authorization Rules

Save+1 Pots are private by default.

Only the following users may access an active Pot:

Pot Owner
    +
Active Participant

## Authorization Rules

* A non-member cannot view a Pot.
* A participant cannot edit Pot details.
* A participant cannot edit another participant's contributions.
* A participant cannot delete another participant's contributions.
* Only the owner can invite users.
* Only the invited user can accept or decline their invitation.
* Only the owner can initiate Pot deletion/closure.

---

# 16. Social Sharing

Social sharing is an optional presentation feature.

## Business Rules

* Sharing is always user-triggered.
* Save+1 never automatically publishes financial information.
* Sharing does not make a Pot public.
* No public saving profile is created.
* Users choose when to share a milestone or completed goal.

---

# 17. Reminders

Reminders are designed to encourage both participants.

## V1 Rule

If neither participant makes a positive contribution for **3 consecutive days**, both participants receive a reminder.

When either participant contributes:

Inactivity period
       ↓
    RESET

## Business Rules

* Reminders apply to both participants.
* A reminder should not publicly identify one participant as the inactive person.
* Positive contributions reset the inactivity period.
* Adjustments do not reset the inactivity period.

---

# 18. Domain Invariants

The following conditions must always be true within the domain.

### Pot

* A Pot has exactly one owner.
* A Pot has at least one active participant.
* A Pot has no more than two active participants.
* The owner is an active participant.
* Ownership cannot be transferred.

### Users

* A user can own no more than two active free Pots.
* The ownership limit does not restrict participation in other users' Pots.

### Contributions

* Only participants can create contributions.
* Contribution amounts are positive.
* Future-dated contributions are invalid.
* Users can modify only their own contributions.

### Adjustments

* Only participants can create adjustments.
* Adjustments cannot create an invalid negative balance.
* Adjustments do not count toward saving streaks.

### Invitations

* Only owners can create invitations.
* Only the invited user can respond to an invitation.
* A Pot cannot exceed two active participants.

### Privacy

* Pots are private by default.
* Only authorized participants can access a Pot.

---

# 19. Architectural Boundary

Save+1 is a **savings tracking application**, not a financial custody or payment application.

The domain does not model:

* Bank accounts
* E-wallet accounts
* Money transfers
* Payment processing
* Bank withdrawals
* Deposits into Save+1
* KYC/AML processes

Instead, the domain models:

User
  ↓
Shared Pot
  ↓
Manual Financial Records
  ↓
Calculated Progress

The fundamental boundary is:

> **Save+1 records savings. Save+1 does not move or hold money.**

---

# 20. Deferred V1+ Concepts

The following are intentionally outside the V1 domain:

* More than 2 owned Pots for free users.
* More than 2 participants per Pot.
* Paid subscriptions.
* Advanced analytics.
* Bank integrations.
* E-wallet integrations.
* Actual money transfers.
* Recurring automatic contributions.
* Streak freezes.
* Public profiles.
* Public Pots.
* Ownership transfer.
* Multi-currency support.
* Financial custody.
