//
//  Model.swift
//  Redux
//
//  Created by Adem Özsayın on 17.03.2024.
//

import Foundation
import MateNetworking
import MateStorage


// MARK: - Exported ReadOnly Symbols
public typealias Account = MateNetworking.Account
public typealias AccountSettings = MateNetworking.AccountSettings
public typealias APNSDevice = MateNetworking.APNSDevice
public typealias MateDevice = MateNetworking.MateDevice

public typealias EmailCheck = MateNetworking.EmailCheckData
public typealias Note = MateNetworking.Note
public typealias NoteBlock = MateNetworking.NoteBlock
public typealias NoteMedia = MateNetworking.NoteMedia

public typealias Credentials = MateNetworking.Credentials
public typealias StoreOnboardingTask = MateNetworking.StoreOnboardingTask
public typealias BlazeTargetLanguage = MateNetworking.BlazeTargetLanguage

// MARK: - Exported Storage Symbols

public typealias LocalAnnouncement = MateStorage.LocalAnnouncement


// MARK: - Internal ReadOnly Models

//typealias UploadableMedia = Networking.UploadableMedia
