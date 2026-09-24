# Save+1 — TDD Test Plan

## 1. Purpose

This document defines the Test-Driven Development (TDD) strategy for Save+1 V1.

The purpose is to ensure that the application's behavior is driven by the requirements, user stories, domain rules, and acceptance criteria defined in the preceding project documents.

The TDD approach follows:

```text
Red
 ↓
Write a failing test
 ↓
Green
 ↓
Write the minimum implementation
 ↓
Refactor
 ↓
Repeat
```

The implementation should not be considered complete merely because the UI works.

A feature is complete when its required behavior is covered by appropriate tests.

---

# 2. Testing Philosophy

Save+1 will prioritize tests around **behavior and business rules**, rather than implementation details.

The most important question is:

> "Does Save+1 behave correctly according to the product rules?"

rather than:

> "Does this particular class contain this particular method?"

---

# 3. Test Pyramid

The project will use multiple testing levels.

```text
                  ┌───────────────┐
                  │  Widget / UI  │
                  │     Tests     │
                  └───────┬───────┘
                          │
                 ┌────────┴────────┐
                 │ Integration /   │
                 │ Firebase Tests  │
                 └────────┬────────┘
                          │
               ┌──────────┴──────────┐
               │   Use Case / State  │
               │       Tests         │
               └──────────┬──────────┘
                          │
             ┌────────────┴────────────┐
             │      Domain Tests       │
             │       (Largest)         │
             └─────────────────────────┘
```

Priority:

1. Domain tests
2. Use-case tests
3. Repository/data tests
4. Riverpod/state tests
5. Widget tests
6. Integration tests

---

# 4. Test Layers

## 4.1 Domain Tests

Test pure business rules without Firebase or Flutter UI.

Examples:

* Contribution amount validation
* Future-date validation
* Progress calculation
* Adjustment validation
* Milestone detection
* Streak calculation
* Participant limits
* Ownership rules
* Leaving behavior
* Deadline decisions

These tests should be fast and deterministic.

---

## 4.2 Use Case Tests

Test application behavior by combining domain rules with repository abstractions.

Examples:

```text
CreatePot
AddContribution
EditContribution
DeleteContribution
AddAdjustment
InviteParticipant
AcceptInvitation
LeavePot
RemoveParticipant
HandleDeadline
```

Dependencies should be mocked/faked.

These tests verify that the application orchestrates the domain correctly.

---

## 4.3 Repository Tests

Test that repositories correctly translate between domain objects and data sources.

Examples:

```text
save contribution
load contributions
update pot
create invitation
accept invitation
```

These tests should verify behavior without unnecessarily testing Firebase itself.

---

## 4.4 Riverpod Tests

Test state behavior.

Examples:

* Loading state
* Loaded state
* Error state
* Adding contribution
* Updating pot state
* Invitation state
* Refresh behavior

Core business rules should not live here.

---

## 4.5 Widget Tests

Test important user-facing behavior.

Examples:

* Add Contribution form validates amount
* Create Pot form validates target
* Owner controls appear for owner
* Participant cannot see owner controls
* Progress is displayed correctly
* Milestone celebration appears
* Leave confirmation appears

Widget tests should focus on meaningful UI behavior rather than pixel-perfect implementation.

---

## 4.6 Integration Tests

Integration tests verify major end-to-end flows using multiple application layers.

Examples:

```text
Sign In
→ Home
→ Create Pot
→ Invite Participant
→ Add Contribution
→ See Updated Progress
```

Integration tests should be fewer than unit/domain tests.

---

# 5. TDD Development Cycle

Each feature follows:

```text
1. Choose one behavior
        ↓
2. Write test
        ↓
3. Run test
        ↓
4. Confirm RED
        ↓
5. Implement minimum behavior
        ↓
6. Run test
        ↓
7. Confirm GREEN
        ↓
8. Refactor
        ↓
9. Run entire test suite
        ↓
10. Move to next behavior
```

Example:

```text
Test:
"Contribution amount must be greater than zero."

RED
↓
Implement validation
↓
GREEN
↓
Refactor
↓
Next rule
```

---

# 6. Test Naming Convention

Tests should describe behavior.

Preferred:

```text
should reject a contribution with zero amount
```

```text
should reject a contribution dated in the future
```

```text
should calculate 50 percent progress for RM5000 of a RM10000 target
```

```text
should allow only the contribution owner to edit a contribution
```

Avoid vague names:

```text
testContribution()
testPot()
testSomething()
```

---

# 7. Test Structure

Tests should generally follow:

```text
Given
When
Then
```

Example:

```text
Given a pot has a RM10,000 target
And RM5,000 has been saved

When progress is calculated

Then progress should be 50%
```

This keeps tests aligned with requirements.

---

# 8. Domain Test Plan

## 8.1 Money

Save+1 stores monetary values as integer sen.

### Tests

```text
should represent RM1.00 as 100 sen
should represent RM10.50 as 1050 sen
should represent RM999.99 as 99999 sen
should reject negative monetary values where prohibited
```

Floating-point arithmetic should not be used as the source of truth for stored money.

---

# 9. Pot Creation Tests

## Happy Path

```text
Given a user owns fewer than two active pots

When they create a pot with a valid name and target

Then the pot should be created
And the creator should become the owner
And the creator should become an active participant
And initial savings should be RM0
```

## Target Validation

```text
should reject a target of RM0
should reject a negative target
should accept a positive target
```

## Name Validation

```text
should reject an empty pot name
should reject a whitespace-only pot name
should accept a valid pot name
```

## Free Pot Limit

```text
Given Person A owns two active pots

When Person A attempts to create another pot

Then creation should be rejected
```

## Joined Pot Does Not Consume Creation Limit

```text
Given Person A owns two active pots
And Person A participates in another person's pot

When Person A checks their owned-pot limit

Then Person A should still have two owned active pots
```

---

# 10. Participant Tests

## Participant Limit

```text
Given a pot has one active participant

When the owner invites another user
And that user accepts

Then the pot should have two active participants
```

```text
Given a pot already has two active participants

When another invitation is attempted

Then the invitation should be rejected
```

## Owner Rule

```text
should create exactly one owner
```

```text
should keep the owner as an active participant
```

```text
should reject ownership transfer
```

```text
should reject a pot with multiple owners
```

---

# 11. Invitation Tests

## Sending Invitation

```text
Given Person A owns a pot with one participant

When Person A invites Person B

Then an invitation should be created
And its status should be pending
```

## Permission

```text
Given Person B is a participant

When Person B attempts to invite another user

Then the action should be rejected
```

## Accept

```text
Given Person B has a pending invitation

When Person B accepts

Then the invitation should become accepted
And Person B should become an active participant
```

## Decline

```text
Given Person B has a pending invitation

When Person B declines

Then the invitation should become declined
And Person B should not become a participant
```

## Unauthorized Response

```text
Given Person B received an invitation

When Person C attempts to accept it

Then the action should be rejected
```

---

# 12. Contribution Tests

## Valid Contribution

```text
Given Person A is an active participant

When Person A records RM50

Then the contribution should be created
And RM50 should be added to shared savings
```

## Amount

```text
should reject RM0
should reject negative amounts
should accept positive amounts
```

## Future Date

```text
Given today is 24 September 2026

When a contribution is recorded for 25 September 2026

Then the contribution should be rejected
```

## Backdated Contribution

```text
Given today is 24 September 2026

When a contribution is recorded for 20 September 2026

Then the contribution should be accepted
```

## Ownership

```text
Given Person A owns a contribution

When Person B attempts to edit it

Then the action should be rejected
```

```text
Given Person A owns a contribution

When Person B attempts to delete it

Then the action should be rejected
```

## Participant Requirement

```text
Given Person B has left the pot

When Person B attempts to add a contribution

Then the action should be rejected
```

---

# 13. Contribution Editing Tests

```text
Given Person A has a RM50 contribution

When Person A changes it to RM75

Then the contribution should become RM75
And shared savings should be recalculated
```

```text
Given Person A has a contribution

When Person B attempts to edit it

Then the action should be rejected
And the original contribution should remain unchanged
```

Editing should also re-evaluate derived values such as:

* Progress
* Streak
* Milestones where applicable

---

# 14. Contribution Deletion Tests

```text
Given Person A has a RM50 contribution

When Person A deletes it

Then the contribution should no longer count toward shared savings
```

```text
Given Person A owns a contribution

When Person B attempts to delete it

Then deletion should be rejected
```

Deletion should trigger recalculation of relevant derived values.

---

# 15. Progress Calculation Tests

The core formula is:

```text
Current Savings
=
Total Contributions
-
Total Adjustments
```

## Example

```text
Given:
Target = RM10,000
Contributions = RM6,000
Adjustments = RM500

When progress is calculated

Then current savings = RM5,500
And progress = 55%
```

## Zero Progress

```text
Given:
Target = RM10,000
Contributions = RM0
Adjustments = RM0

Then progress = 0%
```

## Complete Progress

```text
Given:
Target = RM10,000
Current savings = RM10,000

Then progress = 100%
And the goal should be considered complete
```

## Progress Above Target

The domain must define behavior if recorded savings exceed the target.

The implementation should not silently invent behavior.

A test must be created once the final product rule is selected.

---

# 16. Adjustment Tests

## Valid Adjustment

```text
Given current savings are RM500

When Person A records a RM100 adjustment

Then current savings should become RM400
```

## Invalid Balance

```text
Given current savings are RM50

When Person A attempts a RM100 adjustment

Then the adjustment should be rejected
And current savings should remain RM50
```

## Positive Storage Value

```text
Given an adjustment of RM100

Then the stored adjustment amount should be 100 sen × 100
And its semantic effect should be subtraction
```

## Adjustment Does Not Create Saving Day

```text
Given Person A has no contribution today

When Person A records an adjustment today

Then today should not count as a saving day
```

---

# 17. Streak Tests

## First Saving Day

```text
Given Person A has no previous saving activity

When Person A makes a positive contribution today

Then Person A's streak should become 1
```

## Consecutive Days

```text
Given Person A contributed yesterday

When Person A contributes today

Then the streak should increase by 1
```

## Multiple Contributions

```text
Given Person A makes three contributions today

Then today should count as one saving day
```

## Missing Day

```text
Given Person A contributed two days ago
And Person A made no contribution yesterday

When Person A contributes today

Then the previous consecutive streak should not continue through yesterday
```

## Adjustment

```text
Given Person A makes only an adjustment today

Then today should not count as a saving day
```

---

# 18. Milestone Tests

Required milestones:

```text
25%
50%
75%
100%
```

## 25%

```text
Given progress is 24%

When a contribution increases progress to 25%

Then the 25% milestone should be achieved
```

## 50%

```text
Given progress is 49%

When progress reaches 50%

Then the 50% milestone should be achieved
```

Equivalent tests should exist for:

* 75%
* 100%

## No Duplicate Milestone

```text
Given the 50% milestone has already been achieved

When progress changes from 50% to 55%

Then another 50% milestone should not be created
```

## Milestone History

Milestone records should remain consistent with the defined domain rule if progress later decreases.

This behavior must be explicitly tested once the final milestone rollback policy is implemented.

---

# 19. Goal Completion Tests

```text
Given:
Target = RM10,000
Current savings = RM9,950

When Person B contributes RM50

Then current savings = RM10,000
And the goal should become completed
```

The completion behavior should be tested independently from deadline handling.

---

# 20. Deadline Tests

## Deadline Not Reached

```text
Given the deadline is tomorrow

When the pot is viewed today

Then the pot should remain active
```

## Deadline Reached — Completed

```text
Given the deadline has arrived
And the target has been reached

Then the goal should be completed
```

## Deadline Reached — Incomplete

```text
Given the deadline has arrived
And the target has not been reached

Then the goal should not automatically be marked as failed
And the user should be offered deadline decisions
```

## Extend

```text
Given an unfinished pot has reached its deadline

When the user chooses Extend Deadline

Then a new valid deadline should be stored
And the pot should remain active
```

## Remove Deadline

```text
Given an unfinished pot has reached its deadline

When the user chooses Keep Open Without Deadline

Then deadline should become null
And the pot should remain active
```

## End

```text
Given an unfinished pot has reached its deadline

When the user chooses End & Archive

Then the pot should become ended
And it should no longer appear among active pots
```

---

# 21. Participant Leaving Tests

## Participant Leaves

```text
Given Person B is an active participant
And Person B has contributed RM2,000

When Person B leaves the pot

Then Person B should become inactive
And Person B's contribution should no longer count toward active shared progress
And the pot should remain available to the remaining participant
```

Historical records should be preserved according to the database lifecycle rules.

## Cannot Contribute After Leaving

```text
Given Person B has left

When Person B attempts to add a contribution

Then the action should be rejected
```

## Cannot Access Active Pot

```text
Given Person B has left

When Person B attempts to access the active pot

Then access should be denied
```

---

# 22. Owner Leaving Tests

```text
Given Person A is the owner

When Person A leaves the pot

Then ownership should not transfer
And the pot should become closed/deleted
And the pot should no longer be accessible as an active pot
```

## No Ownership Transfer

```text
Given Person A owns a pot
And Person B is the participant

When Person A leaves

Then Person B should not automatically become owner
```

---

# 23. Owner Permission Tests

Owner can:

```text
edit pot name
edit target
edit deadline
invite participant
remove participant
close/end pot
```

Owner cannot:

```text
edit participant's contribution
delete participant's contribution
transfer ownership
```

Each rule should have both:

* Authorized test
* Unauthorized test

---

# 24. Participant Permission Tests

Participant can:

```text
view pot
add contribution
edit own contribution
delete own contribution
add adjustment
view activity
leave pot
```

Participant cannot:

```text
edit pot settings
invite another participant
remove another participant
transfer ownership
edit partner's contribution
delete partner's contribution
```

---

# 25. Privacy Tests

```text
Given Person A and Person B are participants of a pot

When Person C attempts to access the pot

Then access should be denied
```

```text
Given Person B has left a pot

When Person B attempts to access the active pot

Then access should be denied
```

Private data should not become accessible merely because a user knows the pot ID.

---

# 26. Reminder Tests

## Inactivity

```text
Given both participants have made no positive contribution
for three consecutive days

When the reminder condition is evaluated

Then both participants should receive a reminder
```

## Reset

```text
Given the pot has reached the inactivity threshold

When either participant makes a positive contribution

Then the shared inactivity period should reset
```

## Adjustment Does Not Reset Saving Activity

```text
Given neither participant has made a positive contribution

When an adjustment is recorded

Then the inactivity period should not be treated as a saving day
```

## Neutral Reminder

Reminder content should not identify one participant as the cause of inactivity.

---

# 27. Authentication Tests

## Registration

```text
should create a new account with valid credentials
should reject invalid email
should reject invalid password
should reject duplicate account where applicable
```

## Sign In

```text
should sign in with valid credentials
should reject invalid credentials
```

## User Association

```text
Given Person A signs in

When Person A loads their pots

Then only pots accessible to Person A should be returned
```

---

# 28. Use Case Test Matrix

| Use Case           | Main Behaviors                         |
| ------------------ | -------------------------------------- |
| CreatePot          | validation, owner creation, free limit |
| ViewPot            | authorization, progress                |
| EditPot            | owner-only                             |
| InviteParticipant  | owner-only, participant limit          |
| AcceptInvitation   | invited-user-only, membership creation |
| DeclineInvitation  | invited-user-only                      |
| AddContribution    | validation, participant permission     |
| EditContribution   | owner-of-contribution only             |
| DeleteContribution | owner-of-contribution only             |
| AddAdjustment      | validation, balance                    |
| CalculateProgress  | contributions - adjustments            |
| CalculateStreak    | consecutive saving days                |
| EvaluateMilestones | 25/50/75/100                           |
| HandleDeadline     | complete/extend/no deadline/end        |
| LeavePot           | participant vs owner behavior          |
| RemoveParticipant  | owner-only                             |
| SendReminder       | inactivity logic                       |

---

# 29. Riverpod State Tests

State should generally follow:

```text
Initial
   ↓
Loading
   ↓
Loaded
```

or:

```text
Initial
   ↓
Loading
   ↓
Error
```

## Pot State

Test:

```text
should load pot
should expose current progress
should expose participants
should expose activity
should expose loading state
should expose error state
```

## Contribution State

Test:

```text
should submit contribution
should show loading state
should update state after success
should expose error after failure
```

Business validation should remain in domain/use cases rather than being duplicated inside the provider.

---

# 30. Widget Test Plan

## Home

Test:

```text
should display owned pots
should display joined pots
should display empty state when no pots exist
should allow navigation to create pot
```

## Create Pot

Test:

```text
should display required fields
should reject empty name
should reject invalid target
should submit valid pot
```

## Pot Detail

Test:

```text
should display pot name
should display current savings
should display target
should display progress
should display participants
should display activity
should display streak
```

## Role-Based UI

Owner:

```text
should display owner controls
```

Participant:

```text
should not display owner-only controls
```

## Contribution

Test:

```text
should accept valid amount
should reject zero amount
should reject future date
should submit valid contribution
```

---

# 31. Confirmation Dialog Tests

Important destructive actions should have UI tests.

## Delete Contribution

```text
should show confirmation before deletion
should cancel without deleting
should delete after confirmation
```

## Remove Participant

```text
should explain the consequence
should cancel without removing
should remove after confirmation
```

## Participant Leave

```text
should explain contribution effect
should cancel without leaving
should leave after confirmation
```

## Owner Leave

```text
should show permanent deletion warning
should cancel without deleting pot
should close/delete after confirmation
```

---

# 32. Integration Test Scenarios

Integration tests should cover the most important end-to-end user journeys.

## Scenario 1 — Create Pot

```text
Sign In
→ Home
→ Create Pot
→ Enter details
→ Create
→ Pot Detail
```

Expected:

```text
Pot exists
Owner exists
Participant exists
Progress = 0%
```

---

## Scenario 2 — Invite +1

```text
Person A creates pot
→ Person A invites Person B
→ Person B signs in
→ Person B accepts invitation
→ Person B opens pot
```

Expected:

```text
Person A = owner
Person B = participant
Active participants = 2
```

---

## Scenario 3 — Shared Contribution

```text
Person A contributes RM100
→ Person B sees updated progress
→ Person B contributes RM50
→ Person A sees updated progress
```

Expected:

```text
Shared savings = RM150
```

---

## Scenario 4 — Milestone

```text
Contributions
→ Progress reaches 25%
→ Milestone appears
```

Expected:

```text
25% milestone recorded once
```

---

## Scenario 5 — Participant Leaves

```text
Person A = owner
Person B = participant

Person A = RM500
Person B = RM300

Person B leaves
```

Expected:

```text
Active shared savings = RM500
Person B inactive
Pot remains active
```

---

## Scenario 6 — Owner Leaves

```text
Person A = owner
Person B = participant

Person A leaves
```

Expected:

```text
Pot becomes closed/deleted
No ownership transfer
Pot no longer active
```

---

## Scenario 7 — Deadline

```text
Pot reaches deadline
Target not reached
```

Expected:

```text
User receives:
Extend
Keep Open Without Deadline
End & Archive
```

---

# 33. Security / Backend Tests

Client-side tests are not sufficient.

Backend authorization must also be tested.

Important rules:

```text
Only active participants can access pot
Only owner can modify pot settings
Only owner can invite
Only invited user can accept invitation
Only contribution owner can edit/delete contribution
Only owner can remove participant
Users cannot access another user's private pot
```

These tests should eventually run against a Firebase test environment/emulator where practical.

---

# 34. Atomic Operation Tests

Operations that modify multiple pieces of data must be tested for consistency.

## Accept Invitation

Expected atomic behavior:

```text
Invitation
    ↓
Accepted
    +
Participant created
```

The system should not end up with:

```text
Invitation = accepted
Participant = missing
```

---

## Owner Leaving

Expected:

```text
Owner membership updated
+
Pot closed/deleted
```

The system should not leave an active pot without an owner.

---

## Milestone

Expected:

```text
Milestone achieved
```

should not result in duplicate milestone records when the same threshold is evaluated repeatedly.

---

# 35. Regression Testing

After implementing each feature:

```text
Feature Test
    ↓
Run Feature Tests
    ↓
Run Entire Test Suite
```

A previously passing test must not be ignored because a new feature was added.

Example:

Adding adjustments should not break:

* Contribution calculations
* Progress
* Streaks
* Milestones
* Goal completion

---

# 36. Test Coverage Priorities

Not every line of code has equal importance.

Priority should be:

### Critical

* Money calculations
* Progress calculation
* Contribution validation
* Adjustment validation
* Authorization
* Participant limits
* Ownership rules
* Leaving behavior
* Deadline behavior
* Milestones
* Streaks

### Important

* Use case orchestration
* Repository behavior
* Riverpod state transitions
* Form validation

### Supporting

* UI rendering
* Navigation
* Empty states
* Loading states

The objective is **meaningful behavioral coverage**, not blindly maximizing a coverage percentage.

---

# 37. Suggested Test Directory

The test structure should mirror the application's architecture.

```text
test/
├── core/
│   ├── errors/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   ├── application/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── pots/
│   │   ├── domain/
│   │   ├── application/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── contributions/
│   ├── invitations/
│   ├── milestones/
│   ├── streaks/
│   └── reminders/
│
└── integration/
```

The exact folder names can be adjusted to match the final implementation structure.

---

# 38. First TDD Implementation Order

The recommended implementation sequence is:

```text
1. Money / primitive value handling
          ↓
2. User
          ↓
3. Pot
          ↓
4. Participant
          ↓
5. Contribution
          ↓
6. Progress calculation
          ↓
7. Adjustment
          ↓
8. Streak
          ↓
9. Milestones
          ↓
10. Invitations
          ↓
11. Pot lifecycle
          ↓
12. Deadline
          ↓
13. Use cases
          ↓
14. Repositories
          ↓
15. Riverpod state
          ↓
16. UI
          ↓
17. Firebase integration
          ↓
18. End-to-end integration tests
```

The actual order may change where dependencies require it, but business rules should remain test-first.

---

# 39. Definition of Done

A feature is considered complete when:

* [ ] Requirement is clearly defined
* [ ] Domain behavior is defined
* [ ] Test is written
* [ ] Test initially fails where appropriate
* [ ] Minimum implementation makes test pass
* [ ] Code is refactored
* [ ] Related tests pass
* [ ] Existing tests still pass
* [ ] Authorization behavior is covered
* [ ] Error behavior is covered
* [ ] Relevant UI behavior is covered
* [ ] Documentation remains consistent

---

# 40. TDD Golden Rule

For Save+1:

> **If a business rule matters enough to be written in the requirements, it matters enough to be tested.**

The implementation should emerge from the tests rather than the tests being written afterward merely to validate already-written code.

The intended development loop is:

```text
Requirement
    ↓
User Story
    ↓
Acceptance Criteria
    ↓
Domain Rule
    ↓
Test
    ↓
Implementation
    ↓
Refactor
    ↓
UI
```

---

# 41. Final TDD Strategy

Save+1 will use TDD primarily to protect its **business behavior**, especially around shared savings.

The highest-risk areas are:

```text
Money
Progress
Adjustments
Streaks
Milestones
Participants
Permissions
Leaving
Deadlines
```

These areas should receive the strongest automated test coverage.

The UI should then be built on top of already-tested behavior rather than becoming the source of truth for business rules.

The ultimate development loop is:

```text
                 ┌───────────────┐
                 │   Requirement │
                 └───────┬───────┘
                         ↓
                 ┌───────────────┐
                 │     Test      │
                 └───────┬───────┘
                         ↓
                       RED
                         ↓
                 ┌───────────────┐
                 │ Implementation│
                 └───────┬───────┘
                         ↓
                      GREEN
                         ↓
                    REFACTOR
                         ↓
                 ┌───────────────┐
                 │  Next Rule    │
                 └───────┬───────┘
                         │
                         └──────────────→ Repeat
```

**Save+1 V1 is not considered implementation-ready because the UI has been designed. It is implementation-ready because the behavior has been specified sufficiently to write the tests that will drive the implementation.**
