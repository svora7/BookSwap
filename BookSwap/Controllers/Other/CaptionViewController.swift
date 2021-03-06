//
//  CaptionViewController.swift
//  BookSwap
//
//  Created by Shivani Vora on 3/17/22.
//

import UIKit

class CaptionViewController: UIViewController, UITextFieldDelegate {

    private let image: UIImage
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /*private let textView: UITextView = {
        let textView = UITextView()
        
        return textView
    }()*/
    
    let titleField: BATextField = {
            let field = BATextField()
            field.placeholder = "Add Title"
            field.returnKeyType = .next
            return field
        }()
    
    let authorField: BATextField = {
            let field = BATextField()
            field.placeholder = "Add Author"
        field.returnKeyType = .next
            return field
        }()
    
    let isbnField: BATextField = {
            let field = BATextField()
            field.placeholder = "Add ISBN"
        field.returnKeyType = .next
        field.autocorrectionType = .no
            return field
        }()
    
    let classField: BATextField = {
            let field = BATextField()
            field.placeholder = "Add Class Name"
        field.returnKeyType = .next
            return field
        }()
    
    let subjectField: BATextField = {
            let field = BATextField()
            field.placeholder = "Add Subject"
        field.returnKeyType = .continue
            return field
        }()
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        imageView.image = image
        view.addSubview(titleField)
        view.addSubview(authorField)
        view.addSubview(isbnField)
        view.addSubview(classField)
        view.addSubview(subjectField)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(didTapPost))
        titleField.delegate = self
        authorField.delegate = self
        isbnField.delegate = self
        classField.delegate = self
        subjectField.delegate = self
    }
    
    @objc func didTapPost() {
        titleField.resignFirstResponder()
        authorField.resignFirstResponder()
        isbnField.resignFirstResponder()
        classField.resignFirstResponder()
        subjectField.resignFirstResponder()
        var title = titleField.text ?? ""
        var author = authorField.text ?? ""
        var isbn = isbnField.text ?? ""
        var schoolClass = classField.text ?? ""
        var subject = subjectField.text ?? ""
        
        guard let newPostID = createNewPostID(), let stringDate = String.date(from: Date()) else {
            return
        }
        
        StorageManager.shared.uploadPost(data: image.pngData(), id: newPostID) { newPostDownloadURL in
            guard let url = newPostDownloadURL else {
                print("Error: failed to upload")
                return
            }
            
            let newPost = Post(id: newPostID, title: title, author: author, isbn: isbn, schoolClass: schoolClass, subject: subject, postURLString: url.absoluteString, postedDate: stringDate)
            
            DatabaseManager.shared.createPost(newPost: newPost) { [weak self] finished in
                guard finished else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0
                    self?.navigationController?.popToRootViewController(animated: false)
                    
                    NotificationCenter.default.post(name: .didPostNotification, object: nil)
                }
                
            }
            
                    
        }
    }
    
    private func createNewPostID() -> String? {
            let timeStamp = Date().timeIntervalSince1970
            let randomNumber = Int.random(in: 1...1000)
            guard let firstName = UserDefaults.standard.string(forKey: "firstName") else{
                return nil
            }
            guard let lastName = UserDefaults.standard.string(forKey: "lastName") else{
                return nil
            }
            return "\(firstName)_\(lastName)_\(randomNumber)_\(timeStamp)"
        }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = view.width/4
        imageView.frame = CGRect(x: (view.width-size)/2, y: view.safeAreaInsets.top+10, width: size, height: size)
        titleField.frame = CGRect(x: 20,
                                  y: imageView.bottom+20,
                                         width: view.width-40,
                                         height: 50)
        authorField.frame = CGRect(x: 20,
                                  y: titleField.bottom+10,
                                         width: view.width-40,
                                         height: 50)
        isbnField.frame = CGRect(x: 20,
                                  y: authorField.bottom+10,
                                         width: view.width-40,
                                         height: 50)
        classField.frame = CGRect(x: 20,
                                  y: isbnField.bottom+10,
                                         width: view.width-40,
                                         height: 50)
        subjectField.frame = CGRect(x: 20,
                                  y: classField.bottom+10,
                                         width: view.width-40,
                                         height: 50)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            authorField.becomeFirstResponder()
        } else if textField == authorField {
            isbnField.becomeFirstResponder()
        } else if textField == isbnField {
            classField.becomeFirstResponder()
        } else if textField == classField {
            subjectField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

}
