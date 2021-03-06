//
//  TestCoverFlowViewController.swift
//  BCSwiftExam
//
//  Created by Joon Jang on 8/31/17.
//  Copyright © 2017 Beasts. All rights reserved.
//

import UIKit
import BeastComponents

class TestCoverFlowViewController: UIViewController, BCCoverFlowViewDataSource, BCCoverFlowViewDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
	
	@IBOutlet weak var coverFlowView: BCCoverFlowView!
	
	var originalNavigationDelegate: UINavigationControllerDelegate?
	
	var movies = [[String: Any]]()
	

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.loadMovies()
		
		self.coverFlowView.register(nib: UINib.init(nibName: "MoviePoster", bundle: nil), forCoverReuseIdentifier: "MoviePoster")
		
//		self.coverFlowView.coverFlowStyle = .bottom
		self.coverFlowView.gradientColorForStream = .black
		self.coverFlowView.heightOverPassed = 40
		
		self.coverFlowView.dataSource = self
		self.coverFlowView.delegate = self
		self.coverFlowView.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func loadMovies() {
		if		let fileUrl = Bundle.main.url(forResource: "Movies", withExtension: "plist"),
				let data = try? Data(contentsOf: fileUrl) {
			if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] {
				self.movies.append(contentsOf: result!)
			}
		}
	}
	
	func numberOfCovers(in coverFlowView: BCCoverFlowView) -> Int {
		return self.movies.count
	}
	
	func coverFlowView(_ coverFlowView: BCCoverFlowView, contentAt index: Int) -> BCCoverContentView {
		let coverView = self.coverFlowView.dequeueReusableCoverContentView(withIdentifier: "MoviePoster", for: index) as! MoviePoster
		coverView.movie = self.movies[index]
		coverView.onDeletePoster = {
			coverFlowView.deleteItem(at:index, with: .left, completion: { [weak self] in
				self?.movies.remove(at: index)
			})
		}
		return coverView
	}
	
	func coverFlowView(_ coverFlowView: BCCoverFlowView, didSelectCoverViewAtIndex index: Int) {
		let vc = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailView") as! MovieDetailTableViewController
		if let selectedPosterView = self.coverFlowView.coverContentView(for: index) as? MoviePoster {
			vc.imageHeight = selectedPosterView.imageView.bounds.size.height
		}
		vc.movie = self.movies[index]
		
		self.originalNavigationDelegate = self.navigationController?.delegate
		self.navigationController?.delegate = self
		self.navigationController?.pushViewController(vc, animated: true)
		
		/*
		// It supports transitions to be presented and dismissed on UIViewControllerTransitioningDelegate, too. 
		vc.transitioningDelegate = self
		self.present(vc, animated: true, completion: nil)
		*/
	}

	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		self.navigationController?.delegate = self.originalNavigationDelegate
		return operation == .push ? self.coverFlowView.presentDetailAnimationController.zoomIn : self.coverFlowView.presentDetailAnimationController.zoomOut
	}
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self.coverFlowView.presentDetailAnimationController.zoomInAndFlipRight
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self.coverFlowView.presentDetailAnimationController.zoomOutAndFlipLeft
	}

}

