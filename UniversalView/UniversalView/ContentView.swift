//
//  ContentView.swift
//  UniversalView
//
//  Created by Adrian Suryo Abiyoga on 20/01/25.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State private var show: Bool = false
    @State private var showFAB: Bool = false
    @State private var showSheet: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Button("Floating Video Player") {
                    show.toggle()
                }
                .universalOverlay(show: $show) {
                    FloatingVideoPlayerView(show: $show)
                }
                
                Button("Floating Action Button") {
                    showFAB.toggle()
                }
                .universalOverlay(show: $showFAB) {
                    FloatingActionButton(show: $showFAB)
                }
                
                Button("Show Dummy Sheet") {
                    showSheet.toggle()
                }
                
                NavigationLink("Navigate to Detail View") {
                    Text("Hello World!")
                        .navigationTitle("Detail View")
                }
            }
            .navigationTitle("Universal Overlay")
        }
        .sheet(isPresented: $showSheet) {
            Text("Hello From Sheets!")
        }
    }
}

struct FloatingVideoPlayerView: View {
    @Binding var show: Bool
    /// View Properties
    @State private var player: AVPlayer?
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            Group {
                if let player {
                    VideoPlayer(player: player)
                        .background(.black)
                        .clipShape(.rect(cornerRadius: 25))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                show = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.bar)
                            }
                            .padding(10)
                        }
                } else {
                    RoundedRectangle(cornerRadius: 25)
                        .overlay {
                            Text("Video URL Not Found")
                                .foregroundStyle(.background)
                        }
                }
            }
            .frame(height: 250)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation + lastStoredOffset
                        offset = translation
                    }.onEnded { value in
                        withAnimation(.bouncy) {
                            /// Limiting to not move away from the screen
                            offset.width = 0
                            
                            if offset.height < 0 {
                                offset.height = 0
                            }
                            
                            if offset.height > (size.height - 250) {
                                offset.height = (size.height - 250)
                            }
                        }
                        
                        lastStoredOffset = offset
                    }
            )
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, 15)
        .transition(.blurReplace)
        .onAppear {
            if let videoURL {
                player = AVPlayer(url: videoURL)
                player?.play()
            }
        }
    }
    
    var videoURL: URL? {
        if let bundle = Bundle.main.path(forResource: "Area", ofType: "mp4") {
            return .init(filePath: bundle)
        }
        
        return nil
    }
}

struct FloatingActionButton: View {
    @Binding var show: Bool
    @State private var expand: Bool = false
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                if expand {
                    ActionButton("camera.fill")
                    ActionButton("video.fill")
                    ActionButton("microphone.fill")
                    ActionButton("photo.stack")
                }
            }
            
            Image(systemName: !expand ? "plus" : "xmark")
                .font(.title3)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 45, height: 45)
                .background(.blue.gradient, in: .circle)
                .contentShape(.circle)
                .onTapGesture {
                    withAnimation(.bouncy) {
                        expand.toggle()
                    }
                }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(15)
        .transition(.blurReplace)
    }
    
    @ViewBuilder
    func ActionButton(_ icon: String) -> some View {
        Button {
        } label: {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 45, height: 45)
                .background(.red.gradient, in: .circle)
                .contentShape(.rect)
        }
        .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
    }
}

extension CGSize {
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        return .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

#Preview {
    RootView {
        ContentView()
    }
}

