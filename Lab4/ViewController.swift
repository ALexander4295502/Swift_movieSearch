//
//  ViewController.swift
//  Lab4
//
//  Created by Alexander on 2017/2/15.
//  Copyright © 2017年 Zheng Yuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDataSource,UISearchBarDelegate {
    
    let theAlert = UIAlertController(title: "Notice", message: "Please enter the name in search bar", preferredStyle: UIAlertControllerStyle.alert)
    var myIndicator = UIActivityIndicatorView()
    var myArray:[MovieCell] = []
    var myFavorite:[String] = []
    var emptyArray:[MovieCell] = []
    
    @IBOutlet weak var theSearchBar: UISearchBar!
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    var passMovieInfo:MovieCell? = nil
    
    var searchActive:Bool = false
    var searchFinish:Bool = false
    var segueBackFinish:Bool = false
    
    func activityIndicator(){
        myIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        myIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        myIndicator.center = self.view.center
        self.view.addSubview(myIndicator)
        myIndicator.bringSubview(toFront: self.view)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    

    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = true
        let searchText:String = searchBar.text!
        activityIndicator()
        self.myIndicator.startAnimating()
        self.myIndicator.backgroundColor = UIColor.white
        DispatchQueue.global().async {
            if !searchText.isEmpty {
                self.searchFinish = false
                self.loadData(searchName: searchText)
                //print(searchText)
            }
            DispatchQueue.main.async {
                self.searchFinish = true
                self.theCollectionView.reloadData()
                print("first load the array size =\(self.myArray.count)")
                self.myIndicator.stopAnimating()
                self.myIndicator.hidesWhenStopped = true
            }
        }

        
        //        if(myArray.count == 0){
        //            searchActive = false
        //        } else {
        //            searchActive = true
        //        }
        
        
        print("search button click")
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "movieDetail"){
            let destination = segue.destination as? DetailViewController
//            let cell = sender as! UICollectionViewCell
            let selectedIndex = self.theCollectionView.indexPathsForSelectedItems?.first?.row
            destination?.passMovieCell = myArray[selectedIndex!]
            segueBackFinish = false
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(searchActive == true || searchFinish == true){
            return myArray.count
        }
        return emptyArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath)
        if((searchActive == true || segueBackFinish == true) && searchFinish == true ){
            //print("I am here to update collection cell")
            let theLabel = UILabel(frame: CGRect(x: 0, y: 100, width: 120, height: 50))
            theLabel.text = myArray[indexPath.row].title
            
            theLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            theLabel.numberOfLines = 0
            theLabel.textAlignment = NSTextAlignment.center
            theLabel.font = UIFont.systemFont(ofSize: 11)
            theLabel.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
            do
            {
                //print(myArray[0].poster)
                cell.backgroundView = UIImageView(image: myArray[indexPath.row].poster)
                cell.backgroundView?.addSubview(theLabel)
                
                if(myFavorite.contains(myArray[indexPath.row].imdbID)){
                
                    let theFavView = UIImageView(frame: CGRect(x: 90, y: 15, width: 20, height: 20))
                    theFavView.tag = 2
                    theFavView.image = UIImage(named: "Heart-icon")
                    cell.backgroundView?.addSubview(theFavView)
                }else{
                    if let foundView = cell.backgroundView?.viewWithTag(2) {
                        foundView.removeFromSuperview()
                        print("delete subview")
                    }
                    
                }
                
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = UIColor.black.cgColor
                //cell.backgroundColor = UIColor.black
                //print("Iam in UIimage contents")
            } catch {
                exit(1)
            }
        }

        return cell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        for pageIndex in 1..<3{
//            loadData(searchName: "star", pageNum: pageIndex)
//        }

        theAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        theCollectionView.dataSource = self
        theSearchBar.delegate = self
        loadDatabase()
        self.present(theAlert, animated: true, completion: nil)

    }
    
    
    
    func loadData(searchName:String){
        myArray.removeAll()
        for pageNum in 1...3 {
            let urlOmdb:String = "https://www.omdbapi.com/?s=\(searchName)&page=\(pageNum)&r=json"
            var movieDatas:JSON = getJSON(path: urlOmdb)
            if(movieDatas == JSON.null){
                print("data not found")
            }else{
                for index in 0..<movieDatas["Search"].count{
                    let titleJSON = movieDatas["Search"][index]["Title"]
                    //print("titleJSON = \(movieDatas)")
                    //print("titleJSON = \(movieDatas["Search"][0]["Title"])")
                    let posterJSON = movieDatas["Search"][index]["Poster"]
                    
                    let imdbIDJSON = movieDatas["Search"][index]["imdbID"]
                    
                    do{
                        let myImage = UIImage(data: try Data(contentsOf: URL(string: posterJSON.stringValue)!))
                        self.myArray.append(MovieCell(titleIn: titleJSON.stringValue, posterIn: myImage!, imdbIDIn: imdbIDJSON.stringValue))
                    } catch {
                        self.myArray.append(MovieCell(titleIn: titleJSON.stringValue, posterIn: UIImage(named: "No-image-found")!, imdbIDIn: imdbIDJSON.stringValue))
                    }
                }
            }
        }

        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        segueBackFinish = true
        print("second load the array size =\(myArray.count)")
        print("SearchAcvite = \(searchActive)")
        print("SearchFinish = \(searchFinish)")
        print("segueBackFinish = \(segueBackFinish)")
        loadDatabase()
        if(searchFinish == true){
            //print("before layoutifneeded")
            //theCollectionView.layoutIfNeeded()
            //print("before reload data")
            theCollectionView.reloadData()
            //print("You are back!!!!!!!")
            //theCollectionView.reloadData()
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if(searchFinish == true){
//            print("before layoutifneeded")
//            theCollectionView.layoutIfNeeded()
//            print("before reload data")
//            theCollectionView.reloadData()
//            print("You are back!!!!!!!")
//            //theCollectionView.reloadData()
//        }
//    }
    
    private func getJSON(path:String) -> JSON{
        guard let url = URL(string: path) else{ return JSON.null}
        //print(url)
        do {
            let data = try Data(contentsOf: url)
            return JSON(data: data)
        } catch {
            return JSON.null
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDatabase(){
        myFavorite.removeAll()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let thePath = delegate.favoriteDbPathInDocument
        let contactDB = FMDatabase(path: thePath)
        
        if !(contactDB?.open())!{
            print("Unable to open db")
            return
        } else {
            do {
                let results = try contactDB?.executeQuery("select * from favorite", values: nil)
                while(results?.next())!{
                    let someName = results?.string(forColumn: "name")
                    let someID = results?.string(forColumn: "imdbid")
                    myFavorite.append(someID!)
                }
                contactDB?.close()
            } catch let error as NSError {
                contactDB?.close()
                //print("failed \(error)")
            }
        }
        
    }


}

