//
//  IronPathWidgetBundle.swift
//  IronPathWidget
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import WidgetKit
import SwiftUI

@main
struct IronPathWidgetBundle: WidgetBundle {
    var body: some Widget {
        StreakWidget()
        TodayProgressWidget()
    }
}
