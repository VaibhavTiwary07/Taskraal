import UIKit

class OnboardingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
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
    
    // MARK: - UI Components
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1) // Light grayish background
        return view
    }()
    
    private let contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor(red: 100/255, green: 120/255, blue: 140/255, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1)
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
        pageControl.pageIndicatorTintColor = UIColor(red: 180/255, green: 190/255, blue: 200/255, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 70/255, green: 100/255, blue: 130/255, alpha: 1)
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(UIColor(red: 70/255, green: 90/255, blue: 110/255, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1)
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
        contentContainer.addNeumorphicEffect(cornerRadius: 20)
        nextButton.addNeumorphicEffect(cornerRadius: 15)
        skipButton.addNeumorphicEffect(cornerRadius: 15)
        
        // Add inset effect to collection view container
        collectionView.superview?.addInsetNeumorphicEffect(cornerRadius: 15)
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
        view.backgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1)
        
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
