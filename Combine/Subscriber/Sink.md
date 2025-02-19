
# 🚀 sink란?

`sink`는 **내부적으로 `Subscriber` 객체를 생성하여 `Publisher`를 구독하는 메서드**입니다.  
즉, `Publisher`가 발행하는 데이터를 쉽게 받을 수 있도록 도와주는 간단한 방식입니다.

---

## ✅ 1. sink의 주요 특징

1️⃣ **내부적으로 `Subscriber`를 자동 생성**  
   - `sink`를 사용하면 직접 `Subscriber`를 구현할 필요 없이 **간편하게 구독 가능**.

2️⃣ **기본 Demand 값이 `.unlimited`**  
   - 즉, **Publisher가 발행하는 모든 데이터를 끝까지 받음**.

3️⃣ **`AnyCancellable`을 반환**  
   - `sink`는 `AnyCancellable` 타입을 반환하며,  
   - 이를 저장하지 않으면 **즉시 구독이 취소**되어 더 이상 데이터를 받을 수 없음.

---

## 🔨 2. sink의 사용법

`sink`에는 **두 가지 형태**가 있습니다.

### ✅ 1. `Publisher`가 `Failure`를 가질 경우
```swift
public func sink(
  receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void),
  receiveValue: @escaping ((Self.Output) -> Void)
) -> AnyCancellable
```
- `receiveCompletion`: **완료 이벤트**(`.finished` 또는 `.failure`)를 받음.
- `receiveValue`: **발행된 값**을 처리함.

### ✅ 2. `Publisher`의 `Failure`가 `Never`일 경우
```swift
public func sink(
  receiveValue: @escaping ((Self.Output) -> Void)
) -> AnyCancellable
```
- `Failure == Never`인 경우 **에러가 발생하지 않음** → `receiveCompletion` 필요 없음.

---

## 📌 3. 기본 사용 예제

### 📡 1. 일반적인 sink 사용법 (`Failure`가 존재할 경우)
```swift
var cancellables = Set<AnyCancellable>()

let publisher = Future<String, Error> { promise in
    promise(.success("Hello, Combine!"))
}

publisher
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("✅ finished")
        case .failure(let error):
            print("❌ Error: \(error)")
        }
    }, receiveValue: { value in
        print("📦 Received value: \(value)")
    })
    .store(in: &cancellables)
```
### 📝 실행 결과
```
📦 Received value: Hello, Combine!
✅ finished
```

---

### 📡 2. `Failure == Never`일 경우 (`receiveCompletion` 생략)
```swift
var cancellables = Set<AnyCancellable>()

Just("just value")
    .sink(receiveValue: { value in
        print("📦 Received: \(value)")
    })
    .store(in: &cancellables)
```

### 📝 실행 결과
```
📦 Received: just value
```

---

## 🔄 4. 클로저 축약형으로 사용하기

`sink`는 클로저 축약을 활용하여 더 간결하게 사용할 수도 있습니다.

```swift
var cancellables = Set<AnyCancellable>()

Empty<Int, Error>(completeImmediately: true)
    .sink {
        switch $0 {
        case .finished:
            print("✅ finished")
        case .failure(let error):
            print("❌ Error: \(error)")
        }
    } receiveValue: {
        print("📦 Received: \($0)")
    }
    .store(in: &cancellables)
```

---

## 🏁 5. 핵심 요약

| 개념                | 설명 |
|---------------------|--------------------------------|
| `sink` | `Subscriber`를 내부적으로 생성하여 쉽게 구독 |
| `receiveCompletion` | 완료 이벤트 (`.finished` or `.failure`) 처리 |
| `receiveValue` | Publisher에서 발행한 값 처리 |
| `AnyCancellable` 반환 | 저장하지 않으면 구독이 즉시 취소됨 |
| `Failure == Never` | `receiveCompletion` 생략 가능 |

---

## ✅ 6. 결론
`sink`는 `Publisher`를 구독하는 **가장 간단한 방법**이며,  
메모리 관리와 구독 취소를 위해 `AnyCancellable`과 함께 사용해야 합니다.  
이제 Combine의 `sink`를 활용해 효율적인 데이터 스트림을 관리해 보세요! 🚀
