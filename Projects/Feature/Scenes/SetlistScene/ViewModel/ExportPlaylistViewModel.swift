//
//  ExportPlaylistViewModel.swift
//  Feature
//
//  Created by 장수민 on 11/21/23.
//  Copyright © 2023 com.creative8.seta. All rights reserved.
//

import Foundation
import Photos
import Core
import MusicKit

final class ExportPlaylistViewModel: ObservableObject {
  @Published var playlistTitle: String = ""
  @Published var showAppleMusicAlert: Bool = false
  @Published var showToastMessageAppleMusic: Bool = false
  @Published var showToastMessageSubscription: Bool = false
  @Published var showToastMessageCapture = false
  @Published var showLibrarySettingsAlert = false
  @Published var showMusicSettingsAlert = false
  @Published var showSpotifyAlert = false
  @Published var showCaptureAlert = false
  
  // MARK: Photo
  func checkPhotoPermission() -> Bool {
    var status: PHAuthorizationStatus = .notDetermined
    
    if #available(iOS 14, *) {
      status = PHPhotoLibrary.authorizationStatus()
    } else {
      status = PHPhotoLibrary.authorizationStatus()
    }
    return status == .denied || status == .notDetermined
    
  }
  
  func requestPhotoLibraryPermission() {
    PHPhotoLibrary.requestAuthorization { status in
      switch status {
      case .authorized:
        // 권한이 허용된 경우
        print("Photo library access granted")
      case .denied, .restricted:
        // 권한이 거부되거나 제한된 경우
        print("Photo library access denied")
      case .notDetermined:
        // 권한이 아직 결정되지 않은 경우
        print("Photo library access not determined")
      case .limited:
        print("Photo library access limited")
      @unknown default:
        print("omg")
      }
    }
  }
  
  func getPhotoLibraryPermissionStatus() -> PHAuthorizationStatus {
    let status = PHPhotoLibrary.authorizationStatus()
    return status
  }
  
  func handlePhotoExportButtonAction() {
    if self.getPhotoLibraryPermissionStatus() == .notDetermined {
      self.requestPhotoLibraryPermission()
    } else if self.getPhotoLibraryPermissionStatus() == .denied {
      self.showLibrarySettingsAlert = true
    } else {
      self.showToastMessageCapture = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        self.showToastMessageCapture = false
      }
    }
  }
  
  // MARK: AppleMusic
  
  var musicKitPermissionStatus: MusicAuthorization.Status {
    return MusicAuthorization.currentStatus
  }
  
  func addToAppleMusic(musicList: [(String, String?)], setlist: Setlist?) {
    AppleMusicService().addPlayList(
      name: self.playlistTitle,
      musicList: musicList,
      venue: setlist?.venue?.name
    )
    self.showAppleMusicAlert = false
    self.showToastMessageAppleMusic = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
      self.showToastMessageAppleMusic = false
    }
  }
  
  func handleAppleMusicButtonAction() {
    Task {
      switch musicKitPermissionStatus {
      case .notDetermined:
        AppleMusicService().requestMusicAuthorization()
      case .denied, .restricted:
        self.showMusicSettingsAlert = true
      case .authorized:
        let subscriptionChecker = CheckAppleMusicSubscription.shared
        subscriptionChecker.appleMusicSubscription { [self] isSubscribed in
          
          if isSubscribed {
            self.showAppleMusicAlert.toggle()
            playlistTitle = ""
          } else {
            self.showToastMessageSubscription = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
              self.showToastMessageSubscription = false
            }
          }
        }
      default: break
      }
    }
  }
}
