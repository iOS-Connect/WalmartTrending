import UIKit

let APIKey = "v29uycrkdrkzgaah45pupzsn"
let baseURL = "https://api.walmartlabs.com/v1/trends"

// http://api.walmartlabs.com/v1/trends?format=json&apiKey=v29uycrkdrkzgaah45pupzsn

class ViewController: UICollectionViewController {

    var trendingItems = [TrendingItem]()

    override func viewDidLoad() {
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout

        layout.estimatedItemSize = CGSize(width: 175 , height: 50)
        
        Networking.getItems { [weak self] (items) in
            self?.trendingItems = items
            self?.collectionView?.reloadData()
        }
    }

    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return trendingItems.count
    }

    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let newCell = collectionView
                      .dequeueReusableCellWithReuseIdentifier("Cell",
                                                              forIndexPath: indexPath) as! LabelCell
        newCell.label.text = trendingItems[indexPath.row].name
        Networking.fetchImage(trendingItems[indexPath.row].imageURL){ image in
            newCell.image.image = image
        }
        return newCell
    }

}

class Networking {

    static func fetchImage(imageURL:String, completion: (image: UIImage?) -> ()) {
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


    static func getItems(completion:([TrendingItem])->()) {
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
                var newItems = [TrendingItem]()
                for thing in items {
                    guard let newItem = TrendingItem(json: thing) else { continue }
                    newItems.append(newItem)
                }

                dispatch_async(dispatch_get_main_queue(), {
                    completion(newItems)
                })
        }
        task.resume()
    }
}

struct TrendingItem {
    var name: String
    var imageURL: String

    init?(json: AnyObject) {
        guard let trendingItem = json as? NSDictionary,
            let name = trendingItem["name"] as? String,
            let image = trendingItem["thumbnailImage"] as? String else {
            return nil
        }
        self.name = name
        self.imageURL = image
    }
}

class LabelCell : UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var image: UIImageView!
}
