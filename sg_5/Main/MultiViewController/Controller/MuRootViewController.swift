//
//  MuRootViewController.swift
//  MultiWindow
//
//  Created by zhishen－mac on 2018/4/14.
//  Copyright © 2018年 zhishen－mac. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
class MuRootViewController: UIViewController,UIScrollViewDelegate ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,CategoryButtonViewDelegate,EmptyDataSetProtocol,HomeNavigationViewDelegate{
    //tableView
    var navigationBar = HomeNavigationView.loadViewFromNib()
    var searchBar: UISearchBar?
    var headView: UIView?
    
    //var mainScrollerView:UIScrollView?
    var searchView:UIView = {
        let searchView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 90))
        searchView.backgroundColor = UIColor.colorWithHexColorString("f5f5f5")
        return searchView
    }()
    var subSearchBtn: UIButton?
    var subScanBtn:UIButton?
    
    
    var categoryButtonView:CategoryButtonView?
    var mainTableView: UITableView?
    let footer = MJRefreshFooter()
    var newsListArr: Array = [HomePageNewsModel]()
    var pageNO: Int = 1

    
    //打开的网页
    var html: HTMLViewController?
    //操作视图
    var oprateView: MUOprateView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            mainTableView?.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        if self.responds(to: #selector(setter: edgesForExtendedLayout)) {
            self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        }
        html = HTMLViewController()
       MUMultiWindowViewModel.addNewViewControllerToNavigationController(viewController: self)
        self.view.backgroundColor = UIColor.white
        setUI()
        getNewsList(pageNO: pageNO)
    }
//    override func viewWillLayoutSubviews() {
//        var viewBounds = self.view.bounds
//        let topBarOffset = self.topLayoutGuide.length
//        viewBounds.origin.y = topBarOffset * -1
//        self.view.bounds = viewBounds;
//    }
    func setUI() {
        //上划后的searchBar
        self.view.addSubview(searchView)
        let subScanBtn = UIButton(type: .custom)
        //subScanBtn.setBackgroundImage(UIImage(named: "saoyisao"), for: .normal)
        subScanBtn.setImage(UIImage(named: "sousuo"), for: .normal)
        subScanBtn.setTitle("请输入搜索内容", for: .normal)
        subScanBtn.titleLabel?.textAlignment = .left
        subScanBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        subScanBtn.setTitleColor(UIColor.colorWithHexColorString("333333"), for: .normal)
        subScanBtn.layer.cornerRadius = 3
        subScanBtn.layer.borderColor = UIColor.colorWithHexColorString("333333").cgColor
        subScanBtn.backgroundColor = UIColor.white
        subScanBtn.contentHorizontalAlignment = .left
        subScanBtn.addTarget(self, action: #selector(scanBtnClick), for: .touchUpInside)
        self.subScanBtn = subScanBtn
        self.searchView.addSubview(self.subScanBtn!)

        subScanBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.searchView).offset(20)
            make.top.equalTo(self.searchView).offset(35)
            make.height.equalTo(40)
            make.right.equalTo(self.searchView).offset(-20)
        }
        subScanBtn.titleEdgeInsets = UIEdgeInsets(top: 0 , left: 10 , bottom: 0, right: 0)
        subScanBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        let headView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth/5+150))
        self.headView = headView
        self.headView?.addSubview(self.navigationBar)
        self.navigationBar.layoutIfNeeded()
        self.navigationBar.delegate = self
        categoryButtonView = CategoryButtonView(frame: CGRect(x: 0, y: 150, width: screenWidth, height: screenWidth/5))
        categoryButtonView?.delegate = self
        self.headView?.addSubview(categoryButtonView!)
        mainTableView = UITableView(frame: CGRect(x: 0, y: -20, width: screenWidth, height: screenHeight-24))
        mainTableView?.showsVerticalScrollIndicator = false
        mainTableView?.delegate = self
        mainTableView?.dataSource = self
        mainTableView?.separatorStyle = .none
        mainTableView!.register(UINib(nibName:"ImageTableViewCell", bundle:nil),
                                forCellReuseIdentifier:"Image")
        mainTableView!.register(UINib(nibName:"SingleImageTableViewCell", bundle:nil),
                                forCellReuseIdentifier:"SingleImage")
        mainTableView!.register(UINib(nibName:"VideoTableViewCell", bundle:nil),
                                forCellReuseIdentifier:"Video")
        mainTableView!.register(UINib(nibName:"VideoSubTableViewCell", bundle:nil),
                                forCellReuseIdentifier:"VideoSub")
        mainTableView!.register(UINib(nibName:"SingleTestTableViewCell", bundle:nil),
                                forCellReuseIdentifier:"SingleTest")
        self.view?.addSubview(mainTableView!)
//        self.mainTableView?.mj_footer = MJRefreshAutoFooter(refreshingBlock: {
//            self.pageNO += 1
//            self.getNewsList(pageNO: self.pageNO)
//            self.mainTableView?.mj_footer.endRefreshing()
//        })
        self.mainTableView?.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            print("上拉加载.")
            self.pageNO += 1
            self.getNewsList(pageNO: self.pageNO)
            self.mainTableView!.mj_footer.endRefreshing()
        })
        self.mainTableView?.tableHeaderView = self.headView
        let oprateView = MUOprateView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-44, width: UIScreen.main.bounds.width, height: 44))
        self.oprateView = oprateView
        oprateView.dataArray = ["shuaxin","xinjian","搜瓜","wode","发现"]
        oprateView.OprateBlock =  { sender in
            unowned let uSelf = self
            uSelf.oprateClick(sender: sender)
        }
        self.view.addSubview(oprateView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        //更新按钮状态
        self.oprateView.subViewStatus(viewController: self)
        
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.isNavigationBarHidden = false
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func scanBtnClick() {
        let vc = SearchHistoryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getNewsList(pageNO: Int){
        if pageNO == 1 {
            self.newsListArr = []
        }
        let timeInterval: Int = Int(Date().timeIntervalSince1970 * 1000)
        let dic: Dictionary<String, Any> = ["timestamp":String(timeInterval)]
        var parData = dic.toParameterDic()
        parData["pageNo"] = pageNO
        NetworkTool.requestData(.post, URLString: getNewsUrl, parameters: parData) { (json) in
            if let datas = json["news"].arrayObject{
                self.newsListArr += datas.compactMap({HomePageNewsModel.deserialize(from: $0 as? Dictionary)})
            }
            else{
                self.addEmptyView(iconName: "", tipTitle: "无数据")
            }
            self.mainTableView?.reloadData()
            if pageNO == 1{
                self.mainTableView?.scrollsToTop = true
                //self.mainTableView?.contentOffset = CGPoint(x: 0, y: -20)
            }
        }
    }
    //MARK:--操作视图点击回调操作
    func oprateClick(sender: UIButton) {
        switch sender.tag {
        case 1:
            self.pageNO = 1
            //self.mainTableView?.contentOffset = CGPoint.zero
            self.getNewsList(pageNO: self.pageNO)
            //self.mainTableView?.reloadData()
            //self.view.sendSubview(toBack: self.searchView)
         case 2:
            let vc = MUMultiWindowController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            self.navigationController?.popToRootViewController(animated: false)
        case 4:
            let vc = PersonalCenterViewController.loadStoryboard()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            let vc = FindViewController()
            self.navigationController?.pushViewController(vc, animated: true)   
        }
    }
    func goSearch() {
        let vc = SearchHistoryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension MuRootViewController{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let vc = SearchViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
extension MuRootViewController {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return newsListArr.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aNews = newsListArr[indexPath.row]
//        if aNews.directType == "组图" {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "Image") as! ImageTableViewCell
//            cell.aNews = aNews
//            return cell
//        }
        switch aNews.modelType {
        case "1":
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleTest") as! SingleTestTableViewCell
            cell.selectionStyle = .none
            cell.aNews = aNews
            return cell
        case "2":
            let cell = tableView.dequeueReusableCell(withIdentifier: "SingleImage") as! SingleImageTableViewCell
            cell.selectionStyle = .none
            cell.aNews = aNews
            return cell
        case "3":
            let cell = tableView.dequeueReusableCell(withIdentifier: "Video") as! VideoTableViewCell
            cell.selectionStyle = .none
            cell.aNews = aNews
            return cell
        case "4":
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoSub") as! VideoSubTableViewCell
            cell.selectionStyle = .none
            cell.aNews = aNews
            return cell
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: "Video") as! VideoTableViewCell
            cell.selectionStyle = .none
            cell.aNews = aNews
            return cell
        }
        
     }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let aNews = newsListArr[indexPath.row]
            switch aNews.modelType {
            case "1":
                return 95
            case "2":
                return 120
            case "3":
                return 320
            case "4":
                return 120
            default:
                return 320
            }
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.newsListArr[indexPath.row].directType == "组图" {
            var imageURLs = self.newsListArr[indexPath.row].newsContent.components(separatedBy: ";")
            imageURLs.removeLast()
            let multiPictureVC = MultiPictureViewController()
            multiPictureVC.imageURLArr = imageURLs
            self.navigationController?.pushViewController(multiPictureVC, animated: true)
            
        }else{
            let webVC = HomePageWebViewController()
            webVC.model = newsListArr[indexPath.row]
            self.navigationController?.pushViewController(webVC, animated: true)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        let tabOffsetY:CGFloat = (self.mainTableView?.contentOffset.y)!
        if tabOffsetY >= 80 {
            UIView.animate(withDuration: 0.05) {
                self.view.bringSubview(toFront: self.searchView)
            }
        }else if tabOffsetY >= 0 && tabOffsetY < 80{
            self.view.bringSubview(toFront: self.mainTableView!)
            self.view.bringSubview(toFront: self.oprateView)
           self.navigationBar.alpha = (80 - tabOffsetY)/80
        }
    }
    //MARK: --点击分类跳转
    func categoryBtnClick(sender: UIButton) {
        if sender.tag == 1 {
            //小说
            let vc = NovelViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if sender.tag == 0 {
            //新闻
            let vc = MetooViewController()
            self.navigationController?.pushViewController(vc, animated: true)            
        }
        else if sender.tag == 2 {
            //新闻
            let vc = NewsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if sender.tag == 3 {
            //新闻
            let vc = EpisodeViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = FindViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
