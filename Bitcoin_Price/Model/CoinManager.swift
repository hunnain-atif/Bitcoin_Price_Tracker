//
//  CoinManager.swift
//  Bitcoin_Price
//


import Foundation

protocol CoinManagerDelegate {
    func didUpdateCurrency(rate: String, currencyLabel: String)
    func didFailWithError(error: Error)
}


struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "8020C7D3-C4CA-46A1-A846-765B890E53AC"
    var currency = "AUD"
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    mutating func getCoinPrice(for currency:String) {
        self.currency = currency
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let rate = (self.parseJSON(safeData)) {
                        let rateString = String(format: "%.2f", rate)
                        self.delegate?.didUpdateCurrency(rate: rateString, currencyLabel: self.currency)
                    }
                    
                }
            }
            task.resume()
            
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from:data)
            let rate = decodedData.rate
            return rate
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
