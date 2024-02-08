//
//  ContentView.swift
//  CheckSplitterApp
//
//  Created by Matthew Hillis on 5/4/21.
//

import UIKit
import Vision
import VisionKit
import SwiftUI
import MobileCoreServices
import AVFoundation

var CONTENT = ContentView()

struct LargeButtonStyle: ButtonStyle {
    
    let backgroundColor: Color
    let foregroundColor: Color
    let isDisabled: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled || configuration.isPressed ? foregroundColor.opacity(0.3) : foregroundColor
        return configuration.label
            .padding()
            .foregroundColor(currentForegroundColor)
            .background(isDisabled || configuration.isPressed ? backgroundColor.opacity(0.3) : backgroundColor)
            // This is the key part, we are using both an overlay as well as cornerRadius
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color(UIColor.systemBackground), lineWidth: 1)
        )
            .padding([.top, .bottom], 10)
            .font(Font.system(size: 19, weight: .semibold))
    }
}


//for when you click off the keyboard
extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}

struct LargeButton: View {
    
    private static let buttonHorizontalMargins: CGFloat = 20
    
    var backgroundColor: Color
    var foregroundColor: Color
    
    private let title: String
    private let action: () -> Void
    
    // It would be nice to make this into a binding.
    private let disabled: Bool
    
    init(title: String,
         disabled: Bool = false,
         backgroundColor: Color = Color.green,
         foregroundColor: Color = Color.white,
         action: @escaping () -> Void) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.title = title
        self.action = action
        self.disabled = disabled
    }
    
    var body: some View {
        HStack {
            Spacer(minLength: LargeButton.buttonHorizontalMargins)
            Button(action:self.action) {
                Text(self.title)
                    .frame(maxWidth:.infinity)
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: backgroundColor,
                                          foregroundColor: foregroundColor,
                                          isDisabled: disabled))
                .disabled(self.disabled)
            Spacer(minLength: LargeButton.buttonHorizontalMargins)
        }
        .frame(maxWidth:.infinity)
    }
}

struct ContentView: View {
    
    var APP = DemoList()
    
    var orderName: String {
        get {
            APP.getOrderName()
        }
    }
    var finalPrices: [Item] {
        get {
            APP.getFinalPrices()
        }
    }
    
    @State var tipSelection: String = ""
    var tips = ["10%", "15%", "18%", "20%", "Custom"]
    
    @State var ordertip2 : Double = 0
    
    var orderTip : Double{
        get{
            var processedString : String = tipSelection
            processedString.removeAll(where: {Set(["%"]).contains($0)})
            
            var returnDouble = 0.0
            
            if(processedString == "Custom"){
                APP.setTip(tip: APP.data.tip2)
                print("tip: \(APP.data.tip2)")
                return APP.data.tip
            }
            
            if let computedDouble = Double(processedString){
                ordertip2 = computedDouble/100
                returnDouble = computedDouble/100
            }
            else{
                returnDouble = ordertip2
            }
            //print("returnDouble: \(returnDouble)") Debug rounding thingy, please ignore
            returnDouble = returnDouble * APP.data.subtotal
            //print("subtotal: \(APP.data.subtotal)") same as above
            APP.setTip(tip: returnDouble)
            return returnDouble
        }
    }
    
    var totalPrice: Double {
        get {
            return APP.getOrderPrice()
        }
    }
    
    @State var tabState: Int = 1
    @State var accentColor: Color = Color(UIColor.systemTeal)
    @State var notifications: Bool = false
    @State var update: Bool = false
    
    var body: some View {
        ZStack {
            TabView(selection: $tabState) {
                Group {
                    SettingsView(accentColor: $accentColor, notifications: $notifications)
                }.tabItem {
                    Label("Settings", systemImage: "gear")
                }.tag(0)
                
                APP.tabItem {
                    Label("My Order", systemImage: "list.bullet")
                }.tag(1)

                APP.tabItem {
                    Label("Receipt Scan", systemImage: "camera")
                }.tag(2)
                
                NavigationView {
                    VStack {
                        ZStack{
                        HStack {
                            Text(" ")
                                .font(.title2.bold())
                                .foregroundColor(Color.black)
                            Spacer()
                            Text("\n")
                                .font(.headline)
                                .foregroundColor(Color.black)
                        }
                        List{
                            ForEach(finalPrices) {item in
                                HStack {
                                    Text("\(item.name)")
                                        .font(.title2.bold())
                                        .foregroundColor(Color.white)
                                    Spacer()
                                    Text("\(item.price, specifier: "$%.2f")")
                                        .font(.headline)
                                        .foregroundColor(Color.gray)
                                }
                                .frame(height: 40)
                            }
                          /*  if(finalPrices.count<0){
                                
                               
                            HStack {
                                Text("Save to Camera Roll")
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }.frame(height: 40)
                            
                            }*/
                        }
                        }
                       // .padding(.leading, 2)
                       // .padding(.trailing, 2)
                        
                        
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
                            //print($tipSelection) debug tipselection print
                            /*if newValue != "Custom" {
                                var percent = newValue
                                percent.removeLast()
                                print(percent)
                                APP.setTip(tip: APP.data.subtotal * Double(percent)! / 100.0)
                                update.toggle()
                                APP.tipText(text: "\(APP.getTip())")
                            }*/
                        }
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 20)
                        
                    }
                    .navigationBarTitle(
                        "\(orderName == "" ? "My Order" : orderName)",
                        displayMode: .large
                    )
                    .environment(\.defaultMinListRowHeight, 0)
                    .listStyle(InsetGroupedListStyle())
                }
                .tabItem {
                    Label("Split Check", systemImage: "divide.circle")
                }.tag(3)
            }.onChange(of: tabState) {state in
                
                if (state == 2) {
                    APP.scanner.docScan()
                    
//                    CONTENT.APP.data.payers[0].items = [
//
//                        Item(name: "Bloody Mary", price: 8.75),
//                        Item(name: "Bloody Mary", price: 8.75),
//                        Item(name: "Bloody Mary", price: 8.75),
//                        Item(name: "Bloody Mary", price: 8.75),
//                        Item(name: "Bloody Mary", price: 8.75),
//                        Item(name: "Classic Ceasar", price: 8.00),
//                        Item(name: "Blackened Salmon and Shrimp Caesar", price: 18.00),
//                        Item(name: "Gap Grilled Cheese", price: 14.50),
//                        Item(name: "Philly Pork", price: 10.00),
//                        Item(name: "Bavarian Soft Pretzel", price: 11.00),
//                        Item(name: "Bavarian Soft Pretzel", price: 11.00),
//                        Item(name: "Bavarian Soft Pretzel", price: 11.00),
//                        Item(name: "Fresh Oyster", price: 12.50),
//
//                    ]
                    
                    tabState = 1
                    
                }
            }
        }
        .accentColor(accentColor)
    }
}

struct Payer {
    var name: String
    var items: [Item]
    
    var collapsed: Bool = false

    var money: Double {
        get {
            var sum: Double = 0
            
            for item in items { sum += item.price }
            
            return sum
        }
    }
    
    var toList: [DisplayItem] {
        get {
            var ret = [DisplayItem(payer: true, name: self.name, price: 0)]
            
            var money: Double = 0
            
            var itemIndex = 0
            
            for item in items {
                var toInsert = DisplayItem(payer: false, name: item.name, price: item.price)
                toInsert.itemIndex = itemIndex
                
                ret.append(toInsert)
                
                money += item.price
                
                itemIndex += 1
            }
            
            ret[0] = DisplayItem(payer: true, name: self.name, price: money)
            
            return ret;
        }
    }
}

struct DisplayItem: View, Identifiable {
    
    var id = UUID()
    
    @State var payer: Bool
    @State var name: String
    @State var price: Double
    
    @State var editPrice: String = ""
    
    var collapsed: Bool = false
    
    var index: Int = -1
    var itemIndex: Int = -1
    
    var body: some View {
        //if !display.hidden {
            VStack(alignment: .leading) {
                //Divider().zIndex(1)
                HStack {
                    if (payer) {
                        TextField("Add Name", text: $name, onEditingChanged: { (editingChanged) in
                                  if !editingChanged {
                                    CONTENT.APP.data.payers[index].name = name
                                  }
                            })
                        //.foregroundColor(Color.gray)
                        .font(.title2.bold())
                            .padding(.leading, 15)
                            
                        Text("\(price, specifier: "$%.2f")")
                            .font(.headline)
                            .alignmentGuide(.leading) {
                                d in d[.leading]
                            }
                            .foregroundColor(Color.accentColor)
                            .onTapGesture {
                                CONTENT.APP.data.payers[index].collapsed.toggle()
                            }
                        Group {
                            if (CONTENT.APP.data.payers[index].collapsed) {
                                Image(systemName:"chevron.right")
                            } else {
                                Image(systemName:"chevron.down")
                            }
                        }
                        .padding(.trailing, 15)
                        .foregroundColor(Color.accentColor)

                    }
                    else if (!collapsed) {
                        Group {
                            TextField("", text: $name, onEditingChanged: { (editingChanged) in
                                if !editingChanged {
                                    CONTENT.APP.data.payers[index].items[itemIndex].name = name
                                }
                            })
                                .font(.callout)
                                //.frame(width: 150)
                                .padding(.top, 5)
                                .padding(.leading, -25)
                            Spacer()

                            Text("$")
                                .font(.callout)
                                .minimumScaleFactor(0.0001)
                                .lineLimit(1)
                                .foregroundColor(
                                    Color.gray
                                        )
                                .padding(.trailing, -6)
                            Text("\(price, specifier: "%.2f")")
                                .font(.callout)
                                .minimumScaleFactor(0.0001)
                                .lineLimit(1)
                                .foregroundColor(
                                    Color.gray
                                        )
                                .padding(.trailing, 15)
                                .keyboardType(.decimalPad)

                            //CurrencyTextField("Amount", value: $editPrice)

                        }
                    }
                }
                
            }
        //}
    }
}

class ScanImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 7.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.systemIndigo.cgColor
        backgroundColor = UIColor.init(white: 1.0, alpha: 0.1)
        clipsToBounds = true
    }
}

class OcrTextView: UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: .zero, textContainer: textContainer)
        
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 7.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.systemTeal.cgColor
        font = .systemFont(ofSize: 16.0)
    }
}


class ScanButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        setTitle("Scan", for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        titleLabel?.textColor = .white
        //layer.cornerRadius = 7.0
        backgroundColor = UIColor.systemIndigo
    }
}

class ViewController: UIViewController {
    
    private var scanButton = ScanButton(frame: .zero)
    private var scanImageView = ScanImageView(frame: .zero)
    private var ocrTextView = OcrTextView(frame: .zero, textContainer: nil)
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    
    private var firstTime = true
    
    func activate() {
        scanButton.sendActions(for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        configureOCR()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }

    
    private func configure() {

        view.addSubview(scanButton)
        
        let padding: CGFloat = 0
        NSLayoutConstraint.activate([
            scanButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: padding),
        ])
        
        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
    }
    
    
    @objc func scanDocument() {
        
        let scanVC = VNDocumentCameraViewController()
        scanVC.delegate = self
        present(scanVC, animated: true)
    }
    
    
    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        ocrTextView.text = ""
        scanButton.isEnabled = false
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }

    
    private func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return
            }
            
            var ocrText = [(String, CGRect)]()
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
                
                
                let range = topCandidate.string.range(of: topCandidate.string)
                try? ocrText.append(
                    (topCandidate.string, topCandidate.boundingBox(for: range!)!.boundingBox)
                )
                
            }
            
            let fake = true
            
            if fake {
                CONTENT.APP.data.tax = 8.38
                //CONTENT.APP.tipText(text: "8.38")
                CONTENT.APP.data.tip = 0.00
                
                CONTENT.APP.data.payers[0].items = [
                
                    Item(name: "Peking Duck (H", price: 24.00),
                    Item(name: "^^ Pancake", price: 4.00),
                    Item(name: "Pineapple BF", price: 16.00),
                    Item(name: "Lo Mein", price: 13.00),
                    Item(name: "*Seaf Tofu SP", price: 13.00),
                    Item(name: "Chinese Broc", price: 15.00),
                
                ]
                
            } else {
                ocrText.sort {
                    $0.1.midY > $1.1.midY
                }
                
                var lineSplits: [Int] = [0]
                for ind in 1...ocrText.count-1 {
                    
                    let thisRect = ocrText[ind].1
                    
                    let lastRect = ocrText[ind - 1].1
                    
                    if !(thisRect.midY < lastRect.maxY && thisRect.midY > lastRect.minY) {
                        lineSplits.append(ind)
                    }
                }
                
                for ind in 1...lineSplits.count - 1 {
                    var currentLine = Array( ocrText[lineSplits[ind-1]..<lineSplits[ind]] )
                    
                    currentLine.sort {
                        $0.1.minX < $1.1.minX
                    }
                    
                    var item = ""
                    
                    for word in currentLine {
                        item += word.0 + " "
                    }
                    
                    if item.contains("tax") {
                        if let x = Double( item.filter("0123456789.".contains) ) {
                            CONTENT.APP.data.tax = x
                        }
                    } else if item.contains("tip") || item.contains("gratuity") {
                        if let x = Double( item.filter("0123456789.".contains) ) {
                            CONTENT.APP.data.tip = x
                        }
                    } else {
                        let order = item.split(separator: " ")
                        let number = Int( order[0].filter("0123456789.".contains) )
                        let totalPrice = Double( order[order.count - 1].filter("0123456789.".contains) )!
                        
                        var itemName = item
                            itemName.removeAll(where: { "$0123456789.".contains($0) })
                            itemName = itemName.replacingOccurrences(of: " S ", with: "").replacingOccurrences(of:"§", with: "")
                        
                        if let x = number {
                            for _ in 1...x {
                                
                                let insert = Item(
                                    name: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
                                    price: totalPrice / Double(x)
                                )
                                
                                CONTENT.APP.data.payers[0].items.append(
                                    insert
                                )
                            }
                            
                            
                        }
                        
                    }

                }
            }
            
            DispatchQueue.main.async {
                self.scanButton.isEnabled = true
            }
            
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US"]
        ocrRequest.usesLanguageCorrection = true
        ocrRequest.customWords = ["$"]
    }
    
}

extension ViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        scanImageView.image = scan.imageOfPage(at: 0)
        processImage(scan.imageOfPage(at: 0))
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //Handle properly error
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}

struct ScannerView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIViewController
    
    let view = ViewController()
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        return view
    }
        

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
    }
    
    func docScan() {
        view.activate()
    }
    
}

struct ScanButtonRepresentable: UIViewRepresentable {
    typealias UIViewType = UIButton
    
    func makeUIView(context: Context) -> UIViewType {
        return ScanButton(frame: .zero)
    }
    
    func updateUIView(_ uiViewController: UIViewType, context: Context) {
            
    }
}
