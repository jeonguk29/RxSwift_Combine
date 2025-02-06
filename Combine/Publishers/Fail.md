# 🚨 Fail Publisher

`Fail`은 **에러와 함께 즉시 데이터 스트림을 종료**하는 특별한 Publisher입니다.  
오로지 **에러만 발행**하고, **값(Output)은 발행하지 않습니다**.

---

## ✅ 1. Fail의 주요 특징

- ❌ **에러(Failure)만 발행**하고 즉시 스트림 종료
- 🚫 **값(Output)을 발행하지 않음**
- ⚡ **구독 즉시 에러 발생 후 종료**

---

## 🔨 2. Fail 기본 사용법

### 📥 에러 정의하기

```swift
enum CustomError: Error {
  case customError
}
```

### 🚀 Fail Publisher 생성 및 사용

```swift

import Combine

let failPublisher = Fail<Never, CustomError>(error: .customError)

failPublisher
  .sink { completion in
    switch completion {
    case .finished:
      print("✅ 작업 완료!")  // 실행되지 않음
    case .failure(let error):
      print("❌ 에러 발생: \(error)")
    }
  } receiveValue: { value in
    print("📦 받은 데이터: \(value)") // 실행되지 않음
  }
```

### 🎯 실행 결과

```swift
❌ 에러 발생: customError
receiveValue는 호출되지 않음 (값을 발행하지 않기 때문)
구독 즉시 .failure 이벤트가 발생하며 스트림 종료
```

### ⚡ 3. 전체 코드 모아보기

```swift

import Combine

enum CustomError: Error {
  case customError
}

let failPublisher = Fail<Never, CustomError>(error: .customError)

failPublisher
  .sink { completion in
    switch completion {
    case .finished:
      print("✅ 작업 완료!")  // 실행되지 않음
    case .failure(let error):
      print("❌ 에러 발생: \(error)")
    }
  } receiveValue: { value in
    print("📦 받은 데이터: \(value)") // 실행되지 않음
  }
```

### 🔍 4. Deep Dive - Fail 내부 구조

```swift
public struct Fail<Output, Failure>: Publisher where Failure: Error {
    public init(error: Failure)
}
```

### 🚀 동작 방식
Fail은 구독이 시작되면 즉시 에러를 발행하고 스트림을 종료합니다.
Output이 필요 없기 때문에 Never로 지정하는 것이 일반적입니다.

### 💡 5. Fail은 언제 사용할까?
✅ 1️⃣ 테스트용 Publisher 생성 시

```swift
let testFailPublisher = Fail<Never, URLError>(error: URLError(.badServerResponse))

testFailPublisher
  .sink(
    receiveCompletion: { completion in
      print(completion)
    },
    receiveValue: { value in
      print(value)
    }
  )
```

```swift
결과:
failure(badServerResponse)
```
테스트 중 에러 처리가 잘 되는지 확인할 때 유용합니다.


✅ 2️⃣ 조건부 에러 처리 시
```swift
func validateInput(_ input: String) -> AnyPublisher<String, Error> {
  guard !input.isEmpty else {
    return Fail(error: CustomError.customError).eraseToAnyPublisher()
  }
  return Just(input)
    .setFailureType(to: Error.self)
    .eraseToAnyPublisher()
}

validateInput("")
  .sink(
    receiveCompletion: { completion in
      print(completion)
    },
    receiveValue: { value in
      print("📦 값: \(value)")
    }
  )
```

```swift
failure(customError)
```
입력값이 유효하지 않은 경우 Fail을 사용하여 즉시 에러 반환


✅ 3️⃣ 네트워크 요청 실패 시 대체 Publisher로 사용
```swift
enum NetworkError: Error {
  case serverDown
}

let networkErrorPublisher = Fail<Never, NetworkError>(error: .serverDown)

networkErrorPublisher
  .sink { completion in
    if case .failure(let error) = completion {
      print("❌ 네트워크 오류 발생: \(error)")
    }
  } receiveValue: { _ in
    print("값은 발행되지 않음")
  }
```

❌ 네트워크 오류 발생: serverDown
네트워크 상태를 감지하고 바로 에러를 반환해야 할 때 사용

### ⚠️ 6. Fail 사용 시 주의 사항
- Fail은 값을 발행하지 않으며, 구독 즉시 실패를 반환합니다.
- Output 타입은 보통 Never로 설정합니다.
- 복잡한 로직 대신 간단한 실패 처리를 위한 Publisher로 사용됩니다.

### ✅ 7. Fail을 언제 사용하면 좋을까?
- 📋 테스트용 Publisher 생성 시 (에러 흐름 테스트)
- ⛔ 조건이 만족되지 않을 때 즉시 실패 처리 (입력 검증 등)
- 🚨 에러 흐름을 명확히 제어할 필요가 있을 때 (에러 처리 로직 강화)
- 🧪 에러 처리 로직의 테스트 작성 시 (Combine 스트림의 실패 흐름 테스트)



### 🚀 **`Never`란?**  

`Never`는 **Swift의 특수한 타입**으로, **절대 값이 존재할 수 없는 타입**입니다. 즉, **"아무 값도 가질 수 없다"**는 의미를 가집니다.  

간단히 말하면,  
- `Never`는 **값을 반환하지 않는 함수** 또는  
- **절대 실행되지 않는 코드 경로**를 나타낼 때 사용됩니다.  

---

## ✅ **1. 왜 `Never`가 필요할까?**

- **비정상적인 종료 또는 실패를 나타낼 때**  
- **영원히 끝나지 않는 함수**를 표현할 때  
- **에러만 발생하고 값은 절대 반환하지 않는 경우** (Combine의 `Fail`처럼)

---

## 📌 **2. 예제 1: 종료 함수에서의 사용**

```swift
func crashApp() -> Never {
  fatalError("🚨 앱이 강제 종료되었습니다.")
}

crashApp()  // 이 함수는 절대 반환되지 않음
```

### ✅ 설명:
- `crashApp()` 함수는 호출된 후 **앱을 강제 종료**하기 때문에 **절대 반환되지 않습니다.**
- 반환 타입을 `Never`로 지정하여 **"이 함수는 정상적으로 끝나지 않는다"**는 것을 명확하게 표현합니다.

---

## 📌 **3. 예제 2: `switch` 구문에서의 사용**

```swift
enum Result<Value, Error> {
  case success(Value)
  case failure(Error)
}

func handleResult(_ result: Result<Int, Never>) {
  switch result {
  case .success(let value):
    print("성공한 값: \(value)")
  }
}
```

### ✅ 설명:
- `Result<Int, Never>`는 **절대 에러를 가질 수 없는 경우**를 의미합니다.
- **`Never`가 `Error` 자리에 있기 때문에** `case .failure`를 처리할 필요가 없습니다.  
- 컴파일러가 이미 `failure`가 발생할 수 없다는 것을 알고 있기 때문입니다.

---

## 📌 **4. 예제 3: Combine에서의 `Never`**

```swift
import Combine

let publisher = Just(100)  // Output: Int, Failure: Never

publisher
  .sink(
    receiveCompletion: { completion in
      print("✅ 완료: \(completion)")
    },
    receiveValue: { value in
      print("📦 값: \(value)")
    }
  )
```

### ✅ 설명:
- `Just`는 항상 **성공적으로 완료**되기 때문에 `Failure` 타입이 `Never`입니다.
- 즉, **에러가 발생할 가능성이 전혀 없다는 의미**입니다.

---

## 🔥 **5. `Never`의 활용 요약**

| 상황                           | 설명                                            |
|:-------------------------------|:------------------------------------------------|
| ❌ 에러가 발생할 수 없는 경우    | `Result` 또는 `Publisher`에서 `Failure: Never` 사용 |
| 🚨 앱 강제 종료 함수             | `fatalError()`, `preconditionFailure()`와 함께 사용 |
| 🔄 무한 루프 함수                | 끝나지 않는 루프 함수에서 사용 (`while true {}`)    |
| ✅ 불가능한 코드 경로             | `switch` 문에서 모든 케이스가 처리된 경우           |

---

## ⚠️ **6. 주의 사항**

- `Never`는 **"값이 없다"**는 의미의 `Void`와 다릅니다.  
  - `Void`는 **빈 값을 반환**할 수 있지만,  
  - `Never`는 **아예 반환하지 않는 함수나 상황**을 나타냅니다.

---

## ✅ **7. 정리**

- `Never`는 **절대 발생하지 않는 상황**을 표현하는 타입입니다.  
- Combine에서는 **에러가 발생하지 않는 Publisher**의 `Failure` 타입으로 자주 사용됩니다.  
- `Never`를 통해 코드의 **안정성과 가독성**을 높일 수 있습니다. 🚀

---

