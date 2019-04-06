//
//  Async+await.swift
//  AsyncAwait
//
//  Created by Daniel Illescas Romero on 06/04/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

public extension Async {
	
	static func await<Element, FailureType: Error>(_ asyncHandler: @autoclosure () -> AsyncFunc<Element, FailureType>) -> Result<Element, FailureType> {
		return asyncHandler().completionHandler()
	}
	
	static func await<Element>(_ asyncHandler: @autoclosure () -> AsyncFunc<Element, Failure>) -> Result<Element, Failure> {
		return asyncHandler().completionHandler()
	}
	
	//
	
	static func await<Element, FailureType: Error>(timeout: DispatchTime = .now() + .seconds(60),
												   _ completionHandler: Future<Element, FailureType>) -> Result<Element, Async.FailureOrError<FailureType>> {
		
		var obtainedElement: Element?
		var obtainedError: FailureType?
		
		let dispatchGroup = DispatchGroup()
		
		dispatchGroup.enter()
		completionHandler.then {
			switch $0 {
			case .success(let value):
				obtainedElement = value
				dispatchGroup.leave()
			case .failure(let error):
				obtainedError = error
				dispatchGroup.leave()
			}
		}
		
		let waitResult = dispatchGroup.wait(timeout: timeout)
		
		switch waitResult {
		case .success:
			if let obtainedElement = obtainedElement {
				return .success(obtainedElement)
			} else if let error = obtainedError {
				return .failure(.custom(error: error))
			} else {
				return .failure(.nilValue)
			}
		case .timedOut:
			return .failure(.timedOut)
		}
	}
	
	static func awaitValue<Element, FailureType: Error>(timeout: DispatchTime = .now() + .seconds(60),
														_ completionHandler: Future<Element, FailureType>) throws -> Element {
		return try self.await(timeout: timeout, completionHandler).get()
	}
	
	//
	
	static func await<Element>(timeout: DispatchTime = .now() + .seconds(60),
							   _ callback: @escaping (@escaping Callback<Element>) throws -> ()) -> Result<Element, Async.FailureOrError<Error>> {
		
		let future = Future<Element, Error> { completion in
			do {
				try callback {
					completion(.success($0))
				}
			} catch {
				completion(.failure(error))
			}
		}
		return self.await(timeout: timeout, future)
	}
	
	static func awaitValue<Element>(timeout: DispatchTime = .now() + .seconds(60),
							   _ callback: @escaping (@escaping Callback<Element>) throws -> ()) throws -> Element {
		return try self.await(timeout: timeout, callback).get()
	}
}
