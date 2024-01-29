//
//  EmailAuthenticationClient.swift
//  EveryMeal_iOS
//
//  Created by 김하늘 on 1/7/24.
//

import Foundation

import ComposableArchitecture

struct EmailAuthenticationClient {
  var postEmail: (String) async throws -> Result<EmailSendResponse, EverMealErrorType>
  var postVertifyNumber: (PostVertifyNumberClient) async throws -> Result<Bool, EverMealErrorType>
}

struct PostVertifyNumberClient {
  var token: String
  var vertifyCode: String
}

extension EmailAuthenticationClient: DependencyKey {
  static var liveValue = Self(
    postEmail: { email in
      do {
        let emailPostResponse = try await EmailVertifyService().postEmail(email: email)
        return .success(emailPostResponse)
      } catch {
        return .failure(.fail)
      }
    }, 
    postVertifyNumber: { client in
      do {
        let emailVertifyResponse = try await EmailVertifyService().postVertifyNumber(client: client)
        return .success(emailVertifyResponse.data)
      } catch {
        return .failure(.fail)
      }
      
    }
  )
}

extension DependencyValues {
  var emailAuthResponseClient: EmailAuthenticationClient {
    get { self[EmailAuthenticationClient.self] }
    set { self[EmailAuthenticationClient.self] = newValue }
  }
}
