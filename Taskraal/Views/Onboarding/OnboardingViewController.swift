//
//  OnboardingViewController.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 03/03/25.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    private var slides: [OnboardingSlide] = []
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                nextButton.setTitle("Get Started", for: .normal)
            } else {
                nextButton.setTitle("Next", for: .normal)
            }
        }
    }
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
//        button.backgroundColor = UIColor(cgColor: <#T##CGColor#>)
        
        button.addTarget(OnboardingViewController.self, action: #selector(goToLastSlide), for: .touchUpInside)
        
        
        return button
        
    }()
    // MARK: - UI Components
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSlides()
        setupUI()
        setupCollectionView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Setup
    private func setupSlides() {
        slides = [
            OnboardingSlide(title: "Smart Organization Illustration",
                            description: "Shows prioritized tasks in a visually organized manner with different colors for priority levels",
                            image: UIImage(named: "smartOrganisation") ?? UIImage()),
            OnboardingSlide(title: "Focus Mode Illustration",
                            description: "Depicts a focus timer with distractions being blocked out",
                            image: UIImage(named: "FocusSession") ?? UIImage()),
            OnboardingSlide(title: "Cloud Sync Illustration",
                            description: "Shows your tasks syncing across multiple devices through CloudKit",
                            image: UIImage(named: "synchronization") ?? UIImage())
        ]
    }
    
    @objc private func goToLastSlide(){
        currentPage = slides.count - 1;
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubviews(collectionView, pageControl, nextButton,skipButton)
        
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                              leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              height: view.frame.size.height * 0.7)
        
        pageControl.anchor(top: collectionView.bottomAnchor,
                           leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           paddingTop: 20)
        pageControl.numberOfPages = slides.count
        
        nextButton.anchor(top: pageControl.bottomAnchor,
                          paddingTop: 30,
                          width: 200,
                          height: 50)
        nextButton.centerX(in: view)
        
        skipButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          paddingBottom: 10,
                          width: 200,
                          height: 50)
        skipButton.centerX(in: view)
        
        
       
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier)
    }
    
    // MARK: - Actions
    @objc private func nextButtonTapped() {
        if currentPage == slides.count - 1 {
            UserDefaults.standard.setValue(true, forKey: "OnboardingDone")
            let mainViewController = MainTabBarController() // Replace with your main view controller
            mainViewController.view.backgroundColor = .white
            
            if let sceneDelegate = UIApplication.shared.connectedScenes
                .first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = mainViewController
                sceneDelegate.window?.makeKeyAndVisible()
            } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window?.rootViewController = mainViewController
                appDelegate.window?.makeKeyAndVisible()
            }
        } else {
            // Go to next slide
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as? OnboardingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: slides[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

// Add this extension to your OnboardingViewController
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
}
