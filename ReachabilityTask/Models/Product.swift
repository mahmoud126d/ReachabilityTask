//
//  Product.swift
//  ReachabilityTask
//
//  Created by Mahmoud Salah Mahmoud on 15/02/2026.
//

import Foundation

// MARK: - ProductResponse

struct ProductResponse: Codable{
    let products: [Product]
}


// MARK: - Welcome

struct Welcome: Codable {
    let products: [Product]
    let total, skip, limit: Int
}


// MARK: - Product

struct Product: Codable {
    let id: Int
    let title, description: String
    let price, discountPercentage, rating: Double
    let stock: Int
    let tags: [String]
    let brand: String?
    let sku: String
    let weight: Int
    let dimensions: Dimensions
    let warrantyInformation, shippingInformation: String
    let reviews: [Review]
    let minimumOrderQuantity: Int
    let images: [String]
    let thumbnail: String
}


// MARK: - Dimensions

struct Dimensions: Codable {
    let width, height, depth: Double
}


// MARK: - Review

struct Review: Codable {
    let rating: Int
    let comment: String
    let reviewerName, reviewerEmail: String
}


