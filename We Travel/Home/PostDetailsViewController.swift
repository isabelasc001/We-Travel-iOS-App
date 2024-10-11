//
//  PostDetailsViewController.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 26/09/24.
//

import UIKit
import FirebaseFirestore

class PostDetailsViewController: UIViewController {
    
    var post: Post?

    @IBOutlet weak var postTitleLabel: UILabel!

    @IBOutlet weak var postContentTextView: UITextView!
    
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    @IBOutlet weak var numberOfDislikesLabel: UILabel!
    
    @IBOutlet weak var insertCommentTextView: UITextView!
    
    @IBOutlet weak var displayCommentsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func starConversationButtonPressed(_ sender: Any) {
    }
    
    @IBAction func visitProfileButtonPressed(_ sender: Any) {
    }
    
    @IBAction func sendPostContentButtonPressed(_ sender: Any) {
    }
    

}
