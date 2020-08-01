//
//  FetchContractNetworkOperation.swift
//  networking
//
//  Created by Sydney Morton on 7/22/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import PromiseKit

//open class FetchNetworkOperation<ResponseBody>: NetworkOperation {
//    
//    let urlSession: URLSession
//    let urlRequest: URLRequest
//    let serializer: Serializer
//        
//    init(urlRequest: URLRequest, serializer: Serializer, urlSession: URLSession) {
//        self.urlRequest = urlRequest
//        self.urlSession = urlSession
//        self.serializer = serializer
//    }
//    
//    convenience init(withUrl urlStr: String, serializer: Serializer = Serializer(), urlSession: URLSession = URLSession.shared) throws {
//        guard let url = URL(string: urlStr) else {
//            throw NetworkingError.invalidUrl(withUrl: urlStr)
//        }
//        self.init(urlRequest: URLRequest(url: url), serializer: serializer, urlSession: urlSession)
//    }
//    
//    func fire() -> Promise<Swift.Result<ResponseBody, Error>> {
//        return call(urlSession: self.urlSession, urlRequest: self.urlRequest)
//    }
//    
//    func onSuccess(data: Data, response: HTTPURLResponse) -> Swift.Result<ResponseBody, Error> {
//        return defaultOnSuccess(data: data, response: response, serializer: serializer)
//    }
//    
//    func onFailure(data: Data, response: HTTPURLResponse) -> Swift.Result<ResponseBody, Error> {
//        return defaultOnFailure(data: data, response: response, serializer: serializer)
//    }
//}
//
//class FetchContractOperation: FetchNetworkOperation<Contract> {}
//class FetchPresentationRequestOperation: FetchNetworkOperation<PresentationRequest> {}
//class FetchIdentifierDocumentOperation: FetchNetworkOperation<IdentifierDocument> {}
