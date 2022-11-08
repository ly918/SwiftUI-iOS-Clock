//
//  MusicSelectView.swift
//  Clock
//
//  Created by GNR on 11/7/22.
//

import SwiftUI

struct MusicSelectView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var timerManager: TimerManager
    @State var sound: Sound = .radar
    
    var body: some View {
        NavigationView {
            List(sounds, id: \.self) { sound in
                Button {
                    Task {
                        self.sound = sound
                    }
                } label: {
                    HStack {
                        Text(sound.rawValue)
                            .foregroundColor(.white)
                        Spacer()
                        if self.sound == sound {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("Sound"))
            .onAppear {
                self.sound = self.timerManager.sound
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
        self.timerManager.sound = self.sound
    }
}

struct MusicSelectView_Previews: PreviewProvider {
    static var previews: some View {
        MusicSelectView()
    }
}
