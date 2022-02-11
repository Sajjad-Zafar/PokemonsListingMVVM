//
//  ScrollableBottomSheetViewController.swift
//  Pokemon List
//
//  Created by Sajjad Zafar on 08/02/2022.
//

import UIKit

class ScrollableBottomSheetViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
        }
    }
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            self.searchBar.delegate = self
        }
    }
    //MARK: - Properties
    var bottomSheetViewModel: ScrollableBottomSheetViewModel!
    var frame: CGRect!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomSheetViewModel.getAllFavouritePokemons()
        self.collectionView.reloadData()
    }
    
    //MARK: - Private Methods
    private func setupView() {
        self.bottomSheetViewModel = ScrollableBottomSheetViewModel()
        self.searchBar.isUserInteractionEnabled = false
        setupCollectionViewLayout()
        self.collectionView.register(HomeCollectionViewCell.nib, forCellWithReuseIdentifier: HomeCollectionViewCell.reuseIdentifier)
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(ScrollableBottomSheetViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.6, animations: { [weak self] in
                let frame = self?.view.frame
                let yComponent = self?.bottomSheetViewModel.partialView
                self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height - 100)
            })
        }
    }
    
    func setupCollectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)

        let y = self.view.frame.minY
        if (y + translation.y >= self.bottomSheetViewModel.fullView) && (y + translation.y <= self.bottomSheetViewModel.partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - self.bottomSheetViewModel.fullView) / -velocity.y) : Double((self.bottomSheetViewModel.partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.bottomSheetViewModel.partialView, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.bottomSheetViewModel.fullView, width: self.view.frame.width, height: self.view.frame.height)
                }
                
                }, completion: { [weak self] _ in
                    if ( velocity.y < 0 ) {
                        self?.collectionView.isScrollEnabled = true
                    }
            })
        }
    }
}

//MARK: - UICollectionViewDataSource
extension ScrollableBottomSheetViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bottomSheetViewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.reuseIdentifier, for: indexPath as IndexPath) as? HomeCollectionViewCell else {
            fatalError("Unable to dequeue HomeCollectionViewCell")
        }
        let pokemon = self.bottomSheetViewModel.pokemon(at: indexPath)
        cell.pokemon = pokemon
        return cell
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension ScrollableBottomSheetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/2 - 10
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.collectionViewSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.collectionViewSpacing
    }
}

extension ScrollableBottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y

        let y = view.frame.minY
        if (y == self.bottomSheetViewModel.fullView && collectionView.contentOffset.y == 0 && direction > 0) || (y == self.bottomSheetViewModel.partialView) {
            collectionView.isScrollEnabled = false
        } else {
            collectionView.isScrollEnabled = true
        }
        return false
    }
}

//MARK: - PokemonListDelegate
extension ScrollableBottomSheetViewController: PokemonListDelegate {
    func updatedFavouritesListAt(viewController: PokemonListViewController) {
        bottomSheetViewModel.getAllFavouritePokemons()
        self.collectionView.reloadData()
    }
}

//MARK: - UISearchBarDelegate
extension ScrollableBottomSheetViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        bottomSheetViewModel.isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        bottomSheetViewModel.isSearching = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        bottomSheetViewModel.isSearching = false
    }
}
