//
//  HomeView.swift
//  EveryMeal_iOS
//
//  Created by 김광록 on 2023/07/24.
//

import SwiftUI
import ComposableArchitecture

enum HomeStackViewType: Hashable {
  case writeReview
  case restaurantList
  case reviewList
  case moreStoreView(MoreStoreViewType)
  case emailVertify(type: EmailViewType, model: SignupEntity)
}

struct HomeView: View {
  @State var navigationPath: [HomeStackViewType] = []
  @State private var writeReviewViewTapped: Bool = false
  @State private var topMenuSelected: [Bool] = Array.init(repeating: false, count: 4)
  @Binding var otherViewShowing: Bool
  
  @State private var goToWriteReviewTapped = false
  
  private let viewBottomargin: CGFloat = 24
  private let moreReviewBtnBottomMargin: CGFloat = 13
  
  @State var campusStores: [CampusStoreContent]?
  
  var body: some View {
    NavigationStack(path: $navigationPath) {
      VStack {
        HomeHeaderView()
        ScrollView(showsIndicators: true) {
          GoToReviewBannerView()
            .padding(.top, 12)
            .padding(.horizontal, 20)
            .onTapGesture {
              // FIXME: 학교 인증한 사용자인지 확인
              let isEmailAuthenticationTrue = true
              goToWriteReviewTapped = isEmailAuthenticationTrue
//              if isEmailAuthenticationTrue {
//                self.navigationPath.append(.writeReview)
//              } else {
//                self.navigationPath.append(.emailVertifyPopup)
//              }
            }
            .sheet(isPresented: $goToWriteReviewTapped, content: {
              VStack {
                CustomSheetView(buttonTitle: "인증하러 가기",  content: {
                  EmailAuthPopupView()
                }, buttonAction: {
                  goToWriteReviewTapped.toggle()
                  navigationPath.append(.emailVertify(type: .enterEmail, model: SignupEntity()) )
                })
              }
              .presentationDetents([.height(330)])
              .presentationDragIndicator(.hidden)
            })
          
          TopMenuButtonsView(isSelected: $topMenuSelected)
            .onChange(of: topMenuSelected) { topMenuValue in
              let index = topMenuValue.enumerated().first(where: { $0.1 == true })?.0
              if let index = index {
                let viewType: MoreStoreViewType = {
                  switch index {
                  case 0: return .recommend
                  case 1: return .meal
                  case 2: return .cafe
                  default: return .alcohol
                  }
                }()
                self.navigationPath.append(.moreStoreView(viewType))
              }
            }
          
          Separator()
          HomeTopThreeMealsView(campusStores: $campusStores)
          MoreRestuarantButton()
            .onTapGesture {
              self.navigationPath.append(.moreStoreView(.best))
            }
          Separator()
          HomeReviewsView()
          MoreReviewButton()
            .padding(.horizontal, 20)
            .padding(.bottom, Constants.tabBarHeight + viewBottomargin - moreReviewBtnBottomMargin)
            .onTapGesture {
              navigationPath.append(.reviewList)
            }
        }
        .navigationDestination(for: HomeStackViewType.self) { stackViewType in
          switch stackViewType {
          case .restaurantList:
            MoreBestRestaurantView()
              .toolbar(.hidden, for: .tabBar)
          case .reviewList:
            MoreReviewsView()
              .toolbar(.hidden, for: .tabBar)
          case let .moreStoreView(viewType):
            MoreStoreView(backButtonTapped: {
              navigationPath.removeLast()
            }, moreViewType: viewType)
            .toolbar(.hidden, for: .tabBar)
          case let .emailVertify(type, model):
            EmailAuthenticationView(
              store: .init(
                initialState: EmailAuthenticationReducer.State(signupEntity: model),
                reducer: {
                  EmailAuthenticationReducer()
                }),
              viewType: type,
              emailDidSent: { entity in
                if navigationPath.count == 1 {
                  navigationPath.append(.emailVertify(type: .enterAuthNumber, model: entity))
                }
              }, emailVertifySuccess: { entity in
                navigationPath.append(.emailVertify(type: .makeProfile, model: entity))
              }, backButtonTapped: {
                navigationPath.removeLast()
              }, authSuccess: {
                navigationPath.removeAll()
              }
            )
            .toolbar(.hidden, for: .tabBar)
          default:
            MoreBestRestaurantView()
              .toolbar(.hidden, for: .tabBar)
          }
        }
      }
      .onAppear {
        let univIdx = UserDefaultsManager.getInt(.univIdx)
        Task {
          let model = GetCampusStoresRequest(offset: "0", limit: "3", order: .distance, group: .all, grade: nil)
          if let result = try await StoreService().getCampusStores(univIndex: univIdx, requestModel: model) {
            campusStores = result.content
          }
        }
      }
      .onChange(of: navigationPath) { value in
        otherViewShowing = value.count != 0
      }
      .edgesIgnoringSafeArea(.bottom)
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarHidden(true)
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    @State var otherViewShowing = false
    HomeView(otherViewShowing: $otherViewShowing)
  }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
