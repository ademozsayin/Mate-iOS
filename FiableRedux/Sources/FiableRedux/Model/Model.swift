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
public typealias MateEvent = MateNetworking.MateEvent
public typealias MateCategory = MateNetworking.MateCategory
public typealias EventStatus = MateNetworking.EventStatus
public typealias GooglePlace = MateNetworking.GooglePlace

public typealias EmailCheck = MateNetworking.EmailCheckData
public typealias Note = MateNetworking.Note
public typealias NoteBlock = MateNetworking.NoteBlock
public typealias NoteMedia = MateNetworking.NoteMedia

public typealias Credentials = MateNetworking.Credentials
public typealias StoreOnboardingTask = MateNetworking.StoreOnboardingTask
public typealias BlazeTargetLanguage = MateNetworking.BlazeTargetLanguage

// MARK: - Exported Storage Symbols
public typealias StorageAccount = MateStorage.Account
public typealias LocalAnnouncement = MateStorage.LocalAnnouncement
public typealias StorageEvent = MateStorage.Event
public typealias StorageEventCategory = MateStorage.EventCategory
public typealias StorageGooglePlace = MateStorage.GooglePlace




// MARK: - Internal ReadOnly Models

//typealias UploadableMedia = Networking.UploadableMedia
