//
//  UnDeliverGoodsViewController.swift
//  pointSingleThatIsTo
//
//  Created by 卢洋 on 16/2/25.
//  Copyright © 2016年 penghao. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import SVProgressHUD

///未发货
class UnDeliverGoodsViewController:BaseViewController,UITableViewDataSource,UITableViewDelegate{
    
    /// 未发货Table
    private var unDeliverGoodsTable:UITableView?
    
    /// 存放订单entity
    private var stockOrderEntityArray:[OrderListEntity]=[]
    
    /// 没有数据加载该视图
    private var nilView:UIView?
    
    /// 默认从第0页开始
    private var currentPage=0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="未发货"
        self.view.backgroundColor=UIColor.whiteColor()
        //监听通知 刷新数据
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateOrderList:", name:"postUpdateOrderList", object: nil)
        creatUnDeliverGoodsTable()
    }
    /**
     更新list
     
     - parameter obj:NSNotification
     */
    func updateOrderList(obj:NSNotification){
        unDeliverGoodsTable?.headerBeginRefreshing()
    }
    /**
    创建未发货Table
    */
    func creatUnDeliverGoodsTable(){
        unDeliverGoodsTable=UITableView(frame: CGRectMake(0, 0, boundsWidth, boundsHeight-104), style: UITableViewStyle.Plain)
        unDeliverGoodsTable?.delegate=self
        unDeliverGoodsTable?.dataSource=self
        unDeliverGoodsTable?.backgroundColor=UIColor.whiteColor()
        unDeliverGoodsTable?.separatorStyle=UITableViewCellSeparatorStyle.None
        self.view.addSubview(unDeliverGoodsTable!)
        
        unDeliverGoodsTable!.addHeaderWithCallback({//下拉重新加载数据
            //从第一页开始
            self.currentPage=1
            //重新发送请求
            self.queryOrderInfo4AndroidStoreByOrderStatus(self.currentPage,isRefresh: true)
        })
        unDeliverGoodsTable!.addFooterWithCallback({//上拉加载更多
            //每次页面索引加1
            self.currentPage+=1
            self.queryOrderInfo4AndroidStoreByOrderStatus(self.currentPage,isRefresh: false)
        })
        //加载等待视图
        SVProgressHUD.showWithStatus("数据加载中")
        unDeliverGoodsTable!.headerBeginRefreshing()
        
    
    }
    //MARK -------------实现Table的一些协议----------------------------
    //返回几组
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    //返回行高
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 170
    }
    //返回行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockOrderEntityArray.count
    }
    //返回数据源
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let Identifier="StockOrderManageTableViewCellId"
        var cell=tableView.dequeueReusableCellWithIdentifier(Identifier) as? StockOrderManageTableViewCell
        if(cell == nil){
            cell=NSBundle.mainBundle().loadNibNamed("StockOrderManageTableViewCell", owner:self, options: nil).last as? StockOrderManageTableViewCell
        }
        if stockOrderEntityArray.count > 0{
            cell!.updateCell(stockOrderEntityArray[indexPath.row])
            let viewMiddle=UIView(frame:CGRectMake(0,40,boundsWidth,80))
            viewMiddle.tag=indexPath.row
            viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target:self, action:"pushOrderDetail:"))
            cell!.contentView.addSubview(viewMiddle)
        }
        cell!.selectionStyle=UITableViewCellSelectionStyle.None
        return cell!
    }
    /**
     跳转到详情页面
     
     - parameter sender:UITapGestureRecognizer
     */
    func pushOrderDetail(sender:UITapGestureRecognizer){
        let vc=StockOrderDetailsViewController()
        vc.orderList=stockOrderEntityArray[sender.view!.tag]
        self.navigationController!.pushViewController(vc, animated:true)
    }
    //tableview开始载入的动画
    func tableView(tableView: UITableView, willDisplayCell cell:UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        //设置cell的显示动画为3D缩放
        //xy方向缩放的初始值为0.1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        //设置动画时间为0.25秒,xy方向缩放的最终值为1
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    /**
    queryOrderInfo4AndroidStoreByOrderStatus   查询未发货订单
    
    - parameter currentPage: 当前页
    - parameter isRefresh:   是否刷新true是
    */
    func queryOrderInfo4AndroidStoreByOrderStatus(currentPage:Int,isRefresh:Bool){
        let storeId=userDefaults.objectForKey("storeId") as! String
        //判断有无网络
        if(IJReachability.isConnectedToNetwork()){
            //统计订单数，每次发请求先置空
            var count=0
            //开始发送未发货订单查询请求(orderStatus状态为1)
            PHMoyaHttp.sharedInstance.requestDataWithTargetJSON(RequestAPI.queryOrderInfo4AndroidStoreByOrderStatus(orderStatus: 1, storeId: storeId, pageSize: 10, currentPage: currentPage), successClosure: { (result) -> Void in
                //关闭加载等待视图
                SVProgressHUD.dismiss()
                let jsonResult=JSON(result)
                if isRefresh{
                    self.stockOrderEntityArray.removeAll()
                }
                for(_,robbedListValue)in jsonResult{//取出订单entity
                    // 每次循环加1
                    count++
                    //储存json一键转entity的值
                    let robbedEntity=Mapper<OrderListEntity>().map(robbedListValue.object)
                    //获取"list"的value
                    let list=robbedListValue["list"]
                    //临时储存商品数组
                    let GoodsArray=NSMutableArray()
                    for(_,GoodsDetailsValue)in list{//取出商品entity
                        let GoodsDetailsEntity=Mapper<GoodDetailEntity>().map(GoodsDetailsValue.object)
                        GoodsArray.addObject(GoodsDetailsEntity!)
                    }
                    //将临时的商品数组赋值给订单实体类中的"list"
                    robbedEntity?.list=GoodsArray
                    //添加到订单entity数组中
                    self.stockOrderEntityArray.append(robbedEntity!)
                }
                if count < 10{//判断count是否小于10  如果小于表示没有可以加载了 隐藏加载状态
                    self.unDeliverGoodsTable?.setFooterHidden(true)
                }else{//否则显示
                    self.unDeliverGoodsTable?.setFooterHidden(false)
                }
                if(self.stockOrderEntityArray.count < 1){//如果数据为空，显示默认视图
                    self.nilView?.removeFromSuperview()
                    self.nilView=nilPromptView("赶快去下单吧^ - ^")
                    self.nilView!.center=self.unDeliverGoodsTable!.center
                    self.view.addSubview(self.nilView!)
                }else{//如果有数据清除
                    self.nilView?.removeFromSuperview()
                }
                //关闭下拉刷新状态
                self.unDeliverGoodsTable?.headerEndRefreshing()
                //关闭上拉加载状态
                self.unDeliverGoodsTable?.footerEndRefreshing()
                //重新加载Table
                self.unDeliverGoodsTable?.reloadData()
                }, failClosure: { (errorMsg) -> Void in
                    //关闭刷新状态
                    self.unDeliverGoodsTable?.headerEndRefreshing()
                    //关闭加载状态
                    self.unDeliverGoodsTable?.footerEndRefreshing()
                    SVProgressHUD.showErrorWithStatus(errorMsg)
            })
        }else{
            SVProgressHUD.showErrorWithStatus("无网络连接")
        }
    }

}