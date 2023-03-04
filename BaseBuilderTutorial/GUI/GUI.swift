//
//  GUI.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 27/02/2023.
//

import SwiftUI

struct GUI: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                if let coord = viewModel.hoverCoord {
                    Text("(\(coord.x),\(coord.y))").padding(.horizontal)
                        .foregroundColor(.white)
                }
                if let tile = viewModel.hoverTile {
                    Text("\(tile.rawValue)").padding(.horizontal)
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
    }
}

struct GUI_Previews: PreviewProvider {
    static var previews: some View {
        GUI(viewModel: ViewModel())
    }
}
