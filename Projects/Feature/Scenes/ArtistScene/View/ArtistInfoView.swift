//
//  ArtistInfoView.swift
//  Feature
//
//  Created by 고혜지 on 11/7/23.
//  Copyright © 2023 com.creative8.seta. All rights reserved.
//

import SwiftUI
import SwiftData
import Core
import UI

struct ArtistInfoView: View {
  @ObservedObject var vm: ArtistViewModel
  @Query var concertInfo: [ArchivedConcertInfo]
  @Query var likeArtist: [LikeArtist]
  @Environment(\.modelContext) var modelContext
  @Environment(\.scenePhase) var scenePhase
  @State private var scale: CGFloat = 1.0
  
  var body: some View {
    VStack(spacing: 24) {
      imageLayer
      HStack {
        nameLayer
        Spacer()
        buttonLayer
      }
      .padding(.horizontal, UIWidth * 0.07)
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      vm.swiftDataManager.modelContext = modelContext
      vm.isLikedArtist = vm.swiftDataManager.isAddedLikeArtist(likeArtist, vm.artistInfo.mbid)
    }
    .onChange(of: scenePhase) {
      if scenePhase == .inactive || scenePhase == .background {
        if vm.isLikedArtist && !vm.swiftDataManager.isAddedLikeArtist(likeArtist, vm.artistInfo.mbid) { // 뷰를 나갈 때 swiftData에 추가되어있지 않은 상태에서 하트를 눌렀으면
          vm.swiftDataManager.addLikeArtist(
            name: vm.artistInfo.name,
            country: "",
            alias: vm.artistInfo.alias ?? "",
            mbid: vm.artistInfo.mbid,
            gid: vm.artistInfo.gid ?? 0,
            imageUrl: vm.artistInfo.imageUrl ?? "",
            songList: vm.artistInfo.songList ?? []
          )
        }
        if !vm.isLikedArtist && vm.swiftDataManager.isAddedLikeArtist(likeArtist, vm.artistInfo.mbid) { // 뷰를 나갈 때 swiftData에 추가되어있는 상태에서 하트를 누르지 않았으면
          vm.swiftDataManager.findArtistAndDelete(likeArtist, vm.artistInfo.mbid)
        }
      }
    }
  }
  
  private var imageLayer: some View {
    if let imageUrl = vm.artistInfo.imageUrl {
      return AnyView(AsyncImage(url: URL(string: imageUrl)) { image in
        image
          .centerCropped()
          .aspectRatio(1, contentMode: .fit)
          .frame(width: UIWidth * 0.57)
          .cornerRadius(12)
          .overlay(Color.black.opacity(0.2).cornerRadius(12))
      } placeholder: {
        ProgressView()
      })
    } else {
      return AnyView(Image("artistViewTicket", bundle: Bundle(identifier: "com.creative8.seta.UI"))
        .resizable()
        .renderingMode(.template)
        .foregroundStyle(Color(UIColor.systemGray3))
        .background {
          Color(UIColor.systemGray)
            .cornerRadius(12)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: UIWidth * 0.57)
      )
    }
  }
  
  private var nameLayer: some View {
    Text(vm.artistInfo.name)
      .font(.title3)
      .fontWeight(.semibold)
      .foregroundStyle(Color.mainBlack)
      .minimumScaleFactor(0.1)
  }
  
  private var buttonLayer: some View {
    Button {
      vm.isLikedArtist.toggle()
      withAnimation(.easeInOut(duration: 0.3)) {
        self.scale = 0.7
      }
      withAnimation(.easeInOut(duration: 0.3).delay(0.3)) {
        self.scale = 1.15
      }
      withAnimation(.easeInOut(duration: 0.3).delay(0.6)) {
        self.scale = 1.0
      }
    } label: {
      Image(systemName: vm.isLikedArtist ? "heart.fill" : "heart")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: UIWidth * 0.07)
        .fontWeight(.thin)
        .foregroundStyle(vm.isLikedArtist ? Color.mainOrange : Color.mainWhite)
        .scaleEffect(vm.isLikedArtist ? scale : 1.0)
    }
    .onDisappear {
      if vm.isLikedArtist && !vm.swiftDataManager.isAddedLikeArtist(likeArtist, vm.artistInfo.mbid) { // 뷰를 나갈 때 swiftData에 추가되어있지 않은 상태에서 하트를 눌렀으면
        vm.swiftDataManager.addLikeArtist(
          name: vm.artistInfo.name,
          country: "",
          alias: vm.artistInfo.alias ?? "",
          mbid: vm.artistInfo.mbid,
          gid: vm.artistInfo.gid ?? 0,
          imageUrl: vm.artistInfo.imageUrl ?? "",
          songList: vm.artistInfo.songList ?? []
        )
      }
      if !vm.isLikedArtist && vm.swiftDataManager.isAddedLikeArtist(likeArtist, vm.artistInfo.mbid) { // 뷰를 나갈 때 swiftData에 추가되어있는 상태에서 하트를 누르지 않았으면
        vm.swiftDataManager.findArtistAndDelete(likeArtist, vm.artistInfo.mbid)
      }
    }
  }
}

#Preview {
  ArtistInfoView(vm: ArtistViewModel())
}
