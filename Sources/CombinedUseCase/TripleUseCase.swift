//
//  TripleUseCase.swift
//  CleanArchitectureUseCase
//
//  Created by Robert on 23/11/24.
//

import Foundation
import Combine

extension UseCases {
    public static func makeTriple<UseCase1, UseCase2, UseCase3>(_ useCase1: UseCase1, _ useCase2: UseCase2, _ useCase3: UseCase3) -> some TripleReactiveUseCase<UseCase1.Input, UseCase2.Input, UseCase3.Input, (UseCase1.Output.Output, UseCase2.Output.Output, UseCase3.Output.Output), UseCase1.Output.Failure> where UseCase1: ReactiveUseCase, UseCase2: ReactiveUseCase, UseCase3: ReactiveUseCase, UseCase1.Output.Failure == UseCase2.Output.Failure, UseCase2.Output.Failure == UseCase3.Output.Failure {
        TripleUseCase(useCase1: useCase1, useCase2: useCase2, useCase3: useCase3)
    }
}

extension ReactiveUseCase {
    public func makeTriple<UseCase, UseCase1>(with useCase: UseCase, _ useCase1: UseCase1) -> some TripleReactiveUseCase<Self.Input, UseCase.Input, UseCase1.Input, (Self.Output.Output, UseCase.Output.Output, UseCase1.Output.Output), Self.Output.Failure> where UseCase: ReactiveUseCase, UseCase1: ReactiveUseCase, UseCase.Output.Failure == Output.Failure, UseCase1.Output.Failure == Output.Failure {
        UseCases.makeTriple(self, useCase, useCase1)
    }
}

public protocol TripleReactiveUseCase<Input1, Input2, Input3, ReactiveOutput, ReactiveFailure>: ReactiveUseCase where Input == (Input1, Input2, Input3) {
    associatedtype Input1
    associatedtype Input2
    associatedtype Input3
}

extension TripleReactiveUseCase {
    public func execute(input1: Input1, input2: Input2, input3: Input3) -> Output {
        execute(input: (input1, input2, input3))
    }
}

extension TripleReactiveUseCase where Input1 == Void {
    public func execute(input2: Input2, input3: Input3) -> Output {
        execute(input: ((), input2, input3))
    }
}

extension TripleReactiveUseCase where Input2 == Void {
    public func execute(input1: Input1, input3: Input3) -> Output {
        execute(input: (input1, (), input3))
    }
}

extension TripleReactiveUseCase where Input3 == Void {
    public func execute(input1: Input1, input2: Input2) -> Output {
        execute(input: (input1, input2, ()))
    }
}

extension TripleReactiveUseCase where Input1 == Void, Input2 == Void, Input3 == Void {
    public func execute() -> Output {
        execute(input: ((), (), ()))
    }
}

private struct TripleUseCase<UseCase1, UseCase2, UseCase3>: TripleReactiveUseCase where UseCase1: ReactiveUseCase, UseCase2: ReactiveUseCase, UseCase3: ReactiveUseCase, UseCase1.Output.Failure == UseCase2.Output.Failure, UseCase2.Output.Failure == UseCase3.Output.Failure {
    typealias Input1 = UseCase1.Input
    typealias Input2 = UseCase2.Input
    typealias Input3 = UseCase3.Input

    let useCase1: UseCase1
    let useCase2: UseCase2
    let useCase3: UseCase3

    func execute(input: (UseCase1.Input, UseCase2.Input, UseCase3.Input)) -> some Publisher<(UseCase1.Output.Output, UseCase2.Output.Output, UseCase3.Output.Output), UseCase1.Output.Failure> {
        Publishers.Zip3(useCase1.execute(input: input.0), useCase2.execute(input: input.1), useCase3.execute(input: input.2))
    }
}
