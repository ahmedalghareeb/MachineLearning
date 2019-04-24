//
//  ViewController.swift
//  MachineLearning
//
//  Created by Ahmed Ghareeb on 2019-04-24.
//  Copyright © 2019 Ahmed Ghareeb. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    var toPredict = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func selectImage(_ sender: Any) {
    let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Cannot load Image!")
        }
        
        
        guard let selectedImageConversion = CIImage(image: selectedImage) else{
            fatalError("cannot convert selected image to CIImage")
        }
            toPredict = selectedImageConversion
        photoImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func detectImage(_ sender: Any) {
        detectSceen(image: toPredict)
    }
}

extension ViewController{
    //let model = VNCoreMLModel(for: GoogLeNetPlaces().model)
    
    
    func detectSceen(image: CIImage){
        answerLabel.text = "Detecting scene ..."
        
        guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            
            fatalError("Can't load the model")
        }//end guard

        let request = VNCoreMLRequest(model: model){
            [weak self] request , error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else{
                fatalError("Error in inference!")
            }
            let article = topResult.identifier
           
            
            DispatchQueue.main.sync {
                [weak self] in self?.answerLabel.text = "Top result is \(article) with probability of \(Int(topResult.confidence * 100)) %"
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            }catch{
                print("somthing went wrong in queue dispatch")
            }
        }
        
    }//end detectSceen()
    
}//end extencsion

