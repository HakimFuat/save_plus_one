# Save+1 — V1 User Stories

**Version:** 1.0  
**Status:** Draft / Working Specification  
**Last Updated:** 2026-09-24

Epic 1 — Account

US-01: Create an account

As a user, I want to create an account so that I can use Save+1 and participate in shared pots.

Acceptance Criteria

User can register with the required account information.
Duplicate accounts are rejected.
Successfully registered users can access Save+1.

US-02: Sign in

As a user, I want to sign in so that I can access my pots and contributions.

Acceptance Criteria

Valid credentials allow access.
Invalid credentials are rejected.
User remains associated with their own pots and contributions.
Epic 2 — Pots

US-03: Create a savings pot

As a user, I want to create a shared savings pot so that my +1 and I can work toward a common financial goal.

Acceptance Criteria

User provides a pot name.
User provides a target amount.
User may provide a deadline.
Creator becomes the owner.
Creator automatically becomes the first participant.
Initial progress is RM0.
A free user cannot create more than 2 owned pots.

US-04: View a pot

As a participant, I want to view my pot so that I can see our savings progress.

The pot should show:

Pot name
Target
Current total
Progress percentage
Deadline, if applicable
Owner
Participants
Individual contributions
Saving activity
Milestones

Only the owner and participant can access the pot.

US-05: Edit a pot

As the owner, I want to edit my pot details so that I can keep the goal accurate.

Acceptance Criteria

Owner can edit pot name.
Owner can edit target.
Owner can edit deadline.
Participant cannot edit these details.
Epic 3 — +1 Invitations

US-06: Invite a +1

As the owner, I want to invite another user so that we can save together.

Acceptance Criteria

Owner can send an invitation.
A pot can have a maximum of 2 participants.
Invitation starts as Pending.
The invited user can accept or decline.
Only the invited user can accept that invitation.

Invitation lifecycle:

Pending
   │
   ├── Accept → Accepted
   │
   └── Decline → Declined
Epic 4 — Contributions 💰

US-07: Add a contribution

As a participant, I want to record money I've saved so that our shared progress is updated.

Contribution contains:

Amount
Date
Note (optional)

Acceptance Criteria

Participant can add a positive contribution.
Contribution increases the pot's total.
Contribution increases the participant's personal total.
Future-dated contributions are rejected.
Only participants can contribute.
Currency is MYR in V1.

US-08: Edit my contribution

As a participant, I want to edit my own contribution so that I can correct mistakes.

Acceptance Criteria

User can edit their own contribution.
User cannot edit another participant's contribution.
Pot totals update accordingly.

US-09: Delete my contribution

As a participant, I want to delete my own contribution so that incorrect records can be removed.

Acceptance Criteria

User can delete their own contribution.
User cannot delete another participant's contribution.
Pot totals update accordingly.
Epic 5 — Adjustments

US-10: Record a savings adjustment

Because Save+1 doesn't actually hold money, we're not implementing a financial "withdrawal."

Instead:

As a participant, I want to record an adjustment when money previously recorded as saved is no longer part of the goal.

Example:

Contribution    +RM500
Adjustment      -RM100
----------------------
Net contribution RM400

Acceptance Criteria

Participant can create a negative adjustment.
Adjustment cannot make the relevant balance invalid.
Adjustment decreases shared progress.
Adjustment does not increase a saving streak.
Transaction history remains visible.

This distinction is important:

Save+1 records money.
Save+1 does not move money.

🔥 That's one of our core architectural boundaries.

Epic 6 — Saving Streaks 🔥

US-11: Track saving streak

As a participant, I want to maintain a saving streak so that I stay motivated to contribute consistently.

Rules

A streak increases when:

At least one positive contribution
        +
on that calendar day

Multiple contributions on the same day:

RM10 + RM20 + RM30

= 1 saving day, not 3.

Adjustments alone:

-RM20

= not a saving day.

Epic 7 — Milestones 🎉

US-12: Celebrate milestones

Milestones:

25%
50%
75%
100%

When the pot reaches a milestone:

Show celebration.
Milestone is recorded as achieved.
Same milestone should not repeatedly trigger as newly achieved.

At 100%:

🎉 Goal Complete

US-13: Share goal completion

As a participant, I want to share our achievement so that we can celebrate reaching our goal.

Sharing is:

Optional
User-triggered
Never automatic

Example:

🎉 GOAL COMPLETE

Japan Trip
RM10,000 saved together

Hakim + Jannah

No public financial profile is created.

Epic 8 — Reminders 🔔

US-14: Receive shared saving reminders

As a participant, I want reminders when our saving activity becomes inactive so that we stay accountable.

V1 rule:

If neither participant contributes for 3 consecutive days, both receive a reminder.

When either participant contributes:

Inactivity period
       ↓
     RESET

Reminders should encourage the pair rather than expose one participant as "the inactive one."

Epic 9 — Leaving Pots

US-15: Participant leaves

As a participant, I want to leave a pot when I no longer want to participate.

Before leaving:

⚠️ Leave this pot?

Your contributed amount will be removed
from the shared pot progress.

[Cancel] [Leave]

After leaving:

Participant is removed.
Their contribution is removed from shared progress.
Pot remains for the owner/remaining participant.

US-16: Owner leaves

This one has a special business rule.

Ownership cannot be transferred.

If owner attempts to leave:

⚠️ Delete pot?

You are the owner of this pot.
Leaving will permanently delete the pot
and its saving history for all participants.

[Cancel] [Delete Pot]

User-facing behavior:

Owner leaves
     ↓
Pot disappears for everyone

Backend may use a soft-delete/closed state for data integrity, but from the user's perspective:

the pot is deleted.

Epic 10 — Deadline

US-17: Handle deadline

When the deadline arrives:

If target reached
Target reached
      ↓
Goal Complete
If target NOT reached

User gets three choices:

1. Extend deadline
2. Continue without deadline
3. End goal

No automatic failure.

If ended:

Active Pot
    ↓
Ended / Archived