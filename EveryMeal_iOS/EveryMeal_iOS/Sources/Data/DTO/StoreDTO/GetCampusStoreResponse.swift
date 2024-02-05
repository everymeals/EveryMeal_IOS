//
//  GetCampusStoreRequest.swift
//  EveryMeal_iOS
//
//  Created by 김광록 on 1/30/24.
//

import Foundation

struct GetCampusStoreResponse: Decodable {
  let localDateTime: String?
  let message: String?
  let data: CampusStoreData?
}

struct CampusStoreData: Codable {
  let content: [CampusStoreContent]?
  let pageable: CampusStorePageable?
  let totalPages: Int?
  let totalElements: Int?
  let last: Bool?
  let size: Int?
  let number: Int?
  let sort: CampusStoreSort?
  let numberOfElements: Int?
  let first: Bool?
  let empty: Bool?
}

struct CampusStoreContent: Codable {
  let idx: Int?
  let name: String?
  let address: String?
  let phoneNumber: String?
  let categoryDetail: String?
  let distance: Int?
  let grade: Double?
  let reviewCount: Int?
  let recommendedCount: Int?
  let images: [String]?
  let isLiked: Bool?
}

struct CampusStorePageable: Codable {
  let sort: CampusStoreSort?
  let offset: Int?
  let pageNumber: Int?
  let pageSize: Int?
  let unpaged: Bool?
  let paged: Bool?
}

struct CampusStoreSort: Codable {
  let empty: Bool?
  let sorted: Bool?
  let unsorted: Bool?
}

