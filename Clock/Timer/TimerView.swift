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
        VStack {
            if self.timerManager.state == .ready {
                MutiplePicker(data: timerManager.data, selection: $timerManager.selection)
                    .frame(height: 300)
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
            
            Spacer()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}

struct MutiplePicker: View {
    typealias Label = String
    typealias Entry = String
    
    let data: [(Label, [Entry])]
    @Binding var selection: [Entry]
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ForEach(0..<self.data.count, id: \.self) { column in
                    Picker(self.data[column].0, selection: $selection[column]) {
                        ForEach(0..<self.data[column].1.count, id: \.self) { row in
                            Text(verbatim: self.data[column].1[row])
                                .tag(self.data[column].1[row])
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: geometry.size.width / Double(self.data.count), height: geometry.size.height)
                    .clipped()
                }
            }
        }
    }
}
