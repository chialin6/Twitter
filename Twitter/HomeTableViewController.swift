//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by stlp on 10/3/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    var tweetArr = [NSDictionary]()
    var numTweets: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        
        // pull to refresh
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }

    @objc func loadTweets() {
        // Call API
        numTweets = 20
        let tweetUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let tweetParams = ["count": numTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetUrl, parameters: tweetParams as [String : Any], success: { (tweets: [NSDictionary]) in
            // empty and then append
            self.tweetArr.removeAll()
            for tweet in tweets {
                self.tweetArr.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not retrieve tweets!")
        })
    }
    
    func loadMoreTweets() {
        numTweets = numTweets + 20
        let tweetUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let tweetParams = ["count": numTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetUrl, parameters: tweetParams as [String : Any], success: { (tweets: [NSDictionary]) in
            // empty and then append
            self.tweetArr.removeAll()
            for tweet in tweets {
                self.tweetArr.append(tweet)
            }
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print("Could not retrieve tweets!")
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArr.count {
            loadMoreTweets()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetTableViewCell
        
        let user = tweetArr[indexPath.row]["user"] as! NSDictionary
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContentLabel.text = tweetArr[indexPath.row]["text"] as? String
        
        // set image
        let imgUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imgUrl!)
        
        if let imgData = data {
            cell.profileImage.image = UIImage(data: imgData)
        }
        
        return cell
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArr.count
    }

   
}
