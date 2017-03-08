//
//  secondViewController.swift
//  Lab4
//
//  Created by Alexander on 2017/2/16.
//  Copyright © 2017年 Zheng Yuan. All rights reserved.
//

import UIKit

class secondViewController: UIViewController,UITableViewDataSource {
    
    @IBOutlet weak var theTableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tableDetail"){
            let destination = segue.destination as? DetailViewController
            //            let cell = sender as! UICollectionViewCell
            let selectedIndex = self.theTableView.indexPathsForSelectedRows?.first?.item
            destination?.passMovieCell = myArray[selectedIndex!]
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            self.theTableView.beginUpdates()
            let deleteId:String = myArray[indexPath.row].imdbID
            myArray.remove(at: indexPath.row)
            self.theTableView.deleteRows(at: [indexPath], with: .fade)
            self.theTableView.endUpdates()
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let thePath = delegate.favoriteDbPathInDocument
            let contactDB = FMDatabase(path: thePath)
            
            if !(contactDB?.open())!{
                print("Unable to open db")
                return
            } else {
                do {
                    try contactDB?.executeUpdate("delete from favorite where imdbid=?", values: ["\(deleteId)"])
                    contactDB?.close()
                } catch let error as NSError {
                    contactDB?.close()
                    print("failed \(error)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "tableMovieCell", for: indexPath)
        myCell.textLabel?.text = myArray[indexPath.row].title
        myCell.imageView?.image = myArray[indexPath.row].poster
        return myCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDatabase()
        theTableView.reloadData()
    }
    
    var myArray:[MovieCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //myArray.removeAll()
        loadDatabase()
        theTableView.dataSource = self
    }
    
    func loadDatabase(){
        myArray.removeAll()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let thePath = delegate.favoriteDbPathInDocument
        let contactDB = FMDatabase(path: thePath)
        
        if !(contactDB?.open())!{
            //print("Unable to open db")
            return
        } else {
            do {
                let results = try contactDB?.executeQuery("select * from favorite", values: nil)
                while(results?.next())!{
                    let someName = results?.string(forColumn: "name")
                    let someId = results?.string(forColumn: "imdbid")
                    myArray.append(MovieCell(titleIn: someName!, posterIn: getImage(imdbIdIn: someId!), imdbIDIn: someId!))
                }
                contactDB?.close()
            } catch let error as NSError {
                contactDB?.close()
                //print("failed \(error)")
            }
        }
        
    }
    
    func getImage(imdbIdIn:String) -> UIImage{
        let urlOmdb:String = "https://www.omdbapi.com/?i=\(imdbIdIn)&plot=short&r=json"
        var movieDatas:JSON = getJSON(path: urlOmdb)
        if(movieDatas == JSON.null){
            print("data not found")
            return UIImage(named: "No-image-found")!
        }else{
            let posterJSON = movieDatas["Poster"]
            do{
                let myImage = UIImage(data: try Data(contentsOf: URL(string: posterJSON.stringValue)!))
                return myImage!
            } catch {
                return UIImage(named: "No-image-found")!
            }
        }

    }
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
