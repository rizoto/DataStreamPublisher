//
//  main.swift
//  DataStreamPublisher
//
//  Created by Lubor Kolacny on 10/4/20.
//  Copyright © 2020 Lubor Kolacny. All rights reserved.
//

import Foundation
import Combine

print("Hello, Oanda!")

let account = "xxx"
let bearer = "yyy"

let url = URL(string: "https://stream-fxpractice.oanda.com/v3/accounts/\(account)/pricing/stream?instruments=AUD_USD,EUR_USD,SPX500_USD,AUD_NZD")
var can = Set<AnyCancellable>()
var req = URLRequest(url: url!)
req.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
let pub = URLSession.dataStreamPublisher(for: req)

let sink = pub
    .sink(receiveCompletion: { completion in
            print("received the completion", String(describing: completion))
            switch completion {
                case .finished:
                    break
                case .failure(let anError):
                    print("received error: ", anError)
            }
            exit(0)
    }, receiveValue: { data in
        print(String(decoding: data, as: UTF8.self))
    })

RunLoop.main.run(until: Date(timeIntervalSinceNow: 20))
// run forever
//dispatchMain()

