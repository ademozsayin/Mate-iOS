//
//  MapView.swift
//  Mate
//
//  Created by Adem Özsayın on 19.04.2024.
//


import SwiftUI
import MapKit
import Observation

struct MapView: View {

    @State private var locationViewModel = LocationViewModel()
    @State var viewModel: MapViewModel
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {

        Map(position: $locationViewModel.cameraPosition) {
            UserAnnotation()
            ForEach(viewModel.events, id: \.id) { event in
                if let coordinate = event.coordinate {
                    Marker(event.name ?? "Mate Event", coordinate: coordinate)
                }
            }
        }
        .ignoresSafeArea() // Optional: expand map to edges
        .overlay(alignment: .bottom) { // Overlay for permission handling
            if locationViewModel.authorizationStatus == .notDetermined {
                Button("Request Location Permission") {
                    locationViewModel.requestLocationPermission()
                }
            } else if locationViewModel.authorizationStatus == .denied {
                Text("Location permission denied. Please enable it in settings.")
            }
        }
        .onAppear {
            if locationViewModel.authorizationStatus == .notDetermined {
                locationViewModel.requestLocationPermission()
            }
        }
        .onChange(of: locationViewModel.userLocation) {
            if let location = locationViewModel.userLocation  {
                Task {
                    await viewModel.fetchEvents(location: location, isReload: false)
                }
            }
        }
//        .environment(locationViewModel)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

//struct MapView: View {
//    
//    @State private var lookAroundScene: MKLookAroundScene?
//    var body: some View {
////        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//        Map() {
//            Marker("Sisli", coordinate: .sisli)
//                .tint(.background)
//            Annotation("Deneme Anno", coordinate: .sisli2) {
//                ZStack {
//                   RoundedRectangle(cornerRadius: 5)
//                       .fill(Color.teal)
//                   Text("🎓")
//                       .padding(5)
//                    HStack {
//                        MapUserLocationButton()
//                    }
//               }
//            }
//        }
//        .mapStyle(.standard(elevation: .automatic))
////        .mapStyle(.hybrid(elevation: .realistic))
//        .mapControls {
//            MapUserLocationButton()
//        }
//    }
//}

#Preview {
    LocationPreviewView()
}

//            if let userLocation = viewModel.userLocation {
//                Annotation("", coordinate: userLocation) { // Use MapAnnotation directly
//
//                }
//                Marker(coordinate: userLocation, tint: .blue)
//            }
//        }

extension CLLocationCoordinate2D {
    static let sisli = CLLocationCoordinate2D(latitude: 41.0536, longitude: 28.9820)
    static let sisli2 = CLLocationCoordinate2D(latitude: 41.0636, longitude: 28.9820)
    static let columbiaUniversity = CLLocationCoordinate2D(latitude: 40.8075, longitude: -73.9626)
}

struct LocationPreviewLookAroundView: View {
    @State private var lookAroundScene: MKLookAroundScene?
    var selectedResult: MyFavoriteLocation
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedResult.name)")
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(18)
            }
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: selectedResult) {
                getLookAroundScene()
            }
    }
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(coordinate: selectedResult.coordinate)
            lookAroundScene = try? await request.scene
        }
    }
}

struct MyFavoriteLocation: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    static func == (lhs: MyFavoriteLocation, rhs: MyFavoriteLocation) -> Bool {
        return lhs.id == rhs.id
    }
}

struct LocationPreviewView: View {
    @State private var selection: UUID?
    
    let myFavoriteLocations = [
        MyFavoriteLocation(name: "Columbia University", coordinate: .sisli2),
        MyFavoriteLocation(name: "Sisli halısaha", coordinate: .sisli)
    ]
        
    
    var body: some View {
        Map(selection: $selection) {
            ForEach(myFavoriteLocations) { location in
                Marker(location.name, coordinate: location.coordinate)
                    .tint(.orange)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    if let selection {
                        if let item = myFavoriteLocations.first(where: { $0.id == selection }) {
                            VStack {
                                Text("asdasdasd")
                                HStack(content: {
                                    /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                                    Text("Placeholder")
                                    /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                                })
                                
                                LocationPreviewLookAroundView(selectedResult: item)
                                    .frame(height: 128)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding([.top, .horizontal])
                            }
                          
                        }
                    }
                }
                Spacer()
            }
            .background(.thinMaterial)
        }
        .onChange(of: selection) {
            guard let selection else { return }
            guard let item = myFavoriteLocations.first(where: { $0.id == selection }) else { return }
            print(item.coordinate)
        }
    }
}
