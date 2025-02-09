
# 🚀 Subscriber란?

`Subscriber`는 `Publisher`로부터 **이벤트나 데이터를 받아서 처리**하는 객체입니다.  
쉽게 말해, **"데이터를 구독하는 소비자"**라고 볼 수 있습니다. 😊  

---

## ✅ 1. Subscriber의 기본 개념

`Subscriber`는 **3가지 중요한 메서드**로 이루어져 있습니다.

```swift
public protocol Subscriber<Input, Failure>: CustomCombineIdentifierConvertible {
    associatedtype Input
    associatedtype Failure: Error
    
    func receive(subscription: Subscription)      // 구독 시작 시 호출
    func receive(_ input: Input) -> Demand        // 데이터 수신 시 호출
    func receive(completion: Subscribers.Completion<Failure>) // 완료 또는 에러 발생 시 호출
}
```

### 📦 Input과 Failure
- **Input:** `Publisher`가 보내는 데이터의 타입
- **Failure:** `Publisher`가 보낼 수 있는 에러 타입 (`Error`를 준수해야 함)

---

## 🔗 2. Subscriber와 Publisher의 연결 과정

1️⃣ **Publisher 생성하기**  
```swift
let publisher = Just("Hello, Combine!")
```
- `Just`는 단일 값을 발행하는 `Publisher`입니다.

2️⃣ **Subscriber로 구독 시작하기**  
```swift
publisher
    .sink { value in
        print(value)
    }
```
- `sink`는 간단한 `Subscriber` 역할을 합니다.

---

## 🚀 3. Subscriber의 동작 순서

1. **`receive(subscription:)`**  
   - `Publisher`가 구독 요청을 수락하고, 구독 정보를 `Subscriber`에게 전달합니다.

2. **`receive(_:)`**  
   - `Publisher`가 데이터를 발행하면, `Subscriber`가 이 데이터를 받아 처리합니다.

3. **`receive(completion:)`**  
   - 데이터 스트림이 끝나거나 에러가 발생하면 호출됩니다.

---

## 📊 4. Demand란?

`Demand`는 `Subscriber`가 **얼마나 많은 데이터를 받을지 요청하는 방식**입니다.

- `.none` → 추가 데이터 요청 없음
- `.unlimited` → 제한 없이 무한히 요청
- `max(_:)` → 특정 개수만큼 데이터 요청

```swift
func receive(_ input: Int) -> Subscribers.Demand {
    print("Received: \(input)")
    return .none  // 추가 요청 없이 현재 데이터만 처리
}
```

---

## 🧩 5. Custom Publisher & Subscriber 만들기

### ✅ 짝수만 발행하는 Custom Publisher

```swift
import Combine

struct EvenNumbersPublisher: Publisher {
    typealias Output = Int
    typealias Failure = Never

    let numbers: [Int]

    func receive<S>(subscriber: S) where S: Subscriber, S.Input == Int, S.Failure == Never {
        let subscription = EvenNumbersSubscription(subscriber: subscriber, numbers: numbers)
        subscriber.receive(subscription: subscription)
    }
}

final class EvenNumbersSubscription<S: Subscriber>: Subscription where S.Input == Int, S.Failure == Never {
    private var subscriber: S?
    private let numbers: [Int]

    init(subscriber: S, numbers: [Int]) {
        self.subscriber = subscriber
        self.numbers = numbers
    }

    func request(_ demand: Subscribers.Demand) {
        var demand = demand
        for number in numbers where number % 2 == 0 {
            guard demand > 0 else { break }
            demand -= 1
            demand += subscriber?.receive(number) ?? .none
        }
        subscriber?.receive(completion: .finished)
    }

    func cancel() {
        subscriber = nil
    }
}
```

---

### ✅ 짝수만 수신하는 Custom Subscriber

```swift
class EvenNumbersSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never

    func receive(subscription: Subscription) {
        subscription.request(.max(10))  // 최대 10개의 데이터 요청
    }

    func receive(_ input: Int) -> Subscribers.Demand {
        print("Received even number: \(input)")
        return .none  // 추가 요청 없음
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("✅ 모든 짝수 데이터 수신 완료")
    }
}
```

---

### 🚀 구독 시작하기

```swift
let evenPublisher = EvenNumbersPublisher(numbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
let evenSubscriber = EvenNumbersSubscriber()

evenPublisher.subscribe(evenSubscriber)
```

### 🎯 실행 결과:

```
Received even number: 2
Received even number: 4
Received even number: 6
Received even number: 8
Received even number: 10
✅ 모든 짝수 데이터 수신 완료
```

---

## 🗂️ 6. 핵심 요약

| 메서드                          | 역할                             |
|:--------------------------------|:---------------------------------|
| `receive(subscription:)`        | 구독 시작 요청 처리              |
| `receive(_:)`                   | 발행된 데이터 수신 및 처리        |
| `receive(completion:)`          | 스트림 완료 또는 에러 처리       |
| `request(_:)`                   | 데이터 요청 개수 설정             |
| `cancel()`                      | 구독 취소                        |

---

## ✅ 7. 마무리

- `Subscriber`는 `Publisher`의 데이터를 받아 처리하는 역할을 합니다.
- **Demand**를 통해 얼마나 많은 데이터를 받을지 조절할 수 있습니다.
- `Custom Publisher`와 `Custom Subscriber`를 통해 데이터 스트림을 유연하게 관리할 수 있습니다.

