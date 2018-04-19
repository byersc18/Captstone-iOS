//
//  PromotionsViewController.swift
//  Bar Hopper
//
//  Created by Cameron Byers on 4/3/18.
//  Copyright © 2018 Cameron Byers. All rights reserved.
//

import UIKit

class BarPromotionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //variables for side slide menu
    @IBOutlet var viewConstraint: NSLayoutConstraint!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var sideView: UIView!
    
    var numCells: Int = 0
    var resultsArray: NSArray?
    var dataPassed = [String]()
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //set some attributes for side menu
        viewConstraint.constant = -150
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Dismiss keyboard when background is tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PromotionsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        //MAKE API CALL HERE
        let barID: String = dataPassed[0]
        let urlString = "https://barhopperapi.herokuapp.com/api/promotions/bar/" + barID
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let semaphore = DispatchSemaphore(value: 0) //Use semaphore to make httprequest synchronous
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print(error!)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print(response!)
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print(responseString!)
            
            //parse return data
            let tempData: Data = data
            let myDict: NSDictionary = (try! JSONSerialization.jsonObject(with: tempData, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            var responseJson = [String: AnyObject]()
            responseJson = myDict as! Dictionary
            
            if let results = (responseJson["results"] as? NSArray)
            {
                //NOT NULL
                self.numCells = results.count
                self.resultsArray = results
            }
            
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func panPerform(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            
            let translation = sender.translation(in: self.view).x
            
            //swipe right
            if translation > 0 {
                if viewConstraint.constant < 20 {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.viewConstraint.constant += translation / 10
                        self.view.layoutIfNeeded()
                    })
                }
            }
                //swipe left
            else {
                if viewConstraint.constant > -150  {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.viewConstraint.constant += translation / 10
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
        else if sender.state == .ended {
            if viewConstraint.constant < -100 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewConstraint.constant = -150
                    self.view.layoutIfNeeded()
                })
            }
            else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewConstraint.constant = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set("", forKey: "token")
        UserDefaults.standard.set("", forKey: "desc_id")
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set("", forKey: "password")
        UserDefaults.standard.set("false", forKey: "switch")
        self.performSegue(withIdentifier: "Logout Segue", sender: self)
    }
    
    //Dismiss keyboard from view
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return numCells
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Bar Promotions", for: indexPath) as! PromotionsCollectionViewCell
        
        // Configure the cell
        let cellNumber = (indexPath as NSIndexPath).row
        
        let results: NSArray = self.resultsArray!
        let temp = results[cellNumber] as! NSDictionary
        var promotionInfo = [String: AnyObject]()
        promotionInfo = temp as! Dictionary
        
        let name: String = promotionInfo["barName"]! as! String
        let start: String = promotionInfo["startDate"]! as! String
        let end: String = promotionInfo["endDate"]! as! String
        let time: String = parseTime(startDate: start, endDate: end)
        let description: String = promotionInfo["description"]! as! String
        let promotionTitle: String = promotionInfo["name"]! as! String
        
        cell.nameLabel.text = name
        cell.timeLabel.text = time
        cell.descriptionLabel.text = description
        cell.promotionTitle.text = promotionTitle
        
        return cell
    }
    
    
    
}

