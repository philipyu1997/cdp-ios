//
//  ViewController.swift
//  CDP
//
//  Created by Philip Yu on 4/28/20.
//  Copyright © 2020 Philip Yu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set class as delegate
        imagePicker.delegate = self
        
    }
    
    // MARK: - IBAction Section
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.allowsEditing = false
        
        // Present camera, if available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera is available 📸")
            imagePicker.sourceType = .camera
            
            // Present photo library
        } else {
            print("Camera 🚫 available so we will use photo library instead")
            imagePicker.sourceType = .photoLibrary
            // Present imagePicker source type (either camera or library)
        }
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    // MARK: - Private Function Section
    
    private func detect(image: CIImage) {
        
        // Create model using PetImageClassifier
        guard let model = try? VNCoreMLModel(for: PetImageClassifier().model) else {
            fatalError("Failed to load CoreML model.")
        }
        
        // Process image using ML model
        let request = VNCoreMLRequest(model: model) { (request, _) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            print(results)
            
            if let animal = results.first?.identifier, let confidence = results.first?.confidence {
                self.navigationItem.title = confidence != 1 ? "Not CDP" : "\(animal)"
            }
            
        }
        
        // Handle user request
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate Section
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage.")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
}
