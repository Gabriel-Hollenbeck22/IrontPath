//
//  Typography.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

extension Font {
    // MARK: - Display Fonts
    
    /// 48pt, Bold, Rounded - For hero text
    static let display = Font.system(size: 48, weight: .bold, design: .rounded)
    
    // MARK: - Title Fonts
    
    /// 28pt, Semibold - For section titles
    static let title = Font.system(size: 28, weight: .semibold, design: .default)
    
    /// 22pt, Semibold - For subsection titles
    static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
    
    /// 20pt, Semibold - For card titles
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    // MARK: - Body Fonts
    
    /// 17pt, Semibold - For headlines
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    
    /// 17pt, Regular - For body text
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    
    // MARK: - Caption Fonts
    
    /// 15pt, Regular - For secondary text
    static let callout = Font.system(size: 15, weight: .regular, design: .default)
    
    /// 12pt, Regular - For captions
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    
    /// 11pt, Regular - For fine print
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
}

