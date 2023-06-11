//
//  GameContent.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 14/03/2023.
//

import Foundation

extension Item {
    static var woodenBlocks: Item {
        Item(name: "Wooden Blocks")
    }
    
    static var food: Item {
        Item(name: "Food")
    }
    
    static var cookedMeal: Item {
        Item(name: "Cooked Meal")
    }
}

extension Object {
    static var kitchenCounter: Object {
        Object(name: "Kitchen Counter", size: Vector(x: 3, y: 1), installTime: 5, allowedTiles: [.Floor])
    }
}

extension Recipe {
    static var cookRecipe: Recipe {
        Recipe(object: .kitchenCounter, requiredItems: [ItemStack(item: .food, amount: 1)], resultingItem: ItemStack(item: .cookedMeal, amount: 1), maxJobs: 1)
    }
    
    static var allRecipes: [Recipe] {
        [
            .cookRecipe
        ]
    }
}
