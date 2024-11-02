//
//  RetryableUseCase.swift
//  CleanArchitectureUseCase
//
//  Created by Robert on 2/11/24.
//

import Foundation
import Combine
import CombineExt

public protocol UseCaseRetrySource {
    associatedtype Effect: Publisher<Bool, Never>

    func retryEffect() -> Effect
}

extension ReactiveUseCase {
    public func makeRetryable<RetrySource>(retrySource: RetrySource, when condition: ((Error) -> Bool)? = nil) -> some ReactiveUseCase<Self.Input> where RetrySource: UseCaseRetrySource {
        RetryableUseCase(sourceUseCase: self, retrySource: retrySource, when: condition)
    }
}

private struct RetryableUseCase<UseCase, RetrySource>: ReactiveUseCase where UseCase: ReactiveUseCase, RetrySource: UseCaseRetrySource {
    private let sourceUseCase: UseCase
    private let retrySource: RetrySource
    private let condition: ((Error) -> Bool)?

    init(sourceUseCase: UseCase, retrySource: RetrySource, when condition: ((Error) -> Bool)?) {
        self.sourceUseCase = sourceUseCase
        self.retrySource = retrySource
        self.condition = condition
    }

    func execute(input: UseCase.Input) -> some Publisher<UseCase.Output.Output, UseCase.Output.Failure> {
        var retryEffect: RetrySource.Effect {
            retrySource.retryEffect()
        }
        return sourceUseCase
            .execute(input: input)
            .retryWhen { [condition] errorPublisher in
                errorPublisher
                    .setFailureType(to: UseCase.Output.Failure.self)
                    .flatMap { error in
                        guard condition?(error) ?? true else {
                            return Fail<Void, UseCase.Output.Failure>(error: error).eraseToAnyPublisher()
                        }
                        return retryEffect
                            .flatMap { ok in
                                if ok {
                                    return Just(()).eraseToAnyPublisher()
                                }
                                return Empty().eraseToAnyPublisher()
                            }
                            .setFailureType(to: UseCase.Output.Failure.self)
                            .eraseToAnyPublisher()
                    }
            }
    }
}
