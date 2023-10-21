//
//  MainView.swift
//  ProjectDescriptionHelpers
//
//  Created by 최효원 on 2023/10/06.
//

import Foundation
import SwiftUI
import Combine

public struct MainView: View {
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    @ObservedObject var viewModel = MainViewModel()
    public init() {
    }
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        logo
                        Spacer()
                        ZStack(alignment: .trailing) {
                            Button {
                                // 다크모드 기능 넣기
                                viewModel.isTapped.toggle()
                            } label: {
                                Image(systemName: "moon.fill")
                                
                        }
                            .overlay {
                                if viewModel.isTapped {
                                    darkmodeButtons
                                }
                            }
                            
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical)
                Divider()
                    .padding(.leading, 24)
                    .padding(.vertical)
                if viewModel.sampleData.isEmpty {
                    EmptyMainView()
                } else {
                    mainArtistsView
                }
            }
        }

    }
    public var logo: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 19, height: 20)
                .cornerRadius(50, corners: .bottomRight)
                .cornerRadius(50, corners: .bottomLeft)
            Rectangle()
                .frame(width: 18, height: 20)
                .cornerRadius(50, corners: .topRight)
                .cornerRadius(50, corners: .topLeft)

        }
    }
    public var darkmodeButtons: some View {
        HStack {
            Button {
                viewModel.isTapped.toggle()
            } label: {
                VStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                    Text("시스템")
                        .font(.system(size: 10))
                        
                }
                .foregroundStyle(.black)
            }
            Button {
                viewModel.isTapped.toggle()
            } label: {
                VStack {
                    Image(systemName: "moon")
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                    Text("라이트")
                        .foregroundStyle(.black)
                        .font(.system(size: 10))
                }
                .foregroundStyle(.black)
            }
            Button {
                viewModel.isTapped.toggle()
            } label: {
                VStack {
                    Image(systemName: "moon.fill")
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                    Text("다크")
                        .foregroundStyle(.black)
                        .font(.system(size: 10))
                }
                .foregroundStyle(.black)
            }
        }
        .padding(EdgeInsets(top: 10, leading: 16, bottom: 6, trailing: 16))
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 36))
        .frame(width: (screenWidth * 0.5), height: (screenWidth * 0.18))
        .offset(x: -(screenWidth * 0.16))
    }
    public var mainArtistsView: some View {
        VStack(spacing: 0) {
            artistNameScrollView
                .padding(.bottom)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 18) {
                    ForEach(0 ..< viewModel.sampleData.count, id: \.self) { data in
                        VStack(spacing: 0) {
                            Button {
                                print("\(data)")
                            } label: {
                                Image(viewModel.sampleData[data].image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenWidth * 0.78, height: screenWidth * 0.78)
                                    .overlay {
                                        ZStack {
                                            Color.black
                                                .opacity(0.2)
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Circle()
                                                        .frame(width: screenWidth * 0.15)
                                                        .foregroundStyle(.black)
                                                        .overlay {
                                                            Image(systemName: "arrow.right")
                                                                .foregroundStyle(.white)
                                                        }
                                                }
                                            }
                                            .padding([.trailing, .bottom])
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                            ForEach(0 ..< viewModel.sampleData[data].concertInfo.count, id: \.self) { item in
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        VStack(alignment: .center) {
                                            Text("\(viewModel.sampleData[data].concertInfo[item].date, formatter: viewModel.yearFormatter)")
                                                .foregroundStyle(.gray)
                                            Text("\(viewModel.sampleData[data].concertInfo[item].date, formatter: viewModel.dateMonthFormatter)")
                                        }
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        Spacer()
                                            .frame(width: screenWidth * 0.11)
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(viewModel.sampleData[data].concertInfo[item].tourName)
                                                .bold()
                                                .padding(.bottom, 2)
                                            Text(viewModel.sampleData[data].concertInfo[item].venue)
                                        }
                                        .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .padding(.vertical)
                                    Divider()
                                }
                                .opacity(viewModel.selectedIndex == data ? 1.0 : 0)
//                                .animation(.easeInOut(duration: 0.1))
                            }
                        }
                    }
                }
                .scrollTargetLayout()
                
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $viewModel.scrollToIndex)
            .safeAreaPadding(.horizontal, screenWidth * 0.11)
            Spacer()
        }
        .onChange(of: viewModel.scrollToIndex) {
            viewModel.selectedIndex = viewModel.scrollToIndex
        }
        .onAppear {
            if viewModel.sampleData.count != 0 {
                viewModel.selectedIndex = 0
                viewModel.scrollToIndex = 0
            }
        }
    }
    public var artistNameScrollView: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { scrollViewProxy in
                HStack(spacing: 54) {
                    ForEach(0..<viewModel.sampleData.count, id: \.self) { data in
                        Text(.init(viewModel.sampleData[data].artist))
                            .background(Color.clear)
                            .font(.system(size: 25))
                            .bold()
                            .id(data)
                            .foregroundColor(viewModel.selectedIndex == data ? .black : .gray)
                            .animation(.easeInOut(duration: 0.2))
                            .onTapGesture {
                                withAnimation {
                                    viewModel.selectedIndex = data
                                    viewModel.scrollToIndex = data
                                }
                            }
                    }
                    Color.clear
                        .frame(width: screenWidth * 0.6)
                }
                .onReceive(Just(viewModel.scrollToIndex)) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scrollViewProxy.scrollTo(viewModel.scrollToIndex, anchor: .leading)
                    }
                }
                .scrollTargetLayout()
            }
        }
        .frame(maxHeight: 60)
        .scrollIndicators(.hidden)
        .safeAreaPadding(.leading, screenWidth * 0.12)
    }
}
struct EmptyMainView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("찜한 아티스트가 없습니다")
                .font(.callout)
                .padding(.bottom)
            Text("관심있는 아티스트 정보를 빠르게\n확인하고 싶으시다면 찜을 해주세요")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    .gray)
                .padding(.bottom)
            // TODO: 찜하기 화면 연결
            NavigationLink(destination: Text("아티스트 찜하기 이동")) {
                Text("아티스트 찜하러 가기 →")
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 25.0)
                        .foregroundStyle(.black))
            }
            .padding(.vertical)
            Spacer()
            }
        }
}

// 로고 만들기
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
// MARK: 임시로 만든 데이터입니다.
struct ConcertInfo: Identifiable {
    var id = UUID()
    var date: Date
    var tourName: String
    var venue: String
}

struct MainArchiveData: Identifiable {
    var id = UUID()
    var image: String
    var artist: String
    var concertInfo: [ConcertInfo]
}

#Preview {
    MainView()
}
