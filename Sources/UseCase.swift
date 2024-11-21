//
//  UseCase.swift
//  CleanArchitectureUseCase
//
//  Created by Robert on 2/11/2024.
//

import Foundation
import Combine

public protocol UseCase<Input, Output> {
    associatedtype Input
    associatedtype Output

    func execute(input: Input) -> Output
}

extension UseCase where Input == Void {
    public func execute() -> Output {
        execute(input: ())
    }
}

public protocol ReactiveUseCase<Input, ReactiveOutput, ReactiveFailure>: UseCase where Output: Publisher<ReactiveOutput, ReactiveFailure> {
    associatedtype ReactiveOutput
    associatedtype ReactiveFailure
}

public enum UseCases {}
