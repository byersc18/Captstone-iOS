//
//  PromotionsViewController.swift
//  Bar Hopper
//
//  Created by Cameron Byers on 4/3/18.
//  Copyright © 2018 Cameron Byers. All rights reserved.
//

import UIKit
import CoreLocation

class PromotionsViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //variables for side slide menu
    @IBOutlet var viewConstraint: NSLayoutConstraint!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var sideView: UIView!
    

    var locationManager = CLLocationManager()
    var numCells: Int = 0
    var resultsArray: NSArray?
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var locationTextView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //set some attributes for side menu
        /*
        blurView.layer.cornerRadius = 15
        blurView.layer.shadowColor = UIColor.black.cgColor
        blurView.layer.shadowOpacity = 1
        blurView.layer.shadowOffset = CGSize(width: 5, height: 0)
         */
        viewConstraint.constant = -150
        
    
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Dismiss keyboard when background is tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PromotionsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //get current location as coordinates
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            //coordinates
            let long = Double((locationManager.location?.coordinate.longitude)!)
            let lat = Double((locationManager.location?.coordinate.latitude)!)
            
            let longString: String = String(format:"%f", long)
            let latString: String = String(format:"%f", lat)
            
            print(longString)
            print(latString)
            
            //MAKE API CALL HERE
            let urlString = "https://barhopperapi.herokuapp.com/api/promotions/loc/%5B" + longString + ",%20" + latString + "%5D"
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
    
    //get coordinates from a address
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate, error)
        }
    }
    
    //get bars in a certain area specified by the user
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        getCoordinateFrom(address: locationTextView.text) { coordinate, error in
            guard let coordinate = coordinate, error == nil else { return }
            // don't forget to update the UI from the main thread
            DispatchQueue.main.async {
                print(coordinate)
                
                let lat = coordinate.latitude
                let long = coordinate.longitude
                
                let latString: String = String(format:"%f", lat)
                let longString: String = String(format:"%f", long)
                
                //MAKE API CALL HERE
                let urlString = "https://barhopperapi.herokuapp.com/api/promotions/loc/%5B" + longString + ",%20" + latString + "%5D"
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
                
                //update collection view
                self.collectionView.reloadData()
            }
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Promotion", for: indexPath) as! PromotionsCollectionViewCell
        
        // Configure the cell        
        let cellNumber = (indexPath as NSIndexPath).row
        
        let results: NSArray = self.resultsArray!
        let temp = results[cellNumber] as! NSDictionary
        var promotionInfo = [String: AnyObject]()
        promotionInfo = temp as! Dictionary
        
        let name: String = promotionInfo["barName"]! as! String
        let start: String = promotionInfo["startDate"]! as! String
        let end: String = promotionInfo["endDate"]! as! String
        let description: String = promotionInfo["description"]! as! String
        
        cell.nameLabel.text = name
        cell.timeLabel.text = start + " " + end
        cell.descriptionLabel.text = description
        
        return cell
    }
    
    

}
