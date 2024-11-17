//
//  WebViewController.swift
//  industrialchronometer
//
//  Created by ulas özalp on 19.02.2022.
//

import UIKit
import WebKit
import StoreKit

class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var aboutStackView: UIStackView?
    var chosen : (Int,Int) = (0,0)
   
    override func loadView() {
        webPageView = WKWebView()
        webPageView.navigationDelegate = self
        view = webPageView
    }
    override func willMove(toParent parent: UIViewController?) {
        print("ok")
    }
    @IBOutlet weak var webPageView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
       var link = ""
        switch chosen {
        case (0,1) :
            
          link =  "https://www.agromtek.com/indchroprivacypol.html"
            
         break
        case (1,1) :
            
         link = "https://www.agromtek.com/industrialchronometer/about.html"
            
          
            break
        
        
        default:
            link =  "https://www.google.com"
        }
        let url = URL(string : link)!
        webPageView.load(URLRequest(url: url))
        webPageView.allowsBackForwardNavigationGestures = true
        // Do any additional setup after loading the view.
    }
   
   
}

