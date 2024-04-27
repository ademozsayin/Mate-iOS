// Generated using Sourcery 1.0.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import CodeGen
import Foundation
import UIKit


extension MateNetworking.MateEvent {
    public func copy(
        id: CopiableProp<Int> = .copy,
        name: CopiableProp<String> = .copy
        
    ) -> MateNetworking.MateEvent {
        let id = id ?? self.id
        let name = name ?? self.name

        return MateNetworking.MateEvent(
            id: id, 
            name: name,
            startTime: nil,
            categoryID: nil,
            createdAt: nil,
            updatedAt: nil,
            userID: nil,
            address: nil,
            latitude: nil,
            longitude: nil,
            maxAttendees: nil,
            joinedAttendees: nil,
            category: nil,
            user: nil,
            status: nil
        )
    }
}
