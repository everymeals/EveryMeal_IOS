//
//  EmailAuthenticationClient.swift
//  EveryMeal_iOS
//
//  Created by 김하늘 on 1/7/24.
//

import Foundation

import ComposableArchitecture

struct SignupClient {
  var postEmail: (String) async throws -> Result<EmailSendResponse, EverMealErrorType>
  var postVertifyNumber: (PostVertifyNumberClient) async throws -> Result<Bool, EverMealErrorType>
  var getImageConfig: () async throws -> Result<ImageResponse, EverMealErrorType>
  var signup: (SignupRequest) async throws -> Result<SignupResponse, EverMealErrorType>
}

struct PostVertifyNumberClient {
  var token: String
  var vertifyCode: String
}

extension SignupClient: DependencyKey {
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
    }, 
    getImageConfig: {
      do {
        let imageConfigResponse = try await ImageService().getImageURL(fileDomain: .user)
        return .success(imageConfigResponse)
      } catch {
        return .failure(.fail)
      }
      
    },
    signup: { client in
      do {
        let signupResponse = try await UserService().postSignup(client: client)
        return .success(signupResponse)
      } catch {
        return .failure(.fail)
      }
      
    }
    
  )
}

extension DependencyValues {
  var signupClient: SignupClient {
    get { self[SignupClient.self] }
    set { self[SignupClient.self] = newValue }
  }
}
