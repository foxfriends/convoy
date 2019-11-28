# Convoy

Protected (strongly-typed) shipments (notifications). Convoy is a system that works very
much like the standard `NotificationCenter`, but in a strongly-typed manner.

## Usage

```swift
// First, define a Convoy, and its contents.
enum MyConvoy: Convoy {
    typealias Contents = String
}

// Then, set up a receiver (to receive your Convoys)
var subscription: ConvoyHandle?
func receiveMyConvoy() {
    // Unlike NotificationCenter, we use the type of our Convoy to identify our events.
    //
    // `ConvoyDispatcher.receive` returns a handle which we should clean up later. This is 
    // similar to the object returned from `NotificationCenter.addObserver`, which you must 
    // later pass to `NotificationCenter.removeObserver`.
    subscription = ConvoyDispatcher.default.receive(MyConvoy.self) { (contents: String) in
        // all we receive here is the payload, so let's just print it out!
        print(contents)
    }
}

// We can then dispatch Convoys to the ConvoyDispatcher, and they will be sent to all
// the receivers
func sendMyConvoy(contents: String) {
    ConvoyDispatcher.default.dispatch(MyConvoy.self, contents: contents)
}

// Finally, later on, we have to clean up our Receivers, or else we'll have memory leaks:
func removeReceiver() {
    subscription.remove()
}
```

## Installation

Only Swift Package Manager is supported:

```swift
Package(
    dependencies: [
        .package(url: "https://github.com/foxfriends/convoy.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "MyProject", dependencies: ["Convoy"])
    ]
)
```

## RxSwift

Convoy has support for RxSwift style receivers as well, compatible with RxSwift version 5 and above.

```swift
Package(
    dependencies: [
        .package(url: "https://github.com/foxfriends/convoy.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "MyProject", dependencies: ["Convoy", "RxConvoy"])
    ]
)
```

### Usage

```swift
let disposable = ConvoyDispatcher.default.rx.receive(MyConvoy.self)
    .subscribe(onNext: { (contents: String) in
        print(contents)
    })
```
