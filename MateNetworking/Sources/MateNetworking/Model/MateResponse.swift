//
//  MateResponse.swift
//
//
//  Created by Adem Özsayın on 26.04.2024.
//

import Foundation

public struct MateResponse<T: Decodable>: Decodable {
    public let success: Bool?
    public let data: T?
    public let user_message: String?
}
