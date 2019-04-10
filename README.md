AsyncAwait
-----

Lightweight library for modern async/await syntax in Swift 5.

Inspired by the [Async/await JavaScript](https://javascript.info/async-await) syntax.

## Examples

### Futures

With `Future`'s you can transform your callbacks from:

`func somethingAsync1(_ completionHandler: @escaping (Int) -> Void))`

to: `func somethingAsync1() -> Future<Int, CustomError>`

**Example:**
```swift
func somethingAsync1(_ completionHandler: @escaping (Int) -> Void) {
  DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
    completionHandler(200)
  }
}
```
```swift
func somethingAsync() -> Future<Int, CustomError> {
  return Future { completion in
    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
      if everythingOK {
        completion(.success(4000))
      } else if X {
        completion(.failure(CustomError.errorBlabla))
      } else {
        completion(.failure(CustomError.other))
      }
    }
  }
}
```

### Async-await

To retrieve values from `Future`'s, you need to call `Async.await(...)` inside `Async.run`:

- First way
```swift
Async.run {
  let result1 = Async.await(somethingAsync1)
  let result2 = result1.map { Async.await(somethingAsync2(inValue: $0)) }
  print(result2)
  // let result 3 = result2 .map { ... }
  // etc
}
```

- Second way (My favourite <3)
```swift
Async.run {
  do {
    let value = try self.asyncTestValue()
    print(value)
  } catch {
    print(error)
  }
}

private func asyncTestValue() throws -> Int {
  let value = try await { somethingAsync1 } // or: Async.awaitValue
	let secondValue = try await { somethingAsync2(inValue: value) }
	return secondValue
}
```

- Third way. Not recomended for linked calls (pyramid of doom...).
```swift
Async.run {
  let result1 = Async.await(somethingAsync1)
  switch result1 {
  case .success(let value):
    let result2 = Async.await(somethingAsync2(inValue: value))
    switch result2 {
    case .success(let value):
      print(value)
    case .failure(let error):
      print(error)
    }
  case .failure(let error):
    print(error)
  }
}
```