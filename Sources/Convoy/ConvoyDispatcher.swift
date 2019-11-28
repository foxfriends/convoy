import Foundation

/// The `ConvoyDispatcher` provides the means to dispatch and receive a `Convoy`.
///
/// The current implementation of `ConvoyDispatcher` uses the existing and well known `NotificationCenter` to actually
/// facilitate the transmission of data, but this is not guaranteed to always be the case. As such, it is not
/// recommended to try and intercept messages sent via `ConvoyDispatcher` by using the standard `NotificationCenter`
/// APIs.
public class ConvoyDispatcher {
  // MARK: - Implementation

  /// A dummy class to serve as the object used by `NotificationCenter` to filter events.
  private class Object {}

  /// RAII wrapper around an observer added to the `NotificationCenter`.
  public class ConvoyHandle {
    private weak var dispatcher: ConvoyDispatcher?
    private let observer: AnyObject

    fileprivate init(dispatcher: ConvoyDispatcher, observer: AnyObject) {
      self.dispatcher = dispatcher
      self.observer = observer
    }

    public func remove() {
      dispatcher?.notificationCenter.removeObserver(observer)
    }
  }

  /// The default `ConvoyDispatcher` system, which is backed by the default `NotificationCenter`.
  public static let `default`: ConvoyDispatcher = ConvoyDispatcher(name: "Default ConvoyDispatcher")

  /// Internal identifier that should be a sufficient defense against stringly-typed attackers.
  private let identifier: UUID = UUID()

  /// Internal object used to filter events sent through the `NotificationCenter`.
  private let object = Object()

  /// The `NotificationCenter` that this `ConvoyDispatcher` is using as its backing transport mechanism.
  private let notificationCenter: NotificationCenter

  // MARK: - Public API

  /// The user-friendly name of this `ConvoyDispatcher`, which serves mainly as an aid for debugging.
  let name: String

  /// Set this flag to print debug messages. By default, this is disabled. __DO NOT__ leave this flag enabled in a
  /// production environment.
  var printDebug: Bool = false

  /// Creates a new `ConvoyDispatcher`.
  ///
  /// - Parameter name: A developer facing name for this `ConvoyDispatcher`. Only of importance for debugging.
  /// - Parameter notificationCenter: The `NotificationCenter` instance to use as the underlying transport mechanism.
  public init(name: String, notificationCenter: NotificationCenter = .default) {
    self.name = name
    self.notificationCenter = notificationCenter
  }

  /// Dispatch an `Convoy` with no `Contents`.
  ///
  /// - Parameter convoy: The type of `Convoy` that is being sent.
  public func dispatch<C: Convoy>(_ convoy: C.Type) where C.Contents == Void {
    dispatch(convoy, contents: ())
  }

  /// Dispatch an `Convoy` with some `Contents`.
  ///
  /// - Parameter convoy: The type of `Convoy` that is being sent.
  /// - Parameter contents: The value of the `Contents` to send with the `Convoy`
  public func dispatch<C: Convoy>(_ convoy: C.Type, contents: C.Contents) {
    notificationCenter.post(
      name: notificationName(convoy),
      object: object,
      userInfo: [identifier: contents]
    )
  }

  /// Set up a receiver for a `Convoy`.
  ///
  /// - Parameter convoy: The type of `Convoy` to receive
  /// - Parameter queue: The `OperationQueue` to handle events on. See
  ///                    `NotificationCenter.addObserver(forName:object:queue)` for details on how this works.
  /// - Parameter handler: The handler callback, which is called whenever a matching `Convoy` is received
  /// - Parameter contents: The received `Contents` that was sent with the `Convoy`
  ///
  /// - Returns: A handle to this receiver, which will remove the receiver when the handle is deallocated (RAII)
  public func receive<C: Convoy>(
    _ convoy: C.Type,
    queue: OperationQueue? = nil,
    handler: @escaping (_ contents: C.Contents) -> Void
  ) -> ConvoyHandle {
    let observer = notificationCenter.addObserver(
      forName: notificationName(convoy),
      object: object,
      queue: queue
    ) { [identifier] notification in
      guard let userInfo = notification.userInfo else { return }
      guard let payload = userInfo[identifier] as? C.Contents else { return }
      handler(payload)
    }

    return ConvoyHandle(dispatcher: self, observer: observer)
  }

  // MARK: - Implementation

  /// Compute the name for the notification
  private func notificationName<C: Convoy>(_ convoy: C.Type) -> Notification.Name {
    Notification.Name("\(name).\(identifier):\(convoy.identifier)")
  }
}
