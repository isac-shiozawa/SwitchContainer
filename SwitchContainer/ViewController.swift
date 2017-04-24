//
//  ViewController.swift
//  SwitchContainer
//
//  Created by 塩澤 on 2017/03/31.
//  Copyright © 2017年 co.i-sac.test. All rights reserved.
//

import UIKit

class ViewController:UIViewController, UIScrollViewDelegate {
    var main:SwitchContainerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Call viewDidLoad()")
        main = SwitchContainerViewController.instance()
        
        main.initData(self, controller: self)
        //main.setOnScreenFlag(true)//trueにしたら1ページ表示
        main.addViewFromNIB("FirstView", header:"FirstHeaderView")//タイトル部分にもviewを指定するならこんな感じ
        main.addViewFromNIB("SecondView")
        main.addViewFromNIB("ThirdView")
        main.addViewFromNIB("ForthView")
        main.makeView()
        
        self.view.addSubview(main)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:-UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        main.scrollViewDidScroll(scrollView)
    }
    
    //MARK:-
}

