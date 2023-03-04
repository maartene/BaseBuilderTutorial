//
//  ViewModel.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 27/02/2023.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    weak var world: World?
    
    @Published var hoverCoord: Vector?
    @Published var hoverTile: Tile?
    @Published var hoverEntity: Entity?
    @Published var hoverItems: ItemStack?
    
    @Published var selectedEntity: Entity?
}
