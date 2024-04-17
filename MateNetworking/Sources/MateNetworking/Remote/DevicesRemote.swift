//
//  DevicesRemote.swift
//
//
//  Created by Adem Özsayın on 16.04.2024.
//

import Foundation


/// Devices: Remote Endpoints (Push Notifications Registration / Unregistration!)
///
public class DevicesRemote: Remote {

    /// Registers a device for Push Notifications Delivery.
    ///
    /// - Parameters:
    ///     - device: APNS Device to be registered.
    ///     - applicationId: App ID.
    ///     - applicationVersion: App Version.
    ///     - defaultStoreID: Active Store ID.
    ///     - completion: Closure to be executed on completion.
    ///
    public func registerDevice(device: APNSDevice,
                               userId: Int,
                               applicationId: String,
                               applicationVersion: String,
                               completion: @escaping (MateDevice?, Error?) -> Void) {
        var parameters = [
           
            ParameterKeys.applicationId: applicationId,
            ParameterKeys.applicationVersion: applicationVersion,
            ParameterKeys.deviceFamily: device.family,
            ParameterKeys.deviceToken: device.token,
            ParameterKeys.deviceModel: device.model,
            ParameterKeys.deviceName: device.name,
            ParameterKeys.deviceOSVersion: device.iOSVersion,
            ParameterKeys.userID: "\(userId)"

        ]

        if let deviceUUID = device.identifierForVendor {
            parameters[ParameterKeys.deviceUUID] = deviceUUID
        }
        
            
        let request = OnsaApiRequest(method: .post, path: Paths.register, parameters: parameters)

        let mapper = MateDeviceMapper()

        enqueue(request, mapper: mapper) { (device, error) in
            completion(device, error)
        }
    }


    /// Removes a given DeviceId from the Push Notifications systems.
    ///
    /// - Parameters:
    ///     - deviceId: Identifier of the device to be removed.
    ///     - completion: Closure to be executed on completion.
    ///
    public func unregisterDevice(deviceId: String, completion: @escaping (Error?) -> Void) {
        let path = String(format: Paths.delete, deviceId)
        let unregisterRequest = FiableRequest(method: .post, path: path)

        let mapper = SuccessResultMapper()

        enqueue(unregisterRequest, mapper: mapper) { (success, error) in
            guard success == true else {
                completion(error ?? DotcomError.empty)
                return
            }

            completion(nil)
        }
    }
}


// MARK: - Constants!
//
private extension DevicesRemote {

    enum Paths {
        static let register = "user/devices"
        static let delete = "devices/%@/delete"
    }

    enum ParameterKeys {
        static let applicationId = "applicationId"
        static let applicationVersion = "applicationVersion"
        static let deviceFamily = "family"
        static let deviceToken = "token"
        static let deviceModel = "model"
        static let deviceName = "name"
        static let deviceOSVersion = "iOSVersion"
        static let deviceUUID = "device_uuid"
        static let userID = "user_Id"
    }
}
