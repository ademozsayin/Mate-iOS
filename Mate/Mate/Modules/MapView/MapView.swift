//
//  MapView.swift
//  Mate
//
//  Created by Adem Özsayın on 5.04.2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            userTrackingMode: $viewModel.trackingMode)
        .edgesIgnoringSafeArea(.all)
    }
}
    
