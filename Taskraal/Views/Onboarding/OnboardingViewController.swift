import UIKit

class OnboardingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - Properties
    private let themeManager = ThemeManager.shared
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
    
    // MARK: - UI Components
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white // Pure white background
        return view
    }()
    
    private let contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white // Pure white background
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0), for: .normal) // Blue accent
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.white // Pure white background
        button.layer.cornerRadius = 15
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor(red: 200/255, green: 210/255, blue: 220/255, alpha: 1.0) // Light gray
        pageControl.currentPageIndicatorTintColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0) // Blue accent
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal) // White text
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0) // Blue accent
        button.layer.cornerRadius = 15
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
        
        // Apply neumorphic effects after layout
        contentContainer.addNeumorphicEffect(cornerRadius: 20, backgroundColor: UIColor.white)
        skipButton.addNeumorphicEffect(cornerRadius: 15, backgroundColor: UIColor.white)
        
        // Next button doesn't need a neumorphic effect since it's colored
        nextButton.layer.shadowColor = UIColor.black.cgColor
        nextButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        nextButton.layer.shadowOpacity = 0.2
        nextButton.layer.shadowRadius = 4
        
        // Add inset effect to collection view container
        collectionView.superview?.addInsetNeumorphicEffect(cornerRadius: 15, backgroundColor: UIColor.white)
    }
    
    // Collection view methods
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
    
    // MARK: - Setup
    private func setupSlides() {
        slides = [
            OnboardingSlide(title: "Smart Organization",
                            description: "Prioritized tasks with different colors for priority levels",
                            image: UIImage(named: "smartOrganisation") ?? UIImage()),
            OnboardingSlide(title: "Focus Mode",
                            description: "Eliminate distractions with our focus timer",
                            image: UIImage(named: "FocusSession") ?? UIImage()),
            OnboardingSlide(title: "Cloud Sync",
                            description: "Your tasks sync across all your devices with CloudKit",
                            image: UIImage(named: "synchronization") ?? UIImage())
        ]
    }
    
    @objc private func goToLastSlide() {
        currentPage = slides.count - 1
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.white // Pure white background
        
        view.addSubview(backgroundView)
        backgroundView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        view.addSubview(contentContainer)
        contentContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                               leading: view.leadingAnchor,
                               trailing: view.trailingAnchor,
                               paddingTop: 20,
                               paddingLeading: 20,
                               paddingTrailing: 20,
                               height: view.frame.size.height * 0.6)
        
        contentContainer.addSubview(collectionView)
        collectionView.anchor(top: contentContainer.topAnchor,
                             leading: contentContainer.leadingAnchor,
                             bottom: contentContainer.bottomAnchor,
                             trailing: contentContainer.trailingAnchor,
                             paddingTop: 15,
                             paddingLeading: 15,
                             paddingBottom: 15,
                             paddingTrailing: 15)
        
        view.addSubview(pageControl)
        pageControl.anchor(top: contentContainer.bottomAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          paddingTop: 30)
        pageControl.numberOfPages = slides.count
        
        view.addSubview(nextButton)
        nextButton.anchor(top: pageControl.bottomAnchor,
                         paddingTop: 40,
                         width: 200,
                         height: 60)
        nextButton.centerX(in: view)
        
        view.addSubview(skipButton)
        skipButton.anchor(top: nextButton.bottomAnchor,
                         paddingTop: 20,
                         width: 200,
                         height: 50)
        skipButton.centerX(in: view)
        
        skipButton.addTarget(self, action: #selector(goToLastSlide), for: .touchUpInside)
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
            let mainViewController = MainTabBarController()
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
