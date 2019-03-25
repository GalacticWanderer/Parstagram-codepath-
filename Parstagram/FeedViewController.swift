//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Joy Paul on 3/21/19.
//  Copyright © 2019 Joy Paul. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var tableView: UITableView!
    
    //holds the objects from database
    var posts = [PFObject]()
    
    //limit for the query
    var postLimit = 5
    
    //is used for pull to refresh
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 278
        
        pullToRefresh()
    }
    
    //pull to refresh funcs. had to order by createdAt to make this function useful
    func pullToRefresh(){
        myRefreshControl.addTarget(self, action: #selector(loadDataWithPtF), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    @objc func loadDataWithPtF(){
       loadsDataWithQuery(limt: postLimit)
        self.tableView.reloadData()
        self.myRefreshControl.endRefreshing()
    }
    
    //runs when the view appears on screen successfully
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadsDataWithQuery(limt: postLimit)
    }
    
    //the get request to database with Parse
    func loadsDataWithQuery(limt l:Int){
        let query = PFQuery(className: "Posts").order(byDescending: "createdAt")
        query.includeKey("author")
        query.limit = l
        
        query.findObjectsInBackground{(posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
            print(self.posts)
        }
    }
    
    //configure tableView cell counts and the cell itself
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]

        let user = post["author"]as! PFUser
        cell.authorName.text = user.username
        
        let caption = post["caption"] as! String
        cell.postTag.text = caption
        
        let postedImage = post["image"] as! PFFileObject
        let urlString = postedImage.url!
        let url = URL(string: urlString)
        
        cell.postImageView.af_setImage(withURL: url!)
        
        return cell
    }
    
    //onScrollEnd
    func loadMorePostsOnScroll(){
        print("loadMore getting called")
        let query = PFQuery(className: "Posts").order(byDescending: "createdAt")
        query.includeKey("author")
        postLimit = postLimit + 5
        query.limit = postLimit
        
        query.findObjectsInBackground{(posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Scroll end getting triggered")
        indexPath.row + 1 == posts.count ? loadMorePostsOnScroll() : nil
    }
    
    //logout
    @IBAction func onLogout(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        //LoginViewController
        
        //referencing the Main.storyboard
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        //referencing the loginViewController
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        //getting access to the delegate of the app and then settingb the rootVC back to loginVC
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = loginViewController
    }
    
}
