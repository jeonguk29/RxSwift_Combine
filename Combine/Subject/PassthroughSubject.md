
# 🚀 PassthroughSubject란?

`PassthroughSubject`는 **Subject의 한 종류**로,  
이름에서도 알 수 있듯이 **값을 저장하지 않고 그대로 전달(Pass Through)하는** 역할을 합니다.  

✅ **즉, 이전 데이터를 기억하지 않고 새로운 값만 전달합니다!**  

---

## ✅ 1. PassthroughSubject의 주요 특징

1️⃣ **이전 값을 저장하지 않음**  
   - 현재 어떤 값을 가지고 있는지 **알 수 없음**  
   - 구독 전에 발행된 값은 받을 수 없음  

2️⃣ **구독 이후에 발행된 값만 받을 수 있음**  
   - 구독 전 데이터는 무시됨  

3️⃣ **Publisher와 Subscriber 역할을 동시에 수행**  

---

## 🔥 2. PassthroughSubject 기본 사용법

```swift
import Combine

var cancellables = Set<AnyCancellable>()

let subject = PassthroughSubject<String, Never>()

// 구독 설정
subject
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("✅ Completed")
            case .failure(let error):
                print("❌ Failed with error: \(error)")
            }
        },
        receiveValue: { value in
            print("📦 Received value: \(value)")
        }
    )
    .store(in: &cancellables)

// 값 발행
subject.send("Hello")
subject.send(completion: .finished)
```

### 📝 실행 결과
```
📦 Received value: Hello
✅ Completed
```

✅ **일반적인 Subject와 사용 방식이 비슷합니다!**

---

## ⚠️ 3. PassthroughSubject는 구독 전에 발생한 값은 받을 수 없음

```swift
let subject = PassthroughSubject<String, Never>()

subject.send("Nice to meet you") // ✅ 구독 전에 값을 발행!

let subscription1 = subject.sink(
    receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("✅ Completed")
        case .failure(let error):
            print("❌ Failed with error: \(error)")
        }
    },
    receiveValue: { value in
        print("📦 Received value: \(value)")
    }
)

// 구독 후 값 발행
subject.send("Hello")
subject.send(completion: .finished)
```

### 📝 실행 결과
```
📦 Received value: Hello
✅ Completed
```
✅ **구독 전에 발행한 `"Nice to meet you"`는 출력되지 않음!**  
✅ **즉, 구독 이후의 값만 받을 수 있음!**

---

## 🛠 4. PassthroughSubject를 언제 사용할까?

| 상황 | 기존 Publisher | PassthroughSubject |
|----------------|----------------|----------------|
| UI 이벤트 처리 (버튼 클릭) | ❌ `Just`는 한 번만 실행됨 | ✅ Subject는 계속 발행 가능 |
| 실시간 데이터 변경 | ❌ `Just`는 값을 저장하지 않음 | ✅ 최신 데이터만 구독자에게 전달 |
| 네트워크 응답을 여러 곳에서 사용할 때 | ❌ 새로운 요청마다 Publisher 생성 필요 | ✅ 같은 Subject로 여러 곳에서 사용 가능 |

### 🎯 **사용 예제 1 - 버튼 클릭 이벤트 처리**
```swift
let buttonClickSubject = PassthroughSubject<Void, Never>()

// 구독
buttonClickSubject
    .sink { print("🖱️ 버튼 클릭됨!") }
    .store(in: &cancellables)

// 버튼 클릭 시 이벤트 발생
buttonClickSubject.send(())
buttonClickSubject.send(())
```

### 📝 실행 결과
```
🖱️ 버튼 클릭됨!
🖱️ 버튼 클릭됨!
```
✅ **버튼이 클릭될 때마다 새로운 값을 발행할 수 있음!**  

---

### 🎯 **사용 예제 2 - 네트워크 응답을 여러 곳에서 활용**
```swift
let apiResponseSubject = PassthroughSubject<String, Never>()

// 첫 번째 구독자
apiResponseSubject
    .sink { print("📡 뷰 컨트롤러: \( $0 )") }
    .store(in: &cancellables)

// 두 번째 구독자
apiResponseSubject
    .sink { print("📊 데이터 매니저: \( $0 )") }
    .store(in: &cancellables)

// 네트워크 응답이 왔을 때
apiResponseSubject.send("API 응답 데이터")
```

### 📝 실행 결과
```
📡 뷰 컨트롤러: API 응답 데이터
📊 데이터 매니저: API 응답 데이터
```
✅ **네트워크 응답 데이터를 여러 곳에서 사용할 때 유용!**

---

## 🏁 5. 결론

✔ `PassthroughSubject`는 **이전 데이터를 저장하지 않고 새로운 값만 전달하는 Subject**  
✔ **구독 전에 발행된 값은 받을 수 없음!**  
✔ **UI 이벤트 처리, 실시간 데이터 업데이트에 효과적!**  
✔ **여러 구독자에게 동일한 데이터를 전달할 수 있음!**  
