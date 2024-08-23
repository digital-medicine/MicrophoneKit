//
//  SwiftUIView.swift
//
//
//  Created by Leonard Pries on 23.08.24.
//

import SwiftUI

struct AudioWaveView: View {
    @Binding var viewModel: AudioWaveViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: viewModel.barSpacing) {
                ForEach(Array(viewModel.paddedHeights().enumerated()), id: \.offset) { index, height in
                    Rectangle()
                        .fill(Color(red: 110 / 255, green: 186 / 255, blue: 180 / 255))
                        .frame(width: viewModel.barWidth, height: geometry.size.height * min(height / 0.05 , 1))
                        .cornerRadius(viewModel.barWidth)
                }
            }
            .onChange(of: geometry.size.width) { old, new in
                viewModel.updateMaxBars(width: new)
            }
            .onAppear(perform: {
                viewModel.updateMaxBars(width: geometry.size.width)
            })
            .frame(maxHeight: .infinity)
        }
        .padding()
        .background(Color(red: 245/255, green: 246/255, blue: 235/255))
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
    
}

@Observable class AudioWaveViewModel {
    var numbers: [Double] = []
    var maxBars: Int = 0
    let barWidth: Double = 10.0
    let barSpacing: Double = 6.0
    
    func paddedHeights() -> [Double] {
        let paddedArray = Array(repeating: 0, count: max(maxBars - numbers.count, 0)) + numbers
        return paddedArray
    }
    
    public func addNumber(_ newNumber: Double) {
        if numbers.count >= maxBars {
            numbers.removeFirst()
        }
        numbers.append(newNumber)
    }
    
    func updateMaxBars(width: CGFloat) {
        maxBars = Int(width / (barWidth + barSpacing))
    }
}
