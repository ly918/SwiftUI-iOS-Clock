//
//  SoundSelectView.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import SwiftUI

struct SoundSelectView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @Binding var alarm: Alarm

    var body: some View {
        List(sounds, id: \.self) { sound in
            Button {
                alarm.sound = sound
            } label: {
                HStack {
                    Text(sound.rawValue)
                        .foregroundColor(.white)
                    Spacer()
                    if alarm.sound == sound {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

struct SoundSelectView_Previews: PreviewProvider {
    static var previews: some View {
        SoundSelectView(alarm: .constant(Alarm()))
    }
}
