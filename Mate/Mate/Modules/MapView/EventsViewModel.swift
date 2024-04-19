//
//  EventsViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 19.04.2024.
//

import SwiftUI
import CoreLocation

@Observable class EventsViewModel {
    var events: [String] = []
    
    func fetchEvents(near location: CLLocationCoordinate2D) {
        // Mock request: Simulate fetching events near the user's location
        // In a real application, you would replace this with an actual API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simulate a delay
            self.events = [
                "Event 1 near you",
                "Event 2 nearby",
                "Another event in your area"
            ]
        }
    }
}
