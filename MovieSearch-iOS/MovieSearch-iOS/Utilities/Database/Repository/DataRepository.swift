//
//  DataRepository.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 27/03/23.
//

import CoreData

protocol DataRepositoryProvider {
    var viewContext: NSManagedObjectContext { get }
    func backgroundContext() -> NSManagedObjectContext
}

class DataRepository: DataRepositoryProvider {
    
    static var shared: DataRepository = .init()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }
    
    private init() {}
}
