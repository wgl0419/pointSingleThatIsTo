//
//  IndexSpecialAndPromotions.swift
//  pointSingleThatIsTo
//
//  Created by hao peng on 2017/3/14.
//  Copyright © 2017年 penghao. All rights reserved.
//

import Foundation
import UIKit
/// 首页特价和促销区
class IndexSpecialAndPromotions:UICollectionViewCell{
    private var img:UIImageView!
    override init(frame: CGRect){
        super.init(frame:frame);
        img=UIImageView(frame:CGRectMake(0,0,boundsWidth/2,boundsWidth/2-70))
        self.contentView.addSubview(img)
    }
    /**
     更新cell图片
     */
    func updateCell(entity:SpecialAndPromotionsEntity){
        img.sd_setImageWithURL(NSURL(string:URLIMG+entity.advertisingURL!),placeholderImage:UIImage(named:"def_nil"))
//        //拉伸图片4个边角
//        img.image=img.image?.resizableImageWithCapInsets(UIEdgeInsets(top:1, left:1, bottom:1, right: 1))
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}