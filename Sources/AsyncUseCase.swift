//
//  AsyncUseCase.swift
//  CleanArchitectureUseCase
//
//  Created by Robert on 7/12/24.
//

import Foundation
import Combine

public protocol AsyncUseCase<Input, Output, Failure> {
    associatedtype Input
    associatedtype Output
    associatedtype Failure: Error

    func execute(input: Input) async throws(Failure) -> Output
}

extension AsyncUseCase where Input == Void {
    public func execute() async throws(Failure) -> Output {
        try await execute(input: ())
    }
}

extension AsyncUseCase where Input: Sendable {
    public func makeReactive() -> some ReactiveUseCase<Input, Output, Failure> {
        AsyncToReactiveUseCase(sourceUseCase: self)
    }
}

private struct AsyncToReactiveUseCase<UseCase>: ReactiveUseCase where UseCase: AsyncUseCase, UseCase.Input: Sendable, UseCase.Failure: Sendable {
    nonisolated(unsafe) let sourceUseCase: UseCase

    func execute(input: UseCase.Input) -> some Publisher<UseCase.Output, UseCase.Failure> {
        Future { promise in
#if swift(>=6)
            let wrappedPromise = FutureResultWrapper(promise)
#endif
            Task {
                do throws(UseCase.Failure) {
                    let output = try await sourceUseCase.execute(input: input)
#if swift(>=6)
                    wrappedPromise(.success(output))
#else
                    promise(.success(output))
#endif
                } catch {
#if swift(>=6)
                    wrappedPromise(.failure(error))
#else
                    promise(.failure(error))
#endif
                }
            }
        }
    }
}

#if swift(>=6)
@dynamicCallable
fileprivate final class FutureResultWrapper<Output, Failure: Error>: @unchecked Sendable {
    fileprivate typealias Promise = (Result<Output, Failure>) -> Void

    fileprivate let completionResult: Promise

    /// Creates a publisher that invokes a promise closure when the publisher emits an element.
    ///
    /// - Parameter attemptToFulfill: A ``Future/Promise`` that the publisher invokes when the publisher emits an element or terminates with an error.
    fileprivate init(_ attemptToFulfill: @escaping Promise) {
        self.completionResult = attemptToFulfill
    }

    func dynamicallyCall(withArguments arguments: [Result<Output, Failure>]) {
        guard let firstArgument = arguments.first else {
            return
        }
        completionResult(firstArgument)
    }

    func callAsFunction(_ result: Result<Output, Failure>) -> Void {
        completionResult(result)
    }
}
#endif
