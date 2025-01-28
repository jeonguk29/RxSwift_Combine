# Combine - Just Publisher

`Just`는 Combine 프레임워크에서 제공하는 기본 Publisher로, 단 한 번의 값을 발행하고 종료하는 특징을 가지고 있습니다. 간단하지만 Combine의 동작 원리를 이해하기에 좋은 도구입니다.

---

## 1. `Just`란?
- **하나의 값**을 발행하고 스트림을 **종료**하는 Publisher.
- 항상 `.finished` 이벤트로 종료하며, 에러를 방출하지 않습니다.

```swift
let helloPublisher = Just("Hello Combine!")
```

위 코드에서 `helloPublisher`는 "Hello Combine!"이라는 값을 발행하고 종료하는 Publisher입니다.

---

## 2. `Just`의 주요 특징
1. **단일 값 발행:**
   - `Just`는 값을 한 번 발행한 뒤, 스트림을 종료합니다.
   
2. **완료 이벤트:**
   - 값 발행 후 반드시 `.finished` 이벤트를 발생시킵니다.

3. **에러 미발생:**
   - `Just`의 `Failure` 타입은 `Never`로, 에러를 방출하지 않습니다.

---

## 3. 사용 예제

### 기본 예제
```swift
let helloPublisher = Just("Hello Combine!")

helloPublisher
  .sink { completion in
    switch completion {
    case .finished:
      print("finished")
    case .failure:
      break // 에러를 방출하지 않으므로 실행되지 않음
    }
  } receiveValue: { value in
    print("value received: \(value)")
  }
```

### 출력 결과
```
value received: Hello Combine!
finished
```

### 실행 과정
1. **값 발행:**
   - `Just`는 "Hello Combine!" 값을 발행하며 `receiveValue` 클로저를 호출합니다.
   - 출력: `value received: Hello Combine!`

2. **스트림 종료:**
   - 값 발행 후 `.finished` 이벤트를 발행하며 `completion` 클로저를 호출합니다.
   - 출력: `finished`

---

## 4. `Just`의 제약사항
- 한 번에 하나의 값만 발행 가능.
- 에러를 처리할 필요가 없는 간단한 작업에 적합.

---

## 5. 활용 사례
- **기본 데이터 테스트:** 단일 값으로 Combine의 동작 확인.

---

## 6. 요약
- **`Just`는 값 1개와 `.finished` 이벤트를 발행하는 간단한 Publisher입니다.**
- **구독자가 연결되면 항상 값 발행 후 완료 이벤트가 호출됩니다.**

`Just`는 Combine의 기본 동작 원리를 학습하기에 좋은 도구입니다. 더 복잡한 Publisher를 이해하기 전에 꼭 익혀두세요! 😊

