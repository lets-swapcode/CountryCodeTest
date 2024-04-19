
# Country and Currency Data App

## Overview
This iOS application fetches country and currency data from an external API and displays it to the user. It is designed as part of an interview test to demonstrate coding style, API integration, and data handling in Swift. The app showcases how to dynamically decode JSON data, handle errors, and present data using Swift's Codable.

## Features
- **Fetch Data**: Retrieves data from `https://restcountries.com/v3.1/all` which includes comprehensive details about countries and their respective currencies.
- **Data Decoding**: Utilizes Swift's Codable for efficient JSON parsing.
- **Dynamic Currency Handling**: Implements a custom method to dynamically select the first available currency from a predefined priority list.
- **Error Handling**: Robust error management to ensure the app gracefully handles API failures or data issues.

## Installation
Clone this repository and open the project in Xcode. Ensure you are running Xcode 12 or higher to support all Swift features used in this project.

```bash
git clone https://github.com/yourusername/country-currency-app.git
cd country-currency-app
open Xclerise_test.xcodeproj
```

## Usage
Build and run the application using Xcode. The main interface will display a list of countries and their corresponding currencies fetched from the API. Tap on any country to view detailed information.

## Architecture
- **Model**: Defines data structures for countries and currencies.
- **View**: Manages UI components and user interaction.
- **Controller**: Handles data fetching, decoding, and business logic.

## Code Example
Here is a snippet from `ApiHandler.swift`, demonstrating how we fetch and decode country data:

```swift
func getCountry(completion: @escaping (_ countries: [CountryLite],_ error: String) -> ()){
        
        guard let url = URL(string: url_countries) else {
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error{
                completion([], error.localizedDescription)
                return
            }
            
            guard let data = data else {
                completion([], "No response, please check the API.")
                return
            }
            
            do{
                let countries = try JSONDecoder().decode(Country.self, from: data)
                var countriesLite = [CountryLite]()
                
                //Note: Need to handle extra process for currency due to complex structure.
                for country in countries{
                    let currency = country.currencies?.getFirstNonNullCurrencyName()
                    countriesLite.append(CountryLite(name: country.name.official, currency: currency?.0 ?? "NA", symbol: currency?.1 ?? "NA"))
                }
                
                completion(countriesLite, "")
            }
            catch(let e){
                completion([], e.localizedDescription)
            }
        }
        task.resume()
    }
```

## Contributing
Contributions are welcome. Please open an issue first to discuss what you would like to change or improve.

## License
This project is provided as-is under the [MIT License](LICENSE). By using this software, you agree to the terms and conditions of the license.

---

### Additional Notes
- Adjust the repository URL in the Installation section to match your actual repository.
- If the application requires specific setup steps (e.g., API keys, environment settings), include those instructions.
- If there is a `LICENSE` file in your repository, ensure it matches the license type mentioned in the README.
- Keep the README updated as you develop your project further or make significant changes.

