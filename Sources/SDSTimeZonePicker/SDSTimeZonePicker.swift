//
//  SDSTimeZonePicker.swift
//
//  Created by : Tomoaki Yagishita on 2021/04/14
//  © 2021  SmallDeskSoftware
//

import SwiftUI

public typealias TZCompletion = (TimeZone) -> Void

public struct SDSTimeZonePicker: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPresented: Bool
    @Binding var selectedTimeZone: TimeZone?
    @State private var localSelectedTZ:TimeZone? = nil
    @State private var searchString: String = ""
    
    @State private var tzSelectionType: String = "abbreviation"
    
    @State private var selectedTimeZoneWithAbbrev:String = ""
    
    @State private var detailViewIsActive = false
    let completion:TZCompletion?
    
    public init(isPresented: Binding<Bool>, selection: Binding<TimeZone?>,_ completion:TZCompletion? = nil) {
        self._isPresented = isPresented
        self._selectedTimeZone = selection
        self.completion = completion
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                Picker("timezone type", selection: $tzSelectionType) {
                    Text("Abbrev (ex: JST)").tag("abbreviation")
                    Text("ID (ex: Asia/Tokyo)").tag("identifier")
                    Text("search").tag("search")
                }
                .pickerStyle(SegmentedPickerStyle())
                if tzSelectionType == "search" {
                    TextField("search keyword", text: $searchString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.alphabet)
                }
                
                if tzSelectionType == "identifier" {
                    List {
                        ForEach( TimeZone.regionList, id: \.self ) { region in
                            TimeZoneDetailNavigationLink(selectedTimeZone: $localSelectedTZ, region: region)
                        }
                    }
                } else if tzSelectionType == "abbreviation" {
                    List {
                        ForEach(TimeZone.abbrevList, id:\.self) { key in
                            Text(key)
                                .onTapGesture {
                                    if let newTimeZone = TimeZone.init(abbreviation: key) {
                                        selectedTimeZone = newTimeZone
                                        completion?(newTimeZone)
                                        isPresented = false
                                    }
                                }
                        }
                    }
                } else {
                    List {
                        if searchString == "" {
                            Text("")
                            Text("type keyword to filter TimeZone")
                            Text("")
                        } else {
                            ForEach( TimeZone.relatedZoneList(key: searchString), id:\.self) { region in
                                Text(region)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .onTapGesture {
                                        if let selected = TimeZone.init(identifier: region) {
                                            selectedTimeZone = selected
                                            completion?(selected)
                                            isPresented = false
                                        }
                                    }
                            }
                        }
                    }
                }
                
            }
            .padding()
            .onAppear {
                // for the case returning back from TimeZoneDetailView
                if let localSelectedTZ = localSelectedTZ {
                    selectedTimeZone = localSelectedTZ
                    completion?(localSelectedTZ)
                    isPresented = false
                }
            }
            .navigationBarTitle("select timezone")
            .modifier(BarTitleModifier())
        }
    }
}

struct BarTitleModifier: ViewModifier {
    typealias Body = NavigationView
    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            return AnyView(content.navigationBarTitleDisplayMode(.inline))
        } else {
            return AnyView(content)
        }
    }
}

struct TimeZoneDetailNavigationLink: View {
    @State private var detailViewIsActive = false
    @Binding var selectedTimeZone: TimeZone?
    let region: String
    
    var body: some View {
        NavigationLink(
            destination: TimeZoneDetailSelector(isActive: $detailViewIsActive, selectedTimeZone: $selectedTimeZone, selectedRegion: region),
            isActive: $detailViewIsActive,
            label: {
                Text(region)
            })
    }
}


struct TimeZoneDetailSelector: View {
    @Binding var isActive: Bool
    @Binding var selectedTimeZone: TimeZone?
    let selectedRegion: String
    var body: some View {
        List( TimeZone.regionDetailList(region: selectedRegion), id:\.self) { detail in
            Text(detail)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    selectedTimeZone = TimeZone.init(identifier: detail)!
                    isActive = false
                }
        }
        .environment(\.editMode, .constant(.active))
    }
}

struct TimeZoneSelector_Previews: PreviewProvider {
    static var previews: some View {
        SDSTimeZonePicker(isPresented: .constant(true), selection: .constant(TimeZone.current))
    }
}
