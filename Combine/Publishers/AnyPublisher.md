
# 🗃️ AnyPublisher란?

`AnyPublisher`는 **다양한 Publisher 타입을 하나로 추상화**하는 데 사용됩니다.  
즉, 여러 Publisher의 타입을 숨기고 **공통된 Publisher로 처리**할 수 있게 도와줍니다.

---

## ✅ AnyPublisher의 주요 특징

- 🔍 **타입 소거(Type Erasure):** 실제 Publisher의 구체 타입을 감추고 일관성 유지
- 🔄 **다양한 Publisher 통합:** 여러 다른 Publisher들을 하나로 관리 가능
- 🤝 **유연한 코드 작성:** Publisher 간의 상호작용을 더 쉽게 만듦

---

## 📦 AnyPublisher 기본 사용법

```swift
func fetchData() -> AnyPublisher<Data, Error> {
  URLSession.shared.dataTaskPublisher(for: URL(string: "https://example.com")!)
    .map { $0.data }
    .mapError { $0 as Error }
    .eraseToAnyPublisher()  // 구체 타입을 감추고 AnyPublisher로 변환
}
```

### ✅ 설명:
- `URLSession.DataTaskPublisher`라는 구체적인 타입을 `AnyPublisher<Data, Error>`로 변환합니다.
- `eraseToAnyPublisher()`는 **타입 소거** 역할을 합니다.

---

## 📊 AnyPublisher 활용 예제 1 - 여러 API 요청 처리

```swift
func fetchUserProfile() -> AnyPublisher<String, Error> {
  Just("👤 유저 프로필")
    .setFailureType(to: Error.self)
    .eraseToAnyPublisher()
}

func fetchUserSettings() -> AnyPublisher<String, Error> {
  Just("⚙️ 유저 설정")
    .setFailureType(to: Error.self)
    .eraseToAnyPublisher()
}

let combinedPublisher = Publishers.Zip(fetchUserProfile(), fetchUserSettings())
  .map { profile, settings in
    return "\(profile), \(settings)"
  }
  .eraseToAnyPublisher()

combinedPublisher
  .sink(receiveCompletion: { completion in
    print("✅ 모든 요청 완료")
  }, receiveValue: { combinedData in
    print("📦 받은 데이터: \(combinedData)")
  })
  .store(in: &cancellables)
```

### ✅ 설명:
- `Publishers.Zip`을 사용하여 **두 개의 API 요청을 병렬로 처리**합니다.
- `eraseToAnyPublisher()`로 타입을 단일화하여 편리하게 사용합니다.

---

## 📊 AnyPublisher 활용 예제 2 - 조건부 Publisher 처리

```swift
enum FetchError: Error {
  case networkUnavailable
}

func fetchDataBasedOnCondition(isOnline: Bool) -> AnyPublisher<String, FetchError> {
  if isOnline {
    return Just("🌐 온라인 데이터")
      .setFailureType(to: FetchError.self)
      .eraseToAnyPublisher()
  } else {
    return Fail(error: FetchError.networkUnavailable)
      .eraseToAnyPublisher()
  }
}

fetchDataBasedOnCondition(isOnline: Bool.random())
  .sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
      print("✅ 완료")
    case .failure(let error):
      print("❌ 에러: \(error)")
    }
  }, receiveValue: { value in
    print("📦 데이터: \(value)")
  })
  .store(in: &cancellables)
```

### ✅ 설명:
- 인터넷 연결 상태에 따라 **성공 또는 실패 Publisher를 동적으로 선택**합니다.
- `AnyPublisher`를 사용하여 반환 타입을 통일합니다.

---
