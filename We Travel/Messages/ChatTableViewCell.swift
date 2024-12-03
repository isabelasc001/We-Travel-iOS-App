//
//  ChatTableViewCell.swift
//  We Travel
//
//  Created by Isabela da Silva Cardoso on 25/09/24.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var lastMessageContentTextView: UITextView!
    
    @IBOutlet weak var unreadMessagesImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellAppearance()
    }

    func setupCellAppearance() {
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.height/2
        userPhotoImageView.clipsToBounds = true
        unreadMessagesImageView.isHidden = true
        unreadMessagesImageView.layer.cornerRadius = unreadMessagesImageView.frame.size.width / 2
        unreadMessagesImageView.clipsToBounds = true
    }
    
    func configureCell(chat: Chat) {
        userNameLabel.text = chat.username
        lastMessageContentTextView.text = chat.lastMessage.isEmpty ? "No messages yet" : chat.lastMessage
        unreadMessagesImageView.isHidden = !chat.hasUnreadMessages
        if let url = URL(string: chat.photoURL) {
                loadProfileImage(from: url)
            }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadProfileImage(from url: URL) {
        DispatchQueue.global().async {
            if let data =  try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.userPhotoImageView.image = image
                }
            }
        }
    }
}
