//
//  Item.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/01/2023.
//

import Foundation

struct Item {
    let name: String
    let sprite: String
    let preferredPickupStackSize: Int
    
    init(name: String, sprite: String? = nil, preferredPickupStackSize: Int = 10) {
        self.name = name
        self.sprite = sprite ?? name
        self.preferredPickupStackSize = preferredPickupStackSize
    }
}

extension Item: Hashable { }
