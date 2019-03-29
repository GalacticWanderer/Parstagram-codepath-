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
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageInputBarDelegate {
   
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var canShowCommentBar: Bool = false
    var selectedPost: PFObject!
    
    //holds the objects from database
    var posts = [PFObject]()
    
    //limit for the query
    var postLimit = 5
    
    //is used for pull to refresh
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //commentBar setup
        commentBar.inputTextView.placeholder = "Type your comment"
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(hideKeyBoard(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        tableView.keyboardDismissMode = .onDrag
        
        //tableView setups
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 278
        
        //pull to refresh func
        pullToRefresh()
    }
    
    //for commentInputBar and send the comment to server
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return canShowCommentBar
    }
    
    @objc func hideKeyBoard(note: Notification){
        commentBar.inputTextView.text = nil
        canShowCommentBar = false
        becomeFirstResponder()
    }
    
    //message send function
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        //crearte class at parse (if not exists)
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()
        
        //add comment to the Post PFObject that is selected from the tableView
        selectedPost.add(comment, forKey: "comments")
        
        //saves in background
        selectedPost.saveInBackground { (success, error) in
          success ? print("Comment posted") : print("Couldn't post comment \(error)")
        }
        
        tableView.reloadData()
        
        commentBar.inputTextView.text = nil
        canShowCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
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
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = l
        
        query.findObjectsInBackground{(posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    //configure tableView cell counts and the cell itself
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        // ?? indicates a way of checking if the comments are nil. If they are nil, set it to the defualt empty array
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    //returns sections for tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    //the tableView cell configuration func
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //getting the proper section of data
        let post = posts[indexPath.section]
        //getting the comments
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //for the first section, configure the post cell and return it
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"]as! PFUser
            cell.authorName.text = user.username
            
            let caption = post["caption"] as! String
            cell.postTag.text = caption
            
            let postedImage = post["image"] as! PFFileObject
            let urlString = postedImage.url!
            let url = URL(string: urlString)
            
            cell.postImageView.af_setImage(withURL: url!)
            
            return cell
            
        //for second section which is less than or equal to the comments attached to the post, return the comment cell
        } else if indexPath.row <= comments.count {
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            commentCell.commenterComment.text = comment["text"] as! String
            
            let user = comment["author"] as! PFUser
            commentCell.commenterName.text = user.username
            
            return commentCell
        
            //and finally, the add a comment cell activates the InputKeyboard so the user can post a comment
        } else{
            let addCommentCell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return addCommentCell
        }
    }
    
    //triggers when tapped on a table cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //adding a comment on each tap
        //post stores the index of the tapped cell
        let post = posts[indexPath.section]
        
        //creating a new class called comment
        let comments = (post["comments"] as? [PFObject]) ?? []
        print("The section is->> \(indexPath.section) indexPath.row is->> \(indexPath.row) and comment.count is \(comments.count)")
        
        if indexPath.row == comments.count + 1 {
            canShowCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
       
    }
    
    //onScrollEnd
    func loadMorePostsOnScroll(){
        print("loadMore getting called")
        let query = PFQuery(className: "Posts").order(byDescending: "createdAt")
        query.includeKeys(["author", "comments", "comments.author"])
        postLimit = postLimit + 5
        query.limit = postLimit
        
        query.findObjectsInBackground{(posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
    }
    
    //triggers on scroll end
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
