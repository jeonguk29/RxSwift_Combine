
# 🚀 AnyCancellable이란?

`AnyCancellable`은 **Combine의 구독을 관리하고 자동으로 취소하는 역할**을 합니다.  
메모리 관리와 리소스 해제 측면에서 **굉장히 중요한 역할**을 합니다.

---

## ✅ 1. Cancellable 프로토콜 이해하기

먼저, `AnyCancellable`은 `Cancellable`이라는 프로토콜을 구현하고 있습니다.

```swift
public protocol Cancellable {
    func cancel()
}
```

### 🔍 Cancellable의 역할
- `cancel()` 메서드를 호출하면 **구독을 취소**할 수 있습니다.
- **더 이상 데이터를 받지 않음** → 불필요한 리소스 사용을 방지하여 **메모리 누수를 예방**할 수 있습니다.

---

## 🏷️ 2. AnyCancellable의 주요 특징

1️⃣ **자동으로 `cancel()`을 호출**  
   - `deinit`(객체가 메모리에서 해제될 때) 자동으로 `cancel()`을 실행합니다.  
   - 이를 통해 **구독이 자동으로 해제**됩니다.

2️⃣ **여러 구독을 한 번에 관리 가능**  
   - `Set<AnyCancellable>`을 사용하면 여러 구독을 한 번에 해제할 수 있습니다.

---

## 🔨 3. AnyCancellable 사용 방법

### ✅ 기본 사용법
```swift
var cancellables = Set<AnyCancellable>()

Just("Hello, Combine!")
    .sink(receiveValue: { value in
        print(value)
    })
    .store(in: &cancellables) // ✅ 구독을 Set에 저장
```

### 📌 이 코드의 동작 과정
1. `sink`를 호출하면 **구독이 시작됨**.
2. `sink`는 **구독을 관리할 수 있는 `AnyCancellable`을 반환**.
3. `.store(in: &cancellables)`를 사용하여 **Set에 저장**.
4. **Set이 메모리에서 해제되면** → 내부 `AnyCancellable`이 `cancel()`을 자동 호출하여 **구독 취소**.

---

## 📌 4. AnyCancellable을 활용한 메모리 관리

### ✅ store(in:) 없이 관리하는 방법
```swift
let cancellable = Just("Hello, Combine!")
    .sink(receiveValue: { value in
        print(value)
    })
```
- `cancellable`이 유지되는 동안 **구독이 활성화됨**.
- `cancellable`이 메모리에서 해제될 때 자동으로 `cancel()` 실행됨.

**🚨 하지만, `cancellable`을 따로 저장하지 않으면 구독이 즉시 해제됨!**

---

## 🏁 5. 핵심 요약

| 개념              | 설명 |
|-----------------|--------------------------------|
| `Cancellable`  | `cancel()`을 호출하여 구독 취소 가능 |
| `AnyCancellable` | `deinit` 시 자동으로 `cancel()` 호출 |
| `.store(in:)`   | 여러 구독을 `Set<AnyCancellable>`에 저장하여 한 번에 관리 |
| `cancellable` 변수 | 개별적으로 구독을 관리하는 방법 |

Combine에서 **메모리 누수를 방지하고 구독을 안전하게 관리하는** 핵심 도구입니다.  

