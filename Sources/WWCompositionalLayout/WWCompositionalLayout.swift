//
//  CompositionalLayout.swift
//  CompositionalLayout
//
//  Created by William.Weng on 2021/11/11.
//

import UIKit

open class WWCompositionalLayout: NSObject {
    
    public static let shared = WWCompositionalLayout()
    
    public var visibleItemsInvalidationBlock: (([NSCollectionLayoutVisibleItem], CGPoint, NSCollectionLayoutEnvironment) -> Void)?
    
    private var itemSettings: [ItemSetting] = []
    private var groupSetting: GroupSetting?
    private var sectionSetting: SectionSetting?
    private var headerSetting: HeaderSetting?
    private var footerSetting: FooterSetting?
    private var decorationSetting: DecorationSetting?
    private var multipleGroups: [NSCollectionLayoutGroup] = []
}

// MARK: - typealias
public extension WWCompositionalLayout {
    
    typealias BadgeSetting = (key: String, size: ItemSize, zIndex: Int, containerAnchor: AnchorSetting, itemAnchor: AnchorSetting)
    typealias ItemSize = (width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension)
    typealias AnchorSetting = (edges: NSDirectionalRectEdge, absoluteOffset: CGPoint)
    typealias FooterSetting = HeaderSetting
}

// MARK: - enum
public extension WWCompositionalLayout {
    
    /// 滾動的方向
    enum NSCollectionLayoutDirection {
        case horizontal
        case vertical
    }
    
    /// UICollectionReusableView的Kind (自定義文字)
    enum ReusableSupplementaryViewKind: CustomStringConvertible {
        
        public var description: String { return toString() }
        
        case none
        case header
        case footer
        case badge(key: String)
        case decoration
        
        /// 轉換成對應的文字
        /// - Returns: String
        func toString() -> String {
            switch self {
            case .none: return "UICollectionNone"
            case .header: return "UICollectionElementKindSectionHeader"
            case .footer: return "UICollectionElementKindSectionFooter"
            case .badge(let key): return "UICollectionElementKindSectionBadge-\(key)"
            case .decoration: return "UICollectionElementKindDecoration"
            }
        }
    }
}

// MARK: - struct
public extension WWCompositionalLayout {
    
    struct HeaderSetting {
        let width: NSCollectionLayoutDimension
        let height: NSCollectionLayoutDimension
        let kind: ReusableSupplementaryViewKind
        let alignment: NSRectAlignment
        let absoluteOffset: CGPoint
    }
    
    struct ItemSetting {
        let width: NSCollectionLayoutDimension
        let height: NSCollectionLayoutDimension
        let contentInsets: NSDirectionalEdgeInsets?
        let badgeSetting: BadgeSetting?
    }
    
    struct GroupSetting {
        
        let width: NSCollectionLayoutDimension
        let height: NSCollectionLayoutDimension
        let interItemSpacing: NSCollectionLayoutSpacing?
        let scrollingDirection: NSCollectionLayoutDirection?
        
        public init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, interItemSpacing: NSCollectionLayoutSpacing? = nil, scrollingDirection: NSCollectionLayoutDirection? = nil) {
            self.width = width
            self.height = height
            self.interItemSpacing = interItemSpacing
            self.scrollingDirection = scrollingDirection
        }
    }
    
    struct SectionSetting {
        
        let scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
        let contentInsets: NSDirectionalEdgeInsets
        
        public init(scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior, contentInsets: NSDirectionalEdgeInsets) {
            self.scrollingBehavior = scrollingBehavior
            self.contentInsets = contentInsets
        }
    }
    
    struct DecorationSetting {
        let kind: ReusableSupplementaryViewKind
        let contentInsets: NSDirectionalEdgeInsets
    }
}

// MARK: - CompositionalLayout.Setting (function)
public extension WWCompositionalLayout {
    
    /// [設定item的size (可以有很多個)](https://www.donnywals.com/using-compositional-collection-view-layouts-in-ios-13/)
    /// - Parameters:
    ///   - width: [NSCollectionLayoutDimension](https://www.raywenderlich.com/5436806-modern-collection-views-with-compositional-layouts)
    ///   - height: [NSCollectionLayoutDimension](https://www.raywenderlich.com/9477-uicollectionview-tutorial-reusable-views-selection-and-reordering)
    ///   - contentInsets: [NSDirectionalEdgeInsets?](https://medium.com/flawless-app-stories/all-what-you-need-to-know-about-uicollectionviewcompositionallayout-f3b2f590bdbe)
    ///   - badgeSetting: [小紅點的相關設定](https://stackoverflow.com/questions/60112393/section-header-zindex-in-uicollectionview-compositionallayout-ios-13)
    /// - Returns: [Self](https://medium.com/@Anantha1992/stretchable-header-view-in-uicollectionview-swift-5-ios-a14a25dcd383)
    func addItem(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, contentInsets: NSDirectionalEdgeInsets? = nil, badgeSetting: BadgeSetting? = nil) -> Self {
        
        let setting = ItemSetting(width: width, height: height, contentInsets: contentInsets, badgeSetting: badgeSetting)
        itemSettings.append(setting)
        
        return self
    }
    
    /// [設定group的size (只會有一個)](https://www.jianshu.com/p/40868928a1cf)
    /// - Parameters:
    ///   - width: [NSCollectionLayoutDimension](https://www.appcoda.com.tw/compositional-layout/)
    ///   - height: [NSCollectionLayoutDimension](https://ali-akhtar.medium.com/uicollection-compositional-layout-part-3-7d6d66806979)
    ///   - interItemSpacing: [NSCollectionLayoutSpacing?](https://apestalk.github.io/2020/07/19/初探UICollectionViewCompositionalLayout/)
    ///   - scrollingDirection: [NSCollectionLayoutDirection](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/如何讓-static-cell-自動計算高度-cb493a522245)
    /// - Returns: [Self](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/uicollectionviewcompositionallayout-常見排版範例-7656068783d9)
    func setGroup(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, interItemSpacing: NSCollectionLayoutSpacing? = nil, scrollingDirection: NSCollectionLayoutDirection) -> Self {
        groupSetting = GroupSetting(width: width, height: height, interItemSpacing: interItemSpacing, scrollingDirection: scrollingDirection)
        return self
    }
    
    /// [設定section的size (只會有一個)](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/方便排版的-uicollectionviewcompositionallayout-初體驗-ab0c81ffecf6)
    /// - Parameters:
    ///   - scrollingBehavior: 滾動的方向
    ///   - contentInsets: NSDirectionalEdgeInsets
    /// - Returns: Self
    func setSection(with scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none, contentInsets: NSDirectionalEdgeInsets) -> Self {
        sectionSetting = SectionSetting(scrollingBehavior: scrollingBehavior, contentInsets: contentInsets)
        return self
    }
    
    /// header的大小 (最上方的View)
    /// - Parameters:
    ///   - width: NSCollectionLayoutDimension
    ///   - height: NSCollectionLayoutDimension
    ///   - absoluteOffset: CGPoint
    /// - Returns: Self
    func setHeader(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, absoluteOffset: CGPoint = .zero) -> Self {
        headerSetting = HeaderSetting(width: width, height: height, kind: .header, alignment: .top, absoluteOffset: absoluteOffset)
        return self
    }
    
    /// footer的大小 (最下方的View)
    /// - Parameters:
    ///   - width: NSCollectionLayoutDimension
    ///   - height: NSCollectionLayoutDimension
    ///   - absoluteOffset: CGPoint
    /// - Returns: Self
    func setFooter(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, absoluteOffset: CGPoint = .zero) -> Self {
        footerSetting = FooterSetting(width: width, height: height, kind: .footer, alignment: .bottom, absoluteOffset: absoluteOffset)
        return self
    }
    
    /// 設定背景圖的View
    /// - Parameters:
    ///   - contentInsets: NSDirectionalEdgeInsets
    /// - Returns: NSCollectionLayoutDecorationItem
    func setDecoration(with contentInsets: NSDirectionalEdgeInsets = .zero) -> Self {
        decorationSetting = DecorationSetting(kind: .decoration, contentInsets: contentInsets)
        return self
    }
    
    /// 產生複合式的LayoutGroup
    /// - Returns: NSCollectionLayoutGroup?
    func groupLayoutMaker() -> NSCollectionLayoutGroup? {
        
        defer { cleanAllSetting() }
        
        guard let subItems = subItemsMaker(with: itemSettings),
              let group = groupMaker(with: groupSetting, subitems: subItems)
        else {
            return nil
        }
        
        return group
    }
    
    /// 加入複合式的LayoutGroup
    /// - Parameter group: NSCollectionLayoutGroup
    /// - Returns: Self
    func addGroup(with group: NSCollectionLayoutGroup) -> Self {
        multipleGroups.append(group)
        return self
    }
    
    /// [產生UICollectionViewCompositionalLayout](https://lickability.com/blog/getting-started-with-uicollectionviewcompositionallayout/)
    /// - Returns: UICollectionViewCompositionalLayout?
    func build() -> UICollectionViewCompositionalLayout? {
        
        defer { cleanAllSetting() }
        
        guard let subItems = subItemsMaker(with: itemSettings),
              let group = groupMaker(with: groupSetting, subitems: subItems),
              let section = sectionMaker(with: sectionSetting, group: group)
        else {
            return nil
        }
        
        if let header = headerMaker(with: headerSetting) { section.boundarySupplementaryItems.append(header) }
        if let footer = footerMaker(with: footerSetting) { section.boundarySupplementaryItems.append(footer) }
                
        section.visibleItemsInvalidationHandler = self.visibleItemsInvalidationBlock
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    /// 產生複合式Group的UICollectionViewCompositionalLayout
    /// - Parameters:
    ///   - groupSetting: GroupSetting
    ///   - sectionSetting: SectionSetting
    /// - Returns: UICollectionViewCompositionalLayout?
    func build(with groupSetting: GroupSetting, sectionSetting: SectionSetting) -> UICollectionViewCompositionalLayout? {

        defer {
            cleanAllSetting()
            multipleGroups = []
        }
        
        guard let group = groupMaker(with: groupSetting, subitems: multipleGroups),
              let section = sectionMaker(with: sectionSetting, group: group)
        else {
            return nil
        }

        if let header = headerMaker(with: headerSetting) { section.boundarySupplementaryItems.append(header) }
        if let footer = footerMaker(with: footerSetting) { section.boundarySupplementaryItems.append(footer) }
        
        section.visibleItemsInvalidationHandler = self.visibleItemsInvalidationBlock
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - WWCompositionalLayout (private function)
private extension WWCompositionalLayout {
    
    /// [NSCollectionLayoutSize] => [NSCollectionLayoutItem]
    /// - Parameter setting: [ItemSetting]
    /// - Returns: [NSCollectionLayoutItem]?
    func subItemsMaker(with setting: [ItemSetting]) -> [NSCollectionLayoutItem]? {
        
        guard !setting.isEmpty else { return nil }
        
        let items = setting.compactMap { (setting) -> NSCollectionLayoutItem? in
            
            let size = NSCollectionLayoutSize(widthDimension: setting.width, heightDimension: setting.height)
            var item: NSCollectionLayoutItem

            if let badgeItem = badgeMaker(with: setting.badgeSetting) {
                item = NSCollectionLayoutItem(layoutSize: size, supplementaryItems: [badgeItem])
            } else {
                item = NSCollectionLayoutItem(layoutSize: size)
            }
            
            if let contentInsets = setting.contentInsets { item.contentInsets = contentInsets }
            
            return item
        }
        
        return items
    }
    
    /// 產生小紅點 => NSCollectionLayoutSupplementaryItem
    /// - Parameter setting: BadgeSetting?
    /// - Returns: NSCollectionLayoutSupplementaryItem?
    func badgeMaker(with setting: BadgeSetting?) -> NSCollectionLayoutSupplementaryItem? {
        
        guard let setting = setting else { return nil }
        
        let kind = "\(ReusableSupplementaryViewKind.badge(key: setting.key))"
        let size = NSCollectionLayoutSize(widthDimension: setting.size.width, heightDimension: setting.size.height)
        let containerAnchor = NSCollectionLayoutAnchor(edges: setting.containerAnchor.edges, absoluteOffset: setting.containerAnchor.absoluteOffset)
        let itemAnchor = NSCollectionLayoutAnchor(edges: setting.itemAnchor.edges, absoluteOffset: setting.itemAnchor.absoluteOffset)
        let item = NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: kind, containerAnchor: containerAnchor, itemAnchor: itemAnchor)
        
        item.zIndex = setting.zIndex
        return item
    }
    
    /// [NSCollectionLayoutItem] => NSCollectionLayoutGroup
    /// - Parameters:
    ///   - setting: GroupSetting?
    ///   - subitems: [NSCollectionLayoutItem]
    /// - Returns: NSCollectionLayoutGroup?
    func groupMaker(with setting: GroupSetting?, subitems: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup? {
        
        guard let setting = setting,
              let scrollingDirection = setting.scrollingDirection,
              let layoutSize = Optional.some(NSCollectionLayoutSize(widthDimension: setting.width, heightDimension: setting.height))
        else {
            return nil
        }
        
        let group: NSCollectionLayoutGroup
        
        switch scrollingDirection {
        case .horizontal: group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: subitems)
        case .vertical: group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, subitems: subitems)
        }
        
        group.interItemSpacing = groupSetting?.interItemSpacing
        
        return group
    }
    
    /// NSCollectionLayoutGroup => NSCollectionLayoutSection
    /// - Parameters:
    ///   - setting: SectionSetting?
    ///   - group: NSCollectionLayoutGroup
    /// - Returns: NSCollectionLayoutSection?
    func sectionMaker(with setting: SectionSetting?, group: NSCollectionLayoutGroup) -> NSCollectionLayoutSection? {
        
        guard let setting = setting,
              let section = Optional.some(NSCollectionLayoutSection(group: group))
        else {
            return nil
        }
        
        section.orthogonalScrollingBehavior = setting.scrollingBehavior
        section.contentInsets = setting.contentInsets
        
        if let decoration = decorationMaker(with: decorationSetting) { section.decorationItems = [decoration] }
                
        return section
    }
    
    /// 將header的設定 => NSCollectionLayoutBoundarySupplementaryItem
    /// - Parameter setting: HeaderSetting
    /// - Returns: NSCollectionLayoutBoundarySupplementaryItem?
    func headerMaker(with setting: HeaderSetting?) -> NSCollectionLayoutBoundarySupplementaryItem? {
        
        guard let setting = setting else { return nil }
        
        let headerSize = NSCollectionLayoutSize(widthDimension: setting.width, heightDimension: setting.height)
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "\(setting.kind)", alignment: setting.alignment, absoluteOffset: setting.absoluteOffset)
        
        return header
    }
    
    /// 將footer的設定 => NSCollectionLayoutBoundarySupplementaryItem
    /// - Parameter setting: HeaderSetting
    /// - Returns: NSCollectionLayoutBoundarySupplementaryItem?
    func footerMaker(with setting: FooterSetting?) -> NSCollectionLayoutBoundarySupplementaryItem? { return headerMaker(with: setting) }
    
    /// 將背景圖的設定 => NSCollectionLayoutDecorationItem
    /// - Returns: NSCollectionLayoutDecorationItem?
    func decorationMaker(with setting: DecorationSetting?) -> NSCollectionLayoutDecorationItem? {
        
        guard let setting = setting else { return nil }
        
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "\(setting.kind)")
        decorationItem.contentInsets = setting.contentInsets
        
        return decorationItem
    }
    
    /// 清除所有設定
    func cleanAllSetting() {
        itemSettings = []
        groupSetting = nil
        sectionSetting = nil
        headerSetting = nil
        footerSetting = nil
        decorationSetting = nil
    }
}
