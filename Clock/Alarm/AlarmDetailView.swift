//
//  AlarmDetailView.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import SwiftUI

struct AlarmDetailView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject private var alarmManager: AlarmManager
    @State var showDelete = false
    @Binding var alarm: Alarm
    
    var reportsSection: some View {
        Section {
            NavigationLink(destination: RepeatSelectView(alarm: $alarm)) {
                HStack {
                    Text("Repeat")
                    Spacer()
                    Text(alarm.repeatLabel)
                        .foregroundColor(Color(.systemGray))
                }
            }
            HStack {
                Text("Label")
                ZStack(alignment: .trailing) {
                    TextField(Alarm.labelPlaceholder, text: $alarm.label)
                        .multilineTextAlignment(.trailing)
                }
            }
            NavigationLink(destination: SoundSelectView(alarm: $alarm)) {
                HStack {
                    Text("Sound")
                    Spacer()
                    Text(alarm.sound.rawValue)
                        .foregroundColor(Color(.systemGray))
                }
            }
            HStack {
                Text("Snooze")
                Toggle(isOn: $alarm.isLater) {}
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                DatePicker("", selection: $alarm.time, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                
                reportsSection
                
                if self.showDelete {
                    Section {
                        Button {
                            alarmManager.remove(alarm: self.alarm)
                            self.mode.wrappedValue.dismiss()
                        } label: {
                            Text("Delete Alarm")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("Edit Alarm"))
            .onAppear {
                self.showDelete = self.alarmManager.isEdit(self.alarm.id)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.mode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.save()
                        self.mode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }
                }
            }
        }
    }
    
    func save() {
        if self.alarmManager.isEdit(self.alarm.id) {
            alarmManager.update(self.alarm)
        } else {
            alarmManager.add(self.alarm)
        }
    }
}

struct AlarmDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailView(alarm: .constant(Alarm()))
            .environmentObject(AlarmManager())
    }
}
