//
//  HomePageWebViewController.swift
//  sg_5
//
//  Created by zhishen－mac on 2018/5/23.
//  Copyright © 2018年 zhishen－mac. All rights reserved.
//

import UIKit
import SVProgressHUD
import WebKit
import BMPlayer

class HomePageWebViewController: UIViewController{
    var navView: UIView?
    var titleLab:UILabel?
    var backBtn: UIButton?
    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: CGFloat(0), y: CGFloat(65), width: UIScreen.main.bounds.width, height: 2))
        self.progressView.tintColor = UIColor.colorAccent      // 进度条颜色
        self.progressView.trackTintColor = UIColor.white // 进度条背景色
        return self.progressView
    }()
    var model: HomePageNewsModel?
    var scrollerView: UIScrollView?
    var scrollContent: UIView?
    var popview: UIView?
    
    var webview: WKWebView?
    var webHeitht: CGFloat?{
        didSet{
            
            self.webview?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: webHeitht ?? 0)
        }
    }
    
    var contentView:UIView?
    var upBtn: UIButton?
    var shareBtn: UIButton?
    var type: Int = 0
    var lineView: UIView?
    var sectionView: UIView?
    
    var totolComment: UILabel?
    var totolUp: UILabel?
    var totolUpNum : Int = 0
    
    //tableView
    
    var tableView: UITableView?
    var footView: UIView?
    var textField: UITextField?
    var commentBtn: UIButton?
    var commentCountLab: UILabel?
    
    var collectBtn: UIButton?
    var isCollect: Bool = false
    var footshare: UIButton?
    var commentListArray:Array<NovelCommentModel> = []
    /// 播放器
    lazy var player: BMPlayer = BMPlayer(customControlView: VideoPlayerCustomView())
    override func viewWillAppear(_ animated: Bool) {
         player.autoPlay()
        self.navigationController?.isNavigationBarHidden = true
        if self.textField != nil {
            let center = NotificationCenter.default
            center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
        }
    }
    deinit {
        player.prepareToDealloc()
        self.webview?.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webview?.uiDelegate = nil
        self.webview?.navigationDelegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let navView = UIView()
        navView.backgroundColor = .white
        self.view.addSubview(navView)
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "fanhui"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        navView.addSubview(backBtn)
        self.backBtn = backBtn
        let rightBtn = UIButton(type: .custom)
        rightBtn.setImage(UIImage(named: "gengduo"), for: .normal)
        rightBtn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        navView.addSubview(rightBtn)
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 16)
        titleLab.textAlignment = .center
        titleLab.textColor = UIColor.colortext1
        titleLab.text = model?.title
        navView.addSubview(titleLab)
        self.titleLab = titleLab
        self.navView = navView
        navView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.height.equalTo(64)
        }
        backBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(navView).offset(10)
            make.left.equalTo(navView)
            make.width.height.equalTo(44)
        }
        rightBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(navView).offset(10)
            make.right.equalTo(navView)
            make.width.height.equalTo(44)
        }
        titleLab.snp.makeConstraints { (make) in
            make.centerY.height.equalTo(backBtn)
            make.width.equalTo(navView).offset(-100)
            make.centerX.equalTo(navView)
        }
        makeUI()
    }
    func makeUI(){
        let scrollview = UIScrollView()
        scrollview.showsVerticalScrollIndicator = false
        scrollview.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollview)
        self.scrollerView = scrollview
        let scrollContent = UIView()
        self.scrollerView?.addSubview(scrollContent)
        self.scrollContent = scrollContent
        let webview: WKWebView = WKWebView(frame: self.view.frame, configuration: WKWebViewConfiguration())
        if model?.directType != "1" {
            if (model?.newsContent) != nil {
                webview.loadHTMLString((model?.newsContent)!, baseURL: nil)
            }
        }else{
            
        }
        webview.navigationDelegate = self
        self.scrollContent?.addSubview(webview)
        self.webview = webview
        self.view.addSubview(progressView)
        self.webview?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        let contentView = UIView()
        contentView.backgroundColor = .white
        self.scrollContent?.addSubview(contentView)
        self.contentView = contentView
        
        let upBtn = UIButton(type: .custom)
        upBtn.setImage(UIImage(named: "dianzan_b"), for: .normal)
        upBtn.setTitle(String(model?.up ?? 0), for: .normal)
        upBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        upBtn.addTarget(self, action: #selector(upBtnClick), for: .touchUpInside)
        upBtn.layer.cornerRadius = 18
        upBtn.layer.borderWidth = 1
        upBtn.layer.borderColor = UIColor.colorWithHexColorString("999999").cgColor
        upBtn.setTitleColor(.black, for: .normal)
        contentView.addSubview(upBtn)
        self.upBtn = upBtn
        let shareBtn = UIButton(type: .custom)
        shareBtn.setTitle("分享", for: .normal)
        shareBtn.addTarget(self, action: #selector(share), for: .touchUpInside)
        shareBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        shareBtn.setImage(UIImage(named: "fenxiang"), for: .normal)
        shareBtn.layer.cornerRadius = 18
        shareBtn.layer.borderWidth = 1
        shareBtn.layer.borderColor = UIColor.colorWithHexColorString("999999").cgColor
        shareBtn.setTitleColor(.black, for: .normal)
        contentView.addSubview(shareBtn)
        self.shareBtn = shareBtn
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorWithHexColorString("ebebeb")
        contentView.addSubview(lineView)
        self.lineView = lineView
        let sectionView = UIView()
        let totolComment = UILabel()
        totolComment.text = "评论 0"
        totolComment.font = UIFont.systemFont(ofSize: 14)
        totolComment.textColor = UIColor.colorWithHexColorString("666666")
        sectionView.addSubview(totolComment)
        let totolUp = UILabel()
        totolUp.text = "0 赞"
        totolUp.font = UIFont.systemFont(ofSize: 14)
        totolUp.textColor = UIColor.colorWithHexColorString("666666")
        sectionView.addSubview(totolUp)
        contentView.addSubview(sectionView)
        self.sectionView = sectionView
        self.totolComment = totolComment
        self.totolUp = totolUp
        let tableView = UITableView()
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "EpisodeCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension // 自适应单元格高度
        tableView.estimatedRowHeight = 50
        self.scrollContent?.addSubview(tableView)
        self.tableView = tableView
        //footView
        let footView = UIView()
        footView.backgroundColor = .white
        self.view.addSubview(footView)
        self.footView = footView
        let line = UIView()
        line.backgroundColor = UIColor.colorWithHexColorString("e1e2e3")
        self.footView?.addSubview(line)
        let textField = UITextField()
        textField.placeholder = "写评论..."
        textField.layer.borderWidth = 1
        textField.returnKeyType = .send
        textField.delegate = self
        textField.layer.borderColor = UIColor.colorWithHexColorString("e1e2e3").cgColor
        textField.layer.cornerRadius = 15
        textField.leftViewMode = UITextFieldViewMode.always
        textField.font = UIFont.systemFont(ofSize: 15)
        self.footView?.addSubview(textField)
        self.textField = textField
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 30, height: 30))
        imageView.image = UIImage(named: "xiepinglun")
        self.textField?.leftView = imageView
        let commentBtn = UIButton(type: .custom)
        commentBtn.setImage(UIImage(named: "pinglun"), for: .normal)
        self.footView?.addSubview(commentBtn)
        self.commentBtn = commentBtn
        let commentCountLab = UILabel()
        commentCountLab.textAlignment = .center
        commentCountLab.backgroundColor = .red
        commentCountLab.textColor = .white
        commentCountLab.font = UIFont.systemFont(ofSize: 8)
        commentCountLab.layer.cornerRadius = 5
        commentCountLab.layer.masksToBounds = true
        self.footView?.addSubview(commentCountLab)
        self.commentCountLab = commentCountLab
        let collectBtn = UIButton(type: .custom)
        collectBtn.setImage(UIImage(named: "shoucang"), for: .normal)
        collectBtn.addTarget(self, action: #selector(collectBtnClick), for: .touchUpInside)
        self.footView?.addSubview(collectBtn)
        self.collectBtn = collectBtn
        let footshare = UIButton(type: .custom)
        footshare.setImage(UIImage(named: "zhuanfa"), for: .normal)
        footshare.addTarget(self, action: #selector(share), for: .touchUpInside)
        self.footView?.addSubview(footshare)
        self.footshare = footshare
        // Do any additional setup after loading the view.
        self.footView?.snp.makeConstraints({ (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(40)
        })
        self.textField?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.footView!).offset(20)
            make.centerY.equalTo(self.footView!)
            make.height.equalTo(30)
            make.width.equalTo(screenWidth/2-20)
        })
        self.commentBtn?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.footView!)
            make.width.height.equalTo(40)
            make.right.equalTo(self.collectBtn!.snp.left).offset(-10)
        })
        self.commentCountLab?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.commentBtn!.snp.top).offset(15)
            make.left.equalTo(self.commentBtn!.snp.right).offset(-15)
            make.width.greaterThanOrEqualTo(10)
            make.height.equalTo(10)
        })
        self.collectBtn?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.footView!)
            make.width.height.equalTo(40)
            make.right.equalTo(self.footshare!.snp.left).offset(-10)
        })
        self.footshare?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.footView!)
            make.width.height.equalTo(40)
            make.right.equalTo(self.footView!.snp.right).offset(-10)
        })
        requestComment()
        requestIsCollect()
    }
    func requestIsCollect(){
        guard KeyChain().getKeyChain()["isLogin"] == "1" else {
            return
        }
        let timeInterval: Int = Int(Date().timeIntervalSince1970 * 1000)
        let dic: Dictionary<String, Any> = ["timestamp":String(timeInterval),"userId":KeyChain().getKeyChain()["id"]!,"contentId":model?.id ?? ""]
        let parData = dic.toParameterDic()
        NetworkTool.requestData(.post, URLString: getIsCollectUrl, parameters: parData ) { (json) in
            if json.boolValue == false {
                self.collectBtn?.setImage(UIImage(named: "shoucang"), for: .normal)
                self.isCollect = false
            }else{
                self.collectBtn?.setImage(UIImage(named: "shoucang2"), for: .normal)
                self.isCollect = true
            }
          
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    @objc func collectBtnClick(){
        if KeyChain().getKeyChain()["isLogin"] != "1" {
            self.view.makeToast("请登录")
        }else{
            if !self.isCollect {
                let timeInterval: Int = Int(Date().timeIntervalSince1970 * 1000)
                let dic: Dictionary<String, Any> = ["timestamp":String(timeInterval),"userId":KeyChain().getKeyChain()["id"]!,"contentId":model?.id ?? "","token":KeyChain().getKeyChain()["token"]!,"type":ContentType.News.rawValue,"title":model?.title ?? "","url":model?.imageUrl ?? "","mark": 0]
                let parData = dic.toParameterDic()
                NetworkTool.requestData(.post, URLString: addCollectUrl, parameters: parData ) { (json) in
                    if json.boolValue == true {
                        self.collectBtn?.setImage(UIImage(named: "shoucang2"), for: .normal)
                        self.isCollect = true
                    }
                    
                }
            }else{
                let timeInterval: Int = Int(Date().timeIntervalSince1970 * 1000)
                let dic: Dictionary<String, Any> = ["timestamp":String(timeInterval),"userId":KeyChain().getKeyChain()["id"]!,"contentId":model?.id ?? "","token":KeyChain().getKeyChain()["token"]!]
                let parData = dic.toParameterDic()
                NetworkTool.requestData(.post, URLString: cancleCollectUrl, parameters: parData ) { (json) in
                    if json.boolValue == true {
                        self.collectBtn?.setImage(UIImage(named: "shoucang"), for: .normal)
                        self.isCollect = false
                    }   
                }
            }
           
        }
    }
    @objc func upBtnClick() {
        self.model?.up += 1
        self.upBtn?.isEnabled = false
        self.upBtn?.setImage(UIImage(named: "dianzan2"), for: .normal)
        self.upBtn?.setTitle(String(self.model!.up), for: .normal)
        let timeInterval: Int = Int(Date().timeIntervalSince1970 * 1000)
        let dic: Dictionary<String, Any> = ["timestamp":String(timeInterval),"id":self.model?.id ?? ""]
        let parData = dic.toParameterDic()
        NetworkTool.requestData(.post, URLString: UpnewLickUrl, parameters: parData ) { (json) in
            
        }
    }    
    func layoutView() {
        self.scrollerView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 64, left: 0, bottom: 40, right: 0))
        })
        if model?.type == "1" {

            self.view?.addSubview(self.player)
            self.view?.bringSubview(toFront: self.backBtn!)
            self.player.delegate = self
            self.player.setVideo(resource: BMPlayerResource(url: URL(string:model?.newsContent ?? "")!))
            self.player.backBlock = { [unowned self] (isFullScreen) in
                if isFullScreen == true { return }
                let _ = self.navigationController?.popViewController(animated: true)
            }
            self.player.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(64)
                make.left.right.equalToSuperview()
                make.height.equalTo(player.snp.width).multipliedBy(9.0/16.0).priority(500)
            }
        }else{
            self.webview?.snp.makeConstraints({ (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(self.webHeitht!)
            })
        }
        
        self.contentView?.snp.makeConstraints({ (make) in
            if model?.type == "1"{
                make.top.equalTo(self.player.snp.bottom)
            }else{
                make.top.equalTo(self.webview!.snp.bottom)
            }
            
            make.left.right.equalTo(self.scrollContent!)
            make.bottom.equalTo(self.totolUp!).offset(10)
        })
        self.upBtn?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView!).offset(25)
            make.right.equalTo(self.contentView!.snp.centerX).offset(-25)
            make.width.equalTo(110)
            make.height.equalTo(35)
        })
        self.shareBtn?.snp.makeConstraints({ (make) in
            make.centerY.height.width.equalTo(self.upBtn!)
            make.left.equalTo(self.contentView!.snp.centerX).offset(25)
            
        })
        self.lineView?.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.contentView!)
            make.top.equalTo(self.shareBtn!.snp.bottom).offset(10)
            make.height.equalTo(10)
        }
        self.sectionView?.snp.makeConstraints { (make) in
            make.top.equalTo(self.lineView!.snp.bottom)
            make.left.right.equalTo(self.contentView!)
            make.height.equalTo(40)
        }
        self.totolComment?.snp.makeConstraints { (make) in
            make.centerY.height.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        self.totolUp?.snp.makeConstraints { (make) in
            make.centerY.height.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        self.tableView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView!.snp.bottom)
            make.left.right.equalTo(self.contentView!)
            make.height.equalTo(self.view.frame.height - 114)
        })
        
        self.scrollContent?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.scrollerView!).inset(UIEdgeInsets.zero)
            make.width.equalTo(self.scrollerView!)
            make.bottom.equalTo(self.tableView!).offset(1)
        })
        
        self.view.layoutIfNeeded()
    }
    func requestComment() {
        self.commentListArray = []
        let keyChain = KeyChain()
        let fromId = keyChain.getKeyChain()["id"] ?? ""
        let timeInterval: Int = Int(Date().timeIntervalSince1970 * 1000)
        let dic: Dictionary<String, String> = ["timestamp":String(timeInterval),"typeId":self.model?.id ?? "","fromId":fromId]
        let parData = dic.toParameterDic()
        NetworkTool.requestData(.post, URLString: commentByType, parameters: parData) { (json) in
            self.totolUp?.text = "\(String(json["sumComment"].intValue)) 赞"
            self.totolUpNum = json["sumComment"].intValue
            if let datas = json["commentList"].arrayObject{
                self.commentListArray += datas.compactMap({NovelCommentModel.deserialize(from: $0 as? Dictionary)})
            }
            self.totolComment?.text = "评论\(self.commentListArray.count)"
            self.commentCountLab?.text = "\(self.commentListArray.count)"
            self.setTableViewHeight(cellNum: self.commentListArray.count)
            self.tableView?.reloadData()
            self.view.layoutIfNeeded()
        }
    }
    func setTableViewHeight(cellNum: Int){
        if CGFloat(cellNum) * 124 + 50 > screenHeight - 104 {
            self.tableView?.snp.updateConstraints({ (make) in
                make.height.equalTo(self.view.frame.height - 114)
            })
           
        }else{
            self.tableView?.snp.updateConstraints({ (make) in
                make.height.equalTo(CGFloat(cellNum) * 124 + 50)
            })
        }
        self.scrollContent?.snp.remakeConstraints({ (make) in
            make.edges.equalTo(self.scrollerView!).inset(UIEdgeInsets.zero)
            make.width.equalTo(self.scrollerView!)
            make.bottom.equalTo(self.tableView!).offset(1)
        })
    }
    func sendComment(comment: String){
        let keyChain = KeyChain()
        guard let mobile = keyChain.getKeyChain()["mobile"],let token = keyChain.getKeyChain()["token"],let id = keyChain.getKeyChain()["id"] else {
            self.view.makeToast("你还没有登录")
            return
        }
        let timeInterval: Int = Int(Date().timeIntervalSince1970 * 1000)
        let dic: Dictionary<String, Any> = ["timestamp":String(timeInterval),"typeId":self.model?.id ?? "","mobile":mobile,"token":token,"fromId":id,"type":ContentType.News.rawValue,"content":comment]
        let parData = dic.toParameterDic()
        NetworkTool.requestData(.post, URLString: addCommentUrl, parameters: parData) { (json) in
            if json["code"] == "-1"{
                self.view.makeToast(json["msg"].stringValue)
            }else{
                 self.requestComment()
            }
        }
    }
    
    @objc func backBtnClick(){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func leftBtnClick(){
        let popview = BottonPopView(frame: CGRect(x: 0, y: screenHeight-75, width: screenWidth, height: 75))
        popview.delegate = self
        self.view.addSubview(popview)
        self.popview = popview
    }
    //MARK:-- 键盘评论pop收回问题
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.popview?.removeFromSuperview()
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension HomePageWebViewController: UITableViewDelegate,UITableViewDataSource,EpisodeCommentTableViewCellDelegate{
    func addTooleUP() {
        self.totolUpNum += 1
        self.totolUp?.text = "\(String(self.totolUpNum)) 赞"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentListArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! EpisodeCommentTableViewCell
        cell.delegate = self
        cell.model = self.commentListArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
extension HomePageWebViewController: WKNavigationDelegate {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress"{
            progressView.alpha = 1.0
            progressView.setProgress(Float((self.webview?.estimatedProgress)!), animated: true)
            if Float((self.webview?.estimatedProgress)!) >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("网页开始接收网页内容")
        webView.evaluateJavaScript("document.title") { (a, e) in
            //self.titleLab?.text = a as? String ?? ""
        }
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("网页由于某些原因加载失败\(error)")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("网页\(error)")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        self.webHeitht = webView.scrollView.contentSize.height
        if self.webHeitht == 0 {
            self.webHeitht = screenHeight
        }
        if !webView.isLoading{
 
            if (webView.url?.absoluteString ?? "").contains("toutiao.com/"){
                let str = """
document.getElementsByClassName("banner-pannel pannel-top show-top-pannel")[0].parentNode.style.display="none";
document.getElementsByClassName("unflod-field__mask")[0].click();
document.getElementsByClassName("recommendation-container-new-article-test")[0].style.display="none";
document.getElementsByClassName("open-btn")[0].parentNode.parentNode.style.display="none";
document.getElementsByClassName("new-style-test-article-author")[0].style.display="none"
"""
                webView.evaluateJavaScript(str, completionHandler: nil)
            }
        }
        self.layoutView()
    }
}
extension HomePageWebViewController: UITextFieldDelegate {
    //Mark:Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default
            .addObserver(self,selector: #selector(keyboardWillHide(notification:)),
                         name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if let comment = textField.text {
            self.sendComment(comment: comment)
        }
        textField.text = nil
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    //键盘显示
    @objc func keyboardWillShow(notification:NSNotification) {
        let textMaxY = screenHeight
        let keyboardH : CGFloat = ((notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height)
        let keyboardY : CGFloat = self.view.frame.size.height - keyboardH
        var duration: Double  = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        if duration < 0.0 {
            duration = 0.25
        }
        UIView.animate(withDuration: duration) { () -> Void in
            if (textMaxY > keyboardY) {
                self.view.transform = CGAffineTransform(translationX: 0, y: keyboardY - textMaxY)
            }else{
                self.view.transform = CGAffineTransform.identity
            }
        }
        
    }
    //键盘隐藏
    @objc func keyboardWillHide(notification:NSNotification){
        let duration  = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        UIView.animate(withDuration: duration!) { () -> Void in
            self.view.transform = CGAffineTransform.identity
        }
    }
}
extension HomePageWebViewController: BottonPopViewDelegate,UMSocialShareMenuViewDelegate{
    func reloadBtnClick() {
        self.makeUI()
        SVProgressHUD.show()
        SVProgressHUD.dismiss(withDelay: 1)
    }
    
    func copyBtnClick() {
        UIPasteboard.general.string = self.model?.crawlurl
        self.view.makeToast("复制成功")
    }
    
    func openWebClick() {
//        NSString *textURL = @"http://www.yoururl.com/";
//        NSURL *cleanURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", textURL]];
//        [[UIApplication sharedApplication] openURL:cleanURL];
        let url = URL(string: self.model?.crawlurl ?? "")
        UIApplication.shared.openURL(url!)
        
    }
    
    func shareBtnClick() {
        print("share")
        self.popview?.removeFromSuperview()
        share()
    }
    @objc func share(){
        UMSocialUIManager.setPreDefinePlatforms([NSNumber(integerLiteral:UMSocialPlatformType.QQ.rawValue)])
        UMSocialUIManager.setShareMenuViewDelegate(self)
        UMSocialUIManager.showShareMenuViewInWindow(platformSelectionBlock: { (platformType, info) in
            var shareTitle = ""
            var url = ""
            //var share_pic = ""
            if self.model?.type == "0"{
                url = self.model?.crawlurl ?? ""
            }else{
              url = (self.model?.newsContent)!
            }
            
            if self.model?.title != ""{
                shareTitle = (self.model?.title)!
            }else{
                shareTitle = (self.model?.source)!
            }
            
            let desc = "来自搜瓜"
            let messageObject = UMSocialMessageObject()
            //let pic = share_pic.replacingOccurrences(of: "http://", with: "https://")
            let shareObject = UMShareWebpageObject.shareObject(withTitle:shareTitle, descr: desc, thumImage:nil)
            shareObject?.webpageUrl = url
            messageObject.shareObject = shareObject
            UMSocialManager.default().share(to: platformType, messageObject:messageObject, currentViewController: self) { (data, error) in
                if let error = error as NSError?{
                    print("取消分享 : \(error.description)")
                }else{
                    print("分享成功")
                }
            }

        })
        
    }
    func umSocialParentView(_ defaultSuperView: UIView!) -> UIView! {
        return self.view
    }
    func shareWebPageToPlatformType(platformType:UMSocialPlatformType,currentViewController:UIViewController,type:Int? = 1){
        
    }
}
// MARK:- BMPlayerDelegate example
extension HomePageWebViewController: BMPlayerDelegate {
    // Call when player orinet changed
    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        player.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.navView!.snp.bottom)
            if isFullscreen {
                make.height.equalTo(player.snp.width).multipliedBy(9.0/16.0).priority(900)
                //self.leftBtn?.isHidden = true
            } else {
                make.height.equalTo(player.snp.width).multipliedBy(9.0/16.0).priority(900)
                //self.leftBtn?.isHidden = false
            }
        }
        self.footView?.snp.remakeConstraints({ (make) in
            if isFullscreen {
                make.top.equalTo(self.view.snp.bottom).offset(100)
                print("1111111")
            } else {
                print("222222")
                make.left.right.bottom.equalTo(self.view)
                make.height.equalTo(40)
            }
            self.view.layoutIfNeeded()
        })
    }
    
    // Call back when playing state changed, use to detect is playing or not
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        print("| BMPlayerDelegate | playerIsPlaying | playing - \(playing)")
    }
    
    // Call back when playing state changed, use to detect specefic state like buffering, bufferfinished
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        print("| BMPlayerDelegate | playerStateDidChange | state - \(state)")
    }
    
    // Call back when play time change
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        //        print("| BMPlayerDelegate | playTimeDidChange | \(currentTime) of \(totalTime)")
    }
    
    // Call back when the video loaded duration changed
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        //        print("| BMPlayerDelegate | loadedTimeDidChange | \(loadedDuration) of \(totalDuration)")
    }
}
