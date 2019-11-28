/// An `Convoy` is a protected (strongly typed) shipment (notification) which can be sent via the `ConvoyDispatcher`
public protocol Convoy {
  /// The type of data that is being sent with this `Convoy`
  associatedtype Contents = Void
  /// A name for this `Convoy`, which may appear in debugging. This defaults to the name of the `Convoy`'s type
  static var identifier: String { get }
}

public extension Convoy {
  static var identifier: String { String(describing: Self.self) }
}
