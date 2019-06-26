//
//  CustomModelViewController.swift
//  INSPhotoGallery
//
//  Created by Michal Zaborowski on 04.04.2016.
//  Copyright © 2016 Inspace Labs Sp z o. o. Spółka Komandytowa. All rights reserved.
//

import UIKit
import INSPhotoGalleryFramework
import AVKit
import AVFoundation

class CustomModelViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var photos: [CustomPhotoModel] = {
        return [
            CustomPhotoModel(imageURL: URL(string: "http://inspace.io/assets/portfolio/thumb/6-d793b947f57cc3df688eeb1d36b04ddb.jpg"), thumbnailImage: UIImage(named: "thumbnailImage")!, videoURL: URL(string: "https://v-cdn.zjol.com.cn/177836.mp4?userId=75adb2d6-37a8-4712-a9f1-4dd6f138edab"))
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

extension CustomModelViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCollectionViewCell", for: indexPath) as! ExampleCollectionViewCell
        cell.populateWithPhoto(photos[(indexPath as NSIndexPath).row])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ExampleCollectionViewCell
        let currentPhoto = photos[(indexPath as NSIndexPath).row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        galleryPreview.shouldConfirmDeletion = true

        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photos.firstIndex(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                let cell = collectionView.cellForItem(at: indexPath) as? ExampleCollectionViewCell
                return cell
            }
            return nil
        }
        galleryPreview.deletePhotoHandler = { (photo) in
            self.photos.removeAll(where: { $0.image == photo.image })
            self.collectionView.reloadData()
        }
        
        galleryPreview.savePhotoHandler = { (photo) in
            if let image = photo.image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        
        galleryPreview.playPhotoHandler = { (photo) in
            if let videoURL = photo.videoURL {
                let player = AVPlayer(url: videoURL!)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true) {
                    player.play()
                }
            }
        }
        present(galleryPreview, animated: true, completion: nil)
    }
    
    @objc
    func image(_ image: UIImage?, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if (error != nil) {
            print(error.debugDescription)
        } else {
            print("Success")
        }
    }

}
