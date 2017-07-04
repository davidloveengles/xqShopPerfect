//
//  makeRequest.swift
//  Perfect-App-Template
//
//  Created by Jonathan Guthrie on 2017-02-22.
//
//

import Foundation
import PerfectLib
import PerfectCURL
import cURL
import SwiftString
import PerfectHTTP
import PerfectCrypto

class Utility {}

extension Utility {


	/// The function that triggers the specific interaction with a remote server
	/// Parameters:
	/// - method: The HTTP Method enum, i.e. .get, .post
	/// - route: The route required
	/// - body: The JSON formatted sring to sent to the server
	/// Response:
	/// "data" - [String:Any]
	static func makeRequest(
		_ method: HTTPMethod,
		_ url: String,
		body: String = "",
		encoding: String = "JSON",
		bearerToken: String = ""
		) -> ([String:Any]) {

		let curlObject = CURL(url: url)
		curlObject.setOption(CURLOPT_HTTPHEADER, s: "Accept: application/json")
		curlObject.setOption(CURLOPT_HTTPHEADER, s: "Cache-Control: no-cache")
		curlObject.setOption(CURLOPT_USERAGENT, s: "PerfectAPI2.0")

		if !bearerToken.isEmpty {
			curlObject.setOption(CURLOPT_HTTPHEADER, s: "Authorization: Bearer \(bearerToken)")
		}

		switch method {
		case .post :
			let byteArray = [UInt8](body.utf8)
			curlObject.setOption(CURLOPT_POST, int: 1)
			curlObject.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
			curlObject.setOption(CURLOPT_COPYPOSTFIELDS, v: UnsafeMutablePointer(mutating: byteArray))

			if encoding == "form" {
				curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/x-www-form-urlencoded")
            }
            else if encoding == "xml" {
                curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/xml")
			} else {
				curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/json")
			}
            

		default: //.get :
			curlObject.setOption(CURLOPT_HTTPGET, int: 1)
		}


		var header = [UInt8]()
		var bodyIn = [UInt8]()

		var code = 0
		var data = [String: Any]()
		var raw = [String: Any]()

		var perf = curlObject.perform()
		defer { curlObject.close() }

		while perf.0 {
			if let h = perf.2 {
				header.append(contentsOf: h)
			}
			if let b = perf.3 {
				bodyIn.append(contentsOf: b)
			}
			perf = curlObject.perform()
		}
		if let h = perf.2 {
			header.append(contentsOf: h)
		}
		if let b = perf.3 {
			bodyIn.append(contentsOf: b)
		}
		let _ = perf.1

		// assamble the body from a binary byte array to a string
		let content = String(bytes:bodyIn, encoding:String.Encoding.utf8)

		// parse the body data into a json convertible
		do {
            if let content = content {
                if content.startsWith("[") {
                    let arr = try content.jsonDecode() as! [Any]
                    data["response"] = arr
                }else if content.startsWith("{") {
                    data = try content.jsonDecode() as! [String : Any]
                } else if content.startsWith("<xml>") {
                   data["response"] = content
                }
            }
            
			return data
		} catch {
            print("服务端请求失败：\(content ?? "")")
			return [:]
		}
	}
    
    
}


extension Utility {
    
    static func downloadImg(urlStr: String, success: @escaping (String) -> ()) {
        
        let realm = "meituan.net/"
        guard let range = urlStr.range(of: realm) else {
            print("图片域名变化错误 old: \(realm), newUrl: \(urlStr)")
            return
        }
        guard let imgUrl = URL(string: urlStr) else{
            print("\(urlStr) 非url格式")
            return
        }
        
        let rightUrl = urlStr.substring(from: range.upperBound)
        
        // base64
        guard let bytes = rightUrl.encode(.base64), let base64RightUrl = String(validatingUTF8: bytes) else{
            print("base64 error")
            return
        }
        
        let newfilePath = "./webroot/" + base64RightUrl
        
        if File(newfilePath).exists {
            return
        }
        
        
        // 下载 linux上不可用
//        URLSession.shared.downloadTask(with: imgUrl) { (url, response, error) in
//            
//            if let tempUrl = url {
//                
//                let thisFile = File(tempUrl.path)
//            
//                if let _ = try? thisFile.copyTo(path: newfilePath) {
//                    success(base64RightUrl)
//                }
//                
//                
//            }else{
//                print("下载新图片失败：\(error)")
//            }
//            
//        }.resume()
        
        makeDownloadImg(imgUrl.path)
        success(base64RightUrl)
    }
    
    
    
    static func makeDownloadImg(_ url: String)  {
        
        let curlObject = CURL(url: url)
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Cache-Control: no-cache")
        curlObject.setOption(CURLOPT_USERAGENT, s: "PerfectAPI2.0")
        curlObject.setOption(CURLOPT_HTTPGET, int: 1)
        
        
        var header = [UInt8]()
        var bodyIn = [UInt8]()
        
        var code = 0
        var data = [String: Any]()
        var raw = [String: Any]()
        
        var perf = curlObject.perform()
        defer { curlObject.close() }
        
        while perf.0 {
            if let h = perf.2 {
                header.append(contentsOf: h)
            }
            if let b = perf.3 {
                bodyIn.append(contentsOf: b)
            }
            perf = curlObject.perform()
        }
        if let h = perf.2 {
            header.append(contentsOf: h)
        }
        if let b = perf.3 {
            bodyIn.append(contentsOf: b)
        }
        let _ = perf.1
        
        
        let out = OutputStream(toFileAtPath: "./webroot/hehedd.jpg", append: false)
        out?.open()
        out?.write(bodyIn, maxLength: bodyIn.count)
        out?.close()
    }
}





