import UIKit
import LinkPresentation
import UniformTypeIdentifiers // iOS 14+ için gerekli

class MyActivityItemSource: NSObject, UIActivityItemSource {
    
    let title: String
    let text: String
    let fileURL: URL?
    let icon: UIImage?
    
    init(title: String, text: String, icon: UIImage?, file: URL?) {
        self.title = title
        self.text = text
        self.icon = icon
        self.fileURL = file
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
    }
    
    
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
           return fileURL
       }
       func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
          
           return icon
       }
       func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
           return title
       }
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
            let metadata = LPLinkMetadata()
            metadata.title = title
            
            metadata.imageProvider = NSItemProvider(object: icon!)
            
           // metadata.iconProvider = NSItemProvider(object: UIImage(systemName: "text.bubble")!)
            //This is a bit ugly, though I could not find other ways to show text content below title.
            //https://stackoverflow.com/questions/60563773/ios-13-share-sheet-changing-subtitle-item-description
            //You may need to escape some special characters like "/".
            metadata.originalURL = URL(fileURLWithPath: text)
            return metadata
        }
//    // KRİTİK BÖLÜM: Metadata ve Dosya Tipi Tanımlama
//    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
//        let metadata = LPLinkMetadata()
//        metadata.title = title
//        metadata.originalURL = fileURL
//        metadata.url = fileURL // Bazı uygulamalar buna bakar
//        
//        if let icon = icon {
//            metadata.iconProvider = NSItemProvider(object: icon)
//        }
//        
//        return metadata
//    }
    
    
}
