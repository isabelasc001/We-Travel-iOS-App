//
//  MyPostsCollectionViewCell.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 16/10/24.
//

import UIKit
import FirebaseAuth

class MyPostsCollectionViewCell: UICollectionViewCell {
    
    var onSeeMoreButtonTap: (() -> Void)?
    
    var posts: Post?

    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var myPostContentTextView: UITextView!
    
    @IBOutlet weak var tagsTextField: UITextField!
    
    @IBOutlet weak var seeMoreButton: UIButton!
    
    @IBOutlet weak var postedByLabel: UILabel!
    
    @IBOutlet weak var myPostsCollectionViewCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    func configureCell(with post: Post, onSeeMore: @escaping () -> Void) {
            postTitleLabel.text = post.title
            myPostContentTextView.text = post.description
            tagsTextField.text = post.tags.joined(separator: ", ")
            postedByLabel.text = "Postado por \(post.postedBy)"
            self.onSeeMoreButtonTap = onSeeMore
        }

    private func setupStyle() {
        myPostsCollectionViewCell.layer.cornerRadius = 10
        myPostsCollectionViewCell.layer.shadowColor = UIColor.black.cgColor
        myPostsCollectionViewCell.layer.shadowOpacity = 0.2
        myPostsCollectionViewCell.layer.shadowOffset = CGSize(width: 0, height: 2)
        myPostsCollectionViewCell.layer.shadowRadius = 4
        myPostsCollectionViewCell.layer.masksToBounds = false
        myPostsCollectionViewCell.backgroundColor = .white
        myPostsCollectionViewCell.layer.borderColor = UIColor.orange.cgColor
        myPostsCollectionViewCell.layer.borderWidth = 1
       }
    
    @IBAction func detailsButtonTapped(_ sender: Any) {
        onSeeMoreButtonTap?()
    }
}
