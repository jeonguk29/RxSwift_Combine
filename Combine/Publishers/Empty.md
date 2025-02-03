
### **📌 Empty Publisher**  

`Empty`는 **값을 발행하지 않고 선택적으로 즉시 스트림을 종료**할 수 있는 특별한 `Publisher`입니다.

---

## 1️⃣ **Empty의 특징**  
✔️ **값을 발행하지 않음** → 즉, 데이터를 전송하지 않는 퍼블리셔  
✔️ **에러 타입을 지정 가능** (하지만 실제 에러를 방출하지 않음)  
✔️ `completeImmediately` 파라미터로 즉시 종료 여부 설정 가능  

---

## 2️⃣ **Empty 사용법**
### ✅ `completeImmediately: true` (즉시 종료)
```swift
import Combine

let emptyPublisher = Empty<Int, Never>(completeImmediately: true)

emptyPublisher
  .sink { completion in
    switch completion {
    case .finished:
      print("✅ 완료됨!")
    case .failure:
      print("❌ 실패 발생!") // 실행될 일 없음 (Never 타입)
    }
  } receiveValue: { value in
    print("값 받음: \(value)") // 실행되지 않음
  }

// 🏆 결과
// ✅ 완료됨!
```
✔️ `completeImmediately: true` → 즉시 `.finished` 이벤트를 보냄  
✔️ `receiveValue`는 실행되지 않음 (값을 방출하지 않기 때문!)  

---

### ✅ `completeImmediately: false` (이벤트 발생 없음)
```swift
let emptyPublisher = Empty<Int, Never>(completeImmediately: false)

emptyPublisher
  .sink { completion in
    switch completion {
    case .finished:
      print("✅ 완료됨!") // 실행되지 않음
    case .failure:
      print("❌ 실패 발생!") // Never이므로 실행될 일 없음
    }
  } receiveValue: { value in
    print("값 받음: \(value)") // 실행되지 않음
  }

// 🏆 결과
// (아무것도 출력되지 않음)
```
✔️ `completeImmediately: false` → `.finished` 이벤트도 발행되지 않음  
✔️ 따라서 **구독자가 어떤 값도 받지 못하고 그대로 멈춤**  

---

## 3️⃣ **Empty의 Failure 타입은 왜 존재할까?**
Empty 퍼블리셔는 **실제 에러를 방출하지 않지만, Failure 타입을 지정**할 수 있어요.

**💡 이유:**  
✅ **Combine의 타입 시스템을 유지하기 위해!**  
✅ 다른 퍼블리셔와 결합할 때 **타입을 맞춰야** 해서 필요  
✅ 하지만 **실제 에러를 발생시키지는 않음!**  

---

## 4️⃣ **Empty를 활용한 에러 처리 예제**
📌 **`PassthroughSubject`(데이터를 방출할 수 있는 퍼블리셔)가 에러를 발생시킬 때, 이를 `Empty`로 대체**  

```swift
import Combine

enum CustomError: Error {
  case unknownError
}

let subject = PassthroughSubject<Int, CustomError>()

let errorHandlingPublisher = subject
  .catch { error -> Empty<Int, CustomError> in
    print("🚨 에러 발생: \(error)")
    return Empty(completeImmediately: true) // 에러를 Empty로 대체
  }

errorHandlingPublisher
  .sink { completion in
    switch completion {
    case .finished:
      print("✅ 에러 없이 완료됨!")
    case .failure(let error):
      print("❌ 실패: \(error)") // 실행되지 않음
    }
  } receiveValue: { value in
    print("값 받음: \(value)")
  }

subject.send(completion: .failure(.unknownError))

// 🏆 결과
// 🚨 에러 발생: unknownError
// ✅ 에러 없이 완료됨!
```
✔️ `catch` 연산자로 **에러를 잡고 Empty로 변환**  
✔️ 원래라면 `.failure(.unknownError)`가 전달되어야 하지만, **Empty가 대신 실행됨**  
✔️ 따라서 **에러 없이 종료됨 (`.finished`)**  

---

## 5️⃣ **Empty는 언제 쓰면 좋을까?**
🛠 **1. 에러 발생 시, 특정 동작 없이 조용히 종료하고 싶을 때**  
🛠 **2. "아무 값도 방출하지 않는 퍼블리셔"가 필요할 때**  
🛠 **3. 다른 퍼블리셔와 조합할 때 타입을 맞추기 위해 사용**  

---

## ✅ **최종 요약**
✔️ `Empty`는 **값을 방출하지 않는 퍼블리셔**  
✔️ `completeImmediately: true` → 즉시 `.finished` 이벤트 발행  
✔️ `completeImmediately: false` → 아무 이벤트도 발생하지 않음  
✔️ `Failure` 타입을 설정할 수 있지만 **실제로 에러를 방출하지 않음**  
✔️ **에러가 발생한 퍼블리셔를 대체할 때 유용**  

---
