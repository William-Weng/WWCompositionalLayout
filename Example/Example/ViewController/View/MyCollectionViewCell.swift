//
//  MyCollectionViewCell.swift
//  Example
//
//  Created by William.Weng on 2021/11/11.
//

import UIKit
import WWPrint

final class MyCollectionViewCell: UICollectionViewCell, CellReusable {
        
    @IBOutlet weak var myLabel: UILabel!
    
    static var dataSource = [1...30]._repeating(text:
    """
    .
    iPad mini 6
    Liquid Retina 顯示器
    8.3 吋 (對角線) LED 背光多點觸控顯示器，採用 IPS 技術
    2266 x 1488 解析度，每吋 326 像素 (ppi)
    廣色域顯示 (P3)
    原彩顯示
    防指印疏油外膜
    全平面貼合顯示
    抗反射鍍膜
    1.8% 反射率
    500 尼特最大亮度
    支援 Apple Pencil (第 2 代)
    """)
    
    func configure(with indexPath: IndexPath) {
        myLabel.text = Self.dataSource[safe: indexPath.row]
        self.backgroundColor = (indexPath.row % 2 == 0) ? .lightGray : .green
    }
}

