//
//  DemoList.swift
//  CheckSplitterApp
//
//  Created by Ryan Rossman on 4/20/22.
//

import SwiftUI

struct Item: Identifiable {
    var name: String
    var price: Double
    
    var id = UUID()
    init(name : String, price : Double){
        self.name = name
        self.price = price
    }
}

class Data: ObservableObject {
    
    @Published var payers = [Payer(name: "For the Table", items: [
    
    ])]
    
    @Published var tax: Double = 0
    @Published var tip: Double = 0
    @Published var tip2 : Double = 0
    
    var totalPrice: Double {
        get {
            return subtotal + tax + tip
        }
    }
    
    var subtotal: Double {
        get {
            var money: Double = 0
            
            for payer in payers {
                for item in payer.items {
                    money += item.price
                }
            }
            return money
        }
    }
}

struct DemoList: View {
        
    init() {  UITableView.appearance().separatorColor = .clear}
    
    @ObservedObject var data = Data()
    
    @State var splitTaxEvenly: Bool = true
    @State var splitTipEvenly: Bool = true
    
    @State var newItemName: String = ""
    @State var newItemPrice: String = ""
    @State var newItemQuantity: Int = 1
    
    @State var menuOpen: Bool = false
    
    @State private var editMode = EditMode.active
    
    @State var orderName: String = ""
    
    @State var editTax: String = ""
    @State var editTip: String = ""
    
    func setTip(tip: Double) {
        self.data.tip = tip
    }
    
    func getOrderName() -> String {
        return self.orderName
    }
    
    func getFinalPrices() -> [Item] {
        var final: [Item] = []
        
        var sharedItems: Double = 0
        
        for item in data.payers[0].items {
            sharedItems += item.price
        }
        
        sharedItems = sharedItems / Double( max(1, data.payers.count - 1) )
        
        if (data.payers.count > 1) {
            for i in 1...data.payers.count - 1 {
                
                let payer = data.payers[i]
                
                var money: Double = sharedItems
                
                for item in payer.items {
                    money += item.price
                }
                
                
                var payerTax: Double = 0
                var payerTip: Double = 0
                
                if splitTaxEvenly {
                    payerTax = data.tax / Double(data.payers.count - 1)
                } else {
                    payerTax = (money * data.tax) / (data.subtotal)
                }
                
                if splitTipEvenly {
                    payerTip = data.tip / Double(data.payers.count - 1)
                } else {
                    payerTip = (money * data.tip) / (data.subtotal)
                }
                
                money += payerTax
                money += payerTip
                
                var name: String = ""
                
                if (payer.name == "") {
                    name = "Payer \(i)"
                } else {
                    name = payer.name
                }
                
                final.append(Item(name: name, price: money))
            }
        }
        
		return final;
    }
    
    func getOrderPrice() -> Double {
        return data.totalPrice
    }
    
    var list: [DisplayItem] {
        
        get {
            var ret: [DisplayItem] = []
            var index: Int = 0
            for payer in data.payers {
                
                var payerItems = payer.toList
            
                for i in 0...payerItems.count-1 {
                    payerItems[i].index = index
                    payerItems[i].collapsed = payer.collapsed
                    
                }
                
                ret += payerItems
                
                index += 1
            }
            
            return ret
        }
        
    }
    
    public func openMenu() {
        menuOpen.toggle()
    }
        
    let scanner = ScannerView()
    
    
    func total(items: [Item]) -> Double {
        var money: Double = 0.0
        for i in items {
            money += i.price
        }
        
        return money
    }

    
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
                    //removes keyboard when you click off menu
                   self.endTextEditing()
                }
                .ignoresSafeArea()
                
                HStack {
                    VStack {
                    Group{//OrderDetailsGroup
                        HStack{
                            Text("Order Details")
                                .font(.title.bold())
								.padding(EdgeInsets(top: UIScreen.main.bounds.height * 0.08, leading: 25, bottom: -10, trailing: 0))
                            Spacer()
                        }
                        
                        
                        ZStack{
                            let widthpad : CGFloat = CGFloat(37)
                            let inbetweenpad : CGFloat = CGFloat(8)
							RoundedRectangle(cornerRadius: 10).foregroundColor(Color(UIColor.systemGray6)).frame(width: 220, height: 225)
                        VStack{
                            TextField("Order Name", text: $orderName)
                                .padding(EdgeInsets(top: 0, leading: widthpad, bottom: inbetweenpad, trailing: widthpad))
                            Toggle("Evenly Split Tax", isOn: $splitTaxEvenly)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .padding(EdgeInsets(top: 0, leading: widthpad, bottom: inbetweenpad, trailing: widthpad))
                            HStack {
                                Text("Tax: $")
                                TextField("0.00", text: $editTax)
                                    .onChange(of: editTax) { newValue in
                                        data.tax = Double(newValue)!
                                    }
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: widthpad, bottom: inbetweenpad, trailing: widthpad))
                            
                            Toggle("Evenly Split Tip", isOn: $splitTipEvenly)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .padding(EdgeInsets(top: 0, leading: widthpad, bottom: inbetweenpad, trailing: widthpad))
                            
                            HStack {
                                //Text("Tip: $\(String(format:"%.2f", self.data.tip))")
                                Text("Tip: $")
                                TextField("0.00", text: $editTip)
                                    .onChange(of: editTip) { newValue in
                                        data.tip2 = Double(newValue) ?? 0.00
                                    }
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 0, leading: widthpad, bottom: 5, trailing: widthpad))
                            
                        }}
                        .onTapGesture{
                            self.endTextEditing()
                        }
                        .frame(height: 235)
                        .padding(.bottom, 20)
                    }
                    Group{ //NewItemGroup
                        HStack{
                            Text("New Item")
                                .font(.title.bold())
                                .padding(.leading, 25)
                                .padding(.bottom, 5)
                            Spacer()
                        }
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 10).foregroundColor(Color(UIColor.systemGray6)).frame(width: 220, height: 80)
                        VStack{ // shitty implementation
                            TextField("Name", text: $newItemName)
                                .padding(EdgeInsets(top: 5, leading: 37, bottom: 5, trailing: 37))
                            TextField("Price", text: $newItemPrice)
                                .padding(EdgeInsets(top: 0, leading: 37, bottom: 5, trailing: 37))
                        }}
                        .padding(.top, -5)
                        
                        Stepper(value: $newItemQuantity, in: (1...25), step: 1) {
                            Text("Quantity")
                            let _ = print("\(newItemQuantity)")
                        }
                        .padding(EdgeInsets(top: -2, leading: 30, bottom: 10, trailing: 28))
                        
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
                        .padding(EdgeInsets(top: -15, leading: 0, bottom: 35, trailing: 0))
                    }
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 10).foregroundColor(Color(UIColor.systemGray6)).frame(width: UIScreen.main.bounds.width * 0.55, height: UIScreen.main.bounds.width * 0.2)
                        VStack{//List Replacement thing
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
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
                            
                            Button("Reset Items") {
                                for p in 0...data.payers.count - 1 {
                                    data.payers[p].items = []
                                }
                            }
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                            .foregroundColor(.red)
                        }}
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
        }.onTapGesture {
            self.endTextEditing()
        }
    }
    
    private var settingsButton: some View {
        
        Button(action: {
            openMenu()
        }, label: {
            Image(systemName: "ellipsis.circle")
        })
        
    }
    
    private var cameraButton: some View {
        Button(action: {
            scanner.docScan()
        }) {
            Image(systemName: "camera")
        }
        
        
        
    }
    
    private var addButton: some View {
        
        Button(action: onAdd) {
            Image(systemName: "plus")
        }

    }
    
    
    
    private func onAdd() {
        data.payers.append(
            Payer(name: "", items: [])
        )
    }
    private func onDelete(offsets: IndexSet) {
        
        offsets.sorted(by: > ).forEach { (i) in
            let item = list[i]

            if item.payer == true {
                data.payers[0].items += data.payers[item.index].items
                
                data.payers.remove(at: item.index)
            }
        }
        
    }
    private func onMove(source: IndexSet, destination: Int) {
        
        var tempList = list
        
        tempList.move(fromOffsets: source, toOffset: destination)
        
        //move the items in the DisplayList into the order they are in
        
        var payerList = tempList.indices.filter {
            tempList[$0].payer
            //figure out the indices of all the payers
        }
        
        
        
        payerList.append(tempList.count)
        
        //add a last dummy payer
        
        var p: Int = 0
        var newPayers = [Payer]()
        
        for payerIndex in Array(payerList[0..<payerList.count - 1]) {
            
            //loop through all non-dummy payers
            
            var payer = Payer(name: tempList[payerIndex].name, items: [])
            
            
            payer.collapsed = data.payers[tempList[payerIndex].index].collapsed
            
            
            if payerIndex+1 <= (payerList[p + 1] - 1) {
                for itemIndex in payerIndex+1...(payerList[p + 1] - 1) {
                    payer.items.append(
                        Item(name: tempList[itemIndex].name, price: tempList[itemIndex].price)
                    )
                }
            }
            
            p += 1
            
            newPayers.append(payer)
        }
        
        if (destination == 0) {
            newPayers[0].items = [Item(name: tempList[0].name, price: tempList[0].price)] + newPayers[0].items
        }
        
        data.payers = newPayers
    }

}


struct DemoList_Previews: PreviewProvider {
    @State static var orderTip : Double = 20.00
    static var previews: some View {
        DemoList()
    }
}
