//
//  GridViewController.swift
//  Rotten Tomatos
//
//  Created by Nguyễn Vương Anh Vỹ on 8/31/15.
//  Copyright (c) 2015 Nguyễn Vương Anh Vỹ. All rights reserved.
//

import UIKit
import AFNetworking
import JTProgressHUD



class GridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    var movies : [NSDictionary]!
    var filteredMovies: [NSDictionary]? = []
    var refreshControl : UIRefreshControl!
    @IBOutlet weak var gridView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var alertBar: UIView!
    @IBOutlet weak var netStatus: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        JTProgressHUD.show()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        
        gridView.addSubview(refreshControl)
        // Get data here 
        
        let url = NSURL (string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")!
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
                    
                    self.gridView.reloadData()
                    self.delay(1, closure: {JTProgressHUD.hide()})
                    
                }
                
            }
        }
        
        gridView.dataSource = self
        gridView.delegate = self
        searchBar.delegate = self
        

        
        
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if filteredMovies!.count == 0 {
            // show empty cell
            return 1
        } else {
            return filteredMovies!.count
        }

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if filteredMovies!.count == 0 {
            // return our new cell here
            var cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieGrid", forIndexPath: indexPath) as! GridCollectionViewCell
            //cell.textLabel?.text = "No Results Found"
            //cell.textLabel?.textAlignment = NSTextAlignment.Center
            return cell
        }
        else
        {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieGrid", forIndexPath: indexPath) as! GridCollectionViewCell
            
        var movie = filteredMovies![indexPath.row]
            
        cell.titleLabel.text = movie["title"] as? String
        //let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String )!
            
            
            let low_res_url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String )!
            cell.posterView.setImageWithURL(low_res_url)
            var link = movie.valueForKeyPath("posters.thumbnail") as! String
            var range = link.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
            link = link.stringByReplacingCharactersInRange(range!, withString: "https://content6.flixster.com/")
            var high_res_url = NSURL(string: link)!
        cell.posterView.setImageWithURL(high_res_url)
        let options = UIViewAnimationOptions.CurveEaseInOut
        cell.posterView.alpha = 0.0
        UIView.animateWithDuration(0.7, delay: 1, options: options, animations: {cell.posterView.alpha = 1}, completion: nil)
        cell.posterView.layer.cornerRadius = 3
        cell.posterView.clipsToBounds = true
        return cell
        }
        
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailsSegue2" {
            let cell = sender as! UICollectionViewCell
            let indexPath = gridView.indexPathForCell(cell)!
            let movie = filteredMovies![indexPath.row]
            let moviesDetailsViewController = segue.destinationViewController as! MoviesDetailsViewController
            moviesDetailsViewController.movie = movie
        }
        
        
    }


    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.filteredMovies = self.movies
            //self.gridView.reloadSections(NSIndexSet(index:0), withRowAnimation: UITableViewRowAnimation.Bottom)
            self.gridView.reloadData()
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
            
            //self.gridView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
            self.gridView.reloadData()
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
