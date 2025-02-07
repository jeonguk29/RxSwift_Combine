
# 🚀 Deferred Publisher

`Deferred`는 **Publisher의 생성을 지연시키는 역할**을 합니다.  
즉, **구독이 이루어지는 시점까지 Publisher가 생성되지 않습니다.**

---

## ✅ Deferred의 주요 특징

- ⏱ **구독 전까지 실행 지연:** Publisher가 즉시 생성되지 않고 구독 시점에 생성됨
- 🔄 **최신 상태 반영:** 구독 시점의 최신 상태를 반영할 수 있음
- 🗂 **동적으로 Publisher 선택 가능:** 상황에 따라 다른 Publisher를 반환 가능

---

## 💡 Deferred 기본 사용법

```swift
import Combine

var cancellables = Set<AnyCancellable>()

let deferredPublisher = Deferred {
  Just([1, 2, 3, 4, 5])
    .delay(for: .seconds(1), scheduler: RunLoop.main)
}

deferredPublisher
  .sink { values in
    print("📦 받은 값: \(values)")
  }
  .store(in: &cancellables)
```

✅ 설명:
- Just([1,2,3,4,5])는 구독 시점에 생성됩니다.
- sink로 구독하기 전까지는 아무 작업도 하지 않습니다.
- 1초 후 Just가 값들을 발행합니다.

---

## 📊 Deferred의 실제 활용 예제 1 - 동적 Publisher 생성

```swift
struct UserProfile {
  var userId: Int
  var profileUrl: URL
}

enum CustomError: Error {
  case fetchFailed
}

func fetchUserFromLocal() -> AnyPublisher<UserProfile, CustomError> {
  return Just(UserProfile(userId: -1, profileUrl: URL(string: "https://local.profile")!))
    .setFailureType(to: CustomError.self)
    .eraseToAnyPublisher()
}

func fetchUserFromRemote(userId: Int) -> AnyPublisher<UserProfile, CustomError> {
  return Future { promise in
    let url = URL(string: "https://remote.com/user/\(userId)")!
    promise(.success(UserProfile(userId: userId, profileUrl: url)))
  }
  .setFailureType(to: CustomError.self)
  .eraseToAnyPublisher()
}

func isConnectedToInternet() -> Bool {
  return Bool.random()
}

let dynamicPublisher = Deferred {
  isConnectedToInternet() ? fetchUserFromRemote(userId: 1) : fetchUserFromLocal()
}

dynamicPublisher
  .sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
      print("✅ 완료")
    case .failure(let error):
      print("❌ 에러 발생: \(error)")
    }
  }, receiveValue: { userProfile in
    print("👤 유저 프로필: \(userProfile)")
  })
  .store(in: &cancellables)
```

✅ 설명:
- 인터넷 연결 여부에 따라 로컬 데이터 또는 원격 데이터를 가져옵니다.
- Deferred는 구독 시점에 isConnectedToInternet()를 호출하여 최신 상태를 반영합니다.
- eraseToAnyPublisher()로 타입을 통일하여 간편하게 사용합니다.

---

## 📊 Deferred의 실제 활용 예제 2 - 캐시 우선 로딩 전략

```swift
func fetchFromCache() -> AnyPublisher<String, Never> {
  return Just("📦 캐시된 데이터")
    .delay(for: .seconds(1), scheduler: RunLoop.main)
    .eraseToAnyPublisher()
}

func fetchFromNetwork() -> AnyPublisher<String, Never> {
  return Just("🌐 네트워크 데이터")
    .delay(for: .seconds(2), scheduler: RunLoop.main)
    .eraseToAnyPublisher()
}

let shouldUseCache = true

let deferredDataPublisher = Deferred {
  shouldUseCache ? fetchFromCache() : fetchFromNetwork()
}

deferredDataPublisher
  .sink(receiveCompletion: { completion in
    print("✅ 데이터 로딩 완료")
  }, receiveValue: { data in
    print(data)
  })
  .store(in: &cancellables)
```
✅ 설명:
- 캐시 데이터가 우선이고, 없을 경우 네트워크 요청을 수행합니다.
- Deferred 덕분에 구독 시점에 최신 상태를 기반으로 로직이 결정됩니다.
