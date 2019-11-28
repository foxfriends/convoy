import Foundation
import Convoy
import RxSwift

extension ConvoyDispatcher: ReactiveCompatible {}

extension Reactive where Base == ConvoyDispatcher {
  public func receive<C: Convoy>(
    _ convoy: C.Type,
    queue: OperationQueue? = nil
  ) -> Observable<C.Contents> {
    Observable.create { observer in
      var subscription: AnyObject? = self.base.receive(convoy, queue: queue) { payload in
        observer.onNext(payload)
      }

      return Disposables.create {
        if subscription != nil { subscription = nil }
      }
    }
  }
}
