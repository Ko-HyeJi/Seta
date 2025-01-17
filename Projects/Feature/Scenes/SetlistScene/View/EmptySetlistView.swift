//
//  EmptySetlistView.swift
//  Feature
//
//  Created by 고혜지 on 11/7/23.
//  Copyright © 2023 com.creative8.seta. All rights reserved.
//

import SwiftUI
import UI

struct EmptySetlistView: View {
  @StateObject var vm = MainViewModel()
  var body: some View {
    VStack {
      Text("등록된 세트리스트가 없어요")
        .font(.headline)
        .fontWeight(.semibold)
        .padding(.top, UIHeight * 0.1)
        .padding(.bottom, 5)
      Text("세트리스트를 직접 작성하고 싶으신가요?")
        .multilineTextAlignment(.center)
        .font(.footnote)
        .foregroundStyle(Color.gray)
        HStack(spacing: 0) {
          if vm.isKorean() {
            Link(destination: URL(string: "https://www.setlist.fm")!) {
              Text("Setlist.fm")
                .underline()
            }
            Text("에서 추가하세요.")
          } else {
            Text("setlist? Add it on ")
            Link(destination: URL(string: "https://www.setlist.fm")!) {
              Text("Setlist.fm.")
                .underline()
            }
          }
        }
      .foregroundStyle(Color.gray)
      .font(.footnote)
    }
  }
}

#Preview {
    EmptySetlistView()
}
