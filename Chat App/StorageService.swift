//
//  StorageService.swift
//  SocialShare
//
//  Created by Joseph Kim on 2/20/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import Foundation
import FirebaseStorage

typealias StorageMetadataCompletion = (_ errorMsg: String?, _ metadata: FIRStorageMetadata?) -> Void

fileprivate let FIR_CHILD_PROFILEIMG = "profile_images"
fileprivate let FIR_CHILD_IMAGE = "images"
fileprivate let FIR_CHILD_VIDEO = "videos"

enum StorageTypes {
    case profile
    case image
    case video
}


class StorageService {

    fileprivate static let _shared = StorageService()
    
    static var shared: StorageService {
        return _shared
    }
    
    var rootRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var profileRef: FIRStorageReference {
        return rootRef.child(FIR_CHILD_PROFILEIMG)
    }
    
    var messageImgRef: FIRStorageReference {
        return rootRef.child(FIR_CHILD_IMAGE)
    }
    
    var messageVideoRef: FIRStorageReference {
        return rootRef.child(FIR_CHILD_VIDEO)
    }
    
    func delete(type: StorageTypes, url: URL, onCompletion: ((_ error: String?) -> Void)?) {
        let ref = getRef(type: type)
        
        ref.delete { (error) in
            if error != nil {
                onCompletion?("Error deleting from storage")
            } else {
                onCompletion?(nil)
            }
        }
    }
    
    func uploadToStorageAndReturn(type: StorageTypes, data: Data?, url: URL?, filename: String = "", onComplete: StorageMetadataCompletion?) -> FIRStorageUploadTask {
        
        let uploadTask: FIRStorageUploadTask?
        
        if type != .video && data == nil { fatalError("data must be present if the upload type is not video") }
        if type == .video && url == nil { fatalError("url must be present if the upload type is video") }
        
        let ref: FIRStorageReference
        
        let name = filename == "" ? NSUUID().uuidString : filename
        
        switch type {
        case .profile: ref = profileRef.child("\(name).jpg")
        case .image: ref = messageImgRef.child("\(name).jpg")
        case .video: ref = messageVideoRef.child("\(name).mov")
        }
        
        if type != .video {
            uploadTask = ref.put(data!, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    onComplete?("An error has occurred while trying to save data", nil)
                }
                
                onComplete?(nil, metadata)
            }
        } else {
            uploadTask = ref.putFile(url!, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    onComplete?("An error has occurred while trying to upload video", nil)
                }
                
                onComplete?(nil, metadata)
            })
        }
        
        return uploadTask!
    }
    
    func uploadToStorage(type: StorageTypes, data: Data?, url: URL?, filename: String = "", onComplete: StorageMetadataCompletion?) {
        _ = uploadToStorageAndReturn(type: type, data: data, url: url, filename: filename, onComplete: onComplete)
    }
    
    fileprivate func getRef(type: StorageTypes) -> FIRStorageReference {
        switch type {
        case .image: return messageImgRef
        case .profile: return profileRef
        case .video: return messageVideoRef
        }
    }
    
}

