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
        
        return self.object(forKey: AFImageCacheKeyFromURLRequest(request) as AnyObject) as? UIImage
    }
    
    func cacheImage(_ image: UIImage, forRequest request: URLRequest) {
        self.setObject(image, forKey: AFImageCacheKeyFromURLRequest(request) as AnyObject)
    }
    
    // MARK: - Private
    
    fileprivate func AFImageCacheKeyFromURLRequest(_ request:URLRequest) -> String {
        return request.url!.absoluteString
    }
}



@objc public protocol AFImageCacheProtocol:class{
    func cachedImageForRequest(_ request:URLRequest) -> UIImage?
    func cacheImage(_ image:UIImage, forRequest request:URLRequest);
}

extension UIImageView {
    fileprivate static var defaultImageCache = AFImageCache()
    fileprivate static var queue = OperationQueue()
    
    fileprivate struct AssociatedKeys {
        static var SharedImageCache = "SharedImageCache"
        static var RequestImageOperation = "RequestImageOperation"
        static var URLRequestImage = "UrlRequestImage"
    }
    
    public class func setSharedImageCache(_ cache:AFImageCacheProtocol?) {
        objc_setAssociatedObject(self, &AssociatedKeys.SharedImageCache, cache, .OBJC_ASSOCIATION_RETAIN)
    }
    
    public class func sharedImageCache() -> AFImageCacheProtocol {
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: OperationQueue.main) { (NSNotification) -> Void in
            self.defaultImageCache.removeAllObjects()
        }
        return objc_getAssociatedObject(self, &AssociatedKeys.SharedImageCache) as? AFImageCacheProtocol ?? self.defaultImageCache
    }
    
    fileprivate class func af_sharedImageRequestOperationQueue() -> OperationQueue {
        self.queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        return self.queue
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
    
    public func setImageWithUrl(_ url: URL, placeHolderImage:UIImage? = nil) {
        var request = URLRequest(url: url)
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        self.setImageWithUrlRequest(request, placeHolderImage: placeHolderImage, success: nil, failure: nil)
    }
    
    public func setImageWithUrlRequest(_ request:URLRequest, placeHolderImage:UIImage? = nil,
        success:((_ request:URLRequest?, _ response:URLResponse?, _ image:UIImage, _ fromCache:Bool) -> Void)?,
        failure:((_ request:URLRequest?, _ response:URLResponse?, _ error:NSError) -> Void)?)
    {
        self.cancelImageRequestOperation()
        
        if let cachedImage = UIImageView.sharedImageCache().cachedImageForRequest(request) {
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
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let _ = error {
                    DispatchQueue.main.async {
                        failure?(request, response, error as! NSError)
                    }
                } else {
                    if let data = data {
                        DispatchQueue.main.async { [weak self] in
                            if let strongSelf = self {
                                if request.url! == strongSelf.af_requestImageOperation.request?.url {
                                    let image:UIImage? = UIImage(data: data)
                                    if image != nil {
                                        if image!.size != CGSize(width: 1, height: 1) {
                                            if success != nil {
                                                success!(request, response, image!, false)
                                            }
                                            else {
                                                strongSelf.image = image!
                                                
                                                let transition = CATransition()
                                                transition.duration = 0.3
                                                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                                                transition.type = kCATransitionFade
                                                
                                                strongSelf.layer.add(transition, forKey:nil)
                                            }
                                            UIImageView.sharedImageCache().cacheImage(image!, forRequest: request)
                                        }
                                    }
                                    
                                    strongSelf.af_requestImageOperation = (nil, nil)
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            failure?(request, response, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"Empty data"]))
                        }
                    }
                }
            }
        }), request: request)
        
        UIImageView.af_sharedImageRequestOperationQueue().addOperation(self.af_requestImageOperation.operation!)
    }
    
    fileprivate func cancelImageRequestOperation() {
        self.af_requestImageOperation.operation?.cancel()
        self.af_requestImageOperation = (nil, nil)
    }
}
