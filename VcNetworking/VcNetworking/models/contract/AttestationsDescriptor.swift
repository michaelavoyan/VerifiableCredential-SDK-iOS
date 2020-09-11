/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct AttestationsDescriptor: Codable, Equatable {
    let selfIssued: SelfIssuedClaimsDescriptor?
    let presentations: [PresentationDescriptor]?
    let idTokens: [IdTokenDescriptor]?
}
