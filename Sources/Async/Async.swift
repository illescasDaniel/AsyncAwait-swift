//
//  Async.swift
//  AsyncAwait
//
//  Created by Daniel Illescas Romero on 05/04/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

public typealias Callback<T> = (T) -> Void

public enum Async {
	
	public enum Failure: Error {
		case timedOut
		case nilValue
	}
	public enum FailureOrError<OtherError: Error>: Error {
		case timedOut
		case nilValue
		case custom(error: OtherError)
	}
}

public extension Async {
	
	static func run(_ block: @escaping () -> ()) {
		DispatchQueue.global().async {
			block()
		}
	}
	
	static func runForUI(_ block: @escaping () -> ()) {
		DispatchQueue.main.async {
			block()
		}
	}
}

//

typealias AsyncFunc = Async.AsyncFunc
public extension Async {
	
	class AsyncFunc<Element, FailureType: Error> {
		
		// should use `await` instead of calling this externally
		let completionHandler: () -> Result<Element, FailureType>
		
		init(_ completionHandler: @escaping () -> Result<Element, FailureType>) {
			self.completionHandler = completionHandler
		}
	}
}
