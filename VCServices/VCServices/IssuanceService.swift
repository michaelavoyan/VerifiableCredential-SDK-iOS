/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/


import PromiseKit
import VCNetworking
import VCEntities

enum IssuanceServiceError: Error {
    case unableToCastToPresentationResponseContainer
    case unableToFetchIdentifier
}

public class IssuanceService {
    
    let formatter: IssuanceResponseFormatting
    let apiCalls: IssuanceNetworking
    let identifierService: IdentifierService
    let pairwiseService: PairwiseService
    let linkedDomainService: LinkedDomainService
    let sdkLog: VCSDKLog
    
    public convenience init(correlationVector: CorrelationHeader? = nil,
                            urlSession: URLSession = URLSession.shared) {
        self.init(formatter: IssuanceResponseFormatter(),
                  apiCalls: IssuanceNetworkCalls(correlationVector: correlationVector,
                                                 urlSession: urlSession),
                  identifierService: IdentifierService(),
                  linkedDomainService: LinkedDomainService(correlationVector: correlationVector,
                                                           urlSession: urlSession),
                  pairwiseService: PairwiseService(correlationVector: correlationVector,
                                                   urlSession: urlSession),
                  sdkLog: VCSDKLog.sharedInstance)
    }
    
    init(formatter: IssuanceResponseFormatting,
         apiCalls: IssuanceNetworking,
         identifierService: IdentifierService,
         linkedDomainService: LinkedDomainService,
         pairwiseService: PairwiseService,
         sdkLog: VCSDKLog = VCSDKLog.sharedInstance) {
        self.formatter = formatter
        self.apiCalls = apiCalls
        self.identifierService = identifierService
        self.pairwiseService = pairwiseService
        self.linkedDomainService = linkedDomainService
        self.sdkLog = sdkLog
    }
    
    public func getRequest(usingUrl url: String) -> Promise<IssuanceRequest> {
        return logTime(name: "Issuance getRequest") {
            firstly {
                self.apiCalls.getRequest(withUrl: url)
            }.then { signedContract in
                self.formIssuanceRequest(from: signedContract)
            }
        }
    }
    
    private func formIssuanceRequest(from signedContract: SignedContract) -> Promise<IssuanceRequest> {
        
        return firstly {
            linkedDomainService.validateLinkedDomain(from: signedContract.content.input.issuer)
        }.then { linkedDomainResult in
            Promise { seal in
                seal.fulfill(IssuanceRequest(from: signedContract, linkedDomainResult: linkedDomainResult))
            }
        }
    }
    
    public func send(response: IssuanceResponseContainer, isPairwise: Bool = false) -> Promise<VerifiableCredential> {
        return logTime(name: "Issuance sendResponse") {
            firstly {
                self.exchangeVCsIfPairwise(response: response, isPairwise: isPairwise)
            }.then { response in
                self.formatIssuanceResponse(response: response, isPairwise: isPairwise)
            }.then { signedToken in
                self.apiCalls.sendResponse(usingUrl:  response.audienceUrl, withBody: signedToken)
            }
        }
    }
    
    private func exchangeVCsIfPairwise(response: IssuanceResponseContainer, isPairwise: Bool) -> Promise<IssuanceResponseContainer> {
        if isPairwise {
            return firstly {
                pairwiseService.createPairwiseResponse(response: response)
            }.then { response in
                self.castToIssuanceResponse(from: response)
            }
        } else {
            return Promise { seal in
                seal.fulfill(response)
            }
        }
    }
    
    private func formatIssuanceResponse(response: IssuanceResponseContainer, isPairwise: Bool) -> Promise<IssuanceResponse> {
        return Promise { seal in
            do {
                
                var identifier: Identifier?
                
                if isPairwise {
                    // TODO: will change when deterministic key generation is implemented.
                    identifier = try identifierService.fetchIdentifier(forId: VCEntitiesConstants.MASTER_ID, andRelyingParty: response.audienceDid)
                } else {
                    identifier = try identifierService.fetchMasterIdentifier()
                }
                
                guard let id = identifier else {
                    throw IssuanceServiceError.unableToFetchIdentifier
                }
                
                sdkLog.logInfo(message: "Signing Issuance Response with Identifier")
                
                seal.fulfill(try self.formatter.format(response: response, usingIdentifier: id))
            } catch {
                seal.reject(error)
            }
        }
    }
    
    private func castToIssuanceResponse(from response: ResponseContaining) -> Promise<IssuanceResponseContainer> {
        return Promise<IssuanceResponseContainer> { seal in
            
            guard let presentationResponse = response as? IssuanceResponseContainer else {
                seal.reject(IssuanceServiceError.unableToCastToPresentationResponseContainer)
                return
            }
            
            seal.fulfill(presentationResponse)
        }
    }
}
