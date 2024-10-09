//
//  CardsContentTableViewCell.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 11/09/24.
//

import UIKit

class CardsContentTableViewCell: UITableViewCell {

    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postContentTextView: UITextView!
    
    @IBOutlet weak var postedByLabel: UILabel!
    
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var tagsTextField: UITextField!
    
    @IBOutlet weak var cardsContentTableViewCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }
    
    func configureCell(with post: Post) {
            postTitleLabel.text = post.title
            postContentTextView.text = post.description
            tagsTextField.text = post.tags.joined(separator: ", ")
            postedByLabel.text = "Postado por \(post.postedBy)"
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
        
        //tamanho do card
//        cardsContentTableViewCell.constraints.

       }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func expandContentButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cardsContentObject = storyboard.instantiateViewController(withIdentifier: "PostDetailsViewController")
        
        
    }
    
  
    
}
