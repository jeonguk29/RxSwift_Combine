# 🚀 Future Publisher

`Future`는 **비동기 작업의 결과를 단 한 번** 발행하는 특별한 Publisher입니다.  
**네트워크 요청**이나 **파일 읽기**처럼 비동기 작업 처리에 적합해요.  

---

## ✅ 1. Future의 주요 특징

- 🔄 **비동기 작업**을 처리할 수 있음
- ⏱ **결과가 나올 때까지 대기** 후 한 번만 데이터 발행
- 📤 **성공 또는 실패** 결과를 `Promise`로 반환
- 🏷 **클래스 타입** (상태 공유를 위해 사용됨)

---

## 🔨 2. Future 기본 사용법

### 📥 비동기 데이터 가져오기 함수

```swift
func fetchUserDataAsync() async throws -> Data {
  guard let url = URL(string: "https://api.publicapis.org/entries") else {
    throw URLError(.badURL)
  }
  let (data, response) = try await URLSession.shared.data(from: url)
  guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
    throw URLError(.badServerResponse)
  }
  return data
}
```

### 🚀 Future로 비동기 작업 처리

```swift
let futurePublisher = Future<Data, Error> { promise in
  Task {
    do {
      let data = try await fetchUserDataAsync()
      promise(.success(data))  // ✅ 성공 시 데이터 전달
    } catch {
      promise(.failure(error)) // ❌ 실패 시 에러 전달
    }
  }
}
```

### 📡 Future 구독하기
```swift
var cancellables = Set<AnyCancellable>()

futurePublisher
  .sink { completion in
    switch completion {
    case .finished:
      print("✅ 작업 완료!")
    case .failure(let error):
      print("❌ 에러 발생: \(error)")
    }
  } receiveValue: { value in
    print("📦 받은 데이터: \(value)")
  }
  .store(in: &cancellables)
```

### ⚡ 3. 전체 코드 모아보기
```swift
import Combine

var cancellables = Set<AnyCancellable>()

func fetchUserDataAsync() async throws -> Data {
  guard let url = URL(string: "https://api.publicapis.org/entries") else {
    throw URLError(.badURL)
  }
  let (data, response) = try await URLSession.shared.data(from: url)
  guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
    throw URLError(.badServerResponse)
  }
  return data
}

let futurePublisher = Future<Data, Error> { promise in
  Task {
    do {
      let data = try await fetchUserDataAsync()
      promise(.success(data))
    } catch {
      promise(.failure(error))
    }
  }
}

futurePublisher
  .sink { completion in
    switch completion {
    case .finished:
      print("✅ 작업 완료!")
    case .failure(let error):
      print("❌ 에러 발생: \(error)")
    }
  } receiveValue: { value in
    print("📦 받은 데이터: \(value)")
  }
  .store(in: &cancellables)
```

### 🔍 4. Deep Dive - Future 내부 구조
```swift
final public class Future<Output, Failure>: Publisher where Failure: Error {
    public typealias Promise = (Result<Output, Failure>) -> Void

    public init(
      _ attemptToFulfill: @escaping (@escaping Future<Output, Failure>.Promise) -> Void
    )
}
```

### 🤔 왜 클래스일까?
- 클래스 = 참조 타입 → 상태를 공유하기 쉬움
- 여러 구독자들이 같은 결과를 공유해야 할 때 유용
- 반면 구조체는 값 복사로 인해 비동기 결과 공유가 어려움

### 📦 Promise란?
Promise는 비동기 작업의 결과(성공 또는 실패)를 전달하는 약속 같은 개념입니다.
비동기 작업이 끝난 후, 결과를 Promise를 통해 전달하면 Future가 이 값을 Subscriber에게 전달합니다.

### 🚀 Promise 간단 설명
성공할 경우: promise(.success(결과값))
실패할 경우: promise(.failure(에러))
```swift
let futurePublisher = Future<Data, Error> { promise in
  Task {
    do {
      let data = try await fetchUserDataAsync()
      promise(.success(data))  // 성공 결과 전달
    } catch {
      promise(.failure(error)) // 실패 결과 전달
    }
  }
}
```
.success(data) → 데이터를 성공적으로 반환
.failure(error) → 에러 반환
중요: Future는 첫 번째로 전달된 결과만 처리하며, 이후 결과는 무시됩니다.

### 🚀 5. Future 사용 시 주의 사항
- 결과는 단 한 번만 발행됩니다.
- 여러 번 성공/실패를 호출해도 첫 번째 호출만 처리됩니다.
- 비동기 작업의 상태를 여러 구독자와 공유할 수 있습니다.

### ✅ 6. Future를 언제 사용할까?
- 📡 네트워크 요청 처리할 때
- ⏱ 비동기 데이터 로딩에 적합
- 📦 단일 결과만 필요한 경우 (예: API 호출, 파일 다운로드)

