//
//  CryptoHelper.swift
//  WebViewHandle
//
//  Created by Monish Painter on 29/08/22.
//  Email: monishpainter@yahoo.com
//

import Foundation
import CryptoSwift

class CryptoHelper{
    
    //TODO: secret key Provide by SMC
    private static let key = Constants.SECRET_KEY
    
    public static func encrypt(input:String)->String?{
        do{
            let encrypted: Array<UInt8> = try AES(key: key, iv: key, padding: .pkcs5).encrypt(Array(input.utf8))
            
            return encrypted.toBase64()
        }catch{
            
        }
        return nil
    }
    
    public static func decrypt(input:String)->String?{
        do{
            let d=Data(base64Encoded: input)
            let decrypted = try AES(key: key, iv: key, padding: .pkcs5).decrypt(
                d!.bytes)
            return String(data: Data(decrypted), encoding: .utf8)
        }catch{
            
        }
        return nil
    }
}
