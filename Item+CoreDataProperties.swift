//
//  Item+CoreDataProperties.swift
//  Core-Data
//
//  Created by Rajesh Kumar on 30/08/22.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var done: Bool
    @NSManaged public var title: String?
    @NSManaged public var parentCategory: Category?

}

extension Item : Identifiable {

}
