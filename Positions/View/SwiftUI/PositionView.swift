//
//  PositionView.swift
//  Positions
//
//  Created by Petrov Anton on 25.01.2023.
//

import SwiftUI

struct PositionView: View {
    
    let position: Position
    
    var body: some View {
        HStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.black.opacity(0.1))
                .frame(width: 80, height: 60)
                .overlay {
                    Text("\(position.magnitude.formatted(.number.precision(.fractionLength(1))))")
                        .font(.title)
                        .bold()
                        .foregroundStyle(position.color)
                }
            VStack(alignment: .leading) {
                Text(position.place)
                    .font(.title3)
                Text("\(position.time.formatted(.relative(presentation: .named)))")
                    .foregroundStyle(.secondary)
                HStack { Spacer() }
            }
        }
        .padding(.vertical, 8)
    }
    
}

struct PositionView_Previews: PreviewProvider {
    static var previews: some View {
        PositionView(position: Position.previewInstance)
    }
}
