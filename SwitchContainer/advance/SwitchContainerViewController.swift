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
    let headerOnes:CGFloat = 3.0
    var isOnscreen = false
    //メインスクロールデータ
    @IBOutlet weak var scrollMain: UIScrollView!
    var floating:UIView?
    var containers:[UIView] = []
    var childs:[ChildViewController] = []
    //共通
    var pageNow:Int = 0
    // MARK:- 
    class func instance() -> SwitchContainerViewController {
        return UINib(nibName:"SwitchContainerScrollView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! SwitchContainerViewController
    }
    // MARK:- 独自メソド
    func addViewFromNIB(_ name:String){
        let content:ChildViewController = UINib(nibName: name, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ChildViewController
        content.setIndex(containers.count, function: buttonTappedNumber)
        childs.append(content)

        //コンテナ属性追加
        let container:UIView = UIView(frame:(self.masterViewController?.view.frame)!)
        containers.append(container)
        //
        self.masterViewController?.addChildViewController(content)
        content.view.frame = container.bounds
        container.addSubview(content.view)
        content.didMove(toParentViewController: self.masterViewController)
    }
    func initData(_ delegate:UIScrollViewDelegate, controller:UIViewController) {
        //print("self.scrollMain \(self.scrollMain)")
        self.scrollMain.delegate = delegate
        self.masterViewController = controller
    }
    func setOnScreenFlag(_ flag:Bool){
        self.isOnscreen = flag
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
            print("point \(i) = \(pointHeader)")
            let view:UIView = UIView(frame: CGRect(x: pointHeader, y: 0, width: getHeaderWidth(), height: scrollHeader.bounds.height))
            let label:UILabel = UILabel(frame:view.bounds)
            label.text = childs[i].getTitle()
            label.sizeToFit()
            label.center = CGPoint(x: getHeaderWidth()/2.0, y: scrollHeader.bounds.height/2.0)
//            label.isUserInteractionEnabled = true
//            label.tag = i
            view.addSubview(label)
            let button:UIButton = UIButton(frame:view.bounds)
            button.tag = i
            button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
            view.addSubview(button)
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
            switch pageNow {
                case 0:
                    self.scrollHeader.setContentOffset(CGPoint(x:0, y:0), animated: true)
                    break
                case (containers.count - 1):
                    self.scrollHeader.setContentOffset(CGPoint(x:CGFloat(containers.count - 3) * getHeaderWidth(), y:0), animated: true)
                    break
                default:
                    self.scrollHeader.setContentOffset(CGPoint(x:CGFloat(pageNow - 1) * getHeaderWidth(), y:0), animated: true)
                    break
            }
        }
    }
    
    
    //ボタンをタップした際に行われる処理
    func buttonTapped(_ sender: UIButton){
        if(sender.tag == pageNow){
            return
        }
        var offset:CGPoint  = scrollMain.contentOffset;
        offset.x = CGFloat(sender.tag)*getWidth() - (getWidth()/2.0)
        scrollMain.contentOffset = offset
        
        
    }
    func buttonTappedNumber(_ num: Int){
        print("tap \(num)")
    }
    
    
}


class ChildViewController: UIViewController{
    var index:Int!
    var call = { (index: Int) -> Void in }
    
    
    func setIndex(_ i:Int, function:@escaping ((_ index: Int) -> Void)){
        index = i
        call = function
    }
    
    func callView(){
        call(index)
    }
    
    func getTitle()->String{
        return ""
    }
}
