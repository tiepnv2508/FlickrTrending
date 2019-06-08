//
//  PhotoDetailViewController.swift
//  FlickrTrending
//
//  Created by Kaka on 6/6/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import UIKit
import CoreData
class PhotoDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var dateUploadedLabel: UILabel!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    weak var activityIndicator: UIActivityIndicatorView!
    
    private var photoDetailController: PhotoDetailController?
    
    public static func create(photoId: String, persistentContainer: NSPersistentContainer) -> PhotoDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoDetailVC = storyboard.instantiateViewController(withIdentifier: "PhotoDetailViewController") as! PhotoDetailViewController
        let photoDetailController = PhotoDetailController(photoId: photoId, persistentContainer: persistentContainer)
        photoDetailVC.photoDetailController = photoDetailController
        return photoDetailVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchPhoto()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.backgroundColor = UIColor.clear
        self.view.dropShadow()
        descTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    private func fetchPhoto() {
        displayLoading()
        photoDetailController?.fetchPhoto({ [weak self] (success, error) in
            guard let strongSelf = self else { return }
            if !success {
                if let error = error {
                    strongSelf.stopLoading()
                    strongSelf.displayError(message: error.localizedDescription)
                } else {
                    strongSelf.stopLoading()
                    strongSelf.displayError(message: "Can't retrieve photo.")
                }
            } else {
                strongSelf.stopLoading()
                strongSelf.loadUI()
            }
        })
    }
    
    private func loadUI() {
        guard let photoDetailController = photoDetailController,
            let item = photoDetailController.item else {
                return
        }
        
        // Title
        titleLabel.text = item.title ?? ""
        
        // Author
        authorNameLabel.text = item.ownerName ?? ""
        
        // Uploaded date
        guard let dateUploaded = item.dateUploaded else { return }
        let date = Date(timeIntervalSince1970: (Double(dateUploaded))!)
        dateUploadedLabel.text = Date.toString(date: date)
        
        // Description Text View
        let htmlData = NSString(string: item.desc ?? "").data(using: String.Encoding.unicode.rawValue)
        let options = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html
        ]
        let attributedString = try! NSAttributedString(
            data: htmlData!,
            options: options,
            documentAttributes: nil
        )
        descTextView.attributedText = attributedString
        descTextView.font = UIFont.systemFont(ofSize: 16)
        descTextView.setContentOffset(CGPoint.zero, animated: false)
        
        self.infoView.isHidden = false
    }
    
    private func setupUI() {
        //Loading Indicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)
        self.activityIndicator = activityIndicator
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            ])
    }
    
    private func displayError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func displayLoading() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func stopLoading() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    @IBAction func hide(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
