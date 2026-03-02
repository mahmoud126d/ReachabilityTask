//
//  ProductTableViewCell.swift
//  ReachabilityTask
//
//  Created by Mahmoud Salah Mahmoud on 15/02/2026.
//
import UIKit

class ProductTableViewCell: UITableViewCell {

    //MARK: Outlets
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    
    //MARK: Properties

    static let identifier = "ProductTableViewCell"
    
    //MARK: LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCellUI()
    }

    //MARK: Public Methods
    
    func configure(product: Product) {
        productNameLabel.text = product.title
        productDescriptionLabel.text = product.description
        productPriceLabel.text = "\(product.price)$"

        // Load image
        if let url = URL(string: product.thumbnail) {
            productImageView.image = UIImage(systemName: "photo")
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.productImageView.image = image
                }
            }.resume()
        } else {
            productImageView.image = UIImage(systemName: "photo")
        }
    }
    
    
    //MARK: Private Methods
    
    private func setupCellUI() {
        setupContainerViewStyle()
        configureImageViewStyle()
        setupNameLabelStyle()
        setupDescriptionLabelStyle()
        setupPriceLabelStyle()
    }
    
    private func setupContainerViewStyle() {
        
        // Card style container
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .systemBackground

        // Shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
    }
    
    private func configureImageViewStyle() {
        productImageView.contentMode = .scaleAspectFill
        productImageView.layer.cornerRadius = 10
        productImageView.clipsToBounds = true
    }
    
    private func setupNameLabelStyle() {
        productNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        productNameLabel.textColor = .label
    }
    
    private func setupDescriptionLabelStyle() {
        productDescriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        productDescriptionLabel.textColor = .systemGray
        productDescriptionLabel.numberOfLines = 2
    }
    
    private func setupPriceLabelStyle(){
        productPriceLabel.font = .systemFont(ofSize: 16, weight: .bold)
        productPriceLabel.textColor = .white
        productPriceLabel.backgroundColor = .systemGreen
        productPriceLabel.textAlignment = .center
        productPriceLabel.layer.cornerRadius = 8
        productPriceLabel.clipsToBounds = true
        productPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
}

