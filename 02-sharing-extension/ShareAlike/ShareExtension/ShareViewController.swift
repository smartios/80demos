//
// Copyright 2014 Scott Logic
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import Social
import MobileCoreServices


class ShareViewController: SLComposeServiceViewController {
    
    // The URL we're uploading to.
    // NOTE: This almost certainly _won't_ work for you. Create your own request bin
    //       at http://requestb.in/ and substitute that URL here.
    let sc_uploadURL = "http://requestb.in/ykc1ipyk"
    let sc_maxCharactersAllowed = 25
    
    var attachedImage: UIImage?
    
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        if let currentMessage = contentText {
            let currentMessageLength = currentMessage.characters.count//count(currentMessage)
            charactersRemaining = NSNumber(integerLiteral: sc_maxCharactersAllowed - currentMessageLength)
            
            if Int(charactersRemaining) < 0 {
                return false
            }
        }
        
        return true
    }
    
    override func presentationAnimationDidFinish() {
        // Only interested in the first item
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        // Extract an image (if one exists)
        imageFromExtensionItem(extensionItem: extensionItem) {
            image in
            if let image = image {
                
                DispatchQueue.main.async {
                    self.attachedImage = image
                }
                //        dispatch_async(DispatchQueue.main) {
                //
                //        }
            }
        }
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        let configName = "com.shinobicontrols.ShareAlike.BackgroundSessionConfig"
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: configName)
        // Extensions aren't allowed their own cache disk space. Need to share with application
        sessionConfig.sharedContainerIdentifier = "group.ShareAlike"
        let session = URLSession(configuration: sessionConfig)
        
        // Prepare the URL Request
        let request = urlRequestWithImage(image: attachedImage, text: contentText)
        
        // Create the task, and kick it off
        let task = session.dataTask(with: request! as URLRequest)
        
        task.resume()
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        extensionContext?.completeRequest(returningItems: [AnyObject](), completionHandler: nil)
    }
    
    //   override func configurationItems() -> [AnyObject]! {
    //    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    //    return [AnyObject]()
    //  }
    
    
    // MARK:- Utility functions
    
    private func urlRequestWithImage(image: UIImage?, text: String) -> NSURLRequest? {
        let url = NSURL(fileURLWithPath: sc_uploadURL)
        let request: NSMutableURLRequest?  = (url==nil) ? NSMutableURLRequest(url: url as URL) : nil
        request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.addValue("application/json", forHTTPHeaderField: "Accept")
        request?.httpMethod = "POST"
        
        var jsonObject = NSMutableDictionary()
        jsonObject["text"] = text
        if let image = image {
            jsonObject["image_details"] = extractDetailsFromImage(image: image)
        }
        
        // Create the JSON payload
        
        
        do{
            let jsonError: NSError?
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            //    let jsonData = JSONSerialization.dataWithJSONObject(jsonObject, options: nil, error: jsonError)
            
            if (jsonData != nil)
            {
                request?.httpBody = jsonData
            }
            else
            {
//                if let error = jsonError
//                {
//                    print("JSON Error: \(error.localizedDescription)")
//                }
            }
        }
        catch{
            
        }
        
        return request
    }
    
    private func extractDetailsFromImage(image: UIImage) -> NSDictionary {
        var resultDict = [String : AnyObject]()
        resultDict["height"] = image.size.height as AnyObject?
        resultDict["width"] = image.size.width as AnyObject?
        resultDict["orientation"] = image.imageOrientation.rawValue as AnyObject?
        resultDict["scale"] = image.scale as AnyObject?
        resultDict["description"] = image.description as AnyObject?
        return resultDict as NSDictionary
    }
    
    private func imageFromExtensionItem(extensionItem: NSExtensionItem, callback: @escaping (_ image: UIImage?) -> Void) {
        
        for attachment in extensionItem.attachments as! [NSItemProvider] {
            if(attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String)) {
                // Marshal on to a background thread
                
                
                DispatchQueue.global(qos: .default).async {
                    attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: {
                        (imageProvider, error) in
                        var image: UIImage? = nil
                        if let error = error {
                            print("Item loading error: \(error.localizedDescription)")
                        }
                        image = imageProvider as? UIImage
                        
                        DispatchQueue.main.async {
                            callback(image)
                        }
//                        dispatch_async(DispatchQueue.main) {
//                            callback(image: image)
//                        }
                    })
                }
                
                //        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, UInt(0)).asynchronously() {
                //          attachment.loadItemForTypeIdentifier(kUTTypeImage as String, options: nil) {
                //            (imageProvider, error) in
                //            var image: UIImage? = nil
                //            if let error = error {
                //              println("Item loading error: \(error.localizedDescription)")
                //            }
                //            image = imageProvider as? UIImage
                //            dispatch_async(DispatchQueue.main) {
                //              callback(image: image)
                //            }
                //          }
                //        }
            }
        }
    }
    
}
