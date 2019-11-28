import XCTest
@testable import Convoy

final class ConvoyTests: XCTestCase {
  func testEmptyContents() {
    enum VoidConvoy: Convoy {}

    let expectConvoyIsReceived = expectation(description: "The VoidConvoy should be received")

    let subscription = ConvoyDispatcher.default.receive(VoidConvoy.self) {
      expectConvoyIsReceived.fulfill()
    }
    defer { subscription.remove() }

    ConvoyDispatcher.default.dispatch(VoidConvoy.self)
    wait(for: [expectConvoyIsReceived], timeout: .leastNormalMagnitude)
  }

  func testIntContents() {
    enum IntConvoy: Convoy { typealias Contents = Int }

    let expectConvoyIsReceived = expectation(description: "The IntConvoy should be received")

    let subscription = ConvoyDispatcher.default.receive(IntConvoy.self) { contents in
      XCTAssertEqual(contents, 3)
      expectConvoyIsReceived.fulfill()
    }
    defer { subscription.remove() }

    ConvoyDispatcher.default.dispatch(IntConvoy.self, contents: 3)
    wait(for: [expectConvoyIsReceived], timeout: .leastNormalMagnitude)
  }

  func testSubscriptionRemoval() {
    enum VoidConvoy: Convoy {}

    let expectConvoyIsNotReceived = expectation(description: "The VoidConvoy should not be received")
    expectConvoyIsNotReceived.isInverted = true

    let subscription = ConvoyDispatcher.default.receive(VoidConvoy.self) {
      expectConvoyIsNotReceived.fulfill()
    }
    subscription.remove()

    ConvoyDispatcher.default.dispatch(VoidConvoy.self)
    wait(for: [expectConvoyIsNotReceived], timeout: .leastNormalMagnitude)
  }

  static var allTests = [
    ("testEmptyContents", testEmptyContents),
    ("testIntContents", testIntContents),
    ("testSubscriptionRemoval", testSubscriptionRemoval),
  ]
}
