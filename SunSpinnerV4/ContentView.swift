//
//  ContentView.swift
//  SunSpinnerV4
//
//  Created by iKame Elite Fresher 2025 on 5/9/25.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var winner: String?
    
    // Define segments for the wheel - exactly matching the image
    let segments = [
        Segment(text: "20%", isBlack: false),
        Segment(text: "30%", isBlack: true),
        Segment(text: "No luck", isBlack: false),
        Segment(text: "50%", isBlack: true),
        Segment(text: "60%", isBlack: false),
        Segment(text: "70%", isBlack: true),
        Segment(text: "80%", isBlack: false),
        Segment(text: "", isBlack: true, hasGiftIcon: true)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all)
            
            VStack {
                // Title
                Text("Spin to Win")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // Wheel with pointer
                ZStack {
                    // Pointer (triangle)
                    //                    Triangle()
                    //                        .frame(width: 30, height: 40)
                    //                        .foregroundColor(.black)
                    //                        .offset(y: -205)
                    //                        .zIndex(2)
                    Image(.icArrow)
                        .frame(width: 30, height: 40)
                        .foregroundColor(.black)
                        .offset(y: -190)
                        .zIndex(2)
                    
                    
                    // Outer gray border circle with visible gradient
                    Circle()
                        .stroke(RadialGradient(
                            colors: [.black, .gray],
                            center: .center,
                            startRadius: 190,  // Inner radius of the gradient
                            endRadius: 200     // Outer radius of the gradient
                        ), lineWidth: 30)
                        
                        .frame(width: 400, height: 400)
                    
                    
                    // Inner black border
                    Circle()
                        .stroke(Color.black, lineWidth: 12)
                        .frame(width: 370, height: 370)
                    
                    // Wheel with segments
                    ZStack {
                        ForEach(0..<segments.count, id: \.self) { index in
                            WheelSegment(
                                startAngle: .degrees(Double(index) * (360.0 / Double(segments.count))),
                                endAngle: .degrees(Double(index + 1) * (360.0 / Double(segments.count))),
                                segment: segments[index]
                            )
                        }
                    }
                    .frame(width: 360, height: 360)
                    .rotationEffect(.degrees(rotation))
                    .animation(isSpinning ? Animation.easeOut(duration: 2).delay(0.1) : .default, value: rotation)
                    
                    // Center circle with Apple logo
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .stroke(RadialGradient(
                                gradient: Gradient(colors: [.gray, .gray.opacity(0.5)]),
                                center: .center,
                                startRadius: 40,
                                endRadius: 35
                            ), lineWidth: 5)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "applelogo")
                            .resizable()
                        
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    .zIndex(1)
                }
                .frame(width: 400, height: 400)
                .padding()
                
                // Spin button
                Button(action: spinWheel) {
                    Text("SPIN")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 15)
                        .background(isSpinning ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .padding(.top, 30)
                .disabled(isSpinning)
                // Winner display
                if let winner = winner {
                    Text("You won: \(winner)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding()
                }
                Spacer()
            }
        }
    }
    
    func spinWheel() {
        isSpinning = true
        winner = nil
        let randomRotation = Double.random(in: 720...1080) // Spin at least 2-3 times
        rotation += randomRotation
        
        // Calculate which segment wins after spinning
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let winningSegmentIndex = Int(floor(rotation.truncatingRemainder(dividingBy: 360) / (360 / Double(segments.count))))
            let normalizedIndex = segments.count - 1 - winningSegmentIndex
            let actualIndex = normalizedIndex % segments.count
            
            if segments[actualIndex].hasGiftIcon {
                winner = "Gift"
            } else {
                winner = segments[actualIndex].text
            }
            
            isSpinning = false
        }
    }
}

// Shape for the pointer triangle
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

// Model for wheel segments
struct Segment {
    let text: String
    let isBlack: Bool
    var hasGiftIcon: Bool = false
}

// Custom wheel segment shape
struct WheelSegment: View {
    let startAngle: Angle
    let endAngle: Angle
    let segment: Segment
    
    var body: some View {
        ZStack {
            // Segment shape
            Path { path in
                path.move(to: CGPoint(x: 180, y: 180))
                path.addArc(center: CGPoint(x: 180, y: 180),
                            radius: 180,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false)
                path.closeSubpath()
            }
            .fill(segment.isBlack ? Color.black : Color.white)
            //            .overlay(
            //                Path { path in
            //                    path.move(to: CGPoint(x: 180, y: 180))
            //                    path.addArc(center: CGPoint(x: 180, y: 180),
            //                               radius: 180,
            //                               startAngle: startAngle,
            //                               endAngle: endAngle,
            //                               clockwise: false)
            //                    path.closeSubpath()
            //                }
            //                .stroke(Color.black, lineWidth: 1)
            //            )
            
            // Text or icon
            Group {
                if segment.hasGiftIcon {
                    Image(systemName: "gift.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(segment.isBlack ? .white : .black)
                } else {
                    Text(segment.text)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(segment.isBlack ? .white : .black)
                        .padding(.leading,30)
                }
            }
            .offset(x: 90)
            .rotationEffect(Angle(degrees: Double(startAngle.degrees + endAngle.degrees) / 2))
        }
    }
}

#Preview {
    ContentView()
}
