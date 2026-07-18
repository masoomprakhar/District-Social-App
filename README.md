# Social District

### Real plans. Real people.

**Socialize** is a proposed social discovery feature for District that helps people find company for plans they already want to make—dinner, movies, events, sports, and activities.

Instead of matching people around profiles and endless messaging, Socialize starts with a real plan:

> **What are we doing, where are we meeting, and when are we going?**

Built as a native iOS hackathon MVP using SwiftUI and local mock data.

---

## Product specification

### Product summary

Socialize adds a social layer to District's existing discovery and booking
experience. It helps users find compatible people for a specific restaurant,
movie, event, or activity without turning District into a profile-first dating
or social-network product.

The core product loop is:

```text
Discover a plan → See a compatible group → Request to join
→ Host accepts → Booking is confirmed → Coordinate in group chat
```

### Problem

District helps users answer **“What should I do?”**, but a user may still abandon
a plan because they do not have someone to go with.

This is common when a user:

- is new to a city;
- has interests that do not overlap with their existing friends;
- wants to attend an event but does not want to go alone; or
- prefers meeting people through a shared activity instead of cold messaging.

The result is lost intent for the user and potentially lost bookings for
District.

### Product hypothesis

If District introduces users through a concrete, bookable plan at a public
venue, then users will feel more comfortable meeting new people and will
complete more plans than they would through profile-first matching.

### Goals

1. Help a user find company for an existing high-intent plan.
2. Increase conversion from discovery to confirmed booking.
3. Make first-time social participation feel contextual and safe.
4. Keep Socialize integrated with District's normal browsing experience.
5. Support the complete request, approval, booking, and coordination loop.

### Non-goals

- Building a dating product.
- Creating an open-ended follower or content network.
- Supporting private-home meetups in the initial release.
- Replacing District's existing individual booking flow.
- Providing production identity verification or moderation in this prototype.

## Target users

### Primary personas

- **The newcomer** — recently moved to Delhi NCR and wants a low-friction way to
  meet people through local experiences.
- **The interest seeker** — wants to watch a specific film, try a restaurant,
  or attend an event that their existing friends do not.
- **The cautious joiner** — is open to meeting people but needs a public venue,
  small group, and clear host information.
- **The organizer** — enjoys creating plans and wants control over who joins.

### Jobs to be done

- “When I find something interesting on District, help me find suitable people
  so I do not have to go alone.”
- “Before I join strangers, show me enough context to judge whether the plan
  feels relevant and safe.”
- “When I host a group, let me approve participants before confirming them.”
- “After a group is confirmed, give us one place to coordinate.”

## Product principles

- **Plans before profiles** — the activity, time, and place provide immediate
  shared context.
- **Small groups over crowds** — limited capacity makes joining approachable.
- **Public by default** — plans should take place at known public venues.
- **Intentional access** — joining is request-based; it is never presented as
  instantly confirmed.
- **Transparent value** — offers say **up to 20% off**, not a guaranteed flat
  discount.
- **Native to District** — Socialize augments familiar discovery and booking
  flows rather than creating a separate app.

## MVP scope

### 1. Home and Socialize Mode

- Socialize Mode is controlled from the Home screen.
- Off state:
  - regular District browsing remains available;
  - prices and offers remain neutral;
  - group suggestions are hidden;
  - the prompt reads **“Turn on Socialize to enjoy up to 20% off.”**
- On state:
  - compatible group suggestions appear;
  - applicable group offers are highlighted;
  - the state reads **“Best offers applied.”**
- Home categories continue to open listings directly in both states.
- Personalized recommendations use the user's demonstrated interests and
  available local plans.

### 2. Discovery and search

- Browse Dining, Movies, Events, Stores, Activities, and Play.
- Search plans and venues.
- Filter group suggestions by category.
- View a Delhi NCR map of relevant venues and plans.
- Each result communicates title, venue, date/time, price, group size, and
  availability.

### 3. Plan and group details

- Show the plan description and booking context.
- Show host identity, verification status, participants, and shared interests.
- Show capacity and remaining spots.
- Show the public-venue safety indicator.
- Offer two paths where relevant:
  - **Match me** for an assisted recommendation;
  - **Request to join** for a selected group.

### 4. Assisted matching

- Recommend a compatible person or group using local profile and interest data.
- Explain the shared context behind the match.
- Generate a private icebreaker using Apple's on-device Foundation Models.
- Use a deterministic local fallback when Apple Intelligence is unavailable.

### 5. Join request lifecycle

Joining a group follows an explicit state machine:

```text
Available → Request sent → Host review
                         ├→ Declined → Available
                         └→ Accepted → Confirmed booking → Group chat
```

Requirements:

- A request must not be labeled as a completed booking.
- Duplicate active requests must be prevented.
- Pending requests must appear in the Socialize hub.
- Acceptance adds the plan to Bookings and unlocks group chat.
- Declining returns the plan to a joinable state for the demo.

### 6. Host tools

- Create a group with category, venue, time, capacity, and price.
- View hosted groups in the host dashboard.
- Review incoming requests.
- Accept or decline each request.
- Keep confirmed attendance within group capacity.

### 7. Group chat

- Available only after a request is accepted.
- Displays plan context and group participants.
- Supports local demo messages for coordination.
- Does not imply production-grade real-time messaging.

### 8. Bookings and Live Activity

- Bookings combines regular bookings, together bookings, and joined rooms.
- A confirmed upcoming room can start a Live Activity.
- The Lock Screen and Dynamic Island display the plan, venue, group size, and
  countdown.
- The user can end the Live Activity from the app.

### 9. Profile, trust, and safety

- Profile exposes booking and Socialize entry points.
- Trust & Safety communicates identity, phone, emergency-contact, reporting,
  and public-meetup concepts.
- Prototype controls are demonstrations and must not be represented as a
  production safety guarantee.

## Navigation model

The app uses five persistent destinations:

1. **Home** — discovery, recommendations, and Socialize Mode.
2. **Search** — query, category discovery, and venue map.
3. **Socialize** — matches, pending requests, hosted groups, and joined rooms.
4. **Bookings** — regular and social plans, including Live Activity controls.
5. **Profile** — account summary and trust-and-safety access.

## Core data objects

- **Listing** — a bookable restaurant, movie, event, or experience.
- **Room** — a small group attached to a plan, host, capacity, and time.
- **Profile** — participant identity, interests, verification, and match data.
- **Join request** — pending, accepted, or declined access to a room/experience.
- **Match session** — assisted match result and booking state.
- **Chat message** — local coordination message for a confirmed group.

## Success metrics

### North-star metric

**Confirmed social plans per weekly active Socialize user.**

### Funnel metrics

- Socialize Mode activation rate.
- Group suggestion impression-to-detail rate.
- Detail-to-request rate.
- Host request acceptance rate.
- Accepted-request-to-booking rate.
- Confirmed-plan-to-attendance rate.
- Group-chat activation rate.

### Guardrail metrics

- Request decline and cancellation rates.
- Report/block rate per confirmed plan.
- Host response time.
- No-show rate.
- Percentage of plans held at verified public venues.
- User-rated comfort and safety after a plan.

## Trust and safety requirements for production

- District account, phone, and optional identity verification.
- Public venues only for first-time groups.
- Reporting and blocking available from profiles, plans, and chat.
- Host reputation, participant feedback, and no-show tracking.
- Automated moderation for plan descriptions and messages.
- Preference-based groups where legally and ethically appropriate.
- Emergency contact sharing and timed check-in controls.
- Clear escalation and incident-response operations.
- Data minimization, retention rules, and user deletion controls.

## Technical specification

- **Platform:** native iPhone app, built with the iOS 26 SDK.
- **UI:** SwiftUI with a District-inspired dark visual system.
- **Architecture:** MVVM-style state management and typed navigation routes.
- **Data:** deterministic local mock data; no backend or persistence.
- **Dependencies:** Apple frameworks only; no third-party packages.

### Apple frameworks

- **SwiftUI Liquid Glass** — interactive glass treatment for Socialize Mode and
  selected controls.
- **Foundation Models** — private, on-device icebreaker generation with a local
  fallback.
- **ActivityKit + WidgetKit** — upcoming-plan Live Activity on the Lock Screen
  and Dynamic Island.
- **MapKit** — local venue and group-plan discovery across Delhi NCR.

### Project structure

```text
Social District/
├── Models/             # Routes and domain models
├── ViewModels/         # Socialize state and business rules
├── Views/
│   ├── Home/
│   └── Socialize/
├── Components/         # Reusable SwiftUI components
├── Services/           # Mock data, AI, and Live Activity services
└── Theme/              # Colors, spacing, and environment actions

Social District Shared/         # Shared ActivityKit attributes
Social District Live Activity/  # WidgetKit Live Activity extension
```

## Prototype constraints

- All users, plans, requests, bookings, and messages are local mock data.
- State resets when the app process is reset.
- Host approval is simulated on-device.
- Chat is not networked.
- Offers and prices are illustrative.
- Production authentication, payments, moderation, notifications, analytics,
  and backend capacity enforcement are outside this prototype.

## Run the prototype

1. Clone the repository.
2. Open `Social District.xcodeproj` in Xcode.
3. Select the **Social District** scheme.
4. Choose a modern iPhone simulator or device.
5. Build and run.

No API keys, packages, or external services are required.

## Demo script

1. On Home, turn on **Socialize Mode**.
2. Open a category and select a group suggestion.
3. Review its host, participants, venue, capacity, and offer.
4. Send a join request.
5. Open Socialize and review the pending request as the host.
6. Accept the request to create a confirmed booking.
7. Open the group chat and send a coordination message.
8. Open Search and view nearby plans on the map.
9. Start **Match me** and generate an on-device icebreaker.
10. Open Bookings and start the upcoming-plan Live Activity.

## Roadmap

### Next

- Backend persistence and real-time request/chat services.
- District authentication and booking linkage.
- Push notifications for requests, approvals, chat, and plan reminders.
- Production analytics for the discovery-to-attendance funnel.

### Later

- Waitlists and automated spot reassignment.
- Host and participant reputation.
- Post-plan feedback and safety check-ins.
- Smarter recommendations using consented District activity.
- Multi-city rollout with venue-quality and supply controls.

---

**Socialize turns “What should I do?” into “Who should I do it with?”**
