//
//  AFImageCache.swift
//  mlbl
//
//  Created by Valentin Shamardin on 08.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class AFImageCache: NSCache<AnyObject, AnyObject>, AFImageCacheProtocol {
    func cachedImageForRequest(_ request: URLRequest) -> UIImage? {
        switch request.cachePolicy {
        case NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
             NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData:
            return nil
        default:
            break
        }
        
        let key = AFImageCache.imageCacheKeyFromURLRequest(request)
        var res = self.object(forKey: key as AnyObject) as? UIImage
        if res == nil {
            res = AFImageCache.getImageFromDisk(for: key)
        }
        return res
    }
    
    func cacheImage(_ image: UIImage, forRequest request: URLRequest) {
        let key = AFImageCache.imageCacheKeyFromURLRequest(request)
        self.setObject(image, forKey: key as AnyObject)
        AFImageCache.cacheImageToDisk(image, for: key)
    }
    
    // MARK: - Private
    
    static fileprivate func imageCacheKeyFromURLRequest(_ request:URLRequest) -> String {
        return request.url!.absoluteString.replacingOccurrences(of: "/", with: "")
    }
    
    static fileprivate var cacheDirectory: String = { () -> String in
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let res = documentsDirectory.appending("/mlblAvatars")
        let isExist = FileManager.default.fileExists(atPath: res, isDirectory: nil)
        if !isExist {
            try? FileManager.default.createDirectory(atPath: res, withIntermediateDirectories: true, attributes: nil)
        }
        return res
    }()
    
    static fileprivate func getImageFromDisk(for key: String) -> UIImage? {
        let imagePath = AFImageCache.cacheDirectory.appending("/\(key)")
        let image = UIImage(named: imagePath)
        return image
    }
    
    static fileprivate func cacheImageToDisk(_ image: UIImage, for key: String) {
        let concurrentQueue = DispatchQueue(label: "writeImage", attributes: .concurrent)
        concurrentQueue.async {
            if let data = UIImagePNGRepresentation(image) {
                let fileName = AFImageCache.cacheDirectory.appending("/\(key)")
                FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
            }
        }
    }
}

@objc public protocol AFImageCacheProtocol: class{
    func cachedImageForRequest(_ request:URLRequest) -> UIImage?
    func cacheImage(_ image:UIImage, forRequest request:URLRequest);
}

extension UIImageView {
    fileprivate struct AssociatedKeys {
        static var SharedImageCache = "SharedImageCache"
        static var RequestImageOperation = "RequestImageOperation"
        static var URLRequestImage = "UrlRequestImage"
    }
    
    public class func setSharedImageCache(_ cache:AFImageCacheProtocol?) {
        objc_setAssociatedObject(self, &AssociatedKeys.SharedImageCache, cache, .OBJC_ASSOCIATION_RETAIN)
    }
    
    public class var sharedImageCache: AFImageCacheProtocol {
        struct Static {
            static var token : Int = 0
            static let defaultImageCache = AFImageCache()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: OperationQueue.main) { (NSNotification) -> Void in
            Static.defaultImageCache.removeAllObjects()
        }
        return objc_getAssociatedObject(self, &AssociatedKeys.SharedImageCache) as? AFImageCacheProtocol ?? Static.defaultImageCache
    }
    
    fileprivate class var af_sharedImageRequestOperationQueue: OperationQueue {
        struct Static {
            static var token = 0
            static let queue = { () -> OperationQueue in
                let queue = OperationQueue()
                queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
                return queue
            }()
        }
        
        return Static.queue
    }
    
    fileprivate var af_requestImageOperation:(operation:Operation?, request: URLRequest?) {
        get {
            let operation:Operation? = objc_getAssociatedObject(self, &AssociatedKeys.RequestImageOperation) as? Operation
            let request:URLRequest? = objc_getAssociatedObject(self, &AssociatedKeys.URLRequestImage) as? URLRequest
            return (operation, request)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.RequestImageOperation, newValue.operation, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &AssociatedKeys.URLRequestImage, newValue.request, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func setImageWithUrl(_ url:URL, placeHolderImage:UIImage? = nil) {
        let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        self.setImageWithUrlRequest(request as URLRequest, placeHolderImage: placeHolderImage, success: nil, failure: nil)
    }
    
    public func setImageWithUrlRequest(_ request:URLRequest, placeHolderImage:UIImage? = nil,
                                       success:((_ request:URLRequest?, _ response:URLResponse?, _ image:UIImage, _ fromCache:Bool) -> Void)?,
                                       failure:((_ request:URLRequest?, _ response:URLResponse?, _ error:NSError?) -> Void)?)
    {
        self.cancelImageRequestOperation()
        
        if let cachedImage = UIImageView.sharedImageCache.cachedImageForRequest(request) {
            if success != nil {
                success!(nil, nil, cachedImage, true)
            }
            else {
                self.image = cachedImage
            }
            
            return
        }
        
        if placeHolderImage != nil {
            self.image = placeHolderImage
        }
        
        self.af_requestImageOperation = (BlockOperation(block: { () -> Void in
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                DispatchQueue.main.async(execute: { () -> Void in
                    if let _ = data {
                        if request.url! == self.af_requestImageOperation.request?.url {
                            let image:UIImage? = UIImage(data: data!)
                            if image != nil {
                                if image!.size != CGSize(width: 1, height: 1) {
                                    if success != nil {
                                        success!(request, response, image!, false)
                                    }
                                    else {
                                        self.image = image!
                                        
                                        let transition = CATransition()
                                        transition.duration = 0.3
                                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                        transition.type = kCATransitionFade
                                        
                                        self.layer.add(transition, forKey:nil)
                                    }
                                    UIImageView.sharedImageCache.cacheImage(image!, forRequest: request)
                                }
                            }
                            
                            self.af_requestImageOperation = (nil, nil)
                        }
                    } else {
                        failure?(request, response, error as NSError?)
                    }
                })
            }) .resume()
        }), request: request)
        
        UIImageView.af_sharedImageRequestOperationQueue.addOperation(self.af_requestImageOperation.operation!)
    }
    
    fileprivate func cancelImageRequestOperation() {
        self.af_requestImageOperation.operation?.cancel()
        self.af_requestImageOperation = (nil, nil)
    }
}

