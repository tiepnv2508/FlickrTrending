//
//  PhotoListViewController.swift
//  FlickrTrending
//
//  Created by Kaka on 6/6/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import UIKit
import CoreData

class PhotoListViewController: UICollectionViewController {
    weak var activityIndicator: UIActivityIndicatorView!
    
    private let PhotoCellReuseId = "PhotoCell"
    private var photoListController: PhotoListControllerProtocol?
    
    private var items: [PhotoListViewModel?]? {
        didSet {
            self.collectionView.reloadData()
        }
    }

    public static func create(persistentContainer: NSPersistentContainer) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: "PhotoListNavigation") as! UINavigationController
        guard let photoListVC = navVC.topViewController as? PhotoListViewController else {
            fatalError("Invalid View Controller")
        }
        let photoListController = PhotoListController(persistentContainer: persistentContainer)
        photoListVC.photoListController = photoListController
        return navVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        fetchNewPhotos()
    }
    
    private func setupUI() {
        self.title = "Flickr Trending"
        
        //Loading Indicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)
        self.activityIndicator = activityIndicator
        
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            ])
        
        // Configure Refresh Control
        self.collectionView.refreshControl = UIRefreshControl()
    }
    
    private func displayLoading() {
        if !self.collectionView.refreshControl!.isRefreshing {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
    
    private func stopLoading() {
        if activityIndicator.isAnimating {
            activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        if self.collectionView.refreshControl!.isRefreshing {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    private func fetchNewPhotos() {
        displayLoading()
        photoListController?.fetchPhotos({ [weak self] (success, error) in
            guard let strongSelf = self else { return }
            if !success {
                DispatchQueue.main.async {
                    strongSelf.stopLoading()
                    let title = "Oopssssss!!!"
                    if let error = error {
                        strongSelf.showError(title, message: error.localizedDescription)
                    } else {
                        strongSelf.showError(title, message: NSLocalizedString("Can't retrieve photos.", comment: "Can't retrieve photos."))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.items = strongSelf.photoListController?.items
                    strongSelf.stopLoading()
                }
            }
        })
    }
    
    private func loadMorePhotos() {
        photoListController?.fetchMore({ [weak self] (success, error) in
            guard let strongSelf = self else { return }
            if !success {
                DispatchQueue.main.async {
                    strongSelf.stopLoading()
                    let title = "Oopssssss!!!"
                    if let error = error {
                        strongSelf.showError(title, message: error.localizedDescription)
                    } else {
                        strongSelf.showError(title, message: NSLocalizedString("Can't retrieve photos.", comment: "Can't retrieve photos."))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    strongSelf.items?.append(contentsOf: strongSelf.photoListController!.items!)
                }
            }
        })
    }
    
    private func showDetail(row: Int) {
        guard let items = items,
            let viewModel = items[row],
            let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let selectedId = viewModel.id
        let photoDetailVC = PhotoDetailViewController.create(photoId: selectedId, persistentContainer: appDelegate.persistentContainer)
        let segue = CustomSegue(identifier: nil, source: self, destination: photoDetailVC)
        prepare(for: segue, sender: nil)
        segue.perform()
    }
    
    private func hide() {
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoListViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 00
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: PhotoCellReuseId, for: indexPath) as? PhotoCell
        let viewModel = items![indexPath.row]
        cell!.photoUrl = viewModel?.photoUrl
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let items = items else { return }
        if indexPath.row == items.count - 1 { loadMorePhotos() }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetail(row: indexPath.row)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.collectionView.refreshControl!.isRefreshing {
            fetchNewPhotos()
        }
    }
}
