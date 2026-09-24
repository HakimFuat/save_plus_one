# Save+1 — UI/UX Flow

## 1. Purpose

This document defines the V1 user interface and user experience flow for Save+1.

Save+1 is a shared savings accountability app where two people work toward a shared savings goal.

The application tracks manually recorded savings and progress. It does not hold, transfer, or process real money.

> **Core UX principle:** Save+1 tracks savings; it does not hold savings.

The UI should make saving together feel:

* Simple
* Collaborative
* Encouraging
* Transparent
* Private
* Low-friction

V1 should prioritize the core saving experience over advanced customization.

---

# 2. UX Principles

## 2.1 Shared Progress

The primary focus of the application should be the shared goal.

Users should quickly understand:

* How much has been saved
* How much remains
* Percentage of progress
* Who contributed
* Current streak
* Upcoming deadline, if any

---

## 2.2 Mutual Accountability

The application should encourage both participants without creating unnecessary pressure.

Notifications and activity should feel like:

> "Let's keep going."

Rather than:

> "Your partner hasn't saved."

The app should avoid language that publicly blames or shames either participant.

---

## 2.3 Transparency

Both active participants can see:

* Shared progress
* Individual contributions
* Contribution history
* Adjustments
* Milestones
* Participant status

Users should not have hidden financial activity inside a shared pot.

---

## 2.4 Minimal Friction

The main saving action should require as few steps as practical.

Ideal flow:

```text
Pot Detail
    ↓
Add Contribution
    ↓
Enter Amount
    ↓
Confirm
    ↓
Updated Progress
```

---

## 2.5 Private by Default

Pots are private.

Only the owner and active participant can access a pot.

Social sharing is always opt-in.

The application should never automatically publish:

* Savings amount
* Pot name
* Partner information
* Contribution history
* Financial progress

---

# 3. Application Navigation

The V1 navigation structure is:

```text
Launch
  │
  ├── Authentication
  │     ├── Sign In
  │     └── Create Account
  │
  └── Authenticated
          │
          └── Home
                │
                ├── Create Pot
                │
                ├── Pot Detail
                │     ├── Add Contribution
                │     ├── Contribution History
                │     ├── Adjustment
                │     ├── Participant Management
                │     ├── Milestones
                │     ├── Deadline Management
                │     └── Leave / Close Pot
                │
                ├── Invitations
                │
                └── Profile / Settings
```

The exact visual navigation component can be selected during implementation. The logical navigation structure above is the V1 requirement.

---

# 4. Screen Map

| Screen                 | Purpose                        | Access              |
| ---------------------- | ------------------------------ | ------------------- |
| Splash / Auth Gate     | Determine authentication state | Everyone            |
| Sign In                | Authenticate existing user     | Unauthenticated     |
| Create Account         | Create account                 | Unauthenticated     |
| Home                   | View owned and joined pots     | Authenticated       |
| Create Pot             | Create a shared savings goal   | Authenticated       |
| Pot Detail             | Main shared saving workspace   | Active participants |
| Add Contribution       | Record savings                 | Active participants |
| Edit Contribution      | Modify own contribution        | Contribution owner  |
| Delete Contribution    | Remove own contribution        | Contribution owner  |
| Adjustment             | Record reduction to savings    | Active participants |
| Invite Participant     | Invite a +1                    | Pot owner           |
| Invitations            | View/respond to invitations    | Authenticated       |
| Participant Management | Manage +1                      | Pot owner           |
| Milestone Celebration  | Celebrate achievement          | Active participants |
| Goal Complete          | Celebrate completed goal       | Active participants |
| Deadline Decision      | Handle unfinished goal         | Active participants |
| Leave Pot              | Confirm leaving                | Active participant  |
| Profile / Settings     | Account and app settings       | Authenticated       |

---

# 5. Splash / Authentication Gate

## Purpose

Determine whether the user is authenticated and route them to the appropriate starting screen.

## Possible States

### Loading

Display a simple Save+1 loading state.

```text
Save+1

Loading...
```

### Authenticated

Navigate to Home.

### Unauthenticated

Navigate to Sign In.

### Authentication Error

Display a retry option.

---

# 6. Sign In

## Purpose

Allow an existing user to authenticate.

## UI Elements

* Email field
* Password field
* Sign In button
* Create Account navigation
* Forgot password option if supported by the authentication implementation

## Validation

Email:

* Required
* Valid email format

Password:

* Required

## Error States

Examples:

```text
Invalid email or password.
```

```text
Please enter your email.
```

```text
Something went wrong. Please try again.
```

Do not expose unnecessary authentication details.

---

# 7. Create Account

## Purpose

Allow a new user to create a Save+1 account.

## UI Elements

* Display name
* Email
* Password
* Confirm password
* Create Account button

## Validation

* Display name required
* Email required and valid
* Password required
* Password confirmation must match
* Duplicate account rejected

## Success

After successful registration:

```text
Account created
      ↓
Home
```

---

# 8. Home

## Purpose

Provide the user's overview of their saving activity.

The Home screen should immediately answer:

> "What am I saving for, and how am I doing?"

## Main Sections

### Owned Pots

Display pots created by the user.

Example:

```text
My Pots

Vacation Fund
RM 5,500 / RM 10,000
55%

Emergency Fund
RM 1,200 / RM 5,000
24%
```

The free V1 limit is two owned active pots.

### Joined Pots

Display pots where the user participates but is not the owner.

Example:

```text
Shared With Me

Laptop Fund
RM 1,750 / RM 4,000
43%
```

Joining another user's pot does not consume the user's owned-pot creation limit.

---

## Empty State

If the user owns no pots:

```text
No saving pots yet.

Start a goal and invite your +1.

[ Create a Pot ]
```

If the user has no joined pots:

```text
No shared pots yet.

Invitations will appear here when someone invites you.
```

---

## Home Actions

* Create Pot
* Open existing pot
* View invitations
* Open profile/settings

---

# 9. Create Pot

## Purpose

Allow a user to create a shared savings goal.

## Required Information

* Pot name
* Target amount

## Optional Information

* Deadline

## Example

```text
Create a Pot

Pot Name
[ Vacation Fund ]

Target
[ RM 10,000 ]

Deadline
[ 30 Dec 2026 ]

[ Create Pot ]
```

## Validation

### Pot Name

* Required
* Must not be blank

### Target

* Required
* Greater than RM0
* MYR only

### Deadline

If provided:

* Must be a valid date
* Must not violate the domain's date requirements

---

## Success

After creation:

```text
Create Pot
     ↓
Pot Detail
```

The creator automatically becomes:

* Owner
* Active participant

Initial progress:

```text
RM 0 / Target
0%
```

---

# 10. Pot Detail

## Purpose

This is the primary screen of Save+1.

It should be the central workspace for both participants.

## Main Information

Display:

* Pot name
* Current savings
* Target
* Progress percentage
* Remaining amount
* Deadline, if present
* Participants
* Individual contribution totals
* Current streak
* Recent activity
* Milestone progress

Example:

```text
Vacation Fund

RM 5,500
of RM 10,000

███████████░░░░░░░░░
55%

RM 4,500 remaining

👤 Person A     RM 3,000
👤 Person B     RM 2,500

🔥 6 day streak

Deadline
30 Dec 2026
```

---

## Primary Action

The most prominent action should be:

```text
+ Add Contribution
```

This should be easily accessible.

---

## Secondary Actions

Depending on the user's role:

### Participant

* Add contribution
* View activity
* Manage own contributions
* Add adjustment
* Leave pot

### Owner

* Add contribution
* View activity
* Manage own contributions
* Add adjustment
* Manage participant
* Edit pot
* Handle deadline
* Close/delete pot
* Leave pot

---

# 11. Contribution History

## Purpose

Provide transparent saving activity.

Example:

```text
Activity

Today

Person A
+ RM50
"Weekly saving"

Person B
+ RM100

Yesterday

Person A
+ RM30
```

Users should be able to distinguish:

* Contribution
* Adjustment

Example:

```text
Person A
− RM100
Adjustment
"Emergency expense"
```

---

# 12. Add Contribution

## Purpose

Allow an active participant to record savings.

## UI

```text
Add Contribution

Amount
[ RM 50.00 ]

Date
[ Today ]

Note
[ Optional ]

[ Save Contribution ]
```

## Rules

* Amount must be greater than RM0
* MYR only
* Date cannot be in the future
* User must be an active participant

## Date

The user may backdate a contribution.

Example:

```text
Today
Yesterday
12 Sep 2026
```

Future dates must be rejected.

## Success

After saving:

```text
Contribution recorded!
```

Then return to Pot Detail with updated:

* Total
* Progress
* Personal contribution
* Activity
* Streak
* Milestones if applicable

---

# 13. Edit Contribution

## Purpose

Allow a user to correct their own contribution.

The user can edit:

* Amount
* Date
* Note

The user cannot edit another participant's contribution.

## Example

```text
Edit Contribution

RM 50.00
12 Sep 2026

Note:
Weekly saving

[ Save Changes ]
[ Delete Contribution ]
```

## Permission

Person A can edit Person A's contribution.

Person A cannot edit Person B's contribution.

---

# 14. Delete Contribution

## Purpose

Allow users to remove their own incorrectly recorded contribution.

## Confirmation

Use a confirmation dialog:

```text
Delete contribution?

RM 50.00 from 12 Sep 2026
will be removed from this pot.

[ Cancel ]
[ Delete ]
```

After deletion:

* Shared progress recalculates
* Personal total recalculates
* Activity updates
* Streak recalculates where applicable
* Milestone behavior follows the domain rules

---

# 15. Adjustment

## Purpose

Record a reduction to previously tracked savings without implying that Save+1 physically moved money.

The UI should avoid calling this a "withdrawal."

Use:

> **Adjustment**

## Example

```text
Add Adjustment

Amount
[ RM 100.00 ]

Date
[ Today ]

Reason / Note
[ Emergency expense ]

This will reduce the recorded savings
for this pot.

[ Confirm Adjustment ]
```

## Important UX Explanation

Because Save+1 does not hold money:

> "This adjustment only changes the savings amount recorded in Save+1. It does not move money from a bank or wallet."

## Rules

* Amount must be greater than RM0
* Cannot create an invalid savings balance
* Adjustment does not count toward a saving day
* Adjustment appears in activity/history

---

# 16. Invite Participant

## Purpose

Allow the owner to invite one +1.

## UI

```text
Invite Your +1

Email
[ personb@example.com ]

[ Send Invite ]
```

## States

### Pending

```text
Invitation sent

Waiting for Person B to respond.
```

### Accepted

The participant becomes active.

### Declined

The invitation becomes declined.

The owner may send another invitation where permitted.

---

## Participant Limit

A pot can have a maximum of two active participants:

```text
Owner
  +
1 Participant
```

If the pot already has two active participants:

```text
This pot already has two active participants.
```

The invite action should not be available.

---

# 17. Invitations

## Purpose

Allow users to review invitations they have received.

Example:

```text
Invitations

Person A invited you to:

Vacation Fund

Target
RM 10,000

[ Accept ]
[ Decline ]
```

## Invitation Rules

Only the invited account can respond.

Possible states:

```text
Pending
Accepted
Declined
```

---

# 18. Participant Management

## Owner Only

The owner can view and manage the active participant.

Example:

```text
Participants

Person A
Owner

Person B
Participant

[ Remove Participant ]
```

## Remove Participant

Removing a participant should clearly explain the effect on the pot.

Because the participant's contribution affects shared progress, the confirmation should state that their contribution will no longer count toward the active shared total.

Example:

```text
Remove Person B?

Person B will be removed from this pot.
Their recorded contribution will no longer
count toward the active shared progress.

[ Cancel ]
[ Remove ]
```

The exact backend treatment of historical records follows the domain/database rules.

---

# 19. Streak Display

## Purpose

Encourage consistent saving.

Example:

```text
🔥 7 day streak

You and your +1 are keeping the momentum going!
```

The streak is based on contribution activity.

## Rules

A participant gets a saving day when they make at least one positive contribution on that calendar day.

Therefore:

```text
1 contribution today = 1 saving day
5 contributions today = 1 saving day
0 contributions today = no saving day
Adjustment only = no saving day
```

The UI should not imply that multiple contributions on one day produce multiple streak days.

---

# 20. Milestones

## Milestones

Save+1 recognizes:

* 25%
* 50%
* 75%
* 100%

Example:

```text
🎉 50% Milestone!

You've saved RM5,000
toward your RM10,000 goal.

Keep going!
```

## Milestone Trigger

When progress reaches a new milestone:

```text
Pot Detail
    ↓
Milestone Celebration
    ↓
Continue
```

The milestone should only trigger once.

---

# 21. Social Sharing

## Purpose

Allow users to optionally celebrate progress outside the app.

Social sharing is user-triggered.

It should never happen automatically.

## Example

```text
Share Your Milestone

You reached 50% of your goal!

[ Share ]
[ Not Now ]
```

The generated share content should avoid exposing unnecessary private information.

Example share card:

```text
Save+1

50% of our goal reached! 🎉

Saving together.
Staying accountable.
```

The user should explicitly initiate sharing.

---

# 22. Goal Complete

## Trigger

When the shared savings reaches 100% of the target, the pot reaches the completed state according to the domain rules.

## Celebration

Example:

```text
🎉 Goal Complete!

Vacation Fund

RM10,000 / RM10,000

You did it together!

[ Celebrate & Share ]
[ Continue ]
```

The UI should clearly distinguish:

```text
Goal Complete
```

from:

```text
Deadline Reached
```

A goal can reach completion before its deadline.

---

# 23. Deadline Reached

## Scenario A — Target Reached

If the target has already been reached:

```text
Goal Complete
```

No unfinished-goal decision is required.

---

## Scenario B — Target Not Reached

When the deadline arrives and the target has not been reached, do not automatically mark the goal as failed.

Show:

```text
Your deadline has arrived.

You've saved RM7,300
of RM10,000.

What would you like to do?
```

Options:

```text
[ Extend Deadline ]

[ Keep Open Without Deadline ]

[ End & Archive Goal ]
```

---

# 24. Extend Deadline

## Purpose

Allow participants to continue the goal.

Example:

```text
Extend Deadline

Current deadline:
30 Dec 2026

New deadline:
[ 31 Jan 2027 ]

[ Confirm ]
```

After confirmation:

```text
Pot remains active.
```

---

# 25. Keep Open Without Deadline

## Purpose

Allow participants to continue saving without a deadline.

Confirmation:

```text
Remove deadline?

This pot will remain open until
you complete or end the goal.

[ Cancel ]
[ Keep Open ]
```

---

# 26. End & Archive Goal

## Purpose

Allow participants to intentionally stop an unfinished goal.

Confirmation:

```text
End this goal?

The pot will be archived and no longer
appear as an active saving goal.

[ Cancel ]
[ End Goal ]
```

Once ended:

```text
Pot Status = Ended
```

The goal is removed from active views and retained according to the application's data lifecycle rules.

---

# 27. Participant Leaving

## Participant Leaves

A participant can leave a pot.

Before leaving:

```text
Leave this pot?

Your participation will end and your
recorded contribution will no longer count
toward the active shared progress.

The pot will remain available to the other participant.

[ Cancel ]
[ Leave Pot ]
```

After leaving:

* Participant becomes inactive
* Their contribution is excluded from active shared progress
* Pot remains active for the remaining participant
* Pot remains private

---

# 28. Owner Leaving

The owner cannot transfer ownership.

Leaving as owner therefore has a significantly different effect.

Show a strong warning:

```text
Leave this pot?

You are the owner of this pot.

Leaving will permanently delete the pot
and its saving history for all participants.

This action cannot be undone.

[ Cancel ]
[ Delete Pot ]
```

The final action should be visually distinct from ordinary actions.

After confirmation:

```text
Pot
  ↓
Closed / Deleted
  ↓
Return to Home
```

User-facing behavior:

> The pot disappears for all participants.

The backend may use a soft-delete/closed state for data integrity.

---

# 29. Owner Pot Settings

Owner-only settings include:

* Edit pot name
* Edit target
* Edit deadline
* Manage participant
* Invite participant
* Close/end pot where applicable

Participants should not see controls they are not authorized to use.

However:

> Hiding a control in the UI is not a security mechanism.

Authorization must also be enforced by the backend.

---

# 30. Participant View vs Owner View

| Feature                     | Owner | Participant |
| --------------------------- | ----: | ----------: |
| View pot                    |     ✅ |           ✅ |
| Add contribution            |     ✅ |           ✅ |
| Edit own contribution       |     ✅ |           ✅ |
| Delete own contribution     |     ✅ |           ✅ |
| Add adjustment              |     ✅ |           ✅ |
| View partner activity       |     ✅ |           ✅ |
| View milestones             |     ✅ |           ✅ |
| Invite +1                   |     ✅ |           ❌ |
| Edit pot                    |     ✅ |           ❌ |
| Remove participant          |     ✅ |           ❌ |
| Leave pot                   |     ✅ |           ✅ |
| Transfer ownership          |     ❌ |           ❌ |
| Edit partner contribution   |     ❌ |           ❌ |
| Delete partner contribution |     ❌ |           ❌ |

---

# 31. Loading States

Every network-dependent screen should have a meaningful loading state.

Avoid displaying an empty screen while data is loading.

Example:

```text
Loading your pots...
```

For Pot Detail:

```text
Loading pot...
```

Where appropriate, skeleton UI can be used instead of text-only loading indicators.

---

# 32. Empty States

Empty states should explain what happened and what the user can do next.

### No Pots

```text
No saving pots yet.

Create your first shared goal.

[ Create a Pot ]
```

### No Activity

```text
No saving activity yet.

Be the first to contribute!
```

### No Invitations

```text
No pending invitations.
```

### No Participant Yet

```text
Your +1 hasn't joined yet.

[ Invite +1 ]
```

---

# 33. Error States

Errors should be understandable and actionable.

Avoid technical messages such as:

```text
FirestoreException: PERMISSION_DENIED
```

Instead:

```text
You don't have permission to perform this action.
```

Or:

```text
We couldn't save your contribution.

Please try again.
```

For retryable errors:

```text
Something went wrong.

[ Try Again ]
```

---

# 34. Offline / Connection Behavior

Because Save+1 depends on remote data, the UI should account for connection interruptions.

If a user loses connection while loading:

```text
Couldn't load this pot.

Check your connection and try again.

[ Retry ]
```

For write operations, the application should avoid giving the impression that a contribution was successfully recorded unless the operation has been successfully acknowledged according to the application's data layer.

Example:

```text
Saving contribution...
```

Then:

```text
Contribution recorded!
```

or:

```text
Couldn't record contribution.

[ Try Again ]
```

Offline support can be expanded later if required, but V1 must handle connection failure gracefully.

---

# 35. Reminder Notifications

Both participants receive shared inactivity reminders.

## Reminder Rule

If neither participant contributes for three consecutive days:

```text
Shared inactivity detected
        ↓
Reminder sent to both participants
```

Example notification:

```text
Your saving goal is waiting for you 💪

Make a contribution and keep the momentum going.
```

The notification should not identify one participant as the reason for inactivity.

Avoid:

```text
Person B hasn't saved in 3 days.
```

---

# 36. Reminder Reset

If either participant makes a positive contribution:

```text
Contribution
     ↓
Shared inactivity resets
```

No separate reminder should be generated solely because the other participant has not contributed.

The purpose is shared encouragement.

---

# 37. Privacy UX

The application should communicate privacy clearly.

For example, during pot creation:

```text
Your pot is private.

Only you and your +1 can view this pot
and its saving activity.
```

Social sharing should require an explicit action.

There should be no V1 functionality for:

* Public pots
* Public saving profiles
* Searching for strangers' pots
* Public contribution feeds

---

# 38. Accessibility

V1 should follow basic accessibility principles.

## Text

* Use readable font sizes
* Avoid relying only on color
* Use clear labels

## Buttons

Interactive controls should have sufficiently large touch targets.

## Financial Information

Do not communicate financial status through color alone.

For example:

Bad:

```text
████████
```

with color being the only indicator.

Better:

```text
55%

RM5,500 of RM10,000
```

with the progress indicator as additional visual support.

## Error Messages

Errors should be associated with the relevant field where possible.

---

# 39. Confirmation Strategy

Not every action requires a confirmation dialog.

## No Confirmation Needed

Examples:

* Opening a pot
* Viewing activity
* Viewing milestones

## Confirmation Recommended

Examples:

* Delete contribution
* Add adjustment
* Remove participant
* Leave participant pot
* Owner leaving
* End goal

Destructive actions should explain their consequences before confirmation.

---

# 40. Core User Journeys

## Journey A — Create a Shared Pot

```text
Home
 ↓
Create Pot
 ↓
Enter name
 ↓
Enter target
 ↓
Optional deadline
 ↓
Create
 ↓
Pot Detail
 ↓
Invite +1
```

---

## Journey B — Join a Pot

```text
Invitation
 ↓
View Pot Information
 ↓
Accept
 ↓
Become Active Participant
 ↓
Pot Detail
```

---

## Journey C — Record Savings

```text
Pot Detail
 ↓
Add Contribution
 ↓
Enter amount
 ↓
Select date
 ↓
Optional note
 ↓
Save
 ↓
Updated Progress
 ↓
Possible Streak/Milestone
```

---

## Journey D — Correct a Contribution

```text
Pot Detail
 ↓
Contribution History
 ↓
Own Contribution
 ↓
Edit
 ↓
Save
 ↓
Recalculate Progress
```

---

## Journey E — Record an Adjustment

```text
Pot Detail
 ↓
Adjustment
 ↓
Enter amount
 ↓
Enter reason
 ↓
Confirm
 ↓
Updated Progress
```

An adjustment does not increase a streak.

---

## Journey F — Reach a Milestone

```text
Contribution
 ↓
Progress Reaches 25/50/75/100%
 ↓
Milestone Trigger
 ↓
Celebration
 ↓
Continue
```

---

## Journey G — Reach Goal

```text
Contribution
 ↓
Progress = 100%
 ↓
Goal Complete
 ↓
Celebration
 ↓
Optional Share
```

---

## Journey H — Deadline Reached

```text
Deadline
 ↓
Target reached?
 ├── Yes → Goal Complete
 │
 └── No
       ↓
  Choose action
       ├── Extend deadline
       ├── Remove deadline
       └── End & archive
```

---

## Journey I — Participant Leaves

```text
Pot Detail
 ↓
Leave Pot
 ↓
Warning
 ↓
Confirm
 ↓
Participant becomes inactive
 ↓
Contribution excluded from active progress
 ↓
Pot remains for remaining participant
```

---

## Journey J — Owner Leaves

```text
Pot Detail
 ↓
Leave Pot
 ↓
Strong warning
 ↓
Confirm
 ↓
Pot closed/deleted
 ↓
Return to Home
```

---

# 41. Important UI State Matrix

| Scenario                        | UI Behavior                                           |
| ------------------------------- | ----------------------------------------------------- |
| User has no pots                | Show empty state                                      |
| User owns 2 active pots         | Disable/hide create-pot action                        |
| User joins another user's pot   | Does not consume owned-pot quota                      |
| Pot has 1 participant           | Show invite +1                                        |
| Pot has 2 participants          | Disable further invitation                            |
| Invitation pending              | Show pending status                                   |
| Invitation declined             | Show declined status                                  |
| User is participant             | Hide owner controls                                   |
| User is owner                   | Show owner controls                                   |
| Contribution belongs to user    | Show edit/delete                                      |
| Contribution belongs to partner | Read-only                                             |
| Adjustment recorded             | Reduce progress; no streak                            |
| 25/50/75% reached               | Show milestone                                        |
| 100% reached                    | Show Goal Complete                                    |
| Deadline reached below target   | Show deadline decision                                |
| Participant leaves              | Remove their active contribution from shared progress |
| Owner leaves                    | Close/delete pot                                      |
| Network failure                 | Show retryable error                                  |
| Pot is private                  | Only active participants can access                   |

---

# 42. V1 UX Scope Boundary

The following should **not** be added to V1 unless a requirement is introduced:

* Bank integration
* E-wallet integration
* Automatic money movement
* Payment processing
* Recurring savings
* Streak freezes
* Public profiles
* Public pots
* Leaderboards
* Complex analytics
* Multiple currencies
* Group pots with more than two active participants
* Ownership transfer
* Advanced themes
* Paid features
* Premium subscription flows

These can be considered for future versions.

---

# 43. UX Success Criteria

The V1 experience should allow a user to understand and perform the following without unnecessary complexity:

### Within the Home screen

The user can identify:

* Their active pots
* Which pots they own
* Which pots they joined
* Whether they have pending invitations

### Within a Pot

The user can identify:

* Target
* Current savings
* Progress
* Remaining amount
* Partner
* Individual contributions
* Activity
* Streak
* Milestones
* Deadline

### Core Saving Action

A participant can:

```text
Open Pot
→ Add Contribution
→ Confirm
→ See Updated Progress
```

without navigating through unrelated screens.

### Collaboration

Both participants can:

* See shared progress
* See each other's contributions
* Receive shared reminders
* Celebrate milestones

### Safety

Destructive actions clearly explain their consequences before execution.

---

# 44. Final V1 Navigation Model

The complete conceptual experience is:

```text
                         ┌──────────────┐
                         │    Launch    │
                         └──────┬───────┘
                                ↓
                       ┌─────────────────┐
                       │ Authentication  │
                       └────────┬────────┘
                                ↓
                         ┌──────────────┐
                         │     Home     │
                         └──────┬───────┘
                                │
            ┌───────────────────┼───────────────────┐
            ↓                   ↓                   ↓
      Create Pot          Invitations          Profile
            │
            ↓
       ┌─────────┐
       │   Pot   │
       │ Detail  │
       └────┬────┘
            │
    ┌───────┼────────┬───────────┬───────────┐
    ↓       ↓        ↓           ↓           ↓
Contribute Activity Adjustment Milestones Participant
    │                                      Management
    ↓
 Progress
    │
    ├──────────────→ Streak
    │
    ├──────────────→ 25%
    │
    ├──────────────→ 50%
    │
    ├──────────────→ 75%
    │
    └──────────────→ 100%
                         │
                         ↓
                   Goal Complete
                         │
                         ↓
                    Optional Share
```

---

# 45. Design Principle Summary

Save+1 V1 should feel like a **shared accountability workspace**, not a banking application.

The core loop is:

```text
Set Goal
   ↓
Invite +1
   ↓
Save
   ↓
See Progress
   ↓
Encourage Each Other
   ↓
Maintain Streak
   ↓
Reach Milestones
   ↓
Complete Goal 🎉
```

The interface should continuously reinforce one central idea:

> **Save together. Stay accountable.**

All UI behavior must remain consistent with the underlying domain rules, authorization rules, and database design.
