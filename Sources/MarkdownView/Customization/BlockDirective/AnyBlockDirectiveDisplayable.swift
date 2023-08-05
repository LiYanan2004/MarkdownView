import SwiftUI

/// A type-erased BlockDirectiveDisplayable value.
struct AnyBlockDirectiveDisplayable: BlockDirectiveDisplayable {
    typealias BlockDirectiveView = AnyView

    @ViewBuilder private let displayableClosure: ([BlockDirectiveArgument], String) -> AnyView

    init<D: BlockDirectiveDisplayable>(erasing blockDisplayable: D) {
        displayableClosure = { args, text in
            AnyView(blockDisplayable.makeView(arguments: args, text: text))
        }
    }

    func makeView(arguments: [BlockDirectiveArgument], text: String) -> AnyView {
        displayableClosure(arguments, text)
    }
}
