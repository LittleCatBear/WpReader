//
//  Categories.swift
//  WpReader
//
//  Created by Julie Huguet on 18/03/2015.
//  Copyright (c) 2015 Shokunin-Software. All rights reserved.
//

import Foundation
import CoreData

@objc(Categories)
class Categories: NSManagedObject {

    @NSManaged dynamic var name: String
    @NSManaged dynamic var desc: String
    @NSManaged dynamic var id: NSNumber

}
