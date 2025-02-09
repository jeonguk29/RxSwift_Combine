
# 🗃️ Record Publisher

`Record`는 **사전에 정의된 값을 순차적으로 발행**하고, **정의된 완료 이벤트를 발행**하는 특별한 Publisher입니다.  
주로 **테스트 목적**으로 사용되며, **일관된 데이터 시퀀스**를 보장합니다.

---

## ✅ Record의 주요 특징

- 🔢 **미리 정의된 값**을 순차적으로 발행
- 🧪 **단위 테스트에 적합:** 외부 데이터 없이 Mock Data로 테스트 가능
- 🔄 **일관된 데이터 시퀀스:** 모든 Subscriber에게 동일한 데이터와 완료 이벤트 제공

---

## 📦 Record 기본 사용법

### ✅ 에러를 발행하지 않을 경우

```swift
let recordPublisher = Record<Int, Never>(output: [1, 2, 3], completion: .finished)

recordPublisher
  .sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
      print("✅ 완료")
    case .failure(let failure):
      print("❌ 에러: \(failure)")
    }
  }, receiveValue: { value in
    print("📦 값: \(value)")
  })
  .store(in: &cancellables)
```

### 🎯 실행 결과

```
📦 값: 1
📦 값: 2
📦 값: 3
✅ 완료
```

---

### ✅ 에러를 발행할 경우

```swift
enum CustomError: Error {
  case unknownError
}

let recordPublisher = Record<Int, CustomError>(output: [1, 2, 3], completion: .failure(.unknownError))

recordPublisher
  .sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
      print("✅ 완료")
    case .failure(let failure):
      print("❌ 에러: \(failure)")
    }
  }, receiveValue: { value in
    print("📦 값: \(value)")
  })
  .store(in: &cancellables)
```

### 🎯 실행 결과

```
📦 값: 1
📦 값: 2
📦 값: 3
❌ 에러: unknownError
```

---

## 🧪 Record를 활용한 단위 테스트 예제

### ✅ 테스트 시나리오
- **목표:** `Record`를 사용하여 특정 값과 완료 이벤트가 예상대로 발행되는지 확인하기

```swift
import XCTest
import Combine

class RecordPublisherTests: XCTestCase {
  var cancellables: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    cancellables = []
  }

  override func tearDown() {
    cancellables = nil
    super.tearDown()
  }

  func testRecordPublisherWithSuccess() {
    let expectation = XCTestExpectation(description: "Publisher should emit values and complete successfully")
    let expectedValues = [1, 2, 3]
    var receivedValues = [Int]()

    let recordPublisher = Record<Int, Never>(output: expectedValues, completion: .finished)

    recordPublisher
      .sink(receiveCompletion: { completion in
        if case .finished = completion {
          XCTAssertEqual(receivedValues, expectedValues)
          expectation.fulfill()
        }
      }, receiveValue: { value in
        receivedValues.append(value)
      })
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1.0)
  }

  func testRecordPublisherWithError() {
    let expectation = XCTestExpectation(description: "Publisher should emit values and fail with error")
    let expectedValues = [1, 2, 3]
    var receivedValues = [Int]()
    let expectedError = CustomError.unknownError

    let recordPublisher = Record<Int, CustomError>(output: expectedValues, completion: .failure(expectedError))

    recordPublisher
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          XCTFail("Expected failure but received finished")
        case .failure(let error):
          XCTAssertEqual(error, expectedError)
          XCTAssertEqual(receivedValues, expectedValues)
          expectation.fulfill()
        }
      }, receiveValue: { value in
        receivedValues.append(value)
      })
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1.0)
  }
}
```

### ✅ 설명:
- **`testRecordPublisherWithSuccess`**: `Record`가 정상적으로 값과 완료 이벤트를 발행하는지 확인합니다.
- **`testRecordPublisherWithError`**: `Record`가 에러를 발행하는 경우를 검증합니다.
- `XCTestExpectation`을 사용하여 비동기적으로 Publisher의 동작을 테스트합니다.

---

