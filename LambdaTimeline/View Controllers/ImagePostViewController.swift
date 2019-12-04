//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

enum Filters: String {
    case CIHueAdjust
}

class ImagePostViewController: ShiftableViewController {
    
    private let context = CIContext(options: nil)
    
    private var xFactor: Float = 1
    private var yFactor: Float = 1
    private var scaleFactor: Float = 1
    
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            filterView.isHidden = false
            var scaledSize = imageView.bounds.size
            
            // 1x 2x 3x (400 points * 3x = 1200 pixels)
            let scale = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
            
            guard let scaledImage = scaledImage else { return }
            
            // set origin factor
            xFactor = Float(originalImage.size.width / scaledImage.size.width)
            yFactor = Float(originalImage.size.height / scaledImage.size.height)
            scaleFactor = Float((originalImage.size.width * originalImage.size.height) / (scaledImage.size.width * scaledImage.size.height))
            
            // set min max for zoom blur slider
            zoomBlurXValueSlider.minimumValue = 0
            zoomBlurXValueSlider.maximumValue = Float(scaledImage.size.width)
            zoomBlurXValueSlider.value = zoomBlurXValueSlider.maximumValue / 2
            
            zoomBlurYValueSlider.minimumValue = 0
            zoomBlurYValueSlider.maximumValue = Float(scaledImage.size.height)
            zoomBlurYValueSlider.value = zoomBlurYValueSlider.maximumValue / 2
            
            // reset zoom blur value
            zoomBlurValueSlider.value = 0
            
            // set min max for hue slider
            hueSlider.minimumValue = -3.14
            hueSlider.maximumValue = 3.14
            hueSlider.value = 0
            
            // set min max for hole distortion
            holeDistortionXSlider.minimumValue = 0
            holeDistortionXSlider.maximumValue = Float(scaledImage.size.width)
            holeDistortionXSlider.value = holeDistortionXSlider.maximumValue / 2
            
            holeDistortionYSlider.minimumValue = 0
            holeDistortionYSlider.maximumValue = Float(scaledImage.size.height)
            holeDistortionYSlider.value = holeDistortionYSlider.maximumValue / 2
            
            holeDistortionValueSlider.value = 0.1
            holeDistortionValueSlider.minimumValue = 0.01
            holeDistortionValueSlider.maximumValue = 1000
            
            // set min max for Op Tile
            opTileCenter = CIVector(x: CGFloat(scaledImage.size.width/2), y: CGFloat(scaledImage.size.height/2))
            
            opTileAngleSlider.minimumValue = -3.14
            opTileAngleSlider.maximumValue = 3.14
            opTileAngleSlider.value = 0
            
            opTileScaleSlider.minimumValue = 0.1
            opTileScaleSlider.maximumValue = 10
            opTileScaleSlider.value = 1
            
            opTileWidthSlider.minimumValue = 1
            opTileWidthSlider.maximumValue = 1000
            opTileWidthSlider.value = 65
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateFilters()
        }
    }
    @IBOutlet weak var filterView: UIView!
    
    // Hue Properties
    @IBOutlet weak var hueValueLabel: UILabel!
    @IBOutlet weak var hueSlider: UISlider!
    
    private let hueFilter = CIFilter(name: Filters.CIHueAdjust.rawValue)!
    
    // Zoom Blur Properties
    @IBOutlet weak var zoomBlurXValueLabel: UILabel!
    @IBOutlet weak var zoomBlurYValueLabel: UILabel!
    @IBOutlet weak var zoomBlurValueLabel: UILabel!
    @IBOutlet weak var zoomBlurXValueSlider: UISlider!
    @IBOutlet weak var zoomBlurYValueSlider: UISlider!
    @IBOutlet weak var zoomBlurValueSlider: UISlider!
    
    // Comic Effect Property
    @IBOutlet weak var comicEffectSwitch: UISwitch!
    
    // Hole Distortion Properties
    @IBOutlet weak var holeDistortionXLabel: UILabel!
    @IBOutlet weak var holeDistortionYLabel: UILabel!
    @IBOutlet weak var holeDistortionValueLabel: UILabel!
    @IBOutlet weak var holeDistortionXSlider: UISlider!
    @IBOutlet weak var holeDistortionYSlider: UISlider!
    @IBOutlet weak var holeDistortionValueSlider: UISlider!
    
    // Op Tile Properties
    @IBOutlet weak var opTileAngleLabel: UILabel!
    @IBOutlet weak var opTileWidthLabel: UILabel!
    @IBOutlet weak var opTileSacleLabel: UILabel!
    @IBOutlet weak var opTileAngleSlider: UISlider!
    @IBOutlet weak var opTileWidthSlider: UISlider!
    @IBOutlet weak var opTileScaleSlider: UISlider!
    private var opTileCenter: CIVector?
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
        
        if originalImage == nil {
            filterView.isHidden = true
        }
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }
    
    private func updateFilters() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func filterImage(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage, let opTileCenter = opTileCenter else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Hue
        hueFilter.setValue(ciImage, forKey: "inputImage")
        hueFilter.setValue(hueSlider.value, forKey: "inputAngle")
        
        // Zoom Blur
        let zoomBlurCenter = CIVector(x: CGFloat(zoomBlurXValueSlider!.value), y: CGFloat(zoomBlurYValueSlider!.value))
        let zoomBlurImage = hueFilter.outputImage!.applyingFilter("CIZoomBlur", parameters: ["inputCenter" : zoomBlurCenter, "inputAmount": zoomBlurValueSlider.value])
        
        // Comic Effect
        var comicImage: CIImage
        if comicEffectSwitch.isOn {
            comicImage = zoomBlurImage.applyingFilter("CIComicEffect")
        } else {
            comicImage = zoomBlurImage
        }
        
        // Hole Distortion
        let holeDistortionCenter = CIVector(x: CGFloat(holeDistortionXSlider!.value), y: CGFloat(holeDistortionYSlider!.value))
        let holeDistortionImage = comicImage.applyingFilter("CIHoleDistortion", parameters: ["inputCenter" : holeDistortionCenter, "inputRadius" : holeDistortionValueSlider.value])
        
        // Op Tile
        let opTileImage = holeDistortionImage.applyingFilter("CIOpTile", parameters: ["inputCenter" : opTileCenter, "inputScale" : opTileScaleSlider.value, "inputAngle" : opTileAngleSlider.value, "inputWidth" : opTileWidthSlider.value])
        
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(opTileImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func presentImagePickerController() {
    
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        // apply origin factors
        zoomBlurXValueSlider.value *= xFactor
        zoomBlurYValueSlider.value *= yFactor
        
        holeDistortionXSlider.value *= xFactor
        holeDistortionYSlider.value *= yFactor
        
        if let originalImage = originalImage {
            self.opTileCenter = CIVector(x: CGFloat(originalImage.size.width/2), y: CGFloat(originalImage.size.height/2))
            //opTileScaleSlider.value *= scaleFactor
            opTileWidthSlider.value *= scaleFactor
        }
        
        guard let originalImage = originalImage, let imageData = filterImage(originalImage).jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    
    @IBAction func hueValueChanged(_ sender: UISlider) {
        updateFilters()
        hueValueLabel.text = String(format: "%.2f", hueSlider.value)
    }
    @IBAction func zoomBlurXValueChanged(_ sender: Any) {
        updateFilters()
        zoomBlurXValueLabel.text = "x: " + String(format: "%.2f", zoomBlurXValueSlider.value)
    }
    @IBAction func zoomBlurYValueChanged(_ sender: Any) {
        updateFilters()
        zoomBlurYValueLabel.text = "y: " + String(format: "%.2f", zoomBlurYValueSlider.value)
    }
    @IBAction func zoomBlurAmountValueChanged(_ sender: Any) {
        updateFilters()
        zoomBlurValueLabel.text = String(format: "%.2f", zoomBlurValueSlider.value)
    }
    @IBAction func comicEffectValueChanged(_ sender: Any) {
        updateFilters()
    }
    @IBAction func holeDistortionXChanged(_ sender: Any) {
        updateFilters()
        holeDistortionXLabel.text = "x: " + String(format: "%.2f", holeDistortionXSlider.value)
    }
    @IBAction func holeDistortionYChanged(_ sender: Any) {
        updateFilters()
        holeDistortionYLabel.text = "y: " + String(format: "%.2f", holeDistortionYSlider.value)
    }
    @IBAction func holeDistortionValueChanged(_ sender: Any) {
        updateFilters()
        holeDistortionValueLabel.text = String(format: "%.2f", holeDistortionValueSlider.value)
    }
    @IBAction func opTileAngleChanged(_ sender: Any) {
        updateFilters()
        opTileAngleLabel.text = "Angle: " + String(format: "%.2f", opTileAngleSlider.value)
    }
    @IBAction func opTileWidthChanged(_ sender: Any) {
        updateFilters()
        opTileWidthLabel.text = "Width: " + String(format: "%.2f", opTileWidthSlider.value)
    }
    @IBAction func opTileScaleChanged(_ sender: Any) {
        updateFilters()
        opTileSacleLabel.text = "Scale: " + String(format: "%.2f", opTileScaleSlider.value)
    }
    
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        originalImage = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
