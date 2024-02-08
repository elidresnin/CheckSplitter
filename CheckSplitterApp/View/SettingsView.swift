//
//  SettingsView.swift
//  CheckSplitterApp
//
//  Created by Ryan Rossman on 4/20/22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var accentColor : Color
    @Binding var notifications : Bool
    
    var body: some View {
        NavigationView {
        //VStack {
            ScrollView{
                    Group {
                    ZStack{
                        let height = UIScreen.main.bounds.height * 0.18
                        RoundedRectangle(cornerRadius: 10).foregroundColor(Color(UIColor.systemGray6)).frame(height:154, alignment: .leading)
                        VStack{
                            ColorPicker(
                                "Color Scheme",
                                selection: $accentColor,
                                supportsOpacity: false
                            ).onChange(of: self.accentColor) { newValue in
                                self.accentColor = newValue
                            }
                            .padding(EdgeInsets(top: 10, leading: 15, bottom : 0, trailing: 15))
                            
                            Toggle("Notifications", isOn: $notifications)
                                .toggleStyle(SwitchToggleStyle(tint: self.accentColor))
                                .padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
                            
                            HStack {
                                Text("Version")
                                Spacer()
                                Text("0.9.0 beta 2")
                                    .foregroundColor(Color.gray)
                                    
                            }.padding(15)
                            
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                    //.listRowInsets(EdgeInsets())
                    //cornerRadius(8)
                    //.background(Color(UIColor.systemGray6))
                    
                }.listStyle(InsetGroupedListStyle()) // this has been renamed in iOS 14.*, as mentioned by @Elijah Yap
                    .environment(\.horizontalSizeClass, .regular)
                .navigationBarTitle(
                    "Settings",
                    displayMode: .large
                )
                .environment(\.defaultMinListRowHeight, 50)
                .listStyle(SidebarListStyle())
                //.disabled(true)
                
                Group {
                    HStack {
                        Text("About")
                            .font(.largeTitle.bold())
                            .alignmentGuide(.leading) { d in d[.leading] }
                        Spacer()
                    }
                    
                    Text("Quotum was born 'CheckSplitter' sometime early in 2020 for my Computer Science Seminar class. At first, the app was merely an organizational tool for performing the normal bill splitting routine. Eventually, I realized how useful the app could actually be if the tedious task of inputting items manually could be avoided. After learning and implementing VisionKit OCR to do just that, 'CheckSplitter' won the app design contest that year among my classmates. I've continued updating the app since then, finding the name Quotum and a a new UI along the way. Soon, I hope to complete the app and offer it for download on the App Store.")
                            .navigationBarTitle("About", displayMode: .large)
                            .padding(.top, UIScreen.main.bounds.height * -0.05)
                }
                .padding(20)
                
            }
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var accentColor = Color(UIColor.systemTeal)
    @State static var value = false
    static var previews: some View {
		SettingsView(accentColor: $accentColor, notifications: $value)
			.previewInterfaceOrientation(.landscapeLeft)
    }
}
