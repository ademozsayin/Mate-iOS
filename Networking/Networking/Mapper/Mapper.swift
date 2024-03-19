//
//  Mapper.swift
//  Networking
//
//  Created by Adem Özsayın on 18.03.2024.
//

import Foundation


/// Defines a Mapping Entity that will be used to parse a Backend Response.
///
protocol Mapper {

    /// Defines the Mapping Return Type.
    ///
    associatedtype Output

    /// Maps a Backend Response into a generic entity of Type `Output`. This method *can throw* errors.
    ///
    func map(response: Data) throws -> Output
}
