//
//  AlarmRow.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import SwiftUI

struct AlarmRow: View {
    @Binding var alarm: Alarm
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(alarm.time.timeFormat())
                    .font(.system(size: 50))
                Text(alarm.intro)
            }
            Spacer()
            Toggle("", isOn: $alarm.isOn)
        }
    }
}

struct AlarmRow_Previews: PreviewProvider {
    static var previews: some View {
        AlarmRow(alarm: .constant(Alarm()))
            .preferredColorScheme(.dark)
    }
}
