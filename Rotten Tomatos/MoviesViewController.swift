//
//  MoviesViewController.swift
//  Rotten Tomatos
//
//  Created by Nguyễn Vương Anh Vỹ on 8/28/15.
//  Copyright (c) 2015 Nguyễn Vương Anh Vỹ. All rights reserved.
//

import UIKit
import AFNetworking
import JTProgressHUD



class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    var refreshControl : UIRefreshControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var alertBar: UIView!
    @IBOutlet weak var netStatus: UILabel!
    var movies: [NSDictionary]?
    
    var filteredMovies: [NSDictionary]? = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        JTProgressHUD.show()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.addSubview(refreshControl)
        
        let url = NSURL (string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
        let request = NSURLRequest (URL: url)
        var response: NSURLResponse?
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()){ (respone: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if data == nil {
                println("ERROR!! :(")
                self.delay(0.3, closure: {JTProgressHUD.hide()})
                let xPosition = self.alertBar.frame.origin.x
                let yPosition = self.alertBar.frame.origin.y + 65
                //let height = 45
                //let width = 320
                UIView.animateWithDuration(1.2, animations: {
                    
                    self.alertBar.frame = CGRectMake(xPosition, yPosition, 320, 45)
                    
                })
                self.netStatus.text = "Please check your Network"
                //show error
            } else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.filteredMovies = self.movies
                    
                    self.tableView.reloadData()
                    self.delay(1, closure: {JTProgressHUD.hide()})
                    
                }
                
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        // Do any additional setup after loading the view.
        
        // Add Style to tab bar
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredMovies!.count == 0 {
            // show empty cell
            return 1
        } else {
            return filteredMovies!.count
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if filteredMovies!.count == 0 {
            // return our new cell here
            var cell = UITableViewCell()
            cell.textLabel?.text = "No Results Found"
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MoviesCell
            
            let movie = filteredMovies![indexPath.row]
  
            cell.titleLabel.text = movie ["title"] as? String
            cell.descLabel.text = movie ["synopsis"] as? String
            cell.mpaaLabel.text = movie ["mpaa_rating"] as? String
            let rating  = movie.valueForKeyPath("ratings.critics_score") as! Int
            cell.ratingLabel.text = "Rating: \(rating)"
            let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String )!
            let options = UIViewAnimationOptions.CurveEaseInOut
            cell.postersView.setImageWithURL(url)
            
            //Animation for displaying thumbnail
            cell.postersView.alpha = 0.0
            UIView.animateWithDuration(0.7, delay: 1, options: options, animations: {cell.postersView.alpha = 1}, completion: nil)
            
            
            // Customize style for cell
            cell.postersView.layer.cornerRadius = 3
            cell.postersView.layer.borderColor = UIColor(white: 1, alpha: 1).CGColor
            cell.postersView.layer.borderWidth = 2
            cell.mpaaLabel.layer.borderWidth = 1
            cell.mpaaLabel.layer.borderColor = UIColor (white: 1, alpha: 1).CGColor
            cell.mpaaLabel.textAlignment = NSTextAlignment.Center
            cell.postersView.clipsToBounds = true
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
        // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailsSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let movie = filteredMovies![indexPath.row]
            let moviesDetailsViewController = segue.destinationViewController as! MoviesDetailsViewController
            moviesDetailsViewController.movie = movie
        }
        if segue.identifier == "gridSegue" {
            
        }
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.filteredMovies = self.movies
            self.tableView.reloadSections(NSIndexSet(index:0), withRowAnimation: UITableViewRowAnimation.Bottom)
        }
        else
        {
        self.filteredMovies = []
        
        for movie: NSDictionary in movies!  {
            let title = movie["title"] as! String
            if movie["title"]?.rangeOfString(searchText).length != 0 {
                self.filteredMovies?.append(movie)
            }

        }

        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    // Behavior for searchBar cancel button 
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        
    }

}
