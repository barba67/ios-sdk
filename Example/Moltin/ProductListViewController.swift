//
//  ProductListViewController.swift
//  Moltin
//
//  Created by Oliver Foggin on 27/02/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Moltin
import AlamofireImage

class ProductListViewController: UICollectionViewController {
    private var products: [Product] = []
    var category: ProductCategory!
    
    override func loadView() {
        let layout: UICollectionViewFlowLayout = {
            let l = UICollectionViewFlowLayout()
            l.scrollDirection = .vertical
            l.minimumInteritemSpacing = 1
            l.minimumLineSpacing = 1
            l.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            return l
        }()
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = category.name.uppercased()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        
        collectionView?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        collectionView?.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: "ProductCell")
        
        getProducts()
    }
    
    private func getProducts() {
        let query = MoltinQuery(offset: nil, limit: nil, sort: nil, filter: nil, include: [.files, .brands, .categories])
        
        Moltin.product.list(withQuery: query) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let products):
                self.products = products
                self.collectionView?.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCollectionViewCell
        
        let product = products[indexPath.item]
        
        cell.productNameLabel.text = product.name
        cell.categoryNameLabel.text = category.name
        cell.priceLabel.text = product.displayPriceWithTax?.formatted
        
        if let file = product.files.first {
            cell.productImageView.af_setImage(withURL: file.url)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        
        let controller = ProductDetailViewController()
        controller.product = product
        controller.category = category
        show(controller, sender: nil)
    }
}

extension ProductListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}

class ProductCollectionViewCell: UICollectionViewCell {
    let productNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.montserratBlack(size: 16)
        return l
    }()
    
    let categoryNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.montserratBlack(size: 14)
        l.textColor = .lightGray
        return l
    }()
    
    let priceLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.montserratLight(size: 20)
        l.textColor = UIColor(red:0.54, green:0.39, blue:0.70, alpha:1.00)
        return l
    }()
    
    let productImageView: UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFill
        i.heightAnchor.constraint(equalTo: i.widthAnchor).isActive = true
        return i
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let descriptionStackView: UIStackView = {
            let s = UIStackView(arrangedSubviews: [categoryNameLabel, productNameLabel])
            s.translatesAutoresizingMaskIntoConstraints = false
            s.axis = .vertical
            s.spacing = 6
            s.alignment = .leading
            return s
        }()
        
        let labelStackView: UIStackView = {
            let s = UIStackView(arrangedSubviews: [descriptionStackView, priceLabel])
            s.translatesAutoresizingMaskIntoConstraints = false
            s.spacing = 12
            s.axis = .vertical
            s.alignment = .leading
            return s
        }()
        
        let mainStackView: UIStackView = {
            let s = UIStackView(arrangedSubviews: [productImageView, labelStackView])
            s.translatesAutoresizingMaskIntoConstraints = false
            s.axis = .horizontal
            s.spacing = 8
            s.alignment = .center
            return s
        }()
        
        addSubview(mainStackView)
        
        mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
