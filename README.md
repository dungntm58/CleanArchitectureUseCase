
# Clean Architecture UseCase for iOS

This repository provides a reusable **UseCase** implementation for iOS projects, adhering to the principles of **Clean Architecture**. It includes an abstract `UseCase` protocol and concrete `UseCase` structs designed to handle **task retrying** and **activity tracking**.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This library is designed to simplify **Use Case** implementations in iOS projects. By encapsulating task-related logic, such as retrying failed operations and tracking ongoing activities, it enhances the modularity and maintainability of your app.

### Key Concepts:
- **UseCase Protocol**: A generic protocol for defining use cases with type safety.
- **Task Retrying**: Implement robust retry mechanisms for tasks that may fail.
- **Activity Tracking**: Monitor the active state of ongoing operations, useful for UI updates or background tasks.

This library is built with support for **Swift Package Manager (SPM)** to ensure seamless integration with iOS projects.

---

## Features

- **Abstract UseCase Protocol**:  
  A base protocol for defining reusable and type-safe use cases.

- **Task Retrying**:  
  Handle transient failures by implementing configurable retry logic.

- **Activity Tracking**:  
  Track and manage active tasks to streamline UI state updates (e.g., showing a loading spinner).

- **SPM Support**:  
  Easily add the library to your iOS project using **Swift Package Manager**.

---

## Installation

### Swift Package Manager

To integrate this library into your project:

1. Open your project in Xcode.
2. Navigate to **File > Add Packages...**.
3. Enter the repository URL:  
   ```
   https://github.com/dungntm58/CleanArchitectureUseCase
   ```
4. Choose the desired version or branch, then add the package to your project.

---

## Usage

### Defining a Custom UseCase

To create a new use case, conform to the `UseCase` protocol:

```swift
import CleanArchitectureUseCase

struct MyUseCase: UseCase {
    func execute(input: String) -> Int {
        input.count
    }
}

enum MyError: Error {
    case invalidLength
}

struct MyCustomUseCase: ReactiveUseCase {
    func execute(input: String) -> some Publisher<Int, MyError> {
        Future { promise in
            if input.count > 255 {
                promise(.failure(.invalidLength))
            } else {
                promise(.success(input.count))
            }
        }
    }
}
```

### Retrying a Task

Use the built-in retryable use case to handle task failures:

```swift
import CleanArchitectureUseCase

class MyViewModel: UseCaseRetrySource {
    @Published var isShowingErrorPopup: Bool = false

    func retryEffect() -> some Publisher<Bool, Never> {
        $isShowingErrorPopup
    }
}

let viewModel = MyViewModel()
let retryableUseCase = MyCustomUseCase().makeRetryable(retrySource: viewModel)
let result = retryableUseCase.execute("Hello, world!")
print(result)
```

### Tracking Task Activities

Monitor the state of ongoing tasks using the activity tracker:

```swift
import CleanArchitectureUseCase

class MyViewModel: UseCaseTrackableSource, Trackable {
    @Published var isLoading: Bool = false

    func beginActivity() {
        isLoading = true
    }

    func endActivity() {
        isLoading = false
    }
}

let viewModel = MyViewModel()
let trackableUseCase = MyCustomUseCase().makeTrackable(viewModel)
let result = trackableUseCase.execute("Hello, world!")
print(result)
```

---

## Contributing

Contributions are welcome! If you’d like to improve this library:

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature/new-feature
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add new feature"
   ```
4. Push to your fork:
   ```bash
   git push origin feature/new-feature
   ```
5. Open a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Feel free to open issues or discussions for any suggestions or questions. 🚀
