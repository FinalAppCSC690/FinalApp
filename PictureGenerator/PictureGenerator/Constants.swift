import Foundation

let apiKey = "300d72e62bb0b9d72124606653ad9945"

func flickrUrl(forApiKey key : String , withAnnotation annotation: DroppingPin , andNumberOfPhotos number : Int) -> String {
    
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    
}
