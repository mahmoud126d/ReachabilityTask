//
//  ProductsViewModel.swift
//  ReachabilityTask
//
//  Created by Mahmoud Salah Mahmoud on 15/02/2026.
//

import Foundation
import Combine

protocol ProductsViewModelProtocol {
    var productsPublisher: AnyPublisher<[Product], Never> { get }
    var loadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    
    func fetchProducts()
    func numberOfRows() -> Int
    func product(at index: Int) -> Product
}

class ProductsViewModel: ProductsViewModelProtocol {
    
    //MARK: private proberties
    
    private let networkManager: NetworkManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: Private Publishers
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    //MARK: pulic Publishers
    
    var productsPublisher: AnyPublisher<[Product], Never> {
        $products.eraseToAnyPublisher()
    }
        
    var loadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
        
    var errorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
    
    //MARK: init + deinit
    
    init(networkManager: NetworkManagerProtocol =  NetworkManager()) {
        self.networkManager = networkManager
        fetchProducts()
    }
    
    deinit {
        print("deinit \(ProductsViewModel.self)")
    }
    
    //MARK: - Public Methods -
    
    func numberOfRows() -> Int {
        return products.count
    }
    
    func product(at index: Int) -> Product {
        return products[index]
    }
    
    //MARK: API CALLS
    
    func fetchProducts() {
        guard let url = URL(string: "https://dummyjson.com/products") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        networkManager.request(request, type: ProductResponse.self)
            .handleEvents(receiveSubscription: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isLoading = true
                    self?.errorMessage = nil
                }
            })
            .map(\.products)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] products in
                self?.products = products
            }
            .store(in: &cancellables)
    }
}
