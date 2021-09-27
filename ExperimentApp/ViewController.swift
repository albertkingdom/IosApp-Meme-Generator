//
//  ViewController.swift
//  ExperimentApp
//
//  Created by Albert Lin on 2021/9/19.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
   
    private var initialCenter: CGPoint = .zero
    var activeTextField: UITextField?  // to know which is active textfield
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var topTextField: UITextField!
    
    
    //let panGesture = UIPanGestureRecognizer(target: self, action: #selector(userDragged))
    
    //let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
    
    
    @IBAction func share() {
        let memeImage = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        
        activity.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in

            
            if completed {
                self.navigateToSentMeme()
            }
        
        }
        present(activity, animated: true, completion: nil)
        save()
    }
    @IBAction func addTextField() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(userDragged))
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        let newTextField = UITextField(frame: CGRect(x: 20, y: 100, width: 500, height: 40))
        
        newTextField.placeholder = "Enter Text Here"
        newTextField.delegate = self
        newTextField.addGestureRecognizer(panGesture)
        newTextField.addGestureRecognizer(tapGestureRecognizer)
        //newTextField.constraints = []
        tapGestureRecognizer.delegate = self
        panGesture.delegate = self
        
        newTextField.defaultTextAttributes = memeTextAttributes
        
        imageContainer.addSubview(newTextField)
    }
    func navigateToSentMeme () {
       let sentMemeController =  self.storyboard!.instantiateViewController(withIdentifier: "tabBarController")
        present(sentMemeController, animated: true, completion: nil)
        // Remind: to set the presentation to "Full Screen"
        
    }
    
    
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.red,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -0.5
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //topTextField.text = "Enter Here"
       
        //topTextField.defaultTextAttributes = memeTextAttributes
        
        //topTextField.delegate = self
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(userDragged))
        panGesture.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tapGestureRecognizer.delegate = self
      

        //topTextField.addGestureRecognizer(panGesture)
        //topTextField.addGestureRecognizer(tapGestureRecognizer)
 
        
        
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
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    @IBAction func pickImageFromAlbum(_ sender: Any) {
 
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func pickImageFromCamera(_ sender: Any) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func pickColor(){
        let controller = UIColorPickerViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
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
    
    // Move the view up when keyboard shows
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

    
   
    
    //? TODO: when touched outside textfield, to hide keyboard
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        topTextField.resignFirstResponder()
//        bottomTextField.resignFirstResponder()
//
//    }
    
   
    
    func save() {
            // Create the meme
        let memedImage = generateMemedImage()
        let meme = Meme(topText: nil,originalImage: imagePickerView.image, memedImage: memedImage)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)

    }
    
    func generateMemedImage() -> UIImage {
///
        // Render view to an image
       
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: imagePickerView.frame.width, height: imagePickerView.frame.height - imagePickerView.frame.minY ), true, 0.0)
//        //view.drawHierarchy(in: self.imagePickerView.bounds, afterScreenUpdates: true)
//        view.drawHierarchy(in: CGRect(x: 0, y: -imagePickerView.frame.minY, width: imagePickerView.frame.maxX, height: imagePickerView.frame.height + imagePickerView.frame.minY ), afterScreenUpdates: true)
//        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()

        let renderer = UIGraphicsImageRenderer(size: imagePickerView.bounds.size)
        let memedImage = renderer.image(actions: { context in imageContainer.drawHierarchy(in: imagePickerView.bounds, afterScreenUpdates: true)
            
        })

        return memedImage
    }
    
    
}



extension ViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return true
    }
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
