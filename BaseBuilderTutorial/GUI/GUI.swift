//
//  GUI.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 27/02/2023.
//

import SwiftUI

struct GUI: View {
    enum SubMenuState {
        case none
        case build
    }
    
    @ObservedObject var viewModel: ViewModel
    
    @State var subMenuState = SubMenuState.none
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if viewModel.selectedEntity !=  nil  {
                    EntityView(viewModel: viewModel)
                }
            }
            Spacer()
            
            HStack {
                if subMenuState == .build {
                    BuildMenu(viewModel: viewModel, subMenuState: $subMenuState)
                }
                Spacer()
            }
            .padding()
            .background(Color.gray.blendMode(BlendMode.darken))
            
            HStack {
                Button(action: {
                    print("BuildMenu clicked")
                    subMenuState = .build
                }, label: {
                    Text("Build")
                }).disabled(subMenuState == .build)
                Spacer()
            }
            .padding()
            .background(Color.gray.blendMode(BlendMode.darken))
            
            HStack {
                if let coord = viewModel.hoverCoord {
                    Text("(\(coord.x),\(coord.y))").padding(.horizontal)
                        .foregroundColor(.white)
                }
                if let tile = viewModel.hoverTile {
                    Text("\(tile.rawValue)").padding(.horizontal)
                        .foregroundColor(.white)
                }
                if let entity = viewModel.hoverEntity {
                    Text("\(entity.name)").padding(.horizontal)
                        .foregroundColor(.white)
                }
                if let itemStack = viewModel.hoverItems {
                    Text("\(itemStack.item.name): \(itemStack.amount)").padding(.horizontal)
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
