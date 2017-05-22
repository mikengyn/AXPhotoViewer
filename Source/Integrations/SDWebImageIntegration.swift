//
//  SDWebImageIntegration.swift
//  Pods
//
//  Created by Alex Hill on 5/20/17.
//
//

import SDWebImage

class SDWebImageIntegration: NSObject, NetworkIntegration {
    
    weak var delegate: NetworkIntegrationDelegate?
    
    func loadPhoto(_ photo: Photo) {
        if photo.imageData != nil || photo.image != nil {
            self.delegate?.networkIntegration(self, loadDidFinishWith: photo)
        }
        
        guard let url = photo.url else {
            return
        }
        
        let progress: SDWebImageDownloaderProgressBlock = { [weak self] (receivedSize, expectedSize, targetURL) in
            guard let uSelf = self else {
                return
            }
            
            let progress = Progress(totalUnitCount: Int64(expectedSize))
            progress.completedUnitCount = Int64(receivedSize)
            uSelf.delegate?.networkIntegration?(uSelf, didUpdateLoadingProgress: progress, for: photo)
        }
        
        let completion: SDWebImageDownloaderCompletedBlock = { [weak self] (image, data, error, finished) in
            guard let uSelf = self else {
                return
            }
            
            guard let uImage = image, let uData = data, finished else {
                return
            }
            
            if uImage.isGIF() {
                photo.imageData = uData
                photo.image = uImage
            } else {
                photo.image = uImage
            }
            
            if let error = error {
                uSelf.delegate?.networkIntegration(uSelf, loadDidFailWith: error, for: photo)
            } else if let _ = image, let _ = data, finished {
                uSelf.delegate?.networkIntegration(uSelf, loadDidFinishWith: photo)
            }
        }
        
        SDWebImageDownloader.shared().downloadImage(with: url, options: [], progress: progress, completed: completion)
    }
    
}