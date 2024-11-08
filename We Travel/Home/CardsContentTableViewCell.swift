//
//  CardsContentTableViewCell.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 11/09/24.
//

import UIKit
import FirebaseAuth

class CardsContentTableViewCell: UITableViewCell {
    
    var onSeeMoreButton: (() -> Void)?
    var post: Post?
    
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postContentTextView: UITextView!
    
    @IBOutlet weak var postedByLabel: UILabel!
    
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var tagsTextField: UITextField!
    
    @IBOutlet weak var cardsContentTableViewCell: UIView!
    
    @IBOutlet weak var seeMoreButton: UIButton!
    
    @IBOutlet weak var deletePostButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    func configureCell(with post: Post, onSeeMore: @escaping () -> Void) {
            postTitleLabel.text = post.title
            postContentTextView.text = post.description
            tagsTextField.text = post.tags.joined(separator: ", ")
            postedByLabel.text = "Postado por \(post.postedBy)"
            self.onSeeMoreButton = onSeeMore
        
            guard let currentUser = Auth.auth().currentUser else { return }
            
                if post.userId == currentUser.uid {
                    deletePostButton.isHidden = false
                } else {
                    deletePostButton.isHidden = true
                }
        }
    
    private func setupStyle() {
        cardsContentTableViewCell.layer.cornerRadius = 10
        cardsContentTableViewCell.layer.shadowColor = UIColor.black.cgColor
        cardsContentTableViewCell.layer.shadowOpacity = 0.2
        cardsContentTableViewCell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardsContentTableViewCell.layer.shadowRadius = 4
        cardsContentTableViewCell.layer.masksToBounds = false
        cardsContentTableViewCell.backgroundColor = .white
        cardsContentTableViewCell.layer.borderColor = UIColor.orange.cgColor
        cardsContentTableViewCell.layer.borderWidth = 1
       }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    
    @IBAction func expandContentButton(_ sender: Any) {
        onSeeMoreButton?()
    }
    
  
    
}
