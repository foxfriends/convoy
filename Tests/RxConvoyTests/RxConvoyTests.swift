import XCTest
import Convoy
@testable import RxConvoy

final class RxConvoyTests: XCTestCase {
  func testRxConvoy() {
    enum IntConvoy: Convoy { typealias Contents = Int }

    let expectConvoyIsReceived = expectation(description: "The IntConvoy should be received")

    let subscription = ConvoyDispatcher.default.rx.receive(IntConvoy.self)
      .subscribe(onNext: { contents in
        XCTAssertEqual(contents, 3)
        expectConvoyIsReceived.fulfill()
      })
    defer { subscription.dispose() }

    ConvoyDispatcher.default.dispatch(IntConvoy.self, contents: 3)
    wait(for: [expectConvoyIsReceived], timeout: .leastNormalMagnitude)
  }

  func testRxConvoyDisposable() {
    enum VoidConvoy: Convoy {}

    let expectConvoyIsNotReceived = expectation(description: "The VoidConvoy should not be received")
    expectConvoyIsNotReceived.isInverted = true

    let subscription = ConvoyDispatcher.default.rx.receive(VoidConvoy.self)
      .subscribe(onNext: { _ in expectConvoyIsNotReceived.fulfill() })
    subscription.dispose()

    ConvoyDispatcher.default.dispatch(VoidConvoy.self)
    wait(for: [expectConvoyIsNotReceived], timeout: .leastNormalMagnitude)
  }

  static var allTests = [
    ("testRxConvoy", testRxConvoy),
    ("testRxConvoyDisposable", testRxConvoyDisposable),
  ]
}
