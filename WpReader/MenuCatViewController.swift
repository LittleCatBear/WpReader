//
//  MenuCatViewController.swift
//  WpReader
//
//  Created by Julie Huguet on 20/03/2015.
//  Copyright (c) 2015 Shokunin-Software. All rights reserved.
//


import Foundation
import UIKit
import CoreData



class MenuCatViewController : UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var cats:[Categories] = [Categories]()
    var master:MasterViewController? = nil
    
    @IBOutlet var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context: NSManagedObjectContext = appDel.managedObjectContext!
        managedObjectContext = context
        self.getAllCategories(context)
        self.getMenu(context)
    }
    
     override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cats.count
    }
        
    func getAllCategories(context:NSManagedObjectContext){
            let urlPath = "https://public-api.wordpress.com/rest/v1.1/sites/catsparadize.com/categories"
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                
                if (error != nil) { //change 'error' to '(error != nil)'
                    println(error)
                } else {
                    
                    var request = NSFetchRequest(entityName: "Categories")
                    request.returnsObjectsAsFaults = false
                    var results = context.executeFetchRequest(request, error: nil)!
                    
                    for result in results {
                        
                        context.deleteObject(result as NSManagedObject)
                        context.save(nil)
                        
                    }
                    
                    let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                    
                    var categories = [[String:String]()]
                    var category:AnyObject
                    var newCat:NSManagedObject
                    
                    for var i = 0; i < jsonResult["categories"]!.count; i++ {
                        categories.append([String:String]())
                        
                        category = jsonResult["categories"]![i] as NSDictionary
                        if category["post_count"] as NSInteger > 0{
                            newCat = NSEntityDescription.insertNewObjectForEntityForName("Categories", inManagedObjectContext: context) as NSManagedObject
                            
                            newCat.setValue(category["name"] as? String, forKey: "name")
                            newCat.setValue(category["description"] as? String, forKey: "desc")
                            newCat.setValue(category["ID"] as? NSInteger, forKey: "id")
                            context.save(nil)
                        }
                        
                    }
                }
            })
            
            task.resume()
        }
    
    func getMenu(context:NSManagedObjectContext){
        
        var request = NSFetchRequest(entityName: "Categories")
        request.returnsObjectsAsFaults = false
        var results = context.executeFetchRequest(request, error: nil)! as [Categories]
        self.cats = results
      //  tableView.insertRowsAtIndexPaths(<#indexPaths: [AnyObject]#>, withRowAnimation: <#UITableViewRowAnimation#>)
        // menuSegmentedControl.removeAllSegments()
        //for (var i = 0; i < cats.count ; i++){
        //  menuSegmentedControl.insertSegmentWithTitle(cats[i].name, atIndex: i, animated: true)
        // }
    }

        

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = cats[indexPath.row].name
        cell.detailTextLabel!.text = cats[indexPath.row].desc
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
      nameCat = object.valueForKey("name")!.description
       self.performSegueWithIdentifier("goToRoot", sender: self)
       // println(nameCat)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }

    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            
            // Update - changed indexPath to indexPath!
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            
            // Changed indexPath to indexPath!
            
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)  //append '!' after (indexPath) in order to convert optional to non-optional
        case .Move:
            
            // Update - changed indexPath to indexPath!
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
            // Update - changed newIndexPath to newIndexPath!
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
   
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Categories", inManagedObjectContext: self.managedObjectContext!)  //append '!' after managedObjectContext in order to convert optional to non-optional
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
}


