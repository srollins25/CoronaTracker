//
//  ChartViewModel.swift
//  CoronaTracker
//
//  Created by stephan rollins on 4/5/20.
//  Copyright © 2020 OmniStack. All rights reserved.
//

import Foundation
import SwiftUI

class ChartViewModel: ObservableObject {
    @Published var dataSet = [DayData]()
    
    var maxDeaths = 0
    
    init(country: Int){
        let urlString = "https://pomber.github.io/covid19/timeseries.json"
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, error) in
            
            //print(data!)
            
            guard let data = data else { return }
            
            do{
                let timeseries = try JSONDecoder().decode(TimeSeries.self, from: data)
                
                DispatchQueue.main.async {
                    if(country == 0)
                    {
                        self.dataSet = timeseries.Iran.filter{ $0.deaths > 0 }
                    }
                    else if(country == 1)
                    {
                        self.dataSet = timeseries.Italy.filter{ $0.deaths > 0 }
                    }
                    else if(country == 2)
                    {
                        self.dataSet = timeseries.Japan.filter{ $0.deaths > 0 }
                    }
                    else if(country == 3)
                    {
                        self.dataSet = timeseries.US.filter{ $0.deaths > 0 }
                    }
                    //self.dataSet = timeseries.US.filter{ $0.deaths > 0 }
                    
                    self.maxDeaths = self.dataSet.max(by: { (day1, day2) -> Bool in
                        return day2.deaths > day1.deaths
                        
                        })?.deaths ?? 0
                }
                                
                print("us: ", timeseries.US)
                print("italy: ", timeseries.Italy)
                print("Japan: ", timeseries.Japan)
            }
            catch{
                print("json decode failed: ", error)
            }
            
        }.resume()
    }
}
