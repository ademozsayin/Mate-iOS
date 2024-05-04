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
public typealias Announcement = MateNetworking.Announcement

public typealias APNSDevice = MateNetworking.APNSDevice
public typealias BlazeTargetLanguage = MateNetworking.BlazeTargetLanguage
public typealias Credentials = MateNetworking.Credentials
public typealias EmailCheck = MateNetworking.EmailCheckData
public typealias EventStatus = MateNetworking.EventStatus
public typealias InboxNote = MateNetworking.InboxNote
public typealias InboxAction = MateNetworking.InboxAction
public typealias MateDevice = MateNetworking.MateDevice
public typealias MateEvent = MateNetworking.MateEvent
public typealias MateCategory = MateNetworking.MateCategory
public typealias Feature = MateNetworking.Feature
public typealias GooglePlace = MateNetworking.GooglePlace
public typealias Note = MateNetworking.Note
public typealias NoteBlock = MateNetworking.NoteBlock
public typealias NoteMedia = MateNetworking.NoteMedia
public typealias StoreOnboardingTask = MateNetworking.StoreOnboardingTask
public typealias SystemStatus = MateNetworking.SystemStatus

public typealias ProductReview = MateNetworking.ProductReview
public typealias ProductReviewStatus = MateNetworking.ProductReviewStatus

// MARK: - Exported Storage Symbols
public typealias StorageAccount = MateStorage.Account
public typealias LocalAnnouncement = MateStorage.LocalAnnouncement
public typealias StorageEvent = MateStorage.Event
public typealias StorageEventCategory = MateStorage.EventCategory
public typealias StorageGooglePlace = MateStorage.GooglePlace

public typealias StorageInboxNote = MateStorage.InboxNote
public typealias StorageInboxAction = MateStorage.InboxAction

public typealias StorageProductReview = MateStorage.ProductReview

public typealias StorageNote = MateStorage.Note

// MARK: - Internal ReadOnly Models

//typealias UploadableMedia = Networking.UploadableMedia
