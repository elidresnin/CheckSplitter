//
//  MyOrder.swift
//  CheckSplitterApp
//
//  Created by Ryan Rossman on 4/20/22.
//

import SwiftUI

struct MyOrder: View {
    @Binding var orderName : String
    @Binding var finalPrices : [Item]
    @Binding var orderTip : Double
    @Binding var totalPrice : Double
    @Binding var tipSelection : String
    var APP = DemoList()
    var tips = ["10%", "15%", "18%", "20%"]
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("")
                        .font(.title2.bold())
                        .foregroundColor(Color.white)
                    Spacer()
                    Text("")
                        .font(.headline)
                        .foregroundColor(Color.gray)
                }/*.frame(height: 40)*/
                
                List {
                    ForEach($finalPrices) {item in
                        HStack {
                            let _ = print(item.name)
                            Text("\(item.name)")
                                .font(.title2.bold())
                                .foregroundColor(Color.white)
                            Spacer()
                            Text("\(item.price, specifier: "$%.2f")")
                                .font(.headline)
                                .foregroundColor(Color.gray)
                        }
                        /*.frame(height: 40)*/
                        
                        
                    }
                }
                .padding(.top, 15)
                //.foregroundColor(Color(UIColor.systemGray6))
                Text("Tip: $\(orderTip, specifier:"%.2f")")
                    .foregroundColor(.accentColor)
                
                Text("\(totalPrice, specifier: "$%.2f")")
                    .font(.largeTitle.bold())
                    .foregroundColor(.accentColor)
                    .padding(20)
                
                Spacer()
                
                Picker("Please choose a Tip", selection: $tipSelection) {
                    ForEach(tips, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: tipSelection) {newValue in
                    if newValue != "Custom" {
                        var percent = newValue
                        percent.removeLast()
                        print(percent)
                        APP.setTip(tip: APP.data.subtotal * Double(percent)! / 100.0)
                        update.toggle()
                        APP.tipText(text: "\(APP.getTip())")
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .padding(.bottom, 20)
                
            }
            .listSeparatorStyle(.none)
            .navigationBarTitle(
                "\(orderName == "" ? "My Order" : orderName)",
                displayMode: .large
            )
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct MyOrder_Previews: PreviewProvider {
    @State static var ordername = "Penis"
    @State static var finalprices = [Item(name: "balls", price: 20)]
    @State static var ordertip = 0.9
    @State static var totalprice : Double = 90
    @State static var tipSelection: String = ""
    static var previews: some View {
        MyOrder(orderName: $ordername, finalPrices: $finalprices, orderTip: $ordertip, totalPrice: $totalprice, tipSelection: $tipSelection)
    }
}
