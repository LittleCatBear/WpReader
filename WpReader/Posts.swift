//
//  Posts.swift
//  WpReader
//
//  Created by Julie Huguet on 18/03/2015.
//  Copyright (c) 2015 Shokunin-Software. All rights reserved.
//

import Foundation
import CoreData

@objc(Posts)
class Posts: NSManagedObject {

    @NSManaged var author: String
    @NSManaged var title: String
    @NSManaged var content: String
    @NSManaged var publishedDate: String

}
