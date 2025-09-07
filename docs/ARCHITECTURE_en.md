# Architecture

[Xem bằng tiếng Việt](ARCHITECTURE.md).

The app is divided into four main layers.

## Models
Data classes such as `Note` and `Reminder`. They map directly to Firestore documents and convert to/from JSON.

## Providers
Manage state and supply reactive data to widgets. Each provider watches a set of `Model`s and notifies the UI when the data changes.

## Services
Contain business logic and interact with external systems.
- **FirebaseService**: saves and reads notes from Cloud Firestore.
- **NotificationService**: schedules and cancels reminders via local notifications.

## Widgets
UI components: note list, edit screen, and reminder form. Widgets consume data from providers and send user events back.

## Flow: note → save to Firebase → reminder
1. The user creates or edits a note in a widget.
2. The widget calls a provider to update the corresponding `Model`.
3. The provider uses `FirebaseService` to save the note to Firestore.
4. After saving, the provider calls `NotificationService` to schedule a reminder.
5. The user receives a notification at the scheduled time.

<a id="authservice-flow"></a>
## AuthService flow
1. The app launches.
2. `AuthService` checks the current sign-in state.
3. It routes to the appropriate screen based on that state.

<a id="connectivityservice-strategy"></a>
## ConnectivityService strategy
- Monitor network connectivity.
- When offline, mark data for sync and inform the user.
- When connectivity returns, sync changes back to the server.
