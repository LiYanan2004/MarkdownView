//
//  OnValueChange.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/22.
//

import SwiftUI

extension View {
    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// This is a back-deployed version of SwiftUI's `onChange(of:initial:_:)` view modifier.
    ///
    /// You can use `onChange` to trigger a side effect as the result of a
    /// value changing, such as an `Environment` key or a `Binding`.
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task.
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value. The old and new observed values are
    /// passed into the closure. In the following code example, `PlayerView`
    /// passes both the old and new values to the model.
    ///
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .onChange(of: playState) { oldState, newState in
    ///                 model.playStateDidChange(from: oldState, to: newState)
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - initial: Whether the action should be run when this view initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    nonisolated func onValueChange<V>(
        value: V,
        initial: Bool = false,
        _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void
    ) -> some View where V : Equatable {
        modifier(
            _BackDeployedOnChangeViewModifier(
                value: value,
                initial: initial,
                action: .init(action)
            )
        )
    }
    
    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// This is a back-deployed version of SwiftUI's `onChange(of:initial:_:)` view modifier.
    ///
    /// You can use `onChange` to trigger a side effect as the result of a
    /// value changing, such as an `Environment` key or a `Binding`.
    ///
    /// The system may call the action closure on the main actor, so avoid
    /// long-running tasks in the closure. If you need to perform such tasks,
    /// detach an asynchronous background task.
    ///
    /// When the value changes, the new version of the closure will be called,
    /// so any captured values will have their values from the time that the
    /// observed value has its new value. In the following code example,
    /// `PlayerView` calls into its model when `playState` changes model.
    ///
    ///     struct PlayerView: View {
    ///         var episode: Episode
    ///         @State private var playState: PlayState = .paused
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Text(episode.title)
    ///                 Text(episode.showTitle)
    ///                 PlayButton(playState: $playState)
    ///             }
    ///             .onChange(of: playState) {
    ///                 model.playStateDidChange(state: playState)
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - initial: Whether the action should be run when this view initially
    ///     appears.
    ///   - action: A closure to run when the value changes.
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    nonisolated func onValueChange<V: Equatable>(
        _ value: V,
        initial: Bool = false,
        _ action: @escaping () -> Void
    ) -> some View where V : Equatable {
        modifier(
            _BackDeployedOnChangeViewModifier(
                value: value,
                initial: initial,
                action: .init(action)
            )
        )
    }
}

// MARK: - Auxiliary

fileprivate struct _BackDeployedOnChangeViewModifier<Value: Equatable>: ViewModifier {
    nonisolated(unsafe) private var value: Value
    private var initial: Bool
    private var action: Action
    
    nonisolated init(value: Value, initial: Bool, action: Action) {
        self.value = value
        self.initial = initial
        self.action = action
    }
    
    func body(content: Content) -> some View {
        if #available(macOS 14, iOS 17, tvOS 17, watchOS 10, *) {
            content
                .onChange(
                    of: value,
                    initial: initial,
                    action.callAsFunction(before:after:)
                )
        } else {
            content
                .onAppear(perform: performInitialAction)
                .onChange(of: value) { [value] newValue in
                    Task { @MainActor in
                        action(before: value, after: newValue)
                    }
                }
        }
    }
    
    private func performInitialAction() {
        guard initial else { return }
        action(before: value, after: value)
    }
}

extension _BackDeployedOnChangeViewModifier {
    enum Action: @unchecked Sendable {
        case actionWithValues(_ action: (Value, Value) -> Void)
        case directAction(_ action: () -> Void)
        
        func callAsFunction(before: Value, after: Value) {
            switch self {
            case .actionWithValues(let action):
                action(before, after)
            case .directAction(let action):
                action()
            }
        }
        
        init(_ action: @escaping (Value, Value) -> Void) {
            self = .actionWithValues(action)
        }
        
        init(_ action: @escaping () -> Void) {
            self = .directAction(action)
        }
    }
}
