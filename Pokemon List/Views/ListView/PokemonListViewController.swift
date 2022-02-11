//
//  PokemonListViewController.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import UIKit
import Combine

protocol PokemonListDelegate {
    func updatedFavouritesListAt(viewController: PokemonListViewController)
}

class PokemonListViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    //MARK: - Properties
    var listViewModel: PokemonListViewModel!
    var delegate: PokemonListDelegate?
    var subscriptions = Set<AnyCancellable>()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
    }
    
    //MARK: - Private Methods
    func setupView() {
        setupTableView()
        let apiService = BaseService()
        listViewModel = PokemonListViewModel(service: apiService)
        listViewModel.fetchPokemons()
        listViewModel.$isFetchInProgress.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &subscriptions)
    }
    
    private func setupNavigationBar() {
        setupLeftNavigationBarItem()
        setupRightNavigationBarItem()
    }
    
    private func setupTableView() {
        self.tableView.register(ListTableViewCell.nib, forCellReuseIdentifier: ListTableViewCell.reuseIdentifier)
        self.tableView.register(LoadingTableViewCell.nib, forCellReuseIdentifier: LoadingTableViewCell.reuseIdentifier)
        tableView.backgroundColor = .systemBackground
        self.tableView.allowsMultipleSelection = true
    }
    
    private func setupLeftNavigationBarItem() {
        let titleLabel = UILabel()
        titleLabel.text = Constants.Strings.pokemonList
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.regularSystemFont(ofSize: 20)
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: Constants.Assets.backArrow), for: .normal)
        backButton.addTarget(self, action: #selector(backBtnTapped(sender:)), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [backButton, titleLabel])
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 24
        let customTitles = UIBarButtonItem.init(customView: stackView)
        self.navigationItem.leftBarButtonItem = customTitles
    }
    
    @objc func backBtnTapped(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupRightNavigationBarItem() {
        let saveButton = UIButton(type: .custom)
        saveButton.setTitle(Constants.Strings.save, for: .normal)
        saveButton.setTitleColor(Constants.Colors.navigationSaveColor, for: .normal)
        saveButton.titleLabel?.font = UIFont.regularSystemFont(ofSize: 16)
        saveButton.addTarget(self, action: #selector(saveBtnTapped(sender:)), for: .touchUpInside)
        let barButton = UIBarButtonItem.init(customView: saveButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func saveBtnTapped(sender: UIButton) {
        if let products = self.listViewModel.getSelectedProducts() {
            PokemonCacheManager.shared.makeFavourites(products: products)
        }
        self.delegate?.updatedFavouritesListAt(viewController: self)
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableViewDataSource
extension PokemonListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = listViewModel.dataSource?.count ?? 0 <= listViewModel.totalCount ? 1 : 0
        return section == 0 ? listViewModel.dataSource?.count ?? 0 : rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier) as? ListTableViewCell else {
            fatalError("Unable to dequeue ListTableViewCell")
        }
        if indexPath.section == 0 {
            let pokemon = listViewModel.pokemon(at: indexPath)
            cell.configure(with: pokemon, indexPath: indexPath)
            if self.listViewModel.getSelectedPokemon(pokemon: pokemon) {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
            cell.checkboxBtnAction = { [weak self] sender in
                guard let button = sender as? UIButton else {
                    return
                }
                self?.toggleSelection(index: button.tag)
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.reuseIdentifier, for: indexPath) as? LoadingTableViewCell else {
                fatalError("Unable to dequeue ListTableViewCell")
            }
            cell.activityIndicator.startAnimating()
            return cell
        }
        return cell
    }
    
    func toggleSelection(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
        let value = !(cell.isSelected)
        let pokemon = self.listViewModel.pokemon(at: indexPath)
        self.listViewModel.toggleSelection(pokemon: pokemon, status: value)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

//MARK: - UITableViewDelegate
extension PokemonListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
        cell.isSelected = true
        let pokemon = self.listViewModel.pokemon(at: indexPath)
        self.listViewModel.toggleSelection(pokemon: pokemon, status: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
        cell.isSelected = false
        let pokemon = self.listViewModel.pokemon(at: indexPath)
        self.listViewModel.toggleSelection(pokemon: pokemon, status: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY > contentHeight - scrollView.frame.height * 4) && self.listViewModel.dataSource?.count ?? 0 <= self.listViewModel.totalCount {
            self.listViewModel.fetchPokemons()
        }
    }
}
