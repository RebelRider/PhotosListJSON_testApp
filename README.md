Photos List JSON  is an example application developed in Swift/UIKit and without the use of Storyboards. Model-View-ViewModel (MVVM) architecture.

#############################################################
####################### Functionality #######################
#############################################################

- **Asynchronous Data Fetching**: The application fetches JSON data from the API and parses it into model objects. This operation is performed asynchronously to ensure the user interface remains responsive.

- **Image Loading**: The application asynchronously loads thumbnail images for each photo. When a thumbnail is tapped, the application fetches and displays the full-sized image.

- **Image Caching**: To minimize network usage, all images are cached locally. This means that once an image has been loaded, it does not need to be fetched from the network again.

- **Image Filtering**: Users can filter the displayed images based on the album number or the text description. This makes it easy to find specific images. The filtering logic is implemented in the ViewModel, which filters the photos based on the user's input and updates the view state to reflect the filtered photos.

- **Favorites Management**: Users can mark images as favorites. The favorite status of each image is persisted across app launches (with UserDefaults storage). This is managed by the FavoritesModel.

#############################################################
################### Technical Details #######################
#############################################################

### AppModel

AppModel is the central data management class in the application. It fetches all photos from the remote JSON endpoint and organizes them into two dictionaries: one mapping photo IDs to PhotoInfo objects, and another mapping album IDs to arrays of PhotoInfo objects.
AppModel is implemented as a singleton, ensuring that there is only one instance of the class throughout the application. This single instance is responsible for fetching and storing all the photos, making the photos easily accessible from anywhere in the app.
When AppModel fetches the photos, it also sorts them into albums. Each album is represented by an integer ID, and the photos in each album are stored in an array. 
AppModel also provides a mechanism to notify other parts of the application when the data changes. It does this through the onModelChange closure. When the photos are fetched and sorted into albums, AppModel calls this closure to notify the rest of the application that the data has changed.

### FavoritesModel

FavoritesModel is a separate class that manages the favorite status of photos. It maintains a set of photo IDs that have been marked as favorites. This set is persisted across app launches using UserDefaults. By separating this functionality into its own class, the code is more modular and easier to maintain. It also allows the favorite status of photos to be managed independently of the rest of the photo data.

### ViewModel Protocol

The ViewModel protocol defines the basic structure of a ViewModel in the application. It declares an associated type ViewState and a typealias RenderStateCallback for a closure that takes a ViewState as an argument. It also declares a method setRenderCallback(_:) that sets the callback to be used when the view state changes.
The RenderStateCallback is a key part of the MVVM architecture. It allows the ViewModel to communicate changes in its state to the View, which can then update its appearance to reflect the new state. The View calls setRenderCallback(_:) method, passing in its implementation of the RenderStateCallback closure. This allows the ViewModel to call the View’s closure whenever its state changes.

### PhotoCollectionViewModel

PhotoCollectionViewModel is a class that conforms to the ViewModel protocol and manages the state for a photo collection view. It fetches data from the AppModel, manages the favorite status of photos using a FavoritesModel, and notifies the view when the state changes.

### PhotoCollectionViewCell

PhotoCollectionViewCell is a custom collection view cell that displays a photo thumbnail, the album number, the photo title, and a favorite button. The favorite button’s image changes based on whether the photo is marked as a favorite. The `setData()` method is used to set the data for each cell. It takes a thumbnail URL, an album number, a title, and a boolean indicating whether the photo is a favorite. It uses the thumbnail URL to asynchronously load the thumbnail image and updates the UI elements with the provided data. This method is essential because it allows the cell to display the correct data for each photo.

### PhotoDetailViewController

PhotoDetailViewController is a view controller that displays the details of a photo. It shows a full-sized image, the photo title, and a favorite button. The favorite button’s image changes based on whether the photo is marked as a favorite. 
The `showPhotoDetailView()` method is used to animate the transition from the thumbnail image to the full-sized image. This method calculates the final frame for the image view and then uses an animation to transition the image view from its initial frame to the final frame.
The `hidePhotoDetailView(_:)` method is used to animate the transition back to the thumbnail image. It uses an animation to transition the image view from its current frame back to its initial frame. This creates a smooth zooming effect as the image transitions from the full size back to the thumbnail size. Without this method, the transition would be abrupt and not as visually pleasing.
In PhotoDetailViewController, a private instance of FavoritesModel is created. This instance is used to manage the favorite status of the photo being displayed. This design pattern is known as Dependency Injection, which allows the PhotoDetailViewController to be independent of other classes or instances of FavoritesModel.
