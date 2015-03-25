//
//  DetailViewController.swift
//  Blog Reader
//
//  Created by Rob Percival on 14/08/2014.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var labelItem: UINavigationItem!
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        webView.loadHTMLString(activeItem, baseURL: nil)
        self.labelItem.title = activePostTitle

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configureView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

