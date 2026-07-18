# Social District

### Real plans. Real people.

**Socialize** is a proposed social discovery feature for District that helps people find company for plans they already want to make—dinner, movies, events, sports, and activities.

Instead of matching people around profiles and endless messaging, Socialize starts with a real plan:

> **What are we doing, where are we meeting, and when are we going?**

Built as a native iOS hackathon MVP using SwiftUI and local mock data.

---

## The opportunity

District is already where people discover what to do and where to go. But discovery often stops at the booking decision—especially when someone wants to attend but does not have the right company.

Common moments include:

- “I want to watch this film, but nobody in my group is interested.”
- “I am new to Delhi and want people to explore restaurants with.”
- “This event looks great, but I do not want to go alone.”
- “I want to meet people through an activity, not awkward small talk.”

Socialize closes that gap by turning District from a place-discovery app into a **shared-experience platform**.

## The idea

Users discover small, interest-led groups organized around specific public plans.

```text
Home
  → Socialize
  → Discover group plans
  → View plan and host
  → Request to join
  → Get approved
  → Confirmed group
  → Group chat
```

The plan—not the profile—is the starting point. That gives every group immediate context, intent, time, and place.

## MVP experience

### District-inspired home

- Dark premium visual system inspired by District
- Delhi NCR location context
- Dining, Movies, Events, Stores, Activities, and Play discovery
- Dedicated Socialize entry point
- Spotlight carousel and custom bottom navigation

### Socialize discovery

- Search and category filters
- Realistic group plans across Delhi NCR
- Participant avatars and available spots
- Interest tags and verified-host indicators
- Clear date, time, and public venue information

### Plan details and joining

- Rich plan overview and description
- Host and participant profiles
- Public-venue safety indicator
- Sticky **Request to Join** action
- Local demo flow from request sent to host approval

Example plans include:

- **Pizza & Conversations** — Cyber Hub, Gurugram
- **Interstellar IMAX** — Saket, Delhi
- **Stand-up Comedy Night** — Aerocity, Delhi
- **Lodhi Garden Morning Walk** — Lodhi Garden, Delhi

## Why it belongs in District

Socialize builds on District's strongest existing advantages:

1. **High-intent inventory** — users already come to District looking for places and experiences.
2. **Real-world context** — venues, tickets, timings, and categories make every social plan concrete.
3. **Trust potential** — verified bookings, public venues, host reputation, and group limits can create safer introductions.
4. **Incremental value** — more people finding company can lead to more completed plans and bookings.
5. **Retention** — users can return not only to discover things to do, but also people to do them with.

## Product principles

- **Plans before profiles** — reduce awkwardness with immediate shared context.
- **Small groups over crowds** — make joining approachable and conversations meaningful.
- **Public by default** — prioritize known venues and clear meetup details.
- **Intentional access** — join requests give hosts control over group composition.
- **Native to District** — Socialize should feel like a natural extension, not a separate social network.

## Trust and safety direction

The MVP communicates safety intent through verified hosts and public venue indicators. A production version could add:

- District booking and identity verification
- Host reputation and post-plan feedback
- Mutual reporting and blocking
- Women-only or preference-based groups
- Group-size limits and attendee approval
- Automated moderation for public plans and chat
- Emergency sharing and check-in controls

## Technical overview

- **Swift + SwiftUI**
- **Native iPhone application**
- **MVVM-style architecture**
- **iOS 17+ compatible UI approach**
- **No external dependencies**
- **No backend or persistence**
- **Local mock data only**

```text
Social District/
├── Models/
├── ViewModels/
├── Views/
│   ├── Home/
│   └── Socialize/
├── Components/
├── Services/
└── Theme/
```

The application uses a `NavigationStack` and typed routes. Mock plans and profiles are provided by `MockDataService`, keeping the prototype deterministic and easy to demo.

## Run the prototype

1. Clone the repository.
2. Open `Social District.xcodeproj` in Xcode.
3. Select the **Social District** scheme.
4. Choose a modern iPhone simulator or device.
5. Build and run.

No setup, API keys, packages, or external services are required.

## Suggested demo

1. Start on the District-inspired home screen.
2. Tap the purple **Socialize** banner.
3. Filter plans by Dining, Movies, Events, or Activities.
4. Open **Pizza & Conversations**.
5. Review the verified host, participants, interests, and public venue.
6. Tap **Request to Join**.
7. Use the demo approval interaction to simulate host acceptance.

## What comes next

- Confirmed-group screen
- Group chat and plan coordination
- Create-a-plan flow
- Booking-linked plans
- Host and participant reputation
- Smart recommendations based on District activity
- Notifications, waitlists, and cancellations
- Production trust and safety systems

---

**Socialize turns “What should I do?” into “Who should I do it with?”**
