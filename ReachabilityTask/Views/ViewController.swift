//
//  ViewController.swift
//  ReachabilityTask
//
//  Created by Mahmoud Salah Mahmoud on 15/02/2026.
//

import UIKit
import Network
import Combine

class ViewController: UIViewController {
    
    //MARK: OUTLETS
    
    @IBOutlet weak var prouductsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    
    private var viewModel: ProductsViewModelProtocol = ProductsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        tableViewConfiguration()
    }
    
    //MARK: Configuration Methods
    
    private func tableViewConfiguration() {
        prouductsTableView.delegate = self
        prouductsTableView.dataSource = self
        prouductsTableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: ProductTableViewCell.identifier)
        prouductsTableView.rowHeight = 200
    }
}

//MARK: TableView Delegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "\(DetailsViewController.self)") as! DetailsViewController
        vc.product = viewModel.product(at: indexPath.row)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: TableView Data Source

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as! ProductTableViewCell
        let product = viewModel.product(at: indexPath.row)
        cell.configure(product: product)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
}

private extension ViewController {
    
    func bindViewModel() {
        
        viewModel.productsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.prouductsTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.loadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                    //self?.showAlert(message: message)
            }
            .store(in: &cancellables)
    }
}
