//
//  FirstEventCreatedViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 8.05.2024.
//
import UIKit
import FiableRedux

final class FirstEventCreatedViewModel: ObservableObject {
    @Published var isSharePopoverPresented = false
    @Published var isShareSheetPresented = false

    let productURL: URL
    let productName: String
    let showShareProductButton: Bool
    let shareSheet: ShareSheet

    private let isPad: Bool
    private let analytics: MateAnalytics

    init(productURL: URL,
         productName: String,
         showShareProductButton: Bool,
         isPad: Bool = UIDevice.isPad(),
         analytics: MateAnalytics = ServiceLocator.analytics) {
        self.productURL = productURL
        self.productName = productName
        self.showShareProductButton = showShareProductButton


        self.analytics = analytics
        self.isPad = isPad
        self.shareSheet = ShareSheet(activityItems: [productName, productURL])
    }

    func didTapShareProduct() {
        analytics.track(.firstCreatedProductShareTapped)
        if isPad {
            isSharePopoverPresented = true
        } else {
            isShareSheetPresented = true
        }
    }
}
