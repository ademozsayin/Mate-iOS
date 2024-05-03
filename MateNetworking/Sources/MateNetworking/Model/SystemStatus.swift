//
//  SystemStatus.swift
//
//
//  Created by Adem Özsayın on 3.05.2024.
//

import Foundation

// MARK: - SystemStatus
public struct SystemStatus: Codable {
    let environment: Environment
    let database: Database
    let security: Security
    
    // MARK: - Database
    public  struct Database: Codable {
        let connectionName, databaseType, databaseName: String

        enum CodingKeys: String, CodingKey {
            case connectionName = "connection_name"
            case databaseType = "database_type"
            case databaseName = "database_name"
        }
    }

    // MARK: - Environment
    public  struct Environment: Codable {
        let appEnv: String
        let appDebug: Bool
        let appURL: String

        enum CodingKeys: String, CodingKey {
            case appEnv = "app_env"
            case appDebug = "app_debug"
            case appURL = "app_url"
        }
    }

    // MARK: - Security
    public struct Security: Codable {
        let https: Bool
        let headers: Headers
    }

    // MARK: - Headers
    public  struct Headers: Codable {
        let contentSecurityPolicy: String?
        let xFrameOptions: String

        enum CodingKeys: String, CodingKey {
            case contentSecurityPolicy = "content_security_policy"
            case xFrameOptions = "x_frame_options"
        }
    }

}

