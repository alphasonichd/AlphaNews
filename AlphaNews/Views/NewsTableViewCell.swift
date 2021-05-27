//
//  NewsTableViewCell.swift
//  AlphaNews
//
//  Created by developer on 25.05.21.
//

import UIKit
import Kingfisher

class NewsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsContentLabel: UILabel!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    func configure(imageUrl: String?, title: String, content: String?, showMore: Bool) {
        contentView.backgroundColor = #colorLiteral(red: 0.04841674864, green: 0.2590725422, blue: 0.4438114166, alpha: 1)
        
        newsTitleLabel.text = title
        newsTitleLabel.textColor = #colorLiteral(red: 0.9781451821, green: 0.6626796946, blue: 0.8631244302, alpha: 1)
        newsContentLabel.text = content ?? ""
        newsContentLabel.textColor = #colorLiteral(red: 0.9781451821, green: 0.8748882413, blue: 0.8631244302, alpha: 1)
        
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.layer.masksToBounds = true
        newsImageView.layer.borderWidth = 2
        newsImageView.layer.borderColor = #colorLiteral(red: 0.9781451821, green: 0.8748882413, blue: 0.8631244302, alpha: 1)
        newsImageView.layer.cornerRadius = self.newsImageView.frame.width / 2.0
        
        if let url = URL(string: imageUrl ?? "") {
            let processor = DownsamplingImageProcessor(size: newsImageView.bounds.size)
                         |> RoundCornerImageProcessor(cornerRadius: 20)
            newsImageView.kf.indicatorType = .activity
            newsImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "newsPlaceholder"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ])
            {
                result in
                
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
        }
        
        
        let readmoreFont = newsContentLabel.font
        let readmoreFontColor = #colorLiteral(red: 0.9781451821, green: 0.6626796946, blue: 0.8631244302, alpha: 1)
//        if newsContentLabel.text?.count ?? 0 > 1 {
        
        if showMore {
            imageViewBottomConstraint.priority = .defaultLow
            newsContentLabel.text = content
            newsContentLabel.numberOfLines = 0
        } else {
            imageViewBottomConstraint.priority = .defaultHigh
            newsContentLabel.numberOfLines = 3
            if newsContentLabel.text?.count ?? 0 > 1 && newsContentLabel.calculateMaxLines() > 3 {
                DispatchQueue.main.async {
                    self.newsContentLabel.addTrailing(with: "... ", moreText: "Read more", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
                }
            }
        }
    }
    
}
