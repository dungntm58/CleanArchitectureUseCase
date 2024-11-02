//
//  TrackableUseCase.swift
//  CleanArchitectureUseCase
//
//  Created by Robert on 2/11/24.
//

import Foundation
import Combine

public protocol Trackable {
    func beginActivity()
    func endActivity()
}

public protocol UseCaseTrackableSource {
    var tracker: Trackable { get }
}

extension ReactiveUseCase {
    public func makeTrackable(_ trackableSource: UseCaseTrackableSource) -> some ReactiveUseCase<Self.Input> {
        TrackableUseCase(sourceUseCase: self, trackableSource: trackableSource)
    }
}

private struct TrackableUseCase<UseCase>: ReactiveUseCase where UseCase: ReactiveUseCase {
    let sourceUseCase: UseCase
    var trackableSource: UseCaseTrackableSource

    init(sourceUseCase: UseCase, trackableSource: UseCaseTrackableSource) {
        self.sourceUseCase = sourceUseCase
        self.trackableSource = trackableSource
    }

    func execute(input: UseCase.Input) -> some Publisher<UseCase.Output.Output, UseCase.Output.Failure> {
        let tracker = trackableSource.tracker

        return sourceUseCase
            .execute(input: input)
            .handleEvents(receiveCompletion: { _ in
                tracker.endActivity()
            }, receiveCancel: {
                tracker.endActivity()
            }, receiveRequest: { _ in
                tracker.beginActivity()
            })
    }
}
