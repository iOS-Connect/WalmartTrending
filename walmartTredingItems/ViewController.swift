import UIKit

let APIKey = "v29uycrkdrkzgaah45pupzsn"
let baseURL = "https://api.walmartlabs.com/v1/trends"

// http://api.walmartlabs.com/v1/trends?format=json&apiKey=v29uycrkdrkzgaah45pupzsn

class ViewController: UICollectionViewController {

    var names = [String]()
    var images = [String]()

    override func viewDidLoad() {
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout

        layout.estimatedItemSize = CGSize(width: 175 , height: 50)
        getItems()
    }

    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return names.count
    }

    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let newCell = collectionView
                      .dequeueReusableCellWithReuseIdentifier("Cell",
                                                              forIndexPath: indexPath) as! LabelCell
        newCell.label.text = names[indexPath.row]
        fetchImage(images[indexPath.row]){ image in
            newCell.image.image = image
        }
        return newCell
    }

    func fetchImage(imageURL:String, completion: (image: UIImage?) -> ()) {
        //get image from from URL

        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string:imageURL)!) {
            (data, response, error) in
            let image = UIImage(data:data!)
            dispatch_async(dispatch_get_main_queue()){
                completion(image: image)
            }
        }
        task.resume()
    }


    func getItems() {
        let url = NSURL(string: baseURL+"?format=json&apiKey=\(APIKey)")!
        let task = NSURLSession.sharedSession()
            .dataTaskWithURL(url) { (data, response, error) in
                guard error == nil else {
                    return print("Something bad \(error!.localizedDescription)")
                }
                guard let data = data else {
                    return print("No Data! Sorry Bro")
                }
                guard let json = try! NSJSONSerialization
                                 .JSONObjectWithData(data, options: []) as? NSDictionary else {
                    return print("Not a dictionary")
                }
                guard let items = json["items"] as? NSArray else {
                    return print("No ites")
                }
                for thing in items {
                    guard let trendingItem = thing as? NSDictionary else {
                        continue
                    }

                    let name = trendingItem["name"] as! String
                    let image = trendingItem["thumbnailImage"] as! String
                    self.names.append(name)
                    self.images.append(image)
                }
                dispatch_async(dispatch_get_main_queue(), { 
                    self.collectionView?.reloadData()
                })
        }
        task.resume()
    }
}

class LabelCell : UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var image: UIImageView!
}
