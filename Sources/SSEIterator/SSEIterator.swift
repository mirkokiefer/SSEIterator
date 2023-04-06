import Foundation

public struct SSEStream: AsyncSequence {
  let urlRequest: URLRequest
  
  public typealias Element = Result<[String], Error>?
  public typealias AsyncIterator = URLSessionIterator
  
  public func makeAsyncIterator() -> URLSessionIterator {
    return URLSessionIterator(urlRequest: urlRequest)
  }
}

public final class URLSessionIterator: NSObject, AsyncIteratorProtocol, URLSessionDataDelegate, URLSessionTaskDelegate, URLSessionDelegate {
  var urlRequest: URLRequest
  var buffer: String = ""
  var task: URLSessionDataTask!
  var continuation: CheckedContinuation<Element, Never>?
  var isCompleted: Bool = false
  private var session: URLSession!
  
  public typealias Element = Result<[String], Error>?
  
  init(urlRequest: URLRequest) {
    self.urlRequest = urlRequest
    super.init()
    self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    self.task = session.dataTask(with: urlRequest)
  }
  
  public func next() async -> Element? {
    if isCompleted {
      return nil
    }
    
    return await withCheckedContinuation { (continuation: CheckedContinuation<Element, Never>) in
      if self.isCompleted {
        continuation.resume(returning: nil)
      } else {
        self.continuation = continuation
        self.task.resume()
      }
    }
  }
  
  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let error = error {
      continuation?.resume(returning: .failure(error))
    } else {
      isCompleted = true
      continuation?.resume(returning: nil) // Indicate the end of the stream
    }
  }
  
  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let chunk = String(data: data, encoding: .utf8) else { return }
    buffer += chunk
    var events: [String] = []
    while let (event, remaining) = extractEvent(buffer) {
      buffer = remaining
      let lines = event.split(separator: "\n", omittingEmptySubsequences: false)
      for line in lines {
        if line.hasPrefix("data:") {
          let data = String(line.dropFirst(5))
          events.append(data)
        }
      }
    }
    // todo cancel request if continuation is nil / buffer events
    continuation?.resume(returning: .success(events))
    continuation = nil
  }
  
  deinit {
    session.finishTasksAndInvalidate()
  }
}

private func extractEvent(_ string: String) -> (String, String)? {
  if let range = string.range(of: "\n\n") {
    let event = String(string[string.startIndex..<range.lowerBound])
    let remaining = String(string[range.upperBound...])
    return (event, remaining)
  }
  return nil
}

public func sseEvents(for request: URLRequest) -> SSEStream {
  return SSEStream(urlRequest: request)
}
