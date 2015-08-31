//
//  MoviesDetailsViewController.swift
//  Rotten Tomatos
//
//  Created by Nguyễn Vương Anh Vỹ on 8/29/15.
//  Copyright (c) 2015 Nguyễn Vương Anh Vỹ. All rights reserved.
//

import UIKit
import AFNetworking
import JTProgressHUD

class MoviesDetailsViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = movie["title"] as? String
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        synopsisLabel.textAlignment = .Justified
        let low_res_url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String )!
        backgroundView.setImageWithURL(low_res_url)
        
        var link = movie.valueForKeyPath("posters.thumbnail") as! String
        var range = link.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        link = link.stringByReplacingCharactersInRange(range!, withString: "https://content6.flixster.com/")
       // println(link) to check link
        var high_res_url = NSURL(string: link)!
        backgroundView.setImageWithURL(high_res_url)
        

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
