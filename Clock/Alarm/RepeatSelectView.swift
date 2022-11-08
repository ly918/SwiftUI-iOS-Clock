//
//  RepeatSelectView.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import SwiftUI

struct RepeatSelectView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @Binding var alarm: Alarm
    
    var body: some View {
        List(Alarm.repeats, id: \.self) { item in
            Button {
                alarm.selectRepeat(item)
            } label: {
                HStack {
                    Text(item.singleLabel)
                        .foregroundColor(.white)
                    Spacer()
                    if alarm.isSelectedRepeat(item) {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

struct RepeatSelectView_Previews: PreviewProvider {
    static var previews: some View {
        RepeatSelectView(alarm: .constant(Alarm()))
    }
}
