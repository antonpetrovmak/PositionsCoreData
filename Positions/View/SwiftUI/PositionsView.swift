//
//  PositionsView.swift
//  Positions
//
//  Created by Petrov Anton on 24.01.2023.
//

import SwiftUI
import CoreData

struct PositionsView: View {
    let positionsUseCase: PositionsUseCase
    
    // MARK: - Private Properties
    @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .reverse)])
    private var positions: FetchedResults<Position>
    @State private var isLoading: Bool = false
    @State private var isDeleting: Bool = false
    @State private var searching: String = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(positions, id: \.code) { position in
                    PositionView(position: position)
                        .padding(.horizontal, 20)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Positions \(positions.count)")
        .navigationBarTitleDisplayMode(.automatic)
        .clipped()
        .searchable(text: $searching)
        .onChange(of: searching) { newValue in
            positions.nsPredicate = newValue.isEmpty
            ? nil
            : NSPredicate(format: "canonicalPlace CONTAINS[c] %@", newValue)
        }
        .edgesIgnoringSafeArea(.bottom)
        .toolbar(content: toolbarContent)
        
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        if let firstPosition = positions.first {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("-r first") {
                    positionsUseCase.deletePosition(by: [firstPosition.objectID])
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                isDeleting = true
                Task {
                    try await positionsUseCase.deletePosition(positions.map { $0 })
                    isDeleting = false
                }
            } label: {
                if isDeleting {
                    ProgressView().progressViewStyle(.circular)
                } else {
                    Image(systemName: "trash")
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                isLoading = true
                Task {
                    try await positionsUseCase.uploadPositions()
                    isLoading = false
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Image(systemName: "arrow.2.squarepath")
                }
            }
        }
    }
    
}

private struct PositionsUseCaseStab: PositionsUseCase {
    func uploadPositions() async throws {
        
    }
    
    func deletePosition(by itemIds: [NSManagedObjectID]) {
        
    }
    
    func deletePosition(_ items: [Position]) async throws {
        
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PositionsView(positionsUseCase: PositionsUseCaseStab())
            .environment(\.managedObjectContext, AppPersistenceController.preview.container.viewContext)
    }
}
