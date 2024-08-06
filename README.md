# WWCompositionalLayout
[![Swift-5.6](https://img.shields.io/badge/Swift-5.6-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-14.0](https://img.shields.io/badge/iOS-14.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![TAG](https://img.shields.io/github/v/tag/William-Weng/WWCompositionalLayout) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

### [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- A simple integrated version of iOS 13 [Compositional Layout](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/layouts), modified into a way similar to [Functional Programming](https://ithelp.ithome.com.tw/articles/10233399) to generate UICollectionViewCompositionalLayout.
- iOS 13 [Compositional Layout](https://www.appcoda.com.tw/compositional-layout/)的簡單整合版，修改成類似[Functional Programming](https://ithelp.ithome.com.tw/articles/10233399)的方式來生成UICollectionViewCompositionalLayout。

![](./Example.gif)

### [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```
dependencies: [
    .package(url: "https://github.com/William-Weng/WWCompositionalLayout.git", .upToNextMajor(from: "1.1.0"))
]
```

### Function - 可用函式
|函式|功能|
|-|-|
|addItem(width:height:contentInsets:badgeSetting:)|設定item的size (可以有很多個)|
|setGroup(width:height:interItemSpacing:scrollingDirection:)|設定group的size (只會有一個)|
|setSection(with:contentInsets:)|設定section的size (只會有一個)|
|setHeader(width:height:absoluteOffset:)|header的大小 (最上方的View)|
|setFooter(width:height:absoluteOffset:)|footer的大小 (最下方的View)|
|setDecoration(with:)|設定背景圖的View|
|groupLayoutMaker()|產生複合式的LayoutGroup|
|addGroup(with:)|加入複合式的LayoutGroup|
|build()|產生UICollectionViewCompositionalLayout|
|build(with:sectionSetting:)|產生複合式Group的UICollectionViewCompositionalLayout|

### Example
```swift
import UIKit
import WWPrint
import WWCompositionalLayout

final class ViewController: UIViewController {
    
    enum LayoutType: Int, CaseIterable {
        case tableView
        case photoAlbum
        case bookshelf
        case vendingMachine
        case dynamicHeight
        case complexGroup
    }
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    private let badgeViewKey = "Badge"
    private let contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
    private let edgeInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
    private let backgroundInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
    private let firstBadgeSetting: WWCompositionalLayout.BadgeSetting = (key: "Badge", size: (width: .absolute(20), height: .absolute(20)), zIndex: 100,
containerAnchor: (edges: [.top, .leading], absoluteOffset: CGPoint(x: 10, y: 10)), itemAnchor: (edges: [.bottom, .trailing], absoluteOffset: CGPoint(x: 0, y: 0)))
    private var currentLayoutIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetting()
        itemSizeAnimation()
    }
    
    @IBAction func changeLayout(_ sender: UIBarButtonItem) {
        
        currentLayoutIndex += 1
        if (currentLayoutIndex > (LayoutType.allCases.count - 1)) { currentLayoutIndex = 0 }
        initSetting()
    }
}

extension ViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { return 10 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return MyCollectionViewCell.dataSource.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView._reusableCell(at: indexPath) as MyCollectionViewCell
        cell.configure(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
                
        if kind == "\(WWCompositionalLayout.ReusableSupplementaryViewKind.header)" {
            let header = collectionView._reusableSupplementaryView(at: indexPath, ofKind: .header) as MyCollectionReusableHeader
            header.configure(with: indexPath)
            return header
        }
        
        if kind == "\(WWCompositionalLayout.ReusableSupplementaryViewKind.footer)" {
            let header = collectionView._reusableSupplementaryView(at: indexPath, ofKind: .footer) as MyCollectionReusableHeader
            header.configure(with: indexPath)
            return header
        }
        
        let badge = collectionView._reusableSupplementaryView(at: indexPath, ofKind: .badge(key: badgeViewKey)) as MyCollectionReusableBadge
        badge.configure(with: indexPath)
        
        return badge
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        wwPrint(indexPath)
    }
}

extension ViewController: UICollectionViewDelegate, UINavigationControllerDelegate {}

private extension ViewController {
    
    func initSetting() {
        
        guard let layoutType = LayoutType.allCases[safe: currentLayoutIndex],
              let layout = layoutMaker(with: layoutType)
        else {
            return
        }

        title = "\(layoutType)"
        myCollectionView._delegateAndDataSource(with: self)
        myCollectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    func layoutMaker(with type: LayoutType) -> UICollectionViewCompositionalLayout? {
        
        switch type {
        case .tableView: return tableViewLayout()
        case .photoAlbum: return photoAlbumLayout()
        case .bookshelf: return bookshelfLayout()
        case .vendingMachine: return vendingMachineLayout()
        case .dynamicHeight: return dynamicHeightLayout()
        case .complexGroup: return complexGroupLayout()
        }
    }
    
    func itemSizeAnimation(for type: LayoutType = .bookshelf) {
        
        WWCompositionalLayout.shared.visibleItemsInvalidationBlock = { (items, offset, environment) in
            
            guard let layoutType = LayoutType(rawValue: self.currentLayoutIndex), layoutType == type else { return }
            
            items.forEach { item in
                
                let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                let scaleRange: (min: CGFloat, max: CGFloat) = (0.7, 1.1)
                let scale = max(scaleRange.max - (distanceFromCenter / environment.container.contentSize.width), scaleRange.min)
                
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
}

private extension ViewController {
    
    func tableViewLayout() -> UICollectionViewCompositionalLayout? {
                
        let layout = WWCompositionalLayout.shared
            .addItem(width: .fractionalWidth(1.0), height: .absolute(120), contentInsets: edgeInsets, badgeSetting: firstBadgeSetting)
            .setDecoration(with: backgroundInsets)
            .setGroup(width: .fractionalWidth(1.0), height: .absolute(120), scrollingDirection: .horizontal)
            .setSection(with: .none, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(0.5), height: .absolute(16))
            .build()
        
        return layoutRegister(layout)
    }

    func photoAlbumLayout() -> UICollectionViewCompositionalLayout? {
        
        let layout = WWCompositionalLayout.shared
            .addItem(width: .fractionalWidth(1/3), height: .absolute(120), contentInsets: edgeInsets)
            .setDecoration(with: backgroundInsets)
            .setGroup(width: .fractionalWidth(1.0), height: .absolute(120), scrollingDirection: .horizontal)
            .setSection(with: .none, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(0.5), height: .absolute(16))
            .build()
        
        return layoutRegister(layout)
    }
    
    func bookshelfLayout(with count: CGFloat = 4.0) -> UICollectionViewCompositionalLayout? {
        
        let mainScreenWidth = UIScreen.main.bounds.width
        let contentInsets = NSDirectionalEdgeInsets(top: 5, leading: mainScreenWidth/2 - mainScreenWidth/2/count, bottom: 5, trailing: mainScreenWidth/2/count)
        
        let layout = WWCompositionalLayout.shared
            .addItem(width: .fractionalWidth(1.0), height: .absolute(120), contentInsets: edgeInsets, badgeSetting: nil)
            // .setDecoration(with: backgroundInsets)
            .setGroup(width: .fractionalWidth(1.0 / count), height: .absolute(120), scrollingDirection: .vertical)
            .setSection(with: .continuousGroupLeadingBoundary, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(0.5), height: .absolute(16))
            .build()
        
        return layoutRegister(layout)
    }
    
    func vendingMachineLayout() -> UICollectionViewCompositionalLayout? {
        
        let layout = WWCompositionalLayout.shared
            .addItem(width: .fractionalWidth(1.0), height: .absolute(50), contentInsets: edgeInsets, badgeSetting: nil)
            .addItem(width: .fractionalWidth(1.0), height: .absolute(100), contentInsets: edgeInsets, badgeSetting: nil)
            .addItem(width: .fractionalWidth(1.0), height: .absolute(150), contentInsets: edgeInsets, badgeSetting: nil)
            .setDecoration(with: backgroundInsets)
            .setGroup(width: .fractionalWidth(1/2), height: .estimated(100), scrollingDirection: .vertical)
            .setSection(with: .continuousGroupLeadingBoundary, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(0.5), height: .absolute(16))
            .build()
        
        return layoutRegister(layout)
    }
    
    func dynamicHeightLayout() -> UICollectionViewCompositionalLayout? {
        
        let layout = WWCompositionalLayout.shared
            .addItem(width: .fractionalWidth(1.0), height: .estimated(120), contentInsets: edgeInsets, badgeSetting: firstBadgeSetting)
            .setGroup(width: .fractionalWidth(1.0), height: .estimated(120), scrollingDirection: .horizontal)
            .setDecoration(with: backgroundInsets)
            .setSection(with: .none, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(0.5), height: .absolute(16))
            .build()
        
        return layoutRegister(layout)
    }
    
    func complexGroupLayout() -> UICollectionViewCompositionalLayout? {
        
        let groupSetting = WWCompositionalLayout.GroupSetting(width: .estimated(100), height: .absolute(200), interItemSpacing: .fixed(2), scrollingDirection: .vertical)
        let sectionSetting = WWCompositionalLayout.SectionSetting(scrollingBehavior: .continuous, contentInsets: .zero)
        
        let groupLayout1 = WWCompositionalLayout.shared
            .addItem(width: .absolute(120), height: .absolute(120), contentInsets: edgeInsets, badgeSetting: firstBadgeSetting)
            .setGroup(width: .absolute(120), height: .absolute(120), scrollingDirection: .horizontal)
            .groupLayoutMaker()
        
        let groupLayout2 = WWCompositionalLayout.shared
            .addItem(width: .absolute(60), height: .absolute(60), contentInsets: edgeInsets, badgeSetting: nil)
            .setGroup(width: .absolute(120), height: .absolute(60), scrollingDirection: .horizontal)
            .groupLayoutMaker()
        
        guard let groupLayout1 = groupLayout1,
              let groupLayout2 = groupLayout2
        else {
            return nil
        }
        
        let layout = WWCompositionalLayout.shared
            .addGroup(with: groupLayout1)
            .addGroup(with: groupLayout2)
            .setDecoration(with: backgroundInsets)
            .setSection(with: .none, contentInsets: contentInsets)
            .setHeader(width: .fractionalWidth(1.0), height: .absolute(16))
            .setFooter(width: .fractionalWidth(1.0), height: .absolute(16))
            .build(with: groupSetting, sectionSetting: sectionSetting)
        
        return layoutRegister(layout)
    }
}

private extension ViewController {
    
    func layoutRegister(_ layout: UICollectionViewCompositionalLayout?) -> UICollectionViewCompositionalLayout? {
        
        guard let layout = layout else { return nil }
        
        let newLayout = layout
            ._register(with: myCollectionView, supplementaryViewClass: MyCollectionReusableHeader.self, ofKind: .header)
            ._register(with: myCollectionView, supplementaryViewClass: MyCollectionReusableHeader.self, ofKind: .footer)
            ._register(with: myCollectionView, supplementaryViewClass: MyCollectionReusableBadge.self, ofKind: .badge(key: badgeViewKey))
            ._register(with: MyCollectionReusableDecoration.self, ofKind: .decoration)
            ._register(with: MyCollectionReusableBadge.self, ofKind: .badge(key: badgeViewKey))
        
        return newLayout
    }
}
```
