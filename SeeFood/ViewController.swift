//
//  ViewController.swift
//  SeeFood
//
//  Created by Ahmed Ramy on 3/21/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate 
{
    @IBOutlet weak var imageTaken: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imageTaken.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else
            {
                fatalError("Couldn't convert to CIImage.")
            }
            
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image : CIImage)
    {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else
        {
            fatalError("Loading CoreML Model Failed.") //if my model is nil , i am going to trigger the else with fatalError
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else
            {
                fatalError("Model Failed to process the image")
            }
            print(results)
            
            if let firstResult = results.first
            {
                if firstResult.identifier.contains("fish")
                {
                    self.navigationItem.title = "Fish!"
                    self.navigationController?.navigationBar.tintColor = UIColor.green
                }
                else
                {
                    self.navigationItem.title = "not Fish!"
                    self.navigationController?.navigationBar.tintColor = UIColor.red
                }
            }
        }
        
        
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {try handler.perform([request])} catch {print(error)}
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem)
    {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

