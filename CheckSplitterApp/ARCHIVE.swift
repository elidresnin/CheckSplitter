//
//  ARCHIVE.swift
//  CheckSplitterApp
//
//  Created by Ryan Hillis (student LM) on 10/19/21.
//
//
//struct DisplayItem: View {
//
//    @ObservedObject var display: Item
//
//    var body: some View {
//        //if !display.hidden {
//            VStack(alignment: .leading) {
//                Divider().zIndex(1)
//                HStack {
//                    if (display.payer) {
//                        TextField("", text: $display.name)
//                            .foregroundColor(Color.gray)
//                            .font(.title2.weight(.bold))
//                            .padding(.leading, 15)
//                            //.frame(width: 175)
//                        Text("\(display.money, specifier: "$%.2f")")
//                            .font(.headline)
//                            .alignmentGuide(.leading) {
//                                d in d[.leading]
//                            }
//                            .padding(.trailing, 15)
//                            .foregroundColor(
//                                Color(
//                                    red: 237/240, green: 164/240, blue: 172/240
//                                )
//                            )
//
//                    } else {
//                        TextField("", text: $display.name)
//                            .font(.custom("Helvetica Neue", size: 18))
//                            .foregroundColor(.gray)
//                            //.frame(width: 150)
//                            .padding(.leading, -25)
//                            .disabled(true)
//                        Spacer()
//                        Text("\(display.money, specifier: "$%.2f")")
//                            .font(.custom("Helvetica Neue", size: 18))
//                            .minimumScaleFactor(0.0001)
//                            .lineLimit(1)
//                            .foregroundColor(
//                                Color(
//                                    red: 237/240, green: 164/240, blue: 172/240)
//                                )
//                            //.frame(width: 50)
//                            .padding(.trailing, 15)
//                    }
//                }.padding(.bottom, 5)
//
//            }
//        //}
//    }
//}
