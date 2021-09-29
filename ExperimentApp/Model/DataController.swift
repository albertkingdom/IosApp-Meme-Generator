//
//  DataController.swift
//  ExperimentApp
//
//  Created by Albert Lin on 2021/9/27.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    /// load model
    func load(completion: (() -> Void)? = nil){
        persistentContainer
            .loadPersistentStores(completionHandler: { storeDescription, error in
                guard error == nil else {
                    fatalError(error!.localizedDescription)
                }
               
                
                completion?()
            })
    }
}
