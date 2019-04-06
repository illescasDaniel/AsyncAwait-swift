//
//  Future.swift
//  AsyncAwait
//
//  Created by Daniel Illescas Romero on 05/04/2019.
//  Copyright © 2019 Daniel Illescas Romero. All rights reserved.
//

import Foundation

public class Future<Element, FailureType: Error> {
	
	private let completionHandler: Callback<Callback<Result<Element, FailureType>>>
	
	init(_ completionHandler: @escaping Callback<Callback<Result<Element, FailureType>>>) {
		self.completionHandler = completionHandler
	}
	
	func onSuccess(_ handler: @escaping Callback<Element>) -> Future  {
		self.completionHandler {
			if case .success(let value) = $0 {
				handler(value)
			}
		}
		return self
	}
	
	func onError(_ handler: @escaping Callback<FailureType>) -> Future {
		self.completionHandler {
			if case .failure(let error) = $0 {
				handler(error)
			}
		}
		return self
	}
	
	func then(_ handler: @escaping Callback<Result<Element, FailureType>>) {
		self.completionHandler(handler)
	}

	//

	func map<OtherElement>(_ mapper: @escaping (Element) -> OtherElement) -> Future<OtherElement, FailureType> {
		return Future<OtherElement, FailureType> { completion in
			self.then { selfResult in
				switch selfResult {
				case .success(let value):
					completion(.success(mapper(value)))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		}
	}
}
