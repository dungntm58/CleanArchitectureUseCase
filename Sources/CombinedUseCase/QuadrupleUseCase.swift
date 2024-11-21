//
//  QuadrupleUseCase.swift
//  CleanArchitectureUseCase
//
//  Created by Robert on 23/11/24.
//

import Foundation
import Combine

extension UseCases {
    public static func makeQuadruple<UseCase1, UseCase2, UseCase3, UseCase4>(_ useCase1: UseCase1, _ useCase2: UseCase2, _ useCase3: UseCase3, _ useCase4: UseCase4) -> some QuadrupleReactiveUseCase<UseCase1.Input, UseCase2.Input, UseCase3.Input, UseCase4.Input, (UseCase1.Output.Output, UseCase2.Output.Output, UseCase3.Output.Output, UseCase4.Output.Output), UseCase1.Output.Failure> where UseCase1: ReactiveUseCase, UseCase2: ReactiveUseCase, UseCase3: ReactiveUseCase, UseCase4: ReactiveUseCase, UseCase1.Output.Failure == UseCase2.Output.Failure, UseCase2.Output.Failure == UseCase3.Output.Failure, UseCase3.Output.Failure == UseCase4.Output.Failure, UseCase3.Output.Failure == UseCase4.Output.Failure {
        QuadrupleUseCase(useCase1: useCase1, useCase2: useCase2, useCase3: useCase3, useCase4: useCase4)
    }
}

extension ReactiveUseCase {
    public func makeQuadruple<UseCase, UseCase1, UseCase2>(with useCase: UseCase, useCase1: UseCase1, _ useCase2: UseCase2) -> some QuadrupleReactiveUseCase<Self.Input, UseCase.Input, UseCase1.Input, UseCase2.Input, (Self.Output.Output, UseCase.Output.Output, UseCase1.Output.Output, UseCase2.Output.Output), Self.Output.Failure> where UseCase: ReactiveUseCase, UseCase1: ReactiveUseCase, UseCase2: ReactiveUseCase, UseCase.Output.Failure == UseCase1.Output.Failure, UseCase1.Output.Failure == UseCase2.Output.Failure, UseCase2.Output.Failure == Output.Failure {
        QuadrupleUseCase(useCase1: self, useCase2: useCase, useCase3: useCase1, useCase4: useCase2)
    }
}

public protocol QuadrupleReactiveUseCase<Input1, Input2, Input3, Input4, ReactiveOutput, ReactiveFailure>: ReactiveUseCase where Input == (Input1, Input2, Input3, Input4) {
    associatedtype Input1
    associatedtype Input2
    associatedtype Input3
    associatedtype Input4
}

extension QuadrupleReactiveUseCase {
    public func execute(input1: Input1, input2: Input2, input3: Input3, input4: Input4) -> Output {
        execute(input: (input1, input2, input3, input4))
    }
}

extension QuadrupleReactiveUseCase where Input1 == Void {
    public func execute(input2: Input2, input3: Input3, input4: Input4) -> Output {
        execute(input: ((), input2, input3, input4))
    }
}

extension QuadrupleReactiveUseCase where Input2 == Void {
    public func execute(input1: Input1, input3: Input3, input4: Input4) -> Output {
        execute(input: (input1, (), input3, input4))
    }
}

extension QuadrupleReactiveUseCase where Input3 == Void {
    public func execute(input1: Input1, input2: Input2, input4: Input4) -> Output {
        execute(input: (input1, input2, (), input4))
    }
}

extension QuadrupleReactiveUseCase where Input4 == Void {
    public func execute(input1: Input1, input2: Input2, input3: Input3) -> Output {
        execute(input: (input1, input2, input3, ()))
    }
}

private struct QuadrupleUseCase<UseCase1, UseCase2, UseCase3, UseCase4>: QuadrupleReactiveUseCase where UseCase1: ReactiveUseCase, UseCase2: ReactiveUseCase, UseCase3: ReactiveUseCase, UseCase4: ReactiveUseCase, UseCase1.Output.Failure == UseCase2.Output.Failure, UseCase2.Output.Failure == UseCase3.Output.Failure, UseCase3.Output.Failure == UseCase4.Output.Failure {
    typealias Input1 = UseCase1.Input
    typealias Input2 = UseCase2.Input
    typealias Input3 = UseCase3.Input
    typealias Input4 = UseCase4.Input

    let useCase1: UseCase1
    let useCase2: UseCase2
    let useCase3: UseCase3
    let useCase4: UseCase4

    func execute(input: (UseCase1.Input, UseCase2.Input, UseCase3.Input, UseCase4.Input)) -> some Publisher<(UseCase1.Output.Output, UseCase2.Output.Output, UseCase3.Output.Output, UseCase4.Output.Output), UseCase1.Output.Failure> {
        Publishers.Zip4(useCase1.execute(input: input.0), useCase2.execute(input: input.1), useCase3.execute(input: input.2), useCase4.execute(input: input.3))
    }
}
