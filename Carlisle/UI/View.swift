//
//  View.swift
//  Carlisle
//
//  Created by Christopher on 5/9/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State var tapped = false
    @State var asstResponse: String = ""
    
    
    var body: some View {
        return Group {
            if tapped {
                CarlisleView(asstResponse: $asstResponse)
            } else {
                StartupView(tapped: $tapped)
            }
        }
    }
}
    
struct StartupView : View {
    
    @Binding var tapped: Bool
    
    var body: some View {
        
        ZStack {
            
            Color.primaryBackground
                .ignoresSafeArea()
            
            Rectangle()
                .stroke(Color.primaryCarlText, lineWidth: 1)
                .frame(width: 350, height: 40)
                .blur(radius: 4)
            
            Rectangle()
                .stroke(Color.primaryCarlText, lineWidth: 1)
                .frame(width: 350, height: 40)
            
            SwiftUI.Text(".carlisle")
                .font(.custom("Apple ][", size: 20))
                .kerning(-7)
                .foregroundColor(.secondaryCarlText)
                .gesture(tap)
                .opacity(0.06)
                .blur(radius: 10)

        
            SwiftUI.Text(".carlisle")
                .font(.custom("Apple ][", size: 20))
                .kerning(-7)
                .foregroundColor(.primaryCarlText)
                .gesture(tap)

        }
    }
    
    var tap: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                tapped = true
            }
    }
}
    
    struct CarlisleView : View {
        
        var sendHandler = SendHandler()
        
        @Binding var asstResponse: String
        
        @State var x_offset: CGFloat = 0
        @State var y_offset: CGFloat = 0
        @State private var prompt: String = ""
        @State var isFirstTap: Bool = true
        @State var keyboardHeight: CGFloat = 0
        
        @FocusState private var promptIsFocused: Bool
        
        var body: some View {
            
            ZStack {
                
                Color.primaryBackground
                    .ignoresSafeArea()
                
                Rectangle()
                    .stroke(Color.primaryCarlText, lineWidth: 1)
                    .frame(width: 350, height: 40)
                    .blur(radius: 4)
                    .offset(x: x_offset, y: y_offset)
                
                Rectangle()
                    .stroke(Color.primaryCarlText, lineWidth: 1)
                    .frame(width: 350, height: 40)
                    .offset(x: x_offset, y: y_offset)
                
                SwiftUI.Text(".carlisle")
                    .font(.custom("Apple ][", size: 20))
                    .kerning(-7)
                    .foregroundColor(.secondaryCarlText)
                    .offset(x: x_offset, y: y_offset)
                    .onAppear(perform: {
                        withAnimation(
                            .easeOut(duration: 1)) {
                                x_offset = 0
                                y_offset = -350
                            }
                    })
                    .opacity(0.06)
                    .blur(radius: 10)
                
                SwiftUI.Text(".carlisle")
                    .font(.custom("Apple ][", size: 20))
                    .kerning(-7)
                    .foregroundColor(.primaryCarlText)
                    .offset(x: x_offset, y: y_offset)
                    .onAppear(perform: {
                        withAnimation(
                            .easeInOut(duration: 1.5)) {
                                x_offset = 0
                                y_offset = -350
                            }
                    })
                
                ScrollView {
                    ZStack{
                        
                        SwiftUI.Text(asstResponse)
                            .font(.custom("Apple ][", size: 15))
                            .kerning(-5)
                            .foregroundColor(.primaryCarlText)
                            .frame(width: 350)
                            .offset(x: -1, y: 1)
                            .blur(radius: 10)
                            .opacity(0.7)
                            .opacity(1)
                            .padding(15)

                        SwiftUI.Text(asstResponse)
                            .font(.custom("Apple ][", size: 15))
                            .kerning(-5)
                            .foregroundColor(.primaryCarlText)
                            .frame(width: 350)
                            .padding(15)
                        
                    }
                }
                .frame(width: 365, height: 400)
                .offset(y: -120)

                ZStack{
                    
                    TextField(".prompt", text: $prompt, axis: .vertical)
                        .font(.custom("Apple ][", size: 20))
                        .kerning(-5)
                        .foregroundColor(.white)
                        .offset(x: -8, y: 190 )
                        .foregroundColor(.white)
                        .blur(radius: 5)
                        .opacity(0.5)
                        .frame(width: 350, height: 300)
                        .lineLimit(5...10)
                    
                    TextField(".prompt", text: $prompt, axis: .vertical)
                        .font(.custom("Apple ][", size: 20))
                        .kerning(-5)
                        .foregroundColor(.white)
                        .offset(x: -8, y: 190 )
                        .foregroundColor(.white)
                        .frame(width: 350, height: 300)
                        .lineLimit(5...10)
                        .onTapGesture {
                            promptIsFocused = true
                            if (asstResponse != "" && isFirstTap) {
                                prompt = ""
                                isFirstTap = false
                            }
                        }
                        .focused($promptIsFocused)
                }
                
                Button(action: {
                    
                    promptIsFocused = false
                    sendHandler.SendMessage(prompt: prompt) { responseMessage in
                        
                        if let responseMessage = responseMessage {
                            asstResponse = responseMessage
                            isFirstTap = true
                        } else {
                            print("Error in retrieving response")
                            isFirstTap = true
                        }
                    }
                    
                }, label: {
                    SwiftUI.Text("send")
                        .font(.custom("Apple ][", size: 20))
                        .kerning(-5)
                        .foregroundColor(.white)
                }).offset(y: 110)
            }
        }
    }
    
    #Preview {
        ContentView()
            .modelContainer(for: Item.self, inMemory: true)
    }
