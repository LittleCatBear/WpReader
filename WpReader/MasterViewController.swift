//
//  MasterViewController.swift
//  test2
//
//  Created by Rob Percival on 14/08/2014.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit
import CoreData
import Foundation

var activeItem:String = "Welcome to Cats Paradize!"
var activePostTitle:String = "Cats paradize"
var nameCat:String = ""

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var postsToDisplay:[Posts] = [Posts]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("cat name: \(nameCat)")
        var appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context: NSManagedObjectContext = appDel.managedObjectContext!
        managedObjectContext = context
        if (nameCat == ""){
            self.getAllPosts(context)
        } else{
            self.getPostsForCat(context)
        }
        
     //   self.getPostsTab(context)
       // println(postsToDisplay)
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.tableView.reloadData()
    }
    
    func getAllPosts(context: NSManagedObjectContext){
        let urlPath = "https://public-api.wordpress.com/rest/v1.1/sites/catsparadize.com/posts"
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if (error != nil) { //change 'error' to '(error != nil)'
                println(error)
            } else {
                
                var request = NSFetchRequest(entityName: "Posts")
                request.returnsObjectsAsFaults = false
                var results = context.executeFetchRequest(request, error: nil)!
                
                for result in results {
                    context.deleteObject(result as NSManagedObject)
                    context.save(nil)
                    
                }
                
                let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                var posts = [[String:String]()]
                var post:AnyObject
                var authorDictionary:AnyObject
                var newBlogPost:NSManagedObject
                
                for var i = 0; i < jsonResult["posts"]!.count; i++ {
                    posts.append([String:String]())
                    
                    post = jsonResult["posts"]![i] as NSDictionary
                    authorDictionary = post["author"] as NSDictionary
                    
                    newBlogPost = NSEntityDescription.insertNewObjectForEntityForName("Posts", inManagedObjectContext: context) as NSManagedObject
                    
                    newBlogPost.setValue(authorDictionary["name"] as? String, forKey: "author")
                    newBlogPost.setValue(post["title"] as? String, forKey: "title")
                    newBlogPost.setValue(post["content"] as? String, forKey: "content")
                    newBlogPost.setValue(post["modified"] as? String, forKey: "publishedDate")
                    context.save(nil)
                    
                }
            }
            self.getPostsTab(context)
        })
        
        task.resume()
    }
    
    func getPostsForCat(context: NSManagedObjectContext){
            var urlPath = "https://public-api.wordpress.com/rest/v1.1/sites/catsparadize.com/posts?category=\(nameCat)"

            var url2 = urlPath.stringByReplacingOccurrencesOfString(" ", withString: "-")

            let url = NSURL(string: url2)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
                if (error != nil) { //change 'error' to '(error != nil)'
                    println(error)
                } else {
                
                    var request = NSFetchRequest(entityName: "Posts")
                    request.returnsObjectsAsFaults = false
                    var results = context.executeFetchRequest(request, error: nil)!
                
                    for result in results {
                        context.deleteObject(result as NSManagedObject)
                         context.save(nil)
                    }
                    let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                    var posts = [[String:String]()]
                    var post:AnyObject
                    var authorDictionary:AnyObject
                    var newBlogPost:NSManagedObject
                
                    for var i = 0; i < jsonResult["posts"]!.count; i++ {
                        posts.append([String:String]())
                    
                        post = jsonResult["posts"]![i] as NSDictionary
                        authorDictionary = post["author"] as NSDictionary
                    
                        newBlogPost = NSEntityDescription.insertNewObjectForEntityForName("Posts", inManagedObjectContext: context) as NSManagedObject
                    
                        newBlogPost.setValue(authorDictionary["name"] as? String, forKey: "author")
                        newBlogPost.setValue(post["title"] as? String, forKey: "title")
                        newBlogPost.setValue(post["content"] as? String, forKey: "content")
                        newBlogPost.setValue(post["modified"] as? String, forKey: "publishedDate")
                        context.save(nil)
                    }
                }
                self.getPostsTab(context)
            })
        task.resume()
    }
    
    func getPostsTab(context: NSManagedObjectContext){
        println("get posts array")
       var request = NSFetchRequest(entityName: "Posts")
        request.returnsObjectsAsFaults = false
        var res = context.executeFetchRequest(request, error: nil)! as [Posts]
        println(res)
        self.postsToDisplay = res
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
            
            activeItem = object.valueForKey("content")!.description
            let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
            
            controller.navigationItem.leftBarButtonItem = self.splitViewController!.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        } else if segue.identifier == "menuNavigation"{
          
            
            let toViewController = (segue.destinationViewController as MenuCatViewController)
            toViewController.managedObjectContext = self.managedObjectContext
          //  toViewController.master = self
           // self.modalPresentationStyle = UIModalPresentationStyle.Custom
            //toViewController.transitioningDelegate = transitionOperator
        }
    }
    
    // MARK: - Table View
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsToDisplay.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.text = postsToDisplay[indexPath.row].title
        cell.detailTextLabel!.text = postsToDisplay[indexPath.row].author
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
           return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Posts", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "publishedDate", ascending: false)
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
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
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
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
               self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
   
    @IBAction func goToRoot(segue:UIStoryboardSegue){
        NSLog("Called goToRoot: unwind action")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        var appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context: NSManagedObjectContext = appDel.managedObjectContext!
        if (nameCat == ""){
            self.getAllPosts(context)
        } else{
            self.getPostsForCat(context)
        }
    }
    
}