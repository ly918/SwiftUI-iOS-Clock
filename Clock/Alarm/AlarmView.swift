//
//  AlarmView.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import SwiftUI

struct AlarmView: View {
    @EnvironmentObject private var alarmManager: AlarmManager
    @Environment(\.editMode) var editMode
    @State var isPresented = false
    @State var editAlarm: Alarm = Alarm()
    
    var alarmsView: some View {
        List {
            ForEach(alarmManager.alarms) { alarm in
                Button {
                    self.editAlarm = alarm
                    self.editMode?.animation().wrappedValue = .inactive
                    self.isPresented = true
                } label: {
                    AlarmRow(alarm: Binding(get: {
                        alarm
                    }, set: { _ in
                        alarmManager.toggle(alarm)
                    }))
                }
            }
            .onDelete { alarmManager.remove(indexSet: $0) }
        }
        .listStyle(.plain)
    }
    
    var emptyView: some View {
        Text("No Alarm")
    }
    
    var body: some View {
        NavigationView {
            Group {
                if alarmManager.alarms.isEmpty {
                    emptyView
                } else {
                    alarmsView
                }
            }
            .navigationTitle(Text("Alarm"))
            .onDisappear {
                self.editMode?.animation().wrappedValue = .inactive
            }
            .sheet(isPresented: $isPresented) {
                AlarmDetailView(alarm: $editAlarm)
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.editAlarm = Alarm()
                        self.editMode?.animation().wrappedValue = .inactive
                        self.isPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct AlarmView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmView()
            .preferredColorScheme(.dark)
            .environmentObject(AlarmManager())
    }
}
