//
//  SetlistView.swift
//  Feature
//
//  Created by 고혜지 on 10/14/23.
//  Copyright © 2023 com.creative8. All rights reserved.
//

import SwiftUI
import UI
import Core

private let gray: Color = Color(hex: 0xEAEAEA)

struct SetlistView: View {
  let setlist: Setlist
  @Binding var isShowModal: Bool
  let artistInfo: ArtistInfo?
  @StateObject var vm = SetlistViewModel()
  
  var body: some View {
    VStack {
      if vm.isEmptySetlist {
        ConcertInfoView(setlist: setlist, artistInfo: artistInfo, vm: vm)
        EmptySetlistView()
      } else {
        ScrollView {
          ConcertInfoView(setlist: setlist, artistInfo: artistInfo, vm: vm)
          ListView(setlist: setlist, artistInfo: artistInfo, vm: vm)
          AddPlaylistButton()
          BottomView()
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .principal) {
          VStack {
            Text(artistInfo?.name ?? "")
              .font(.system(size: 12))
            Text("세트리스트")
              .font(.system(size: 16))
          }
          .fontWeight(.semibold)
      }
    }
    .foregroundStyle(Color.primary)
    .sheet(isPresented: self.$isShowModal) {
      BottomModalView()
    }
  }
}

private struct ConcertInfoView: View {
  let setlist: Setlist?
  let artistInfo: ArtistInfo?
  @ObservedObject var vm: SetlistViewModel
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 14)
        .foregroundStyle(Color.black)
      
      VStack(alignment: .leading, spacing: 10) {
        Group {
          Text(artistInfo?.name ?? "")
            .font(.system(size: 26))
            .fontWeight(.semibold)
          
          Text(setlist?.tour?.name ?? "")
            .opacity(0.6)
        }
        .padding(.horizontal)
        
        Divider()
          .background(Color.white)
          .padding(.vertical, 5)
        
        Group {
          let venue = "\(setlist?.venue?.name ?? ""), \(setlist?.venue?.city?.name ?? ""), \(setlist?.venue?.city?.country?.name ?? "")"
          InfoComponenet(title: venue, subTitle: "Place")
          HStack {
            InfoComponenet(title: setlist?.eventDate ?? "", subTitle: "Date")
            Spacer()
            InfoComponenet(title: "-", subTitle: "Time")
            Spacer()
            Spacer()
          }
        }
        .padding(.horizontal)
        
        Button(action: {
          
        }, label: {
          ZStack {
            RoundedRectangle(cornerRadius: 14)
              .foregroundColor(Color.white)
            HStack {
              Text("해당 공연 다시 듣기")
              Spacer()
              Image(systemName: "checkmark")
            }
            .padding(.horizontal)
            .foregroundStyle(Color.primary)
            .fontWeight(.semibold)
          }
          .frame(height: UIHeight * 0.065)
        })
        
      }
      .font(.system(size: 16))
      .padding(.horizontal)
      .foregroundStyle(Color.white)
    }
    .padding(.horizontal)
    .frame(height: UIHeight * 0.35)
  }
}

private struct InfoComponenet: View {
  let title: String
  let subTitle: String
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
      Text(subTitle)
        .font(.system(size: 10))
        .opacity(0.4)
    }
  }
}

private struct ListView: View {
  let setlist: Setlist?
  let artistInfo: ArtistInfo?
  let koreanConverter: KoreanConverter = KoreanConverter.shared
  @ObservedObject var vm: SetlistViewModel
  
  var body: some View {
    LazyVStack {
      ForEach(setlist?.sets?.setsSet ?? [], id: \.name) { session in
        VStack(alignment: .leading, spacing: 20) {
          if let sessionName = session.name {
            Text(sessionName)
              .font(.system(size: 18))
              .fontWeight(.bold)
              .opacity(0.3)
          }
          
          let songs = session.song ?? []
          ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
            if let title = song.name {
              if song.tape != nil && song.tape == true {
                ListRowView(
                  index: nil,
                  title: koreanConverter.findKoreanTitle(title: title, songList: artistInfo?.songList ?? []) ?? title,
                  info: song.info
                )
                .opacity(0.6)
              } else {
                ListRowView(
                  index: index,
                  title: koreanConverter.findKoreanTitle(title: title, songList: artistInfo?.songList ?? []) ?? title,
                  info: song.info
                )
              }
              
              if index + 1 < songs.count {
                Divider()
              }
            }
          }
          
        }
        .padding(.vertical, UIHeight * 0.03)
      }
    }
    .padding(.horizontal, UIWidth * 0.1)
    .padding(.bottom)
    
  }
}

private struct ListRowView: View {
  var index: Int?
  var title: String
  var info: String?
  
  var body: some View {
    VStack {
      HStack {
        Group {
          if let index = index {
            Text(String(format: "%02d", index))
          } else {
            Image(systemName: "recordingtape")
          }
        }
        .frame(width: 50)
        
        Text(title)
          .frame(width: UIWidth * 0.65, height: 16, alignment: .leading)
      }
      .fontWeight(.semibold)
      
      if let info = info {
        Text(info)
          .fontWeight(.regular)
          .opacity(0.6)
          .frame(width: UIWidth * 0.65, alignment: .leading)
          .padding(.leading, 55)
      }
    }
    .font(.system(size: 16))
  }
}

private struct BottomView: View {
  var body: some View {
    ZStack {
      Rectangle()
        .frame(height: UIHeight * 0.25)
        .foregroundColor(gray)
      
      VStack(alignment: .leading, spacing: 30) {
        Text("세트리스트 정보 수정을 원하시나요?")
          .font(.system(size: 16))
          .fontWeight(.semibold)
        
        VStack(alignment: .leading, spacing: 0) {
          Text("잘못된 세트리스트 정보를 발견하셨다면,")
          Text("Setlist.fm").underline() + Text("에서 수정할 수 있습니다.")
        }
        .opacity(0.6)
        .font(.system(size: 13))
        
        Button(action: {}, label: {
          HStack {
            Spacer()
            Text("바로가기")
            Image(systemName: "arrow.right")
          }
          .font(.system(size: 16))
          .fontWeight(.semibold)
          .foregroundStyle(Color.primary)
        })
      }
      .padding(.horizontal)
    }
    .frame(height: UIHeight * 0.25)
  }
}

private struct AddPlaylistButton: View {
  @State private var isShowModal = false
  
  var body: some View {
    VStack {
      Spacer()
      Button(action: {
      
      }, label: {
        RoundedRectangle(cornerRadius: 10)
          .frame(width: UIWidth * 0.85, height: UIHeight * 0.065)
          .foregroundStyle(gray)
          .overlay {
            Text("플레이리스트 등록")
              .foregroundStyle(Color.primary)
              .bold()
          }
      })
      .padding(.bottom)
    }
  }
}

private struct EmptySetlistView: View {
  var body: some View {
    VStack(spacing: 10) {
      Spacer()
      
      Text("세트리스트가 없습니다.")
        .font(.system(size: 16))
        .fontWeight(.semibold)
      
      Text("세트리스트를 직접 작성하고 싶으신가요?\nSetlist.fm 바로가기에서 추가하세요.")
        .opacity(0.6)
        .font(.system(size: 13))
      
      Button(action: {
        
      }, label: {
        RoundedRectangle(cornerRadius: 10)
          .frame(width: UIWidth * 0.85, height: UIHeight * 0.065)
          .foregroundStyle(gray)
          .overlay {
            Text("Setlist.fm 바로가기")
              .foregroundStyle(Color.primary)
              .bold()
          }
      })
      .padding(.top, UIHeight * 0.05)
      
      Spacer()
    }
  }
}

private struct BottomModalView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: UIHeight * 0.02) {
      Spacer().frame(height: UIHeight * 0.1)
      Group {
        listView(title: "Apple Music에 옮기기", description: nil, action: {
          // TODO: 플레이리스트 연동
        })
        
        listView(
          title: "세트리스트 캡처하기",
          description: "Bugs, FLO, genie, VIBE의 유저이신가요? OCR 서비스를\n사용해 캡쳐만으로 플레이리스트를 만들어 보세요.",
          action: {
            // TODO: 스크린샷 연동
          }
        )
      }
      .opacity(0.6)
      
      Spacer()
    }
    .padding(.horizontal, 20)
  }
  
  private func listView(title: String, description: String?, action: @escaping () -> Void) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 16, weight: .semibold))
        if let description = description {
          Text(description)
            .font(.system(size: 12, weight: .regular))
            .opacity(0.8)
        }
      }
      Spacer()
      Button {
        action()
      } label: {
        Image(systemName: "chevron.right")
          .foregroundStyle(.gray)
      }
    }
  }
}

#Preview {
  BottomModalView()
}
