//
//  CombinedUseCase.swift
//  CleanArchitectureUseCase
//
//  Created by Robert on 21/11/24.
//

import Foundation
import Combine

extension UseCases {
    public static func makePair<UseCase1, UseCase2>(_ useCase1: UseCase1, _ useCase2: UseCase2) -> some PairedReactiveUseCase<UseCase1.Input, UseCase2.Input, (UseCase1.Output.Output, UseCase2.Output.Output), UseCase1.Output.Failure> where UseCase1: ReactiveUseCase, UseCase2: ReactiveUseCase, UseCase1.Output.Failure == UseCase2.Output.Failure {
        PairedUseCase(useCase1: useCase1, useCase2: useCase2)
    }
}

extension ReactiveUseCase {
    public func makePaired<UseCase>(with useCase: UseCase) -> some PairedReactiveUseCase<Self.Input, UseCase.Input, (Self.Output.Output, UseCase.Output.Output), Self.Output.Failure> where UseCase: ReactiveUseCase, UseCase.Output.Failure == Output.Failure {
        UseCases.makePair(self, useCase)
    }
}

public protocol PairedReactiveUseCase<Input1, Input2, ReactiveOutput, ReactiveFailure>: ReactiveUseCase where Input == (Input1, Input2) {
    associatedtype Input1
    associatedtype Input2
}

extension PairedReactiveUseCase {
    public func execute(input1: Input1, input2: Input2) -> Output {
        execute(input: (input1, input2))
    }
}

extension PairedReactiveUseCase where Input1 == Void {
    public func execute(input2: Input2) -> Output {
        execute(input: ((), input2))
    }
}

extension PairedReactiveUseCase where Input2 == Void {
    public func execute(input1: Input1) -> Output {
        execute(input: (input1, ()))
    }
}

extension PairedReactiveUseCase where Input1 == Void, Input2 == Void {
    public func execute() -> Output {
        execute(input: ((), ()))
    }
}

private struct PairedUseCase<UseCase1, UseCase2>: PairedReactiveUseCase where UseCase1: ReactiveUseCase, UseCase2: ReactiveUseCase, UseCase1.Output.Failure == UseCase2.Output.Failure {
    typealias Input1 = UseCase1.Input
    typealias Input2 = UseCase2.Input

    let useCase1: UseCase1
    let useCase2: UseCase2

    func execute(input: (UseCase1.Input, UseCase2.Input)) -> some Publisher<(UseCase1.Output.Output, UseCase2.Output.Output), UseCase1.Output.Failure> {
        Publishers.Zip(useCase1.execute(input: input.0), useCase2.execute(input: input.1))
    }
}
