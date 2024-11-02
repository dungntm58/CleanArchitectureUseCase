import Testing
import Combine
@testable import CleanArchitectureUseCase

struct CleanArchitectureUseCaseTests {
    @Test func testRetryableUseCase() async throws {
        var cancellables: Set<AnyCancellable> = []
        let retrySource = TestRetrySource()
        var useCase = TestReactiveUseCase { (_: Void) in }.makeRetryable(retrySource: retrySource)

        useCase
            .execute()
            .sink(receiveCompletion: { _ in  }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

enum TestError: Error {
    case test
}

struct TestReactiveUseCase<Input, ReactiveOutput>: ReactiveUseCase {
    var transform: (Input) throws(TestError) -> ReactiveOutput

    init(transform: @escaping (Input) throws(TestError) -> ReactiveOutput) {
        self.transform = transform
    }

    func execute(input: Input) -> some Publisher<ReactiveOutput, TestError> {
        Future<ReactiveOutput, TestError> { promise in
            do throws(TestError) {
                try promise(.success(transform(input)))
            } catch {
                promise(.failure(error))
            }
        }
    }
}

class TestRetrySource: UseCaseRetrySource {
    let effect: PassthroughSubject<Bool, Never>

    init(effect: PassthroughSubject<Bool, Never> = .init()) {
        self.effect = effect
    }

    func retryEffect() -> some Publisher<Bool, Never> {
        effect
    }
}
