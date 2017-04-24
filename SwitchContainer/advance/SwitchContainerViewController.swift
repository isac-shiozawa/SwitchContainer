//
//  SwitchContainerViewController.swift
//  SwitchContainer
//
//  Created by 塩澤 on 2017/03/31.
//  Copyright © 2017年 co.i-sac.test. All rights reserved.
//

import UIKit

class SwitchContainerViewController:UIView{
    var masterViewController:UIViewController?
    
    //ヘッダスクロールデータ
    @IBOutlet weak var scrollHeader: UIScrollView!
    var floatingHeader:UIView?
    var headerOnes:CGFloat = 3.0
    var isOnscreen = false
    //メインスクロールデータ
    @IBOutlet weak var scrollMain: UIScrollView!
    var floating:UIView?
    var containers:[UIView] = []
    var childs:[ChildViewController] = []
    var headers:[ChildHeaderView?] = []
    //共通
    var pageNow:Int = 0
    // MARK:- 
    class func instance() -> SwitchContainerViewController {
        return UINib(nibName:"SwitchContainerScrollView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! SwitchContainerViewController
    }
    // MARK:- 独自メソド
    func addViewFromNIB(_ name:String, header:String? = nil){
        let content:ChildViewController = UINib(nibName: name, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ChildViewController
        content.setIndex(containers.count)
        childs.append(content)

        //コンテナ属性追加
        let container:UIView = UIView(frame:(self.masterViewController?.view.frame)!)
        containers.append(container)
        //
        self.masterViewController?.addChildViewController(content)
        content.view.frame = container.bounds
        container.addSubview(content.view)
        content.didMove(toParentViewController: self.masterViewController)
        
        //ヘッダ管理
        if( header != nil){
            let view:ChildHeaderView = UINib(nibName: header!, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ChildHeaderView
            
            headers.append(view)
        }else{
            headers.append(nil)
        }
    }
    func initData(_ delegate:UIScrollViewDelegate, controller:UIViewController) {
        //print("self.scrollMain \(self.scrollMain)")
        self.scrollMain.delegate = delegate
        self.masterViewController = controller
    }
    func setOnScreenFlag(_ flag:Bool){
        self.isOnscreen = flag
    }
    func setOneScreenCount(_ num:Int){
        if 0 < num {
            self.headerOnes = CGFloat(num)
        }
    }
    
    let CHECK = 100
    func makeView(){
        // 表示できる限界(bound)のサイズ
        let width:CGFloat = getWidth() * CGFloat(containers.count)
        self.scrollMain.contentSize = CGSize(width: width, height: scrollMain.bounds.height)
        floating = UIView(frame: CGRect(x: 0, y: 0, width: width, height: scrollMain.bounds.height))
        floating?.backgroundColor = UIColor.white
        //ヘッダスクロールデータ
        let widteader:CGFloat = getHeaderWidth() * CGFloat(containers.count)
        self.scrollHeader.contentSize = CGSize(width: widteader, height: scrollHeader.bounds.height)
        self.scrollHeader.isScrollEnabled = false
        floatingHeader = UIView(frame: CGRect(x: 0, y: 0, width: widteader, height: scrollHeader.bounds.height))
        
        for i in 0..<containers.count{
            let point:CGFloat = getWidth() * CGFloat(i)
            containers[i].frame = CGRect(x: point, y: 0, width: getWidth(), height: scrollMain.bounds.height)
            floating?.addSubview(containers[i])
            //ヘッダスクロールデータ
            let pointHeader:CGFloat = getHeaderWidth() * CGFloat(i)
            let view:ChildHeaderView = ChildHeaderView.instance(frame: CGRect(x: pointHeader, y: 0, width: getHeaderWidth(), height: scrollHeader.bounds.height), headerview:headers[i], title: childs[i].getTitle(), index: i, master: self)
            floatingHeader?.addSubview(view)
        }
        self.scrollMain.addSubview(floating!)
        self.scrollMain.bounces = false
        
        self.scrollHeader.addSubview(floatingHeader!)
        self.scrollHeader.bounces = false
    }
    
    func getWidth()->CGFloat{
        return self.bounds.width
    }
    func getHeaderWidth()->CGFloat{
        if(isOnscreen){
            return getWidth() / CGFloat(childs.count)
        }
        return getWidth() / headerOnes
    }
    
    
    //MARK:-
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset:CGPoint  = scrollView.contentOffset;
        let page:Int  = Int((offset.x + (getWidth()/2.0))/getWidth())
        shiftPage(page)
    }
    
    func shiftPage(_ page:Int){
        if(page<0 || containers.count <= page){
            return
        }
        if (pageNow == page) {
            return
        }
        pageNow = page
        //メイン遷移
        self.scrollMain.setContentOffset(CGPoint(x:CGFloat(pageNow) * getWidth(), y:0), animated: true)
        //ヘッダ遷移
        if(!isOnscreen){
            if pageNow < getPadding() {
                self.scrollHeader.setContentOffset(CGPoint(x:0, y:0), animated: true)
                return
            }
            var tmp = containers.count
            tmp = tmp - getPadding() - 1
            if tmp < pageNow {
                self.scrollHeader.setContentOffset(CGPoint(x: (CGFloat(containers.count) - headerOnes) * getHeaderWidth(), y:0), animated: true)
                return
            }
            
            self.scrollHeader.setContentOffset(CGPoint(x:CGFloat(pageNow - getPadding() + 1) * getHeaderWidth(), y:0), animated: true)
        }
    }
    func getPadding()->Int{
        return Int(headerOnes / 2.0 + 0.5)
    }
    
    //ボタンをタップした際に行われる処理
    func buttonTapped(_ sender: UIButton){
        if(sender.tag == pageNow){
            return
        }
        var offset:CGPoint  = scrollMain.contentOffset;
        offset.x = CGFloat(sender.tag)*getWidth()
        scrollMain.contentOffset = offset
        
        
    }
    
    
}


/// ヘッダはこれを継承して作る
class ChildHeaderView: UIView{
    var masterViewController:SwitchContainerViewController? = nil
    
    class func instance(frame: CGRect, headerview:ChildHeaderView?, title:String, index:Int, master:SwitchContainerViewController)->ChildHeaderView{
        let view:ChildHeaderView
        if(headerview == nil){
            view = ChildHeaderView(frame: frame)
            //
            let labelTitle:UILabel = UILabel(frame:view.bounds)
            labelTitle.text = title
            labelTitle.sizeToFit()
            labelTitle.center = CGPoint(x: view.bounds.width/2.0, y: view.bounds.height/2.0)
            view.addSubview(labelTitle)
        }else{
            view = headerview!
            view.frame = frame
        }
        view.masterViewController = master
        //かぶせるようにボタンを設置
        let button:UIButton = UIButton(frame:view.bounds)
        button.tag = index
        button.addTarget(view, action: #selector(view.buttonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
        
        return view
    }
    
    func buttonTapped(_ sender: UIButton){
        masterViewController?.buttonTapped(sender)
    }

}

/// メインになるViewControllerはこれを継承して作る
class ChildViewController: UIViewController{
    var index:Int!
    
    
    func setIndex(_ i:Int){
        index = i
    }
    
    
    func getTitle()->String{
        return ""
    }
}
