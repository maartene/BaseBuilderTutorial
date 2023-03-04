//
//  EntityView.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 04/03/2023.
//

import SwiftUI

struct EntityView: View {
    @ObservedObject var viewModel: ViewModel

    var entity: Entity {
        viewModel.selectedEntity ?? Entity(name: "Dummy", position: .zero)
    }
    
    var currentJobDescription: String {
        entity.jobs.peek()?.description ?? "Idling"
    }
    
    var inventory: String {
        var result = ""
        for itemStack in entity.inventory {
            result += "\(itemStack.value) \(itemStack.key.name) \n"
        }
        return result
    }
    
    var body: some View {
        VStack {
            Text(entity.name)
            Text(currentJobDescription)
            Text(inventory)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.gray.blendMode(.darken))
    }
}

struct EntityView_Previews: PreviewProvider {
    static var previews: some View {
        EntityView(viewModel: ViewModel())
    }
}
