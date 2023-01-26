//
//  PositionsViewController.swift
//  Positions
//
//  Created by Petrov Anton on 26.01.2023.
//

import UIKit
import SwiftUI
import CoreData

final class PositionsViewController: UITableViewController {
    
    var positionsUseCase: PositionsUseCase!
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        title = "Positions"
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Position> = {
        let fetchRequest = Position.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Position.Keys.time, ascending: false)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            print("🛑 Fetch for PositionsViewController \(error.localizedDescription)")
        }
        
        return controller
    }()
    
    // MARK: - IBActions
    @IBAction func onReload(_ sender: Any) {
        Task {
            try await positionsUseCase.uploadPositions()
        }
    }
    
    @IBAction func onRemoveAll(_ sender: Any) {
        guard let positions = fetchedResultsController.fetchedObjects, !positions.isEmpty else { return }
        Task {
            try await positionsUseCase.deletePosition(positions)
        }
        
    }
    
    @IBAction func onRemoveFirst(_ sender: Any) {
        guard let firstPosition = fetchedResultsController.fetchedObjects?.first else { return }
        positionsUseCase.deletePosition(by: [firstPosition.objectID])
    }
}

// MARK: -
extension PositionsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PositionCell", for: indexPath) as? PositionCell else {
            fatalError("###\(#function): Failed to dequeue a PositionCell. Check the cell reusable identifier in Main.storyboard.")
        }
        let position = fetchedResultsController.object(at: indexPath)
        
        cell.code.text = position.code
        cell.place.text = position.place
        cell.date.text = "\(position.time.formatted(.relative(presentation: .named)))"
        cell.score.text = "\(position.magnitude.formatted(.number.precision(.fractionLength(1))))"
        cell.score.textColor = position.color.cgColor.flatMap { UIColor(cgColor: $0) } ?? .black
        
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension PositionsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let predicate: NSPredicate
        if let userInput = searchController.searchBar.text, !userInput.isEmpty {
            predicate = NSPredicate(format: "canonicalPlace CONTAINS[c] %@", userInput)
        } else {
            predicate = NSPredicate(value: true)
        }

        fetchedResultsController.fetchRequest.predicate = predicate
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("###\(#function): Failed to performFetch: \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension PositionsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

// MARK: - Representation for SwiftUI
struct PositionsControllerView: UIViewControllerRepresentable {
    
    let positionsUseCase: PositionsUseCase
    let context: NSManagedObjectContext
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let storyboard = UIStoryboard(name: "PositionsViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PositionsViewController") as! PositionsViewController
        vc.positionsUseCase = positionsUseCase
        vc.context = self.context
        return UINavigationController(rootViewController: vc)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
