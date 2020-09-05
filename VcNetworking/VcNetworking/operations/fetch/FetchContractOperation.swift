/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import PromiseKit

final class FetchContractOperation: NetworkOperation {
    typealias SuccessHandler = SimpleSuccessHandler
    
    let retryHandler: RetryHandler  = NoRetry()
    let successHandler: SuccessHandler = SimpleSuccessHandler(decoder: ContractDecoder())
    let failureHandler: FailureHandling = SimpleFailureHandler()
    let urlSession: URLSession
    let urlRequest: URLRequest
    
    init(withUrl urlStr: String, session: URLSession = URLSession.shared) throws {
        guard let url = URL(string: urlStr) else {
            throw NetworkingError.invalidUrl(withUrl: urlStr)
        }
        
        self.urlRequest = URLRequest(url: url)
        self.urlSession = session
    }
}
