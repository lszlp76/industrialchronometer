//
//  PageViewController.swift
//  pageViewdeneme2
//
//  Created by ulas özalp on 3.02.2022.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    let pg = UIPageViewController()
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
       
    
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        if previousIndex < 3 { title = "Chronometer"
            
}
       
        guard previousIndex >= 0 else {
            return   nil // burayı orderedViewControllers.last yaparsan tekrar son sayfaya gelir
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    override func willMove(toParent parent: UIViewController?) {
        
       
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        if nextIndex == 2 { title = "Cycle Time Chart"}
        if nextIndex == 3 { title = "Saved Observations"}
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
       
        
        /*
         * Navbar özelliklerini appdelegate üzerinde tamamlıyorsun
         * buralarda ise title vs. gibi temel fonksiyonları yazıyorsun
         */
        self.navigationItem.title = "Chronometer"
        
        
        
      
//        self.navigationController?.navigationBar.titleTextAttributes = attributes as [NSAttributedString.Key
//        : Any]
//        //let appearence =   self.navigationController?.navigationBar
        //appearence?.topItem?.title = "Industrial Chronometer"
        //appearence?.topItem?.titleView?.tintColor = UIColor(named: "Color")
        //appearence?.tintColor = UIColor(named: "Color") //(red: 0.85, green: 0.11, blue: 0.38, alpha: 1.00)
        
       // let attributes = [NSAttributedString.Key.font: UIFont(name: "DS-Digital", size: 5.0) ,NSAttributedString.Key.foregroundColor: UIColor(named: "Color")]
       
        //self.navigationController?.navigationBar.titleTextAttributes = attributes as [NSAttributedString.Key: Any]
        //https://stackoverflow.com/questions/39438606/change-navigation-bar-title-font-swift
    
        //menu butonu eklemek
        
        let menu =  UIBarButtonItem (image: UIImage(named: "menu"), style: .plain, target: self , action: #selector(callSettingsMenu))
        
        self.navigationItem.leftBarButtonItem = menu
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "clock"),style : .plain,target: self,action: #selector(deneme))
   
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController]
                               , direction: .forward
                               , animated: true,
                               completion: nil)
            
            
        }
       
        
    }
   @objc func deneme() {
        
        let vcs = self.orderedViewControllers
       
       var currentIndex: Int {
           guard let vc = viewControllers?.first else { return 0 }
           return vcs.firstIndex(of: vc) ?? 0
       }
       let currentPage = currentIndex
       
        let nextPage = currentPage + 1

        if nextPage < vcs.count {
            let nextVC =  vcs[0]
            self.setViewControllers([nextVC], direction: .forward, animated: true)
            { _ in
               
            }
            
        }
       else
       {
           let nextVC =  vcs[0]
           self.setViewControllers([nextVC], direction: .forward, animated: true)
           { _ in
              
           }
       }
    }

    @objc func callSettingsMenu (){
        
        self.performSegue(withIdentifier: "toSettingsMenu", sender: nil)
        
    }
    
    
    private (set) lazy var orderedViewControllers : [UIViewController] = {
        
        return [self.callViewController ( order: "Chrono" ),
                self.callViewController ( order: "ChartUI" ),
                self.callViewController ( order: "FileList" )  ]
    }()
    
    func callViewController (order : String )-> UIViewController {
        
        return  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(order)ViewController")
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
              let firstViewControllerIndex = orderedViewControllers.firstIndex(of: firstViewController) else {
                  return 0
              }
        return firstViewControllerIndex
    }
}
