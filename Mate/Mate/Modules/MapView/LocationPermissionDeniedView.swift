//
//  LocationRequestView.swift
//  Mate
//
//  Created by Adem Özsayın on 20.04.2024.
//

import Foundation
import SwiftUI

struct LocationRequestView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack {
                Spacer()
                Image(systemName: "paperplane.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 32)
                LargeTitle(
                    text: Localization.title
                )
                .padding()
                
                Text(Localization.description)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                VStack {
                    Button(Localization.button) {
                        openSettings()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding()
                }
            }
        }
    }
    
    private func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

}

extension LocationRequestView {
    enum Localization {
        static let title = NSLocalizedString("Would you like to explore events nearby?",
                                             comment: "")
        static let description = NSLocalizedString("Unlock a world of exciting events waiting to be explored by sharing your location with us. Join a community of fellow enthusiasts and start exploring today!",
                                                   comment: "")
        static let button = NSLocalizedString("Allow Location",
                                                      comment: "The title of the button")
    }
}

//#Preview {
//    LocationRequestView()
//        .preferredColorScheme(.dark)
//}

