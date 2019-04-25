//
//  ViewController.swift
//  OCS distribution
//
//  Created by Sergey on 24/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit
import SDWebImage

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emtyLabelList: UILabel!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    private var vacancyArray = [Vacancy]()
    private let cellIdentifier = "searchCell"
    private let connection = ConnectionManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        prepareChangeConnectionListener()
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UINib(nibName: "CustomSearchCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
}


//MARK: TableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vacancyArray.count == 0 {
            emtyLabelList.isHidden = false
            tableView.separatorStyle = .none
        } else {
            emtyLabelList.isHidden = true
            tableView.separatorStyle = .singleLine
        }
        return vacancyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchTableCell
        let vacancy = vacancyArray[indexPath.row]
        cell.jobTitle.text = vacancy.title
        cell.cityTitle.text = vacancy.location
        cell.logoImage.sd_setImage(with: URL(string: vacancy.companyLogo), placeholderImage: UIImage(named: "placeholder"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailController", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destintionVC = segue.destination as! DetailViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destintionVC.vacancy = vacancyArray[indexPath.row]
        }
    }
    
}

//MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  vacancyArray.count > 0 && vacancyArray.count - 20 == indexPath.row {
            ConnectionManager.isReachable { _ in
                NetworkManager.shared().getRequestVacancy(listener: self)
            }
            ConnectionManager.isUnreachable { _ in
                self.showLostConnectionMessage()
            }
        }
    }
}

//MARK: Result request
extension SearchViewController: NetworkProtocol {
    func successRequest(result: [Vacancy]) {
        vacancyArray.append(contentsOf: result)
        loadIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func errorRequest(errorMessage: String) {
        print(errorMessage)
        loadIndicator.stopAnimating()
    }
}

//MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let inputText = searchBar.text {
            vacancyArray.removeAll()
            tableView.reloadData()
            loadIndicator.startAnimating()
            emtyLabelList.isHidden = true
            ConnectionManager.isReachable { _ in
                NetworkManager.shared().getRequestVacancy(request: inputText, listener: self)
            }
            ConnectionManager.isUnreachable { _ in
                self.showLostConnectionMessage()
            }
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            vacancyArray.removeAll()
            tableView.reloadData()
        }
    }
}

//MARK: Connection
extension SearchViewController {
    
    private func prepareChangeConnectionListener() {
        
        connection.reachability.whenUnreachable = {
            _ in
            self.showLostConnectionMessage()
        }
    }
    
    private func checkCurrentConnection() {
        ConnectionManager.isUnreachable { _ in
            self.showLostConnectionMessage()
        }
    }
    
    private func showLostConnectionMessage() {
        let dialogMessage = UIAlertController(title: "Lost internet connection", message: "Check connection settings", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { action in
            self.checkCurrentConnection()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .default)
        
        dialogMessage.addAction(okButton)
        dialogMessage.addAction(cancelButton)
        self.present(dialogMessage, animated: true, completion: nil)
    }
}

