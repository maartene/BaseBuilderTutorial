//
//  InstallObjectMenu.swift
//  BaseBuilderTutorial
//
//  Created by Maarten Engels on 10/07/2023.
//

import SwiftUI

struct InstallObjectMenu: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var subMenuState: GUI.SubMenuState
    
    var body: some View {
        ScrollView() {
            ForEach(viewModel.installObjectJobGoals, id: \.jobGoal.description) { jobGoalAvailable in
                Button(action: {
                    logger.info("\(jobGoalAvailable.jobGoal) clicked")
                    viewModel.selectionModus = .selectSingle
                    viewModel.currentIntendedAction = .scheduleJob(jobGoalAvailable.jobGoal)
                    subMenuState = .none
                }, label: {
                    Text(jobGoalAvailable.jobGoal.description)
                }).disabled(jobGoalAvailable.available == false)
            }
        }.frame(height: 100, alignment: .leading)
    }
}

struct InstallObjectMenu_Previews: PreviewProvider {
    static var previews: some View {
        InstallObjectMenu(viewModel: ViewModel(), subMenuState: .constant(.installObject))
    }
}
