//
//  ViewController.swift
//  Xclerise_test
//
//  Created by Harsh1 Surati on 19/04/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableCountry: UITableView!
    @IBOutlet weak var btnCurrency: UIButton!
    
    let spinner = UIActivityIndicatorView(style: .medium)
    let vm: VMCountries = VMCountries()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews(){
        tableCountry.delegate = self
        tableCountry.dataSource = self
        setupLoader()
    }
    
    @IBAction func btnGetCountryAction(_ sender: Any) {
        enableLoader(true)
        self.tableCountry.bringSubviewToFront(spinner)
        vm.fetchCountries { [weak self] isSuccess, error in
            guard let self = self else { return }
            vm.qMainQueue.async {
                self.enableLoader(false)
                if isSuccess{
                    self.tableCountry.reloadData()
                }
                else{
                    //We can show the proper error with \(error)
                    self.showAlertOnError()
                }
            }
        }
    }
    
    func showAlertOnError(){
        let ac = UIAlertController(title: "Alert", message: "We are facing some issues get the country currency data!!", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Okay", style: .cancel)
        ac.addAction(submitAction)
        self.present(ac, animated: true)
    }
}

//MARK: Loader
extension ViewController{
    func setupLoader(){
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.frame = CGRect(x: CGFloat(btnCurrency.frame.origin.x), y: CGFloat(btnCurrency.frame.origin.x), width: btnCurrency.bounds.width, height: btnCurrency.bounds.height - 10)
        self.btnCurrency.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: btnCurrency.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: btnCurrency.centerYAnchor).isActive = true
    }
    
    func enableLoader(_ isEnable: Bool){
        isEnable ? spinner.startAnimating() : spinner.stopAnimating()
        btnCurrency.isUserInteractionEnabled = !isEnable
        btnCurrency.setTitle(isEnable ? "" : "Get Currency", for: .normal)
    }
}

//MARK: Table view
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.modelCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "country", for: indexPath) as? countryCell else { return UITableViewCell() }
        cell.setData(model: vm.modelCountries[indexPath.row])
        return cell
    }

}

class countryCell: UITableViewCell{
    
    @IBOutlet weak var lblCountryName: UILabel!
    @IBOutlet weak var lblCountryCurrency: UILabel!
    
    func setData(model: CountryLite){
        lblCountryName.text = model.name
        lblCountryCurrency.text = model.symbol + "(\(model.currency))"
    }
}

class VMCountries{
    
    var modelCountries: [CountryLite] = []
    let api: apiHandler = apiHandler()
    
    let qMainQueue = DispatchQueue.main
    let qBgQueue = DispatchQueue.global(qos: .background) // can give userinitiated too if important.
    
    func fetchCountries(completion: @escaping (_ isSuccess: Bool, _ error: String) -> ()){
        qBgQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.api.getCountry {  countries, error in
                
                if error.isEmpty{
                    self.modelCountries = countries
                    completion(true, "")
                }
                else{
                    completion(false, error)
                }
            }
        }
    }
}
