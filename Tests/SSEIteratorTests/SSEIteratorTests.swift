import XCTest
@testable import SSEIterator

final class SSEIteratorTests: XCTestCase {
    func testSSEStream() async throws {
        let expectation = XCTestExpectation(description: "SSE stream should receive 5 events and close the connection")

        // Replace with your own endpoint URL
        let url = URL(string: "https://localhost:8000/api/stream_test")!
        let request = URLRequest(url: url)
        let sseStream = sseEvents(for: request)

        var receivedEvents = [String]()
        let maxEvents = 5

        for await result in sseStream {
            switch result {
            case .success(let events):
                for event in events {
                    print("Received event: \(event)")

                    receivedEvents.append(event)

                    if receivedEvents.count >= maxEvents {
                        expectation.fulfill()
                        break
                    }
                }
            case .failure(let error):
                XCTFail("SSE stream failed with error: \(error)")
            case .none:
                continue;
                // XCTFail("SSE stream failed with unknown error")
            }
        }
    }
}
