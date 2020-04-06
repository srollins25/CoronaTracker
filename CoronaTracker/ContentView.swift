//
//  ContentView.swift
//  CoronaTracker
//
//  Created by stephan rollins on 3/27/20.
//  Copyright © 2020 OmniStack. All rights reserved.
//

import SwiftUI

struct TimeSeries: Decodable, Hashable {
    let US: [DayData]
    let Italy: [DayData]
    let Iran: [DayData]
    let Japan: [DayData]
}

struct DayData: Decodable, Hashable {
    let date: String
    let confirmed, deaths, recovered: Int
}

struct ContentView: View {
    
    @ObservedObject var vm = ChartViewModel(country: 3)
    @State var section = 3
    
    var body: some View {
        GeometryReader { geometry in
        VStack{
            Text("Corona").font(.system(size: 34, weight: .bold))
            Text("Total Deaths: \(self.vm.maxDeaths)" )
            
            if (!self.vm.dataSet.isEmpty){
   
                HStack (alignment: .bottom, spacing: 4){
                    ForEach(self.vm.dataSet, id: \.self){ day in
                        HStack{
                            Spacer()
                        }.frame(width: 6, height: (CGFloat( day.deaths) / CGFloat(self.vm.maxDeaths)) * 200)
                            .background(Color.red)
                    }
                }.padding(.horizontal, 24)
            }
            
            Picker(selection: self.$section, label: Text("Picker")){
                Text("Iran").tag(0)
                Text("Italy").tag(1)
                Text("Japan").tag(2)
                Text("US").tag(3)
            }.pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
            .onReceive([self.section].publisher.first()) { (value) in
                newCounrty(section: self.section, vm: self.vm)
                
            }
            }
        }
    }
}

func newCounrty(section: Int, vm: ChartViewModel)
{
    let urlString = "https://pomber.github.io/covid19/timeseries.json"
    
    guard let url = URL(string: urlString) else { return }
    URLSession.shared.dataTask(with: url) { (data, resp, error) in
        
        //print(data!)
        
        guard let data = data else { return }
        
        do{
            let timeseries = try JSONDecoder().decode(TimeSeries.self, from: data)
            
            DispatchQueue.main.async {
                if(section == 0)
                {
                    vm.dataSet = timeseries.Iran.filter{ $0.deaths > 0 }
                }
                else if(section == 1)
                {
                    vm.dataSet = timeseries.Italy.filter{ $0.deaths > 0 }
                }
                else if(section == 2)
                {
                    vm.dataSet = timeseries.Japan.filter{ $0.deaths > 0 }
                }
                else if(section == 3)
                {
                    vm.dataSet = timeseries.US.filter{ $0.deaths > 0 }
                }
                
                vm.maxDeaths = vm.dataSet.max(by: { (day1, day2) -> Bool in
                    return day2.deaths > day1.deaths
                    
                    })?.deaths ?? 0
            }
                            
        }
        catch{
            print("json decode failed: ", error)
        }
    }.resume()
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
