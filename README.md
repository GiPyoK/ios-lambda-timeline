# Lambda Timeline 

## Introduction

The goal of this project is to take an existing project called LambdaTimeline and add features to it throughout this sprint. 

<<<<<<< HEAD
<<<<<<< HEAD
Today you will be adding audio comments.

## Instructions

Create a new branch in the repository called `audioComments` and work off of it from where you left off yesterday.

You're welcome to fulfill these instructions however you want. If you'd like suggestions on how to implement something, open the disclosure triangle and there are some suggestions for most of the instructions.

1. Create UI that allows the user to create an audio comment. The UI should allow the user to record, stop, cancel, and send the recording.
    <details><summary>Recording UI Suggestions</summary>
    <p>

      - In the `ImagePostDetailViewController`, change the `createComment` action to allow the user select whether they want to make a text comment or an audio comment, then create a new view controller with the required UI. The view controller could be presented modally or as a popover.
      
      - Alternatively, you could modify the `ImagePostDetailViewController` to hold the audio recording UI.

    </p>
    </details>
    
2. Create a new table view cell that displays at least the author of the audio comment, and a button to play the comment.

3. Change the `Comment` to be either a text comment or an audio comment.

    <details><summary>Comment Suggestions</summary>
    <p>

    - In the `Comment` object, change the `text`'s type to be an optional string, and create a new `audioURL: URL?` variable as well. Modify the `dictionaryRepresentation` and the `init?(dictionary: ...)` to accomodate the `audioURL` and the now optional `text` string.

    </p>
    </details>

4. In the `PostController`, add the ability to create a comment with the audio data that the user records, and save it to Firebase Storage, add the comment to its post, then save the post to the Firebase Database.

    <details><summary>Post Controller Suggestions</summary>
    <p>

      - Create a separate function to create a comment with the audio data.
      - You can very easily change the `store` method to instead take in data and a `StorageReference` to accomodate for storing both Post media data and now the audio data as well.

    </p>
    </details>
5. In the `ImagePostDetailViewController`, make sure that the audio is being fetched for the audio comments. You are welcome to fetch the audio for each audio comment however you want.

    <details><summary>Audio Fetching Suggestions</summary>
    <p>

      - You can implement the audio fetching similar to the way images are fetched on the `PostsCollectionViewController` by using operations, an operation queue, and a new cache. Make a new subclass of `ConcurrentOperation` that fetches audio using the comment's `audioURL` and a `URLSessionDataTask`.

    </p>
    </details>

6. Implement the ability to play a comment's audio from the new audio comment cell from step 2. As you implement the `AVAudioRecorder`, remember to add a microphone usage description in the Info.plist.

## Go Further

- Add a label (if you don't have one already) to your recording UI that will show the recording time as the user is recording.
- Change the audio comment cell to display the duration of the audio, as well as show the current time the audio is at when playing.
=======
Today you will be adding video posts.

## Instructions

Create a new branch in the repository called `videoPosts` and work off of it from where you left off yesterday.

You're welcome to fulfill these instructions however you want. There are a few suggestions to help you along if you need them.

1. Create UI that allows the user to create a video post. The UI should allow the user to record a video. Once the video has been recorded, it should play back the video (the playback can be looped if you want), allow the user to add a title just like in an image post, then post it.
    <details><summary>Recording UI Suggestions</summary>
    <p>

      - You may take the `CameraViewController` used in the guided project as a base. You will need to modify it so the video doesn't get stored to the user's photo library, but instead you can use the url that the `didFinishRecordingTo outPutFileURL: URL` method gives you back to send the video data to Firebase
      - For information on how to play back the video, refer to `AVPlayer` and `AVPlayerLayer` in the documentation. Of course you're welcome to google for more information, but familiarize yourself with these objects first.

    </p>
    </details>
2. Add a new case to the `MediaType` enum in the Post.swift file for videos. Take a look at the memberwise initializer for the Post. Make sure that it takes in a `MediaType` and sets `mediaType` correctly.
3. Create a new collection view cell in the `PostsCollectionViewController`. It should display the video, as well as the post's title and author. It's up to you if you want the video to play automatically or have it play when you tap the cell, or a button, etc.
4. Create a detail view controller for video posts similar to the `ImagePostDetailViewController`. It should display the post's video, title, artist, and its comments. It should also allow the user to add their own text and audio comments.

## Go Further

- Add the ability to record audio with the video. When the video plays on a cell or in the video post view controller, the audio should play as well.
- Add the ability to record from the front camera and let the user flip the cameras.
- Add the option to save the video to the user's photo library
>>>>>>> ff97e3b9a81c53162a75fa2efd2c91682627745c
=======
Today you will be adding geotagging to posts.

## Instructions

Create a new branch in the repository called `postGeotags` and work off of it from where you left off yesterday.

You're welcome to fulfill these instructions however you want. If you'd like suggestions on how to implement something, open the disclosure triangle and there are some suggestions for you. Of course, you can also ask the PMs and instructors for help as well.

1. Add a `geotag: CLLocationCoordinate2D?` property as well. The user should have the choice to geotag posts or not.

2. You will need to make an `MKAnnotation` that represents a `Post`. The annotation's title should be the post's title and the subtitle should be the name of the post's author. You have at least two options on how to do this:
    a. Change the `Post` object to adopt and conform to the `MKAnnotation` protocol. 
    b. Create a separate object called `PostAnnotation` or something similar that conforms to `MKAnnotation`. The `PostAnnotation` could get its values from a `Post` that is passed into an initializer.

Either way you decide to do this has its pros and cons, so choose whatever makes the most sense to you.

3. Update the `dictionaryRepresentation` and both initializers to account for the property (or properties). 
    - **Note:** Firebase will not store a `CLLocationCoordinate2D`, so you must break it up into a key-value pair for both the latitude and longitude in the `dictionaryRepresentation`.
4. Update the `PostController` to account for creating posts with and without geotags.
5. Create a helper class that will take care of requesting location usage authorization from the user, as well as getting their current location in order to geotag a post that is being created. This can be done through using `CLLocationManager` and `CLLocationManagerDelegate`.
    - **Note:** For the base requirements of this project, every post that should be geotagged will just use the user's current location.
6. Update the UI for creating **image and video** posts to allow the user to choose whether to geotag their posts or not.
7. In the Main.storyboard, embed the navigation controller in a tab bar controller. Add a new view controller scene with a map view on it. There are a few things that you will have to change now that the tab bar is essentially the first view controller to be displayed once the user is authenticated.
    <details><summary>Hints</summary>
    <p>

      - As the map view controller is going to need access to the same instance of `PostController` as the rest of the app uses, consider creating a subclass of `UITabBarController` and initializing a `PostController` there instead of the `PostsCollectionViewController`. That way, the tab bar controller can pass references to it to both the `PostsCollectionViewController` and the new map view controller.
      - In the `AppDelegate` the way the navigation controller holding the `PostsCollectionViewController` becomes the initial view controller if the user is authenticated is by initializing it from the storyboard with a Storyboard ID. You will need to give the tab bar controller a storyboard ID and use it instead of the navigation controller's that is currently used. If you are unfamiliar with how this works, [this Stack Overflow question](https://stackoverflow.com/questions/13867565/what-is-a-storyboard-id-and-how-can-i-use-this) gives a straight answer.

    </p>
    </details>

7. The map view controller should take the posts from the post controller that have geotags, and place annotations on the map view for each of them.

## Go Further

- Add the ability for the user to select a place to geotag the post at. This can be done a number of ways:
    - Use a map view and let them drop a pin (annotation) on it. You can then get the coordinate from the pin.
    - Use `MKLocalSearch` to let the user search for a location.

You are encouraged to implement both methods if you feel up to it.

- Customize the annotations that are shown on the map view controller to also show the media (image or video) associated with it. **Note:** if you chose to create a `PostAnnotation` object, you may need to modify it so you can have more information than just the post's title and author.
- Add the ability to go directly to the detail view controller of a post (the one with the post's comments) from the annotation.
>>>>>>> fb36dc3cde127cd078878bfeee92696db3258a44
