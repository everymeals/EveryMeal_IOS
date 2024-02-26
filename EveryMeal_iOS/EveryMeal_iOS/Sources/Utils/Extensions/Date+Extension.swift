//
//  Date+Extension.swift
//  EveryMeal_iOS
//
//  Created by 김하늘 on 2/25/24.
//

import Foundation

extension Date {
  /// 파라미터로 넘기는 날짜로부터 해당 날짜가 며칠 전인지 반환합니다.
  func beforeDateFrom(_ endDate: Date = Date()) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: self, to: endDate)
    
    if let days = components.day {
      return days
    }
    return 0
  }
}
