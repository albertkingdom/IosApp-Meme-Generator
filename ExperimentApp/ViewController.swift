//
//  ViewController.swift
//  ExperimentApp
//
//  Created by Albert Lin on 2021/9/19.
//

import UIKit
import CoreData

let memeTextAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.strokeColor: UIColor.black,
    NSAttributedString.Key.foregroundColor: UIColor.red,
    NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    NSAttributedString.Key.strokeWidth: -0.5
]

class ViewController: UIViewController {
   
    var dataController: DataController!
    var imageToBeEdit: Image!
    var fetchedImageText: [ImageText]!
    private var initialCenter: CGPoint = .zero
    var activeTextField: UITextField?  // to know which is active textfield
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imagePickerView: UIImageView!

    
    @IBAction func cancelEditor(_ sender: Any) {
        let alertController = UIAlertController(title: "Exit", message: "Do you want to exit editor?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Stay Here!", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Exit!", style: .destructive, handler: {_ in
          
            self.navigateToSentMeme()
            
        }))
        self.present(alertController, animated: true, completion: nil)
        
    }
    @IBAction func SaveFile(_ sender: Any) {
        let saveFileAlertController = UIAlertController(title: "Save", message: "choose where to save?", preferredStyle: .actionSheet)
        saveFileAlertController.addAction(
            UIAlertAction(title: "Save new copy", style: .default, handler: {_ in
                self.saveImageToDatabase(override: false)
                self.navigateToSentMeme()
        }))
       
        if (imageToBeEdit != nil) {
            saveFileAlertController.addAction(UIAlertAction(title: "Override current copy", style: .default, handler: { _ in
                NSLog("Override current copy")
                self.overrideImageToDatabase()
                self.navigateToSentMeme()
            }))
            
        }
        self.present(saveFileAlertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func share() {
        let memeImage = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        
        activity.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                self.navigateToSentMeme()
                //TODO: add complete alert
            }
        }
        present(activity, animated: true, completion: nil)
    
    }
    @IBAction func addTextField() {

        self.textFieldConfiguration(customAttribute: nil, applyDefault: true)
    }
    func navigateToSentMeme () {
      
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
      
        if imageToBeEdit != nil {
            imagePickerView.image = UIImage(data:imageToBeEdit.img!)
            let fetchRequest: NSFetchRequest<ImageText> = ImageText.fetchRequest()
            
            let predicate: NSPredicate = NSPredicate(format: "image == %@", imageToBeEdit)
            
            fetchRequest.predicate = predicate
            
            do{
                fetchedImageText = try dataController.viewContext.fetch(fetchRequest)
               
                for text in fetchedImageText {
                    
                    self.textFieldConfiguration(customAttribute: text.attributedText, applyDefault: false)
                }
            } catch {
                print("cant not fetch \(error.localizedDescription)")
            }
        }
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    @IBAction func pickImage(_ sender: Any) {
 
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let pickImageAlertController = UIAlertController(title: "插入照片", message: "選擇照片來源", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        let albumAction = UIAlertAction(title: "Album", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickImageAlertController.addAction(cameraAction)
        }
        pickImageAlertController.addAction(albumAction)
        present(pickImageAlertController, animated: true, completion: nil)
    }
    
    
    @IBAction func pickColor(){
        let controller = UIColorPickerViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func textFieldConfiguration(customAttribute: NSAttributedString?, applyDefault: Bool){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(userDragged))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        
        let newTextField = UITextField(frame: CGRect(x: 20, y: 100, width: 500, height: 40))
        
        newTextField.placeholder = "Enter Text Here"
        newTextField.delegate = self
        newTextField.addGestureRecognizer(panGesture)
        newTextField.addGestureRecognizer(tapGestureRecognizer)
       
        tapGestureRecognizer.delegate = self
        panGesture.delegate = self
        if applyDefault {
            newTextField.defaultTextAttributes = memeTextAttributes
        } else {
            newTextField.attributedText = customAttribute
        }
        imageContainer.addSubview(newTextField)
    }
   
}
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // implement methods in UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //activeTextField = textField
        textField.becomeFirstResponder()
    }
    // remember to set delegate to self before using this method
    // when tap keyboard return, hide the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // to hide keyboard, send keyboardWillHideNotification
        textField.resignFirstResponder()
        
        return true
    }
}

extension ViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return true
    }
    @objc func userDragged(gesture: UIPanGestureRecognizer){

        let translation = gesture.translation(in: view)
        //print("userdrag active is \(activeTextField)")
        switch gesture.state {
            case .began:
                initialCenter = gesture.view?.center ?? .zero
                activeTextField = gesture.view as? UITextField
            case .changed:
                gesture.view?.center = CGPoint(x: initialCenter.x + translation.x,
                                                     y: initialCenter.y + translation.y)
                
            case .cancelled, .ended:
                break
            default:
                break
            }
    }
    
    @objc func didTapView(_ sender: UITapGestureRecognizer){
        //print("didtapview \(sender.view)")
        //activeTextField = sender.view
        sender.view?.becomeFirstResponder()
        activeTextField = sender.view as? UITextField
    }
    // TODO: auto resize textfield
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if textField.text != nil {
//                    let text = textField.text! as NSString
//                    let finalString = text.replacingCharacters(in: range, with: string)
//                    textField.frame.size.width = getWidth(text: finalString)
//                }
//
//                return true
//    }
//    func getWidth(text: String) -> CGFloat {
//        let txtField = UITextField(frame: .zero)
//        txtField.text = text
//        txtField.sizeToFit()
//        return txtField.frame.size.width
//    }
    
}
extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        activeTextField?.textColor = viewController.selectedColor
        //dismiss(animated: true, completion: nil)
    }
}
// MARK: output image, save to database
extension ViewController {
    
    func generateMemedImage() -> UIImage {


        let renderer = UIGraphicsImageRenderer(size: imagePickerView.bounds.size)
        let memedImage = renderer.image(actions: { context in
            imageContainer.drawHierarchy(in: imagePickerView.bounds, afterScreenUpdates: true)
            
        })

        return memedImage
    }
    func saveImageToDatabase(override: Bool){
        let originalImageToSave = imagePickerView.image?.pngData()
        let editedImageToSave = self.generateMemedImage().pngData()
        

        let image = Image(context: dataController.viewContext)
            image.img = originalImageToSave
            image.editedImg = editedImageToSave
        
        
        do {
            try dataController.viewContext.save()
            saveTextField(image: image)
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
    }
    func overrideImageToDatabase(){
        let originalImageToSave = imagePickerView.image?.pngData()
        let editedImageToSave = self.generateMemedImage().pngData()
        
        imageToBeEdit.img = originalImageToSave
        imageToBeEdit.editedImg = editedImageToSave
        
       
        do {
            try dataController.viewContext.save()
            saveTextField(image: imageToBeEdit)
           
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
        
    }
    func saveTextField(image:Image) {
        let image = image
       
        for subview in imageContainer.subviews{


            if let uitext = subview as? UITextField  {
                let textToSave = NSEntityDescription.insertNewObject(forEntityName: "ImageText", into: dataController.viewContext) as! ImageText
                textToSave.attributedText = uitext.attributedText
                textToSave.image = image

            }

        }
        do {
            try dataController.viewContext.save()
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
    }
}


// MARK: keyboard
extension ViewController {
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification:Notification) {
        // move the view up only when remain space height(from the maxY of textfield to the very bottom of view) is less than keyboard hight
        if(activeTextField != nil){
            if(view.frame.maxY - (activeTextField?.frame.maxY)! < getKeyboardHeight(notification)){
            view.frame.origin.y -= getKeyboardHeight(notification)
            }

        }
        
       
        
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}
