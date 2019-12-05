# Lambda Timeline 

## Introduction

The goal of this project is to take an existing project called LambdaTimeline and add features to it throughout this sprint. 

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
