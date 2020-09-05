/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

// TODO Subject to change when Serializer layer is built.
class SimpleSuccessHandler<Decoder: Decoding>: SuccessHandling {
    
    let decoder: Decoder
    
    init(decoder: Decoder) {
        self.decoder = decoder
    }
    
    func onSuccess(data: Data) throws -> Decoder.ResponseBody {
        return try decoder.decode(data: data)
    }
}
