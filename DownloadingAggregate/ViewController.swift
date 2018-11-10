//
//  ViewController.swift
//  DownloadingAggregate
//
//  Created by Thomas Do on 10/11/2018.
//  Copyright © 2018 Tho Do. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        downloadAggregate()
    }

    func downloadAggregate() {
        // pool

        //
        let pool = SubjectBase()
        pool.addObservers(observers: NetworkObserverBase { _ in
                print("1")
            }, NetworkObserverBase(urlString: "https://brain-images-ssl.cdn.dixons.com/6/5/10185856/u_10185856.jpg") { _ in
                print("google")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            }, NetworkObserverBase { _ in
                print("1 clone")
            })

        pool.downloadDistinct()

//        let fakeQueue = DispatchQueue(label: "fakeQueue", qos: .background, attributes: .concurrent)
//
//        for _ in 0..<10 {
//            fakeQueue.async {
//
//            }
//        }
    }
}

//protocol Observer: class {
//    func notify(user: String, success: Bool)
//}
//
//protocol Subject {
//    func addObservers(observers: Observer...)
//    func removeObserver(observer: Observer)
//}
//
//class SubjectBase: Subject {
//    private var observers: [Observer] = []
//    private var collectionQueue = DispatchQueue(label: "collectionQueue", qos: .background, attributes: .concurrent)
//
//    func addObservers(observers: Observer...) {
//        collectionQueue.sync(flags: .barrier) { [weak self] in
//            self?.observers.append(contentsOf: observers)
//        }
//    }
//
//    func removeObserver(observer: Observer) {
//        collectionQueue.sync(flags: .barrier) { [weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.observers = strongSelf.observers.filter { $0 !== observer }
//        }
//    }
//
//    func sendNotification(user: String, success: Bool) {
//        collectionQueue.sync { [weak self] in
//            guard let strongSelf = self else { return }
//            for observer in strongSelf.observers {
//                observer.notify(user: user, success: success)
//            }
//        }
//    }
//}
//
////
//class RequestPool: SubjectBase {
//    func download(username: String, password: String) -> Bool {
//        sendNotification(user: username.uppercased(), success: true)
//
//        return true
//    }
//}
//
//class Request1: Observer {
//    func notify(user: String, success: Bool) {
//        print("request 1")
//    }
//}
//
//class Request2: Observer {
//    func notify(user: String, success: Bool) {
//        print("request 2: \(user)")
//    }
//}
//
//class Request3: Observer {
//    func notify(user: String, success: Bool) {
//        print("request 3: \(success)")
//    }
//}


protocol NetworkObserver: class {
    var urlString: String { get }
    var completion: (DataResponse<Data>) -> Void { get }
    func notifyDownloadCompleted(response: DataResponse<Data>)
}

class NetworkObserverBase: NetworkObserver {
    private(set) var urlString: String
    private(set) var completion: (DataResponse<Data>) -> Void

    init(urlString: String = "https://www.nasa.gov/sites/default/files/hs-2014-27-a-xlarge_web.jpg",
         completion: @escaping (DataResponse<Data>) -> Void) {
        self.urlString = urlString
        self.completion = completion
    }

    func notifyDownloadCompleted(response: DataResponse<Data>) {
        completion(response)
    }
}

protocol Subject {
    func addObservers(observers: NetworkObserver...)
    func removeObserver(observer: NetworkObserver)
}

class SubjectBase: Subject {
    private var observers: [NetworkObserver] = []
    private var collectionQueue = DispatchQueue(label: "collectionQueue", qos: .background, attributes: .concurrent)
    private let downloadQueue = DispatchQueue(label: "downloadQueue", qos: .background, attributes: .concurrent)

    func addObservers(observers: NetworkObserver...) {
        collectionQueue.sync(flags: .barrier) { [weak self] in
            self?.observers.append(contentsOf: observers)
        }
    }

    func removeObserver(observer: NetworkObserver) {
        collectionQueue.sync(flags: .barrier) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.observers = strongSelf.observers.filter { $0 !== observer }
        }
    }

    func downloadDistinct() {
        collectionQueue.sync { [weak self] in
            guard let strongSelf = self else { return }
            let distinctRequest = NSCountedSet(array: strongSelf.observers.map { $0.urlString} )
            for (index, urlString) in distinctRequest.enumerated() {
                let urlString = urlString as! String
                Alamofire.request(urlString)
                    .downloadProgress(queue: strongSelf.downloadQueue) { (progress) in
//                        let rounded = 100 * round(progress.fractionCompleted) / 100
//                        print("\(urlString) - \(index): \(rounded * 100) %")
                    }
                    .responseData { (response) in
//                        print("Data \(index): \(response)")
                        strongSelf.sendDownloadCompletedNotification(for: urlString, response: response)
                    }
            }
        }
    }

    func sendDownloadCompletedNotification(for urlString: String, response: DataResponse<Data>) {
        let needNotifyingObservers = observers.filter { $0.urlString.lowercased() == urlString.lowercased() }
        for observer in needNotifyingObservers {
            observer.notifyDownloadCompleted(response: response)
        }
    }
}




