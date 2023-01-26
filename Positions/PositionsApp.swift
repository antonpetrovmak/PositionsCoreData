//
//  PositionsApp.swift
//  Positions
//
//  Created by Petrov Anton on 24.01.2023.
//

import SwiftUI

@main
struct PositionsApp: App {
    private let persistenceController: PersistenceController = AppPersistenceController.shared
    private let networkManager: NetworkManager = NetworkManager.shared
    
    @State var isPresented = false
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    swiftUIPositionsView()
                }
                .tabItem {
                    Label("SwiftUI", systemImage: "swift")
                }
                NavigationView {
                    uiKitPositionsView()
                }.tabItem {
                    Label("UIKit", systemImage: "photo.artframe")
                }
            }
        }
    }
    
    private func swiftUIPositionsView() -> some View {
        return PositionsView(positionsUseCase: getPositionsUseCase())
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
    
    private func uiKitPositionsView() -> some View {
        return PositionsControllerView(
            positionsUseCase: getPositionsUseCase(),
            context: persistenceController.container.viewContext
        )
    }
    
    private func getPositionsUseCase() -> PositionsUseCase {
        return PositionsUseCaseImpl(
            positionsRepository: PositionsRepositoryImpl(persistenceController: persistenceController),
            positionsProvider: PositionsProviderImpl(networkManager: networkManager)
        )
    }
}
