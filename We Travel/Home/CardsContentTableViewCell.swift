//
//  CardsContentTableViewCell.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 11/09/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol CardsContentCellDelegate: AnyObject {
    func deletePost(_ post: Post)
}

class CardsContentTableViewCell: UITableViewCell {
    
    weak var delegate: CardsContentCellDelegate?
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
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8))
    }
    
    func configureCell(with post: Post, onSeeMore: @escaping () -> Void) {
            postTitleLabel.text = post.title
            postContentTextView.text = post.description
            tagsTextField.text = post.tags.joined(separator: ", ")
            postedByLabel.text = "Postado por \(post.postedBy)"
            self.onSeeMoreButton = onSeeMore
            self.post = post
        
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
        cardsContentTableViewCell.backgroundColor = UIColor.orange
        
        postContentTextView.backgroundColor = UIColor.orange
        deletePostButton.backgroundColor = UIColor.orange
       }
        
    @IBAction func expandContentButton(_ sender: Any) {
        onSeeMoreButton?()
    }
    
    @IBAction func deleteMyPostButtonPressed(_ sender: Any) {
        guard let post = post else { return }
            print("Botão de deletar pressionado para o post: \(post.title)")
            delegate?.deletePost(post)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
