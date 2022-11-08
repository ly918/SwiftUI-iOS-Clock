//
//  TimerView.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import SwiftUI

struct TimerView: View {
    @StateObject var timerManager = TimerManager()
    @State var isPresented = false
    
    func cancelAction() {
        self.timerManager.cancel()
    }
    
    func startAction() {
        switch self.timerManager.state {
        case .ready:
            self.timerManager.start()
            break
        case .action:
            self.timerManager.pause()
            break
        case .paused:
            self.timerManager.resume()
            break
        }
        
    }
    
    var pickerView: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                
                Picker("", selection: $timerManager.hour) {
                    ForEach(0..<24) { i in
                        Text(String(i))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: geometry.size.width / 3.0, height: geometry.size.height)
                .compositingGroup()
                .clipped()
                
                Picker("", selection: $timerManager.minute) {
                    ForEach(0..<60) { i in
                        Text(String(i))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: geometry.size.width / 3.0, height: geometry.size.height)
                .compositingGroup()
                .clipped()
                
                Picker("", selection: $timerManager.second) {
                    ForEach(0..<60) { i in
                        Text(String(i))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: geometry.size.width / 3.0, height: geometry.size.height)
                .compositingGroup()
                .clipped()
                
            }
        }
        .frame(height: 300)
    }
    
    var actionView: some View {
        HStack {
            Button {
                self.cancelAction()
            } label: {
                Text(self.timerManager.state.cancelText)
                    .foregroundColor(self.timerManager.state.cancelTextColor)
                    .frame(width: 80, height: 80)
            }
            .disabled(self.timerManager.state.cancelDisabled)
            .background(self.timerManager.state.cancelBgColor)
            .clipShape(Circle())
            
            Spacer()
            
            Button {
                self.startAction()
            } label: {
                Text(self.timerManager.state.startText)
                    .foregroundColor(self.timerManager.state.startTextColor)
                    .foregroundColor(.green)
                    .frame(width: 80, height: 80)
            }
            .disabled(self.timerManager.startDisabled)
            .background(self.timerManager.state.startBgColor)
            .clipShape(Circle())
        }
    }
    
    var musicSelectView: some View {
        Button(action: {
            self.isPresented = true
        }, label: {
            HStack {
                Text("Sound")
                    .foregroundColor(.white)
                Spacer()
                Text(self.timerManager.sound.rawValue)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(8)
        })
        .buttonStyle(BorderedButtonStyle())
        .sheet(isPresented: $isPresented) {
            MusicSelectView()
                .environmentObject(timerManager)
        }
    }
    
    var body: some View {
        ScrollView {
            if self.timerManager.state == .ready {
                pickerView
                    .padding()
            } else {
                TimerProgressView()
                    .environmentObject(timerManager)
                    .padding()
            }
            
            actionView
                .padding()
            musicSelectView
                .padding()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
