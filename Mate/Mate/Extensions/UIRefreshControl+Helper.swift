//
//  UIRefreshControl+Helper.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//
import UIKit


extension UIRefreshControl {
    /// Reset animation of refresh control by forcing refreshing animation again
    func resetAnimation(in scrollView: UIScrollView, completion: (() -> Void)? = nil) {
        if isRefreshing {
            endRefreshing()
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.size.height), animated: true)
            beginRefreshing()
            completion?()
        }
    }
}
