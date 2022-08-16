//
//  pageViewController.swift
//  SwiftPlayground
//
//  Created by s.wakasugi on 2022/08/05.
//

import UIKit

class RootPageViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var pageViewController: UIPageViewController!
    var controllers: [UIViewController] = []
    var index: Int = 0
    var cacheIndex: Int?
    
    override func viewDidLoad() {
        // ContainerViewで持っているUIPageViewControllerをselfのpageViewControllerに設定
        self.pageViewController = children.first! as? UIPageViewController
        
        let first = storyboard!.instantiateViewController(withIdentifier: "firstPage")
        let second = storyboard!.instantiateViewController(withIdentifier: "secondPage")
        let third = storyboard!.instantiateViewController(withIdentifier: "thirdPage")
        
        controllers = [first, second, third]
        pageViewController.setViewControllers([controllers[index]], direction: .forward, animated: false)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        pageControl.numberOfPages = controllers.count
        didMovePage()
    }
    
    @IBAction func didPressBackButton(_ sender: UIButton) {
        // アニメーション中は画面を触れなくする
        view.isUserInteractionEnabled = false
        animateToPreviousPage() { [weak self] in
            self?.didMovePage()
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func didPressNextButton(_ sender: UIButton) {
        // アニメーション中は画面を触れなくする
        view.isUserInteractionEnabled = false
        animateToNextPage() { [weak self] in
            self?.didMovePage()
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    func animateToPreviousPage(completion: @escaping (()-> Void)) {
        index = index - 1
        pageViewController.setViewControllers([controllers[index]], direction: .reverse, animated: true) { isFinished in
            completion()
        }
    }
    
    func animateToNextPage(completion: @escaping (()-> Void)) {
        index = index + 1
        pageViewController.setViewControllers([controllers[index]], direction: .forward, animated: true) { isFinished in
            completion()
        }
    }
    
    /// スワイプ、ボタンでのページ遷移終了後に呼ぶメソッド。
    func didMovePage() {
        pageControl.currentPage = index
        if index == 0 {
            backButton.isHidden = true
        } else if index == controllers.count - 1 {
            nextButton.isHidden = true
        } else {
            backButton.isHidden = false
            nextButton.isHidden = false
        }
    }
}

extension RootPageViewController: UIPageViewControllerDelegate {
    /// スワイプ操作が始まった時に呼ばれるメソッド。スワイプ中のボタン操作を無効にして、行き先画面のindexをcacheに入れておく
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        backButton.isEnabled = false
        nextButton.isEnabled = false
        if let index = self.controllers.firstIndex(of: pendingViewControllers.first!) {
            cacheIndex = index
        }
    }
    
    /// スワイプ操作によるアニメーションが終わった時に呼ばれるメソッド。ボタン操作を再び有効にして、もし遷移完了ならcacheをindexに適用
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        backButton.isEnabled = true
        nextButton.isEnabled = true
        if completed {
            self.index = cacheIndex!
            didMovePage()
        }
    }
}

extension RootPageViewController: UIPageViewControllerDataSource {
    /// スワイプ操作における次の画面を渡すメソッド。その画面が最後の画面なら、nilを返して遷移不可とする
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if index < controllers.count - 1 {
            return controllers[index + 1]
        } else {
            return nil
        }
    }
    
    /// スワイプ操作における前の画面を渡すメソッド。その画面が最初の画面なら、nilを返して遷移不可とする
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if index > 0 {
            return controllers[index - 1]
        } else {
            return nil
        }
    }
}


