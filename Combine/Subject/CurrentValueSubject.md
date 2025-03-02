
# 🚀 CurrentValueSubject란?

`CurrentValueSubject`는 **가장 최신 값을 저장하고, 새로운 구독자에게 즉시 발행**하는 Subject입니다.  
기본적으로 `PassthroughSubject`와 동일한 기능을 수행하지만,  
✅ **현재 상태를 저장하고 새로운 구독자가 구독할 때 바로 값을 받을 수 있다는 점이 다릅니다!**  

---

## ✅ 1. CurrentValueSubject의 주요 특징

1️⃣ **초기값을 지정해야 함**  
   - 생성 시 **초기값을 설정**해야 함  

2️⃣ **값을 저장하고 유지**  
   - `send()` 메서드를 호출할 때마다 최신 값이 저장됨  
   - 새로운 Subscriber가 구독하면 **즉시 최신 값 전달**  

3️⃣ **구독자가 없어도 최신 값을 유지**  
   - 기존 `PassthroughSubject`는 값을 저장하지 않지만,  
   - `CurrentValueSubject`는 **값을 저장한 채로 유지**  

---

## 🔥 2. CurrentValueSubject 기본 사용법

```swift
import Combine

var cancellables = Set<AnyCancellable>()

// ✅ 기본값과 함께 Subject 생성
let subject = CurrentValueSubject<String, Never>("Hi")

// ✅ 새로운 값 발행
subject.send("new Hi") 

// ✅ 구독 시작
subject
    .sink { value in
        print("📦 Received: \(value)")
    }
    .store(in: &cancellables)

// ✅ 값 변경
subject.send("new new Hi")
```

### 📝 실행 결과
```
new Hi
📦 Received: new Hi  // 구독 시점에서 가장 최신 값 수신
📦 Received: new new Hi
```
✅ **구독자가 없더라도 값이 유지되고, 새로운 구독자는 최신 값을 즉시 받음!**  

---

## ⚠️ 3. CurrentValueSubject는 최신 값을 유지

```swift
let subject = CurrentValueSubject<String, Never>("Hello")

// ✅ 첫 번째 구독자
subject
    .sink { value in print("👤 첫 번째 구독자: \(value)") }
    .store(in: &cancellables)

// ✅ 값 변경
subject.send("Updated Value")

// ✅ 두 번째 구독자 추가
subject
    .sink { value in print("👥 두 번째 구독자: \(value)") }
    .store(in: &cancellables)
```

### 📝 실행 결과
```
👤 첫 번째 구독자: Hello
👤 첫 번째 구독자: Updated Value
👥 두 번째 구독자: Updated Value
```
✅ **새로운 구독자(`두 번째 구독자`)도 최신 값(`Updated Value`)을 즉시 받음!**  

---

## 🛠 4. 언제 사용해야 할까? (PassthroughSubject와 비교)

| 특징 | PassthroughSubject | CurrentValueSubject |
|----------------|----------------|----------------|
| **값 저장 여부** | ❌ 저장하지 않음 | ✅ 최신 값 유지 |
| **초기값 필요 여부** | ❌ 필요 없음 | ✅ 필요함 |
| **구독 전 값 수신 가능 여부** | ❌ 구독 후 값만 받음 | ✅ 최신 값을 자동으로 제공 |
| **사용 예시** | UI 이벤트(버튼 클릭 등) | 앱 상태 관리(로그인 상태, 설정 값 등) |
| **구독 후 새로운 값 처리** | ✅ 가능 | ✅ 가능 |
| **구독 후 이전 값 처리** | ❌ 불가능 | ✅ 가능 |

---

## ✅ 5. CurrentValueSubject 사용 예시

### 🎯 **사용 예제 1 - 사용자 로그인 상태 관리**
```swift
import Combine

var cancellables = Set<AnyCancellable>()

// ✅ 초기값: 로그아웃 상태(false)
let isLoggedIn = CurrentValueSubject<Bool, Never>(false)

// ✅ 구독 시작
isLoggedIn
    .sink { print("🔐 로그인 상태: \($0 ? "로그인됨" : "로그아웃됨")") }
    .store(in: &cancellables)

// ✅ 로그인 상태 변경
isLoggedIn.send(true)
isLoggedIn.send(false)
```

### 📝 실행 결과
```
🔐 로그인 상태: 로그아웃됨 (초기값)
🔐 로그인 상태: 로그인됨
🔐 로그인 상태: 로그아웃됨
```
✅ **새로운 구독자가 추가되더라도 가장 최근의 로그인 상태를 받을 수 있음!**  

---

### 🎯 **사용 예제 2 - 앱 설정 값 관리 (다크 모드 여부)**
```swift
import Combine

// ✅ 다크 모드 상태 관리 (기본값: 비활성화)
let isDarkModeEnabled = CurrentValueSubject<Bool, Never>(false)

var cancellables = Set<AnyCancellable>()

// ✅ 구독 시작
isDarkModeEnabled
    .sink { print("🌙 다크 모드: \($0 ? "켜짐" : "꺼짐")") }
    .store(in: &cancellables)

// ✅ 설정 값 변경
isDarkModeEnabled.send(true)  // 다크 모드 켜기
isDarkModeEnabled.send(false) // 다크 모드 끄기
```

### 📝 실행 결과
```
🌙 다크 모드: 꺼짐 (초기값)
🌙 다크 모드: 켜짐
🌙 다크 모드: 꺼짐
```
✅ **앱 설정 값을 관리할 때 유용!**  
✅ **현재 상태를 유지하면서 새로운 구독자가 가장 최신 상태를 즉시 받을 수 있음!**  

---

## 🏁 6. 결론

✔ **`PassthroughSubject`는 값을 저장하지 않고 새로운 값만 발행**  
✔ **`CurrentValueSubject`는 최신 값을 저장하고 새로운 구독자에게 즉시 제공**  
✔ **UI 이벤트(버튼 클릭 등)는 `PassthroughSubject`가 적합**  
✔ **앱 상태(로그인, 설정 값)는 `CurrentValueSubject`가 더 적합**  
