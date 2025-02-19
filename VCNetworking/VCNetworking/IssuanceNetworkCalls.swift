/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import PromiseKit
import VCEntities

public protocol IssuanceNetworking {
    func getRequest(withUrl url: String) -> Promise<SignedContract>
    func sendResponse(usingUrl url: String, withBody body: IssuanceResponse) -> Promise<VerifiableCredential>
}

public class IssuanceNetworkCalls: IssuanceNetworking {
    
    private let urlSession: URLSession
    private let correlationVector: CorrelationHeader?
    
    public init(correlationVector: CorrelationHeader? = nil,
                urlSession: URLSession = URLSession.shared) {
        self.correlationVector = correlationVector
        self.urlSession = urlSession
    }
    
    public func getRequest(withUrl url: String) -> Promise<SignedContract> {
        do {
            var operation = try FetchContractOperation(withUrl: url,
                                                       andCorrelationVector: correlationVector,
                                                       session: self.urlSession)
            return operation.fire()
        } catch {
            return Promise { seal in
                seal.reject(error)
            }
        }
    }
    
    public func sendResponse(usingUrl url: String, withBody body: IssuanceResponse) -> Promise<VerifiableCredential> {
        do {
            var operation = try PostIssuanceResponseOperation(usingUrl: url,
                                                              withBody: body,
                                                              andCorrelationVector: correlationVector,
                                                              urlSession: self.urlSession)
            return operation.fire()
        } catch {
            return Promise { seal in
                seal.reject(error)
            }
        }
    }
}
