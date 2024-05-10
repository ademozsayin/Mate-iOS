//
//  EventDateAndTimeView.swift
//  Mate
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation
import SwiftUI

struct DateTimePickerView: View {
    @Binding var selectedDate: Date
    var onApply: () -> Void
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets: EdgeInsets
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ScrollView {
                    VStack {
                        DatePicker("Select Date", selection: $selectedDate, in: nextDay...twoWeeksLater, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(.vertical, 20)
                        Divider()
                        DatePicker(
                            "Select Time",
                            selection: $selectedDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.vertical, 20)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 20)
                    .addingTopAndBottomDividers()
                    .background(Color(.listForeground(modal: false)))
                    FooterNotice(infoText: "You can only create an event between 1 hour and 2 weeks from now.")
                        .padding(.vertical, 20)
                }
                .navigationBarTitle("Event Date")
                .navigationBarTitleDisplayMode(.large)
                .ignoresSafeArea(edges: .horizontal)
                .background(
                    Color(.listBackground).edgesIgnoringSafeArea(.all)
                )
            }
            
            // Sticky bottom button
            Button("Apply") {
                onApply()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .frame(width: geometry.size.width, height: 50)
//            .background(Color.blue)
//            .foregroundColor(.white)
            .position(x: geometry.size.width / 2, y: geometry.size.height - 25)
        }
    }
    
    private var nextDay: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }
    
    private var twoWeeksLater: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    }
}

#Preview {
    DateTimePickerView(selectedDate: .constant(Date()), onApply: {})
}
