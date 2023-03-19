//
//  BuildMenu.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 14/03/2023.
//

import SwiftUI

struct BuildMenu: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var subMenuState: GUI.SubMenuState
    
    var body: some View {
        ScrollView() {
            ForEach(viewModel.buildJobGoals, id: \.jobGoal.description) { jobGoalAvailable in
                Button(action: {
                    print("\(jobGoalAvailable.jobGoal) clicked")
                    viewModel.currentJobGoal = jobGoalAvailable.jobGoal
                    subMenuState = .none
                }, label: {
                    Text(jobGoalAvailable.jobGoal.description)
                }).disabled(jobGoalAvailable.available == false)
            }
        }.frame(height: 100, alignment: .leading)
    }
}

struct BuildMenu_Previews: PreviewProvider {
    static var previews: some View {
        BuildMenu(viewModel: ViewModel(), subMenuState: .constant(.build))
    }
}
