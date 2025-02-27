
# 🚀 Subject란?

`Subject`는 **Publisher와 Subscriber의 역할을 동시에 할 수 있는 객체**입니다.  
즉, **데이터를 발행(Publisher)** 하면서도 **데이터를 구독(Subscriber)** 할 수 있는 특별한 존재입니다!

---

## ✅ 1. Subject의 주요 특징

1️⃣ **데이터를 발행(Publisher)하면서 구독(Subscriber)도 가능**  
2️⃣ **Output(출력) 타입과 Failure(오류) 타입을 명확히 지정해야 함**  
3️⃣ **멀티캐스트 기능 지원** → 여러 구독자에게 같은 데이터를 전달 가능  
4️⃣ **자동으로 `.finished` 이벤트를 발행하지 않음**  
5️⃣ **다른 스레드에서 접근 가능하지만 기본적으로 스레드 안전(Thread Safety)하지 않음**  
6️⃣ **동적으로 구독자를 추가하거나 제거 가능**  

---

## 🔨 2. Subject의 종류

Combine에는 **두 가지 종류의 Subject**가 있습니다.

- **📌 PassthroughSubject** → 최신 값만 전달 (이전 값 저장 X)
- **📌 CurrentValueSubject** → 최신 값 저장 후 구독자에게 전달

👉 각각의 자세한 개념은 별도로 다루겠습니다.

---

## 📌 3. Subject는 자동으로 완료되지 않는다?

우리는 일반 `Publisher`를 사용할 때, 데이터가 모두 발행되면 `.finished` 이벤트가 자동으로 발생하는 것을 봤습니다.

```swift
Just("Hello, Combine!")
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("✅ 자동 완료")
        case .failure(let error):
            print("❌ Error: \(error)")
        }
    }, receiveValue: { value in
        print("📦 Received: \(value)")
    })
```
### ✅ 실행 결과:
```
📦 Received: Hello, Combine!
✅ 자동 완료
```

하지만 **`Subject`는 자동으로 `.finished`를 발행하지 않습니다!**  
즉, **직접 명시적으로 완료 이벤트를 발행해야 합니다.**

---

## 🔄 4. Subject 사용 예제

### 📡 1. Subject에서 값 발행 & 수신

```swift
var cancellables = Set<AnyCancellable>()

let passthroughSubject = PassthroughSubject<String, Never>()

passthroughSubject
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("✅ Received finished")
        case .failure(let error):
            print("❌ Received error: \(error)")
        }
    }, receiveValue: { value in
        print("📦 Received value: \(value)")
    })
    .store(in: &cancellables) // ✅ 구독을 유지하기 위해 저장

// 값 발행
passthroughSubject.send("First value")
passthroughSubject.send("Second value")
passthroughSubject.send(completion: .finished) // ✅ 직접 완료 이벤트 발행
```

### 📝 실행 결과:
```
📦 Received value: First value
📦 Received value: Second value
✅ Received finished
```

---

### ❌ 2. 만약 `.finished`를 호출하지 않는다면?

```swift
let passthroughSubject = PassthroughSubject<String, Never>()

passthroughSubject
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("✅ Received finished")
        case .failure(let error):
            print("❌ Received error: \(error)")
        }
    }, receiveValue: { value in
        print("📦 Received value: \(value)")
    })
    .store(in: &cancellables)

passthroughSubject.send("First value")
passthroughSubject.send("Second value")
// ❌ .finished 호출하지 않음!

```

### ❗ 실행 결과:
```
📦 Received value: First value
📦 Received value: Second value
(데이터 스트림이 계속 열려 있음)
```
👉 **문제:** `completion(.finished)`을 호출하지 않으면 **구독이 계속 유지**되면서 메모리 누수 가능성이 높아집니다.

---

## 🛑 5. Subject의 메모리 누수 방지

### 🚨 **Subject는 구독을 저장하지 않으면 값을 받을 수 없음!**

```swift
let passthroughSubject = PassthroughSubject<String, Never>()

passthroughSubject.sink(
    receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("✅ Received finished")
        case .failure(let error):
            print("❌ Received error: \(error)")
        }
    },
    receiveValue: { value in
        print("📦 Received value: \(value)")
    }
)
// ❌ .store(in: &cancellables) 생략!

passthroughSubject.send("First value")
passthroughSubject.send("Second value")
passthroughSubject.send(completion: .finished)
```
### ❌ 실행 결과:
```
(아무것도 출력되지 않음)
```
👉 **이유:** `sink`에서 반환된 `AnyCancellable`이 **어디에도 저장되지 않아서 즉시 해제**됨 → 구독이 종료됨.

### ✅ 해결 방법: `.store(in:)` 사용
```swift
passthroughSubject
    .sink { print("📦 Received: \($0)") }
    .store(in: &cancellables) // ✅ 구독 유지!
```

---

## 🏁 6. 핵심 요약

| 개념                  | 설명 |
|---------------------|--------------------------------|
| `Subject` | Publisher + Subscriber 역할 가능 |
| `.finished` 자동 발행 없음 | **직접 완료 이벤트를 호출해야 함** |
| 멀티캐스트 가능 | 여러 구독자가 같은 데이터를 받을 수 있음 |
| `.store(in:)` 필요 | 구독을 유지하려면 반드시 저장해야 함 |

---

## ✅ 7. 결론
- `Subject`는 **Publisher + Subscriber**의 역할을 동시에 수행할 수 있는 강력한 도구.
-  **자동으로 `.finished`를 호출하지 않으므로 직접 완료 이벤트를 호출해야 함!**
- `AnyCancellable`을 사용하여 **구독을 유지**해야 메모리 누수를 방지할 수 있음.



# 🚀 언제 **Subject**를 사용할까?

`Subject`는 **Publisher 없이도 직접 데이터를 발행할 수 있는 장점**이 있습니다.  
따라서, 특정 상황에서는 **기존 Publisher보다 효과적으로 사용**될 수 있습니다.

---

## ✅ 1. Subject를 사용할 때 적절한 상황

| 상황 | 기존 Publisher | Subject |
|----------------|------------------|------------------|
| 버튼 클릭 이벤트 처리 | ❌ `Just`는 한 번만 실행됨 | ✅ `Subject`는 계속 발행 가능 |
| 실시간 데이터 업데이트 | ❌ `Just`는 값 1개만 발행 | ✅ 여러 번 값 업데이트 가능 |
| 여러 구독자에게 동일한 데이터 전달 | ❌ `Just`는 새로운 스트림 생성 | ✅ `Subject`는 같은 스트림 공유 가능 |
| 네트워크 요청 & UI 데이터 갱신 | ❌ `Future`는 한 번만 실행됨 | ✅ `Subject`는 반복적으로 값 발행 가능 |

---

## 🔥 2. 예제 1 - 버튼 클릭 이벤트 처리 (UI 이벤트)
```swift
import Combine

// Subject 생성
let buttonTapSubject = PassthroughSubject<Void, Never>()

var cancellables = Set<AnyCancellable>()

// 버튼 클릭 이벤트 구독
buttonTapSubject
    .sink { print("🖱️ 버튼 클릭됨!") }
    .store(in: &cancellables)

// 버튼 클릭 시
buttonTapSubject.send(())
buttonTapSubject.send(())
buttonTapSubject.send(())
```

### 📝 실행 결과
```
🖱️ 버튼 클릭됨!
🖱️ 버튼 클릭됨!
🖱️ 버튼 클릭됨!
```
✅ 기존 Publisher(`Just`)는 **한 번만 값을 발행**할 수 있으므로,  
   UI 이벤트처럼 **계속해서 값이 업데이트되는 경우** Subject가 더 적합합니다.

---

## 🔥 3. 예제 2 - 실시간 데이터 업데이트 (네트워크 요청)
```swift
import Combine

// Subject 생성
let dataSubject = PassthroughSubject<String, Never>()

var cancellables = Set<AnyCancellable>()

// 데이터 갱신 이벤트 구독
dataSubject
    .sink { print("📦 새로운 데이터: \($0)") }
    .store(in: &cancellables)

// 새로운 데이터가 들어올 때마다 발행
dataSubject.send("첫 번째 데이터")
dataSubject.send("두 번째 데이터")
dataSubject.send("세 번째 데이터")
```

### 📝 실행 결과
```
📦 새로운 데이터: 첫 번째 데이터
📦 새로운 데이터: 두 번째 데이터
📦 새로운 데이터: 세 번째 데이터
```
✅ 기존 `Publisher`(`Just`, `Future`)는 **한 번만 값을 발행**하고 끝남.  
✅ **데이터가 지속적으로 변경되는 경우** Subject가 더 적합!

---

## 🔥 4. 예제 3 - 멀티캐스트 (여러 구독자에게 동일한 데이터 전달)
```swift
import Combine

let sharedSubject = PassthroughSubject<Int, Never>()

var cancellables = Set<AnyCancellable>()

// 첫 번째 구독자
sharedSubject
    .sink { print("👤 구독자 1: \($0)") }
    .store(in: &cancellables)

// 두 번째 구독자
sharedSubject
    .sink { print("👥 구독자 2: \($0)") }
    .store(in: &cancellables)

// 값 발행 (모든 구독자에게 동일하게 전달됨)
sharedSubject.send(100)
sharedSubject.send(200)
```

### 📝 실행 결과
```
👤 구독자 1: 100
👥 구독자 2: 100
👤 구독자 1: 200
👥 구독자 2: 200
```
✅ 기존 `Publisher`(`Just`, `Future`)는 **구독할 때마다 새로운 값을 생성**하지만,  
✅ `Subject`는 **하나의 데이터 스트림을 여러 구독자와 공유 가능!**

---

## 🏁 5. 결론
✔ `Subject`는 **Publisher 없이도 직접 데이터를 발행할 수 있어 유연하게 사용 가능**  
✔ UI 이벤트 처리, 실시간 데이터 업데이트, 멀티캐스트 기능이 필요할 때 효과적  
✔ `Just`나 `Future`는 한 번만 데이터를 발행하지만, `Subject`는 계속해서 값을 방출 가능  
