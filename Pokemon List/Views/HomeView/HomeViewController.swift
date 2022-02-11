//
//  ViewController.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import UIKit

class HomeViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
        //MARK: - Properties
    var homeViewModel: HomeViewModel!
    var bottomSheet: ScrollableBottomSheetViewController!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addBottomSheetView()
    }

    //MARK: - Private Methods
    func setupView() {
        homeViewModel = HomeViewModel()
        bottomSheet = ScrollableBottomSheetViewController()
        self.profileImageView.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
    }
    
    func addBottomSheetView(scrollable: Bool? = true) {
        self.addChild(bottomSheet)
        self.view.addSubview(bottomSheet.view)
        bottomSheet.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheet.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Actions
    @IBAction func pokemonListBtnTapped(_ sender: Any) {
        let pokemonList = self.storyboard?.instantiateViewController(withIdentifier: "PokemonListViewController") as! PokemonListViewController
        pokemonList.delegate = bottomSheet
        self.navigationController?.pushViewController(pokemonList, animated: true)
    }
}
