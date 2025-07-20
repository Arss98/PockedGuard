//
//  CalendarDatePicker.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 05.06.2025.
//

import SwiftUI

struct CalendarDatePicker: View {
    var onDatesSelected: (Date, Date) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDates: Set<DateComponents> = []
    @State private var startDate: Date?
    @State private var endDate: Date?
    
    var body: some View {
        VStack {
            MultiDatePicker("Выберите две даты", selection: $selectedDates)
                .colorScheme(.dark)
                .tint(.appSelectedBlue)
                .onChange(of: selectedDates) { oldValue, newValue in
                    handleDateSelection(oldValue, newValue)
                }
            
            Button("Далее") {
                if let start = startDate, let end = endDate {
                    onDatesSelected(start, end)
                }
                dismiss()
            }
            .datePickerButtonStyle()
            .padding()
            .disabled(startDate == nil || endDate == nil)
        }
        .background(.appCardAndField)
    }
}

private extension CalendarDatePicker {
    func handleDateSelection(_ oldValue: Set<DateComponents>, _ newValue: Set<DateComponents>) {
        guard let newDate = newValue.subtracting(oldValue).first?.date else { return }
        
        switch (startDate, endDate) {
        case (nil, _):
            startDate = newDate
            
        case (let start?, nil):
            if newDate < start {
                startDate = newDate
                endDate = start
            } else {
                endDate = newDate
            }
            
        case (let start?, let end?):
            if newDate < start || (newDate > start && newDate < end) {
                startDate = newDate
            } else if newDate > end {
                endDate = newDate
            }
        }
        
        updateSelectedDates()
    }

    func updateSelectedDates() {
        guard let startDate = startDate else {
            selectedDates = []
            return
        }
        
        if let endDate = endDate {
            selectedDates = [
                Calendar.current.dateComponents([.year, .month, .day], from: startDate),
                Calendar.current.dateComponents([.year, .month, .day], from: endDate)
            ]
        } else {
            selectedDates = [Calendar.current.dateComponents([.year, .month, .day], from: startDate)]
        }
    }
}
