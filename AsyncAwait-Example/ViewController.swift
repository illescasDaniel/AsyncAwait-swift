//
//  ViewController.swift
//  AsyncAwait
//
//  Created by Daniel Illescas Romero on 06/04/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import UIKit

func somethingAsync1(_ completionHandler: @escaping (Int) -> Void) {
	DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
		completionHandler(200)
	}
}

//

enum TestError: Error {
	case badValue
}
func somethingAsync2(inValue: Int) -> Future<Int, TestError> {
	return Future { completion in
		if Int.random(in: 1...2) == 1 {
			completion(.success(inValue * 200))
		} else {
			completion(.failure(TestError.badValue))
		}
	}
}

//

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.testAsyncAwait()
	}

	//
	
	private func testAsyncAwait() {
		
		// First way
		Async.run {
			let result1 = Async.await(somethingAsync1)
			let result2 = result1.map { Async.await(somethingAsync2(inValue: $0)) }
			print(result2)
			// let result 3 = result2 .map { ... }
			// etc
		}
		
		// Second way:
		Async.run {
			do {
				let value = try self.asyncTestValue()
				print(value)
			} catch {
				print(error)
			}
		}
		
		// Third way
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
	}
	
	// MARK: - async
	private func asyncTestValue() throws -> Int {
		let value = try Async.awaitValue(somethingAsync1)
		let secondValue = try Async.awaitValue(somethingAsync2(inValue: value))
		return secondValue
	}

}

