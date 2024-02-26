//
//  BaseResponse.swift
//  Network
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation


public struct BaseResponse<T: Codable>: Codable {

    // MARK: - Properties
    public var result: MtekResult?
    public var data: T?
    public var totalCount: Int?
    
    public enum CodingKeys: String, CodingKey {

        case data = "ReturnObject"
        case result = "Result"
        case totalCount = "TotalCount"
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        totalCount = (try keyedContainer.decode(Int.self, forKey: CodingKeys.totalCount))
        result = ( try keyedContainer.decode(MtekResult.self, forKey: CodingKeys.result))
//        data = ( try keyedContainer.decode(T.self, forKey: CodingKeys.data) )
        data = try keyedContainer.decodeIfPresent(T.self, forKey: .data)

    }
}

// MARK: - Result
public struct MtekResult: Codable {
    public var resultCode: Int?
    public var resultMessage: String?

    public enum CodingKeys: String, CodingKey {
        case resultCode = "ResultCode"
        case resultMessage = "ResultMessage"
    }
}

public struct BaseResponseNonGeneric: Codable {

    // MARK: - Properties
    public var result: MtekResult?
    public var totalCount: Int?
    
    public enum CodingKeys: String, CodingKey {

        case result = "Result"
        case totalCount = "TotalCount"
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        totalCount = (try? keyedContainer.decode(Int.self, forKey: CodingKeys.totalCount)) ?? 0
        result = (try? keyedContainer.decode(MtekResult.self, forKey: CodingKeys.result))
    }
}
