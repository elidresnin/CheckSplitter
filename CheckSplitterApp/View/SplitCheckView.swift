//
//  SplitCheckView.swift
//  CheckSplitterApp
//
//  Created by Ryan Rossman on 4/20/22.
//

import SwiftUI

struct SplitCheckView: View {
    let scanner = ScannerView()
    var body: some View {
        ZStack {
            scanner
            NavigationView {
            //VStack {
                ScrollView {
                    List {
                        ForEach(self.list) { item in
                            if (item.payer || !item.collapsed) {
                                item
                                .contextMenu {
                                    if (item.payer) {
                                        if (item.index != 0) {
                                            Text("Payer Name: \(item.name)")
                                        }
                                        Text("Items: \(data.payers[item.index].items.count)")
                                        Text("Item Total: \(total(items: data.payers[item.index].items), specifier: "$%.2f")")
                                    }
                                    if (item.index > 0 || !item.payer) {
                                        Button(action: {
                                            if (item.payer) {
                                                data.payers[0].items += data.payers[item.index].items
                                                    
                                                data.payers.remove(at: item.index)
                                            } else {
                                                data.payers[item.index].items.remove(at: item.itemIndex)
                                            }
                                            
                                        }, label: {
                                            HStack {
                                                Text("Remove")
                                                Spacer()
                                                Image(systemName: "trash")
                                            }
                                        })
                                    }
    
                                }
//                                .swipeActions {
//                                    Button("Delete") {
//                                        print("DELETED")
//                                    }
//                                    .tint(.red)
//                                }
                                .frame(height: 50)
                                .moveDisabled(item.payer)
                                .background(Color(UIColor.systemGray6))
                            }
                        }
                        .onMove(perform: onMove)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color(UIColor.systemGray6))
                    }
                    .listSeparatorStyle(.none)
                    .navigationBarTitle(
                        "\(orderName == "" ? "My Order" : orderName) - \(data.totalPrice, specifier: "$%.2f")",
                        displayMode: .inline
                    )
                    .navigationBarItems(leading: settingsButton, trailing: addButton)
                    .environment(\.editMode, $editMode)
                    .environment(\.defaultMinListRowHeight, 0)
                    .listStyle(SidebarListStyle())
                    .frame(height: 100 + CGFloat(50 * self.list.count) )
                    .listRowBackground(Color.green)
                }
                
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    //.cornerRadius(38.5)
                    .padding(.trailing, 25)
                    .shadow(color: Color.black.opacity(0.3),
                            radius: 3,
                            x: 3,
                            y: 3)
                }
            }
            
            ZStack {
                GeometryReader { _ in
                    EmptyView()
                }
                .background(Color.black.opacity(0.4))
                .opacity(menuOpen ? 1.0 : 0.0)
                .animation(Animation.easeIn.delay(0.25))
                .onTapGesture {
                    openMenu()
                }
                .ignoresSafeArea()
                
                HStack {
                    VStack {
                        
                        Text("Order Details")
                            .font(.title.bold())
                            .frame(height: 75)
                            .padding(.top, 50)
                            .padding(.bottom, -15)
                            .padding(.leading, 15)
                        
                        List {
                            TextField("Order Name", text: $orderName)
                                .frame(height: 35)
                                .padding(.leading, 15)
                            Toggle("Evenly Split Tax", isOn: $splitTaxEvenly)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .frame(height: 35)
                                .padding(.leading, 15)
                            
                            HStack {
                                Text("Tax: $")
                                TextField("0.00", text: $editTax)
                                    .onChange(of: editTax) { newValue in
                                        data.tax = Double(newValue)!
                                    }
                                Spacer()
                            }
                            .frame(height: 35)
                            .padding(.leading, 15)
                            
                            Toggle("Evenly Split Tip", isOn: $splitTipEvenly)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .frame(height: 35)
                                .padding(.leading, 15)
                            
                            HStack {
                                Text("Tip: $\(String(format:"%.2f", orderTip))")
                                /*TextField("0.00", text: $editTip)
                                    .onChange(of: editTip) { newValue in
                                        data.tip = Double(newValue)!
                                        CONTENT.resetTip()
                                    }*/
                                Spacer()
                            }
                            .frame(height: 35)
                            .padding(.leading, 15)
                            
                        }
                        .frame(height: 235)
                        .padding(.bottom, 20)
                        
                        Text("New Item")
                            .font(.title.bold())
                            .padding(.leading, 15)
                        
                        List {
                            TextField("Name", text: $newItemName)
                                .frame(height: 35)
                                .padding(.leading, 15)
                            TextField("Price", text: $newItemPrice)
                                .frame(height: 35)
                                .padding(.leading, 15)
                        }
                        .frame(height: 100)
                        .padding(.top, -5)
                        
                        Stepper(value: $newItemQuantity, in: (1...25), step: 1) {
                            Text("Quantity")
                        }
                        .padding(.leading, 15)
                        .padding(15)
                        .padding(.top, -10)
                        
                        Button("Add \(newItemQuantity) to Order") {
                            
                            if let number = Double(newItemPrice) {
                                for _ in 1...newItemQuantity {
                                    data.payers[0].items.append(Item(name: newItemName, price: number))
                                }
                                
                                newItemName = ""
                                newItemPrice = ""
                                newItemQuantity = 1
                            }
                        }
                        .padding(.leading, 15)
                        
                        
                        List {
                            Text("")
                                .frame(height: 0)
                            Button("Reset Payers") {
                                var items = [Item]()
                                
                                for payer in data.payers {
                                    items += payer.items
                                }
                                
                                data.payers[0].items = items
                                data.payers = [data.payers[0]]
                            }
                            .foregroundColor(.red)
                            .padding(.trailing, 15)
                            .frame(width: 270)
                            
                            Button("Reset Items") {
                                for p in 0...data.payers.count - 1 {
                                    data.payers[p].items = []
                                }
                            }
                            .padding(.trailing, 15)
                            .foregroundColor(.red)
                            .frame(width: 270)
                        }
                        .padding(.top, -10)
                        
                        
                        
                        
                        
                        Spacer()
                    }
                    .background( Color(UIColor.systemBackground) )
                    .frame(width: 270)
                    .offset(x: menuOpen ? 0 : -270)
                    .animation(.default)
                    .ignoresSafeArea(edges: [.top, .leading])
                    .padding(.top, -5)
                    .padding(.leading, -15)
                    
                    Spacer()
                }
            }
        }
    }
}

struct SplitCheckView_Previews: PreviewProvider {
    static var previews: some View {
        SplitCheckView()
    }
}
