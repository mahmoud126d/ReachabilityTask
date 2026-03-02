//
//  DetailsViewController.swift
//  ReachabilityTask
//
//  Created by Mahmoud Salah Mahmoud on 15/02/2026.
//

import UIKit

class DetailsViewController: UIViewController {

    //MARK: Outlets
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    //MARK: Properties
    
    var product: Product?
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUi()
    }

    //MARK: Private Methods
    
    private func setupUi() {
        guard let product else {
            return
        }
        productNameLabel.text = product.title
        productDescription.text = product.description
        productPriceLabel.text = "\(product.price)$"
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
}
