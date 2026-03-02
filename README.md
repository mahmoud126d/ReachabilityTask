# NetworkMonitor

A lightweight, Combine-based network reachability monitor for iOS. Drop it into any project and get real-time connectivity updates with zero boilerplate.

---

## Features

- Real-time network status updates via Combine
- Replays current status to new subscribers immediately
- Protocol-based — easy to mock and test
- Thread-safe — all updates published on the main thread
- Zero third-party dependencies

---

## Installation

Just copy `NetworkMonitor.swift` into your project. No package manager needed.

---

## File Structure

```
NetworkMonitor.swift
├── NetworkMonitoring        # Protocol — depend on this, not the concrete class
├── NetworkMonitor           # Concrete implementation using NWPathMonitor
│   └── NetworkStatus        # .connected / .disconnected
└── NetworkManager           # Network-aware API client with auto-retry
```

---

## Usage

### 1. Observe network status (connected / disconnected)

```swift
import Combine

final class HomeViewModel: ObservableObject {

    @Published private(set) var isConnected: Bool = true

    private let networkMonitor: NetworkMonitoring
    private var cancellables = Set<AnyCancellable>()

    init(networkMonitor: NetworkMonitoring = NetworkMonitor.shared) {
        self.networkMonitor = networkMonitor

        networkMonitor.statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.isConnected = status == .connected
            }
            .store(in: &cancellables)
    }
}
```

---

### 2. Make a network-aware API request

Requests made while offline are held in a pending state and automatically fired when the network comes back.

```swift
final class NetworkManager: NetworkManagerProtocol {

    private let networkMonitor: NetworkMonitoring

    init(networkMonitor: NetworkMonitoring = NetworkMonitor.shared) {
        self.networkMonitor = networkMonitor
    }

    func request<T: Decodable>(_ urlRequest: URLRequest, type: T.Type) -> AnyPublisher<T, Error> {
        networkMonitor.statusPublisher
            .filter { $0 == .connected }        // wait until connected
            .first()                             // take the first connected signal
            .flatMap { _ in                      // then fire the request
                URLSession.shared.dataTaskPublisher(for: urlRequest)
                    .map(\.data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { $0 as Error }
            }
            .catch { [weak self] error -> AnyPublisher<T, Error> in
                guard let self else { return Fail(error: error).eraseToAnyPublisher() }

                guard let urlError = error as? URLError,
                      urlError.code == .notConnectedToInternet ||
                      urlError.code == .networkConnectionLost
                else {
                    return Fail(error: error).eraseToAnyPublisher()
                }

                // Network dropped mid-request — re-queue and wait for reconnect
                return self.request(urlRequest, type: type)
            }
            .eraseToAnyPublisher()
    }
}
```

---

## How It Works

### Offline request flow

```
request() called while offline
        ↓
statusPublisher replays .disconnected
        ↓
.filter { $0 == .connected } blocks
        ↓
⏳ request is pending...
        ↓
network comes back
        ↓
statusPublisher emits .connected
        ↓
.filter passes → .first() → flatMap fires URLSession request
        ↓
✅ ViewModel receives response
```

### Mid-request network drop

```
request() called while online
        ↓
.filter passes → request fires
        ↓
network drops mid-flight
        ↓
URLSession throws URLError (.networkConnectionLost)
        ↓
.catch checks error type
    ├── network error → re-enters request() → waits for reconnect 🔄
    └── server/decode error → propagates failure to caller ❌
```
---

## API Reference

### `NetworkMonitoring`

|       Member        |                 Type                 |                  Description                             |
|---------------------|--------------------------------------|----------------------------------------------------------|
| `isConnected`       | `Bool`                               | Current connectivity state                               |
| `status`            | `NetworkStatus`                      | Current status enum value                                |
| `statusPublisher`   | `AnyPublisher<NetworkStatus, Never>` | Combine publisher, replays current value on subscription |
| `startMonitoring()` | `func`                               | Begin observing network changes                          |
| `stopMonitoring()`  | `func`                               | Stop observing and cancel the monitor                    |

### `NetworkMonitor.NetworkStatus`

|       Case      |             Description             |
|-----------------|-------------------------------------|
| `.connected`    | Device has an active network path   |
| `.disconnected` | Device has no network path          |

---
