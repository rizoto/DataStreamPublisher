//
//  DataStreamPublisher.swift
//  DataStreamPublisher
//
//  Created by Lubor Kolacny on 10/4/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import Foundation
import Combine

extension URLSession {


    static func dataStreamPublisher(for request: URLRequest) -> URLSession.DataStreamPublisher {
        return DataStreamPublisher(request: request)
    }
    
    
    public class DataStreamPublisher : NSObject, Publisher, URLSessionDataDelegate {

        public typealias Output = Data
        public typealias Failure = URLError
        
        private let request: URLRequest
        
        private var sub: AnySubscriber<Data, Failure>?
        private var subscription: DataStreamSubscription?

        public init(request: URLRequest) {
            self.request = request
        }
        
        private lazy var session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = true
            return URLSession(configuration: configuration,
                              delegate: self, delegateQueue: nil)
        }()
        
        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
            let task = session.dataTask(with: request)
            self.sub = AnySubscriber(subscriber)
            subscription = DataStreamSubscription(task: task, combineIdentifier: CombineIdentifier())
            subscriber.receive(subscription: subscription!)
            task.resume()
        }
        
        public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            _ = sub?.receive(data)
        }
        public func urlSession(_ session: URLSession, task dataTask: URLSessionTask, didCompleteWithError error: Error?) {
            if let error = error {
                sub?.receive(completion: .failure(error as! URLError))
                return
            }
            sub?.receive(completion: .finished)
        }
    }
    
    private struct DataStreamSubscription: Subscription {
        let task: URLSessionDataTask
        let combineIdentifier: CombineIdentifier

        func request(_ demand: Subscribers.Demand) {
        }

        func cancel() {
            task.cancel()
        }
    }
}
