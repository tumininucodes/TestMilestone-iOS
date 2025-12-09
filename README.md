# TestMilestone - iOS

## Architecture

The application follows the **MVVM (Model-View-ViewModel)** architectural pattern, leveraging SwiftUI for the UI and the Combine framework for reactive data binding.

-   **Models**: Plain Swift structs (e.g., `Bid`) conforming to `Codable` and `Identifiable` for data representation.
-   **Views**: SwiftUI views (e.g., `RiderBiddingView`, `RiderNegotiationView`) that observe ViewModels and react to state changes.
-   **ViewModels**: Classes (e.g., `RiderBiddingViewModel`, `RiderNegotiationViewModel`) conforming to `ObservableObject`. They manage business logic, hold application state (`@Published` properties), and interface with the data layer.
-   **Services**: The `WebSocketService` handles network communication, abstracting the complexity of WebSocket management from the ViewModels.

## Timer Implementation

The bidding countdown is managed within `RiderBiddingViewModel`:

-   **Logic**: Uses a standard `Timer` scheduled with a `0.1s` interval.
-   **Countdown**: Tracks time remaining in milliseconds (`millisUntilFinished`). Updates are published to the view to drive the progress bar and timer text.
-   **Visual Feedback**: The `CircularProgressView` color changes dynamically from Green -> Yellow -> Orange -> Red as time depletes.

## WebSocket Handling

Real-time communication is powered by `WebSocketService`, utilizing `URLSessionWebSocketTask`.

-   **Connection**: Establishes a connection to `ws://websockeet.onrender.com/ws`.
-   **Lifecycle**:
    -   `connect()`: Initiates the socket connection and sends an initial Ping to verify reachability.
    -   `startReceiving()`: Enters a loop to continuously listen for incoming messages.
    -   `disconnect()`: Cleanly closes the connection and cancels tasks.
-   **Data Parsing**: Incoming text messages are parsed as JSON into `Bid` objects. Timestamps are generated client-side upon receipt to ensure synchronization.

## State Flow

The application relies on a unidirectional data flow:

1.  **Event Source**: `WebSocketService` receives a message using a `PassthroughSubject`.
2.  **Propagation**: The service emits the parsed `Bid` object via the `bids` publisher.
3.  **Consumption**: ViewModels (`RiderBiddingViewModel`, `RiderNegotiationViewModel`) subscribe to `webSocketService.bids` in their `setupBindings()` method.
4.  **State Update**: Received bids are processed (e.g., sorted, winner determined) and assigned to `@Published` property `bidList`.
5.  **UI Render**: SwiftUI views automatically re-render to reflect the updated state.

## Retry Logic

To ensure robustness, the app implements autoreconnection strategies:

-   **Detection**: If `receiveTask` encounters an error or the connection drops unexpectedly.
-   **Action**: `scheduleRetry()` is triggered, which sets the state to `.retrying` and immediately attempts to call `connect()` again.
-   **UI Feedback**: ViewModels observe the `connectionState`. If the state is `.retrying`, a visible banner or message is displayed to the user.

## Known Limitations
- **Time Synchronization and Latency**: For the purpose of the test, timestamps are generated using
  the device's local time, which may not align perfectly with the server or other
  clients. Reason is because of the latency calculation. The provisioned Golang server at
  websockeet.onrender.com, runs on a 0.1CPU and 512MB of RAM whcih would greatly affect the
  performance and the latency of the connection. This is why the latency is calculated as difference
  between the time received and the time displayed. This would mean being in background or delayed display would also
  affect the latency calculation (time displayed on screen - not time the data is available to the
  app).
- **Retry Strategy**: The retry logic is immediate and infinite, it would always try to reconnect to the server. It can be improved by having a spaced reconnection timing that increases with each failure after a set time.
-   **Client-Side Winner Logic**: The determination of the winning bid (lowest amount) is currently performed on the client side for the generic bidding flow. In a production environment, this should ideally be validated by the backend.

