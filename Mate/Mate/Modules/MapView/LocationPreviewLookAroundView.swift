//
//  LocationPreviewLookAroundView.swift
//  Mate
//
//  Created by Adem Özsayın on 20.04.2024.
//

import Foundation
import SwiftUI
import MapKit
import MateNetworking

// MARK: - LocationPreviewLookAroundView
/// A view that displays a preview of location details and a look-around scene.
struct LocationPreviewLookAroundView: View {
    
    /// The look-around scene to be displayed.
    @State private var lookAroundScene: MKLookAroundScene?
    
    /// The MateEvent containing the location details to be previewed.
    var selectedResult: MateEvent
    
    /// A closure to handle the close action.
    var onClose: () -> Void
    
    /// The body of the view.
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                // Close Button
                HStack {
                    Spacer()
                    closeButton {
                        onClose()
                    }
                }
                
                // Title and Value Row
                TitleAndValueRow(
                    title: "Title",
                    value:.placeholder(selectedResult.name ?? ""),
                    selectionStyle: .disclosure,
                    action: { }
                )
                
                // Look-Around Preview
                lookAroundPreview(
                    lookAroundScene: lookAroundScene,
                    getLookAroundScene: getLookAroundScene
                )
            }
            .padding(20) // Add padding to the entire content
            .cornerRadius(10) // Apply corner radius
            .frame(maxWidth: .infinity, // Expand to maximum width
                   alignment: .topLeading // Align to top-leading corner
            )
        }
    }
    
    /// Retrieves the look-around scene for the selected location.
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(coordinate: selectedResult.coordinate!)
            lookAroundScene = try? await request.scene
        }
    }
}

// MARK: - ViewBuilders
/// Extensions providing additional functionality to the LocationPreviewLookAroundView.
extension LocationPreviewLookAroundView {
    
    /// Creates a close button for the location preview.
    ///
    /// - Parameters:
    ///   - onClose: A closure to handle the close action.
    /// - Returns: A button view representing the close button.
    @ViewBuilder
    func closeButton(onClose: @escaping () -> Void) -> some View {
        Button(action: onClose) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.blue)
                .font(.title)
        }
        .padding(.trailing, 10)
    }
    
    /// Creates a look-around preview for the location.
    ///
    /// - Parameters:
    ///   - lookAroundScene: The look-around scene to be displayed.
    ///   - getLookAroundScene: A closure to retrieve the look-around scene.
    /// - Returns: A view representing the look-around preview.
    @ViewBuilder
    func lookAroundPreview(lookAroundScene: MKLookAroundScene?, getLookAroundScene: @escaping () -> Void) -> some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .frame(height: Metrics.lookAroundPreviewHeight) // Fixed height
            .padding(.top, 10) // Add some space between the text and LookAroundPreview
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: selectedResult) {
                getLookAroundScene()
            }
    }
}


// MARK: - Privates
/// Private extension providing metric constants for the LocationPreviewLookAroundView.
private extension LocationPreviewLookAroundView {
    
    /// Metric constants used within the LocationPreviewLookAroundView.
    enum Metrics {
        
        /// The fixed height for the look-around preview.
        static let lookAroundPreviewHeight: CGFloat = 180
    }
}
