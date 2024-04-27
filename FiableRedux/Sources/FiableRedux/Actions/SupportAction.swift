//
//  SupportAction.swift
//
//
//  Created by Adem Özsayın on 24.04.2024.
//

import Foundation
import MateNetworking

public enum SupportAction: Action {

    /// Registers a device for Push Notifications Delivery.
    ///
    case createTicket(
        form_id: String,
        subject:String,
        description: String,
        onCompletion: (Result<MateResponse<Ticket>, OnsaApiError>) -> Void)
}
