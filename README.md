# SSEIterator

A Swift package for consuming Server-Sent Events (SSE) through an `AsyncSequence` in a simple and efficient way. The package is compatible with macOS 10.15 and later.

## Features

- Supports the `AsyncSequence` protocol to easily consume SSE streams
- Handles the buffering and parsing of events
- Allows cancellation of the underlying request by dropping the iterator
- Customizable through `URLRequest`

## Installation

To add the `SSEIterator` package to your project, add the following to your `Package.swift` file's `dependencies` section:

```swift
.package(url: "https://github.com/mirkokiefer/SSEIterator.git", from: "1.0.0"),
```

Then, add "SSEIterator" as a dependency for your target:

```swift
.target(name: "YourTarget", dependencies: ["SSEIterator"]),
```

## Usage

Import the package in your Swift file:

```swift
import SSEIterator
```

Create a `URLRequest` for the SSE endpoint:

```swift
let url = URL(string: "https://example.com/events")!
let request = URLRequest(url: url)
```

Create an `SSEStream` and iterate through the events:

```swift
let stream = sseEvents(for: request)

for await result in stream {
    switch result {
    case .success(let events):
        for event in events {
            print("Received event: \(event)")
        }
    case .failure(let error):
        print("Error: \(error)")
    case .none:
        print("The stream has ended")
    }
}
```

## License

This project is released under the MIT License. See the LICENSE file for more information.

## Contributing

Contributions are welcome! If you find a bug, have a feature request or want to improve the code or documentation, feel free to create an issue or submit a pull request.