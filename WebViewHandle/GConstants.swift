//
//  GConstants.swift
//  WebViewHandle
//
//  Created by Monish Painter on 29/08/22.
//  Email: monishpainter@yahoo.com
//

import Foundation


class Constants{
    static let API_URL = "https://www.*******.gov.in/*****/****" //check document
    static let API_KEY = "********************" //check document
    static let SECRET_KEY = "*********************" //check document
    static let ACCESS_POINT = "2"  // 1 - Android, 2 - iOS
}


//MARK: - Extra Utilis(Helper)

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}



extension String {
    
    /// Returns a new string made from the `String` by replacing all characters not in the unreserved
    /// character set (as defined by RFC3986) with percent encoded characters.
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet.urlQueryAllowed
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

 
