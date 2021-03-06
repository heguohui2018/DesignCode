//
//  CourseList.swift
//  DesignCode
//
//  Created by zsy on 2020/2/19.
//  Copyright © 2020 zsy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct CourseList: View {
     @ObservedObject var store = CourseStore()
     @State var active = false     // 用于隐藏状态栏
     @State var activeIndex = -1  // 用于处理卡片被点击时，另外两张的效果
     @State var activeView = CGSize.zero
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(Double(self.activeView.height / 500))
                .animation(.linear)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30.0) {
                    Text("Courses")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                        .padding(.top, 30)
                        .blur(radius: active ? 20 : 0)
                    
                    // course.indices, id: \.self ??？
                    ForEach(store.courses.indices, id: \.self) { index in
                        GeometryReader { geometry in
                            CourseView(
                                show: self.$store.courses[index].show,
                                course: self.store.courses[index],
                                active: self.$active,
                                index: index,
                                activeIndex: self.$activeIndex,
                                activeView: self.$activeView
                            )
                                // -geometry.frame(in: .global).minY ???
                                .offset(y: self.store.courses[index].show ? -geometry.frame(in: .global).minY : 0)
                                
                                // 当一张卡片被点击，另外两张的效果
                                .opacity(self.activeIndex != index && self.active ? 0 : 1)
                                .scaleEffect(self.activeIndex != index && self.active ? 0.5 : 1)
                                .offset(x: self.activeIndex != index && self.active ? screen.width : 0)
                        }
                        .frame(height: 280)
                        .frame(maxWidth: self.store.courses[index].show ? .infinity : screen.width - 60)
                        .zIndex(self.store.courses[index].show ? 1 : 0)
                    }
                }
                .frame(width: screen.width)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
            } // ScrollView End
                .statusBar(hidden: active ? true : false)
                .animation(.linear)
        } // ZStack End
    }
}

struct CourseList_Previews: PreviewProvider {
    static var previews: some View {
        CourseList()
    }
}

struct CourseView: View {
    @Binding var show: Bool
    var course: Course
    @Binding var active: Bool
    var index: Int
    @Binding var activeIndex: Int
    @Binding var activeView: CGSize
    
    var body: some View {
        ZStack (alignment: .top){
            VStack(alignment: .leading, spacing: 30.0) {
                Text("Take your SwiftUI app to the App Store with advanced techniques like API data, packages and CMS.")
                
                Text("About this course")
                    .font(.title).bold()
                
                Text("This course is unlike any other. We care about design and want to make sure that you get better at it in the process. It was written for designers and developers who are passionate about collaborating and building real apps for iOS and macOS. While it's not one codebase for all apps, you learn once and can apply the techniques and controls to all platforms with incredible quality, consistency and performance. It's beginner-friendly, but it's also packed with design tricks and efficient workflows for building great user interfaces and interactions.")
                
                Text("Minimal coding experience required, such as in HTML and CSS. Please note that Xcode 11 and Catalina are essential. Once you get everything installed, it'll get a lot friendlier! I added a bunch of troubleshoots at the end of this page to help you navigate the issues you might encounter.")
            }
            .padding(30.0)
            .frame(maxWidth: show ? .infinity : screen.width - 60, maxHeight: show ? .infinity : 280, alignment: .top)
            .offset(y: show ? 460 : 0)
            .background(Color("background2"))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)).opacity(0.3), radius: 20, x: 0, y: 20)
            .opacity(show ? 1 : 0)
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(course.title)
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(course.subtitle)
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    Spacer()
                    ZStack {
                        Image(uiImage: course.logo)
                            .opacity(show ? 0 : 1)
                        
                        VStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(width: 36, height: 36)
                        .background(Color.black)
                        .clipShape(Circle())
                        .opacity(show ? 1 : 0)
                    }
                }
                Spacer()
                WebImage(url: course.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 140, alignment: .top)
            }
            .padding(show ? 30 : 20)
            .padding(.top, show ? 30 : 0)
    //        .frame(width: show ? screen.width : screen.width - 60, height: show ? screen.height : 280)
            .frame(maxWidth: show ? .infinity : screen.width - 60, maxHeight: show ? 460 : 280)
            .background(Color(course.color))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color(course.color).opacity(0.3), radius: 20, x: 0, y: 20)
            
            .gesture(
                show ?  // 点击卡片显示内容，才会有拖拽效果
                DragGesture().onChanged { value in
                    // 限定拖拽高度
                    guard value.translation.height < 300 else { return }
                    // 限定拖拽方向，只能向下
                    guard value.translation.height > 0 else { return }
                    self.activeView = value.translation
                }
                .onEnded { value in
                    // 往下拖拽，松手返回Courses页面
                    if self.activeView.height > 50 {
                        self.show = false
                        self.active = false
                        self.activeIndex = -1
                    }
                    self.activeView = .zero
                }
                : nil
            )

            .onTapGesture {
                self.show.toggle()
                self.active.toggle()
                if self.show {
                    self.activeIndex = self.index
                } else {
                    self.activeIndex = -1
                }
            }
            
            // 让if语句生效、注释199行 self.activeView = value.translation
            // 可实现内容页面SrocllView,拖拽脱出效果消失
//            if show {
//                CourseDetail(course: course, show: $show, active: $active, activeIndex: $activeIndex)
//                    .background(Color.white)
//                    .animation(nil)
//            }
            
        }  // ZStack End
            
        .frame(height: show ? screen.height: 280)
        .scaleEffect(1 - self.activeView.height / 1000)
        .rotation3DEffect(Angle(degrees: Double(self.activeView.height) / 10), axis: (x: 0, y: 10.0, z: 0))
            
        // 色彩过度动画
        .hueRotation(Angle(degrees: Double(self.activeView.height)))
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
           
        // 拖拽文字动画效果，和拖拽图片一致
        .gesture(
                  show ?  // 点击卡片显示内容，才会有拖拽效果
                  DragGesture().onChanged { value in
                      // 限定拖拽高度
                      guard value.translation.height < 300 else { return }
                      // 限定拖拽方向，只能向下
                      guard value.translation.height > 0 else { return }
                    
                      self.activeView = value.translation
                  }
                  .onEnded { value in
                      // 往下拖拽，松手返回Courses页面
                      if self.activeView.height > 50 {
                          self.show = false
                          self.active = false
                          self.activeIndex = -1
                      }
                      self.activeView = .zero
                  }
                  : nil
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct Course: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var image: URL
    var logo: UIImage
    var color: UIColor
    var show: Bool
}

var courseData = [
    Course(title: "Prototype Designs in SwiftUI", subtitle: "18 Sections", image: URL(string: "https://cdn.u1.huluxia.com/g3/M01/6E/0E/wKgBOV5XaweALkoCAAHiCjTHucI928.png")!, logo: #imageLiteral(resourceName: "Logo1"), color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), show: false),
    Course(title: "SwiftUI Advanced", subtitle: "20 Sections", image: URL(string: "https://cdn.u1.huluxia.com/g3/M01/6E/0D/wKgBOV5XarWAfL-fAAFAA1ve4KE726.png")!, logo: #imageLiteral(resourceName: "Logo1"), color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), show: false),
    Course(title: "UI Design for Developers", subtitle: "20 Sections", image: URL(string: "https://cdn.u1.huluxia.com/g3/M01/6E/0E/wKgBOV5XavSAESthAACdc4sLg5s697.png")!, logo: #imageLiteral(resourceName: "Logo3"), color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), show: false)
]


