import UIKit
import CoreData

class AIPrioritizationViewController: UIViewController {
    
    // MARK: - Properties
    private let themeManager = ThemeManager.shared
    private let aiTaskManager = AITaskManager.shared
    private var prioritizationResults: [TaskPrioritizationResult] = []
    private var dailyProgress: DailyProgressSummary?
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        return progress
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let actionsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Accept All Suggestions", for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let rejectButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Keep Current Schedule", for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScrollView()
        setupHeaderView()
        setupTableView()
        setupActionsView()
        setupLoadingView()
        
        // Register for theme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
        
        // Load data
        loadDailyProgress()
        analyzeTasks()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyThemeAndStyles()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupView() {
        title = "Smart Task Assistant"
        view.backgroundColor = themeManager.backgroundColor
        
        // Add navigation bar buttons
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshData)
        )
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeaderView() {
        contentView.addSubview(headerView)
        headerView.addSubview(quoteLabel)
        headerView.addSubview(progressView)
        headerView.addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            quoteLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            quoteLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            quoteLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            progressView.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            progressLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            progressLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTableView() {
        contentView.addSubview(tableView)
        
        tableView.register(PriorityTaskCell.self, forCellReuseIdentifier: PriorityTaskCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }
    
    private func setupActionsView() {
        contentView.addSubview(actionsContainer)
        actionsContainer.addSubview(actionsStackView)
        
        actionsStackView.addArrangedSubview(acceptButton)
        actionsStackView.addArrangedSubview(rejectButton)
        
        NSLayoutConstraint.activate([
            actionsContainer.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            actionsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            actionsStackView.topAnchor.constraint(equalTo: actionsContainer.topAnchor, constant: 16),
            actionsStackView.leadingAnchor.constraint(equalTo: actionsContainer.leadingAnchor, constant: 16),
            actionsStackView.trailingAnchor.constraint(equalTo: actionsContainer.trailingAnchor, constant: -16),
            actionsStackView.bottomAnchor.constraint(equalTo: actionsContainer.bottomAnchor, constant: -16),
            
            acceptButton.heightAnchor.constraint(equalToConstant: 50),
            rejectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        acceptButton.addTarget(self, action: #selector(acceptSuggestions), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(rejectSuggestions), for: .touchUpInside)
    }
    
    private func setupLoadingView() {
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func applyThemeAndStyles() {
        view.backgroundColor = themeManager.backgroundColor
        
        // Style header view
        headerView.backgroundColor = themeManager.containerBackgroundColor
        quoteLabel.textColor = themeManager.textColor
        progressView.progressTintColor = themeManager.currentThemeColor
        progressView.trackTintColor = themeManager.secondaryTextColor.withAlphaComponent(0.2)
        progressLabel.textColor = themeManager.secondaryTextColor
        
        // Style table view
        tableView.backgroundColor = themeManager.containerBackgroundColor
        
        // Style action buttons
        actionsContainer.backgroundColor = themeManager.containerBackgroundColor
        acceptButton.backgroundColor = themeManager.currentThemeColor
        acceptButton.setTitleColor(.white, for: .normal)
        
        rejectButton.backgroundColor = themeManager.isDarkModeEnabled ? 
            UIColor.darkGray : UIColor.lightGray
        rejectButton.setTitleColor(themeManager.isDarkModeEnabled ? .white : .darkGray, for: .normal)
        
        // Style loading view
        loadingView.color = themeManager.currentThemeColor
        
        // Apply neumorphic effect
        headerView.addNeumorphicEffect(cornerRadius: 16, backgroundColor: themeManager.containerBackgroundColor)
        tableView.addNeumorphicEffect(cornerRadius: 16, backgroundColor: themeManager.containerBackgroundColor)
        actionsContainer.addNeumorphicEffect(cornerRadius: 16, backgroundColor: themeManager.containerBackgroundColor)
    }
    
    // MARK: - Data Loading
    private func loadDailyProgress() {
        dailyProgress = aiTaskManager.getDailyProgressSummary()
        updateProgressUI()
    }
    
    private func updateProgressUI() {
        guard let progress = dailyProgress else { return }
        
        // Update quote
        quoteLabel.text = "\"" + progress.motivationalQuote + "\""
        
        // Update progress
        let completionRate = progress.completionRate
        progressView.progress = Float(completionRate)
        
        // Update progress label
        progressLabel.text = "\(progress.completedTaskCount) of \(progress.totalTaskCount) tasks completed today (\(Int(completionRate * 100))%)"
    }
    
    private func analyzeTasks() {
        // Show loading indicator
        loadingView.startAnimating()
        
        // Disable buttons
        acceptButton.isEnabled = false
        rejectButton.isEnabled = false
        
        // Get AI suggestions
        aiTaskManager.analyzeAndPrioritizeTasks { [weak self] results in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.prioritizationResults = results
                self.tableView.reloadData()
                self.loadingView.stopAnimating()
                
                // Enable buttons if we have suggestions
                let hasSuggestions = !results.isEmpty
                self.acceptButton.isEnabled = hasSuggestions
                self.rejectButton.isEnabled = hasSuggestions
                
                // Update UI based on results
                if results.isEmpty {
                    self.showEmptyState()
                } else {
                    self.hideEmptyState()
                }
            }
        }
    }
    
    private func showEmptyState() {
        // Create empty state label if needed
        if tableView.backgroundView == nil {
            let emptyLabel = UILabel()
            emptyLabel.text = "No tasks need prioritization right now"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = themeManager.secondaryTextColor
            emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            emptyLabel.numberOfLines = 0
            
            tableView.backgroundView = emptyLabel
        }
        
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = true
    }
    
    // MARK: - Actions
    @objc private func handleThemeChanged() {
        applyThemeAndStyles()
        tableView.reloadData()
    }
    
    @objc private func refreshData() {
        // Add animation
        UIView.animate(withDuration: 0.1, animations: {
            self.navigationItem.rightBarButtonItem?.customView?.transform = CGAffineTransform(rotationAngle: .pi)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.navigationItem.rightBarButtonItem?.customView?.transform = .identity
            }
        }
        
        // Reload data
        loadDailyProgress()
        analyzeTasks()
    }
    
    @objc private func acceptSuggestions() {
        // Show loading
        loadingView.startAnimating()
        
        // Apply suggestions
        aiTaskManager.applyTaskPrioritization(prioritizationResults, approval: true) { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingView.stopAnimating()
                
                // Show confirmation
                if success {
                    self.showSuccessAlert(message: "All tasks have been rescheduled and prioritized!")
                } else {
                    self.showErrorAlert(message: "Failed to update tasks. Please try again.")
                }
                
                // Refresh data
                self.analyzeTasks()
            }
        }
    }
    
    @objc private func rejectSuggestions() {
        // Dismiss without changes
        analyzeTasks()
        
        // Show feedback
        let alert = UIAlertController(
            title: "Keeping Current Schedule",
            message: "No changes were made to your tasks.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Great!", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension AIPrioritizationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prioritizationResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PriorityTaskCell.identifier, for: indexPath) as? PriorityTaskCell else {
            return UITableViewCell()
        }
        
        let result = prioritizationResults[indexPath.row]
        let task = result.task
        
        // Configure cell
        cell.configure(
            title: task.value(forKey: "title") as? String ?? "Untitled",
            originalPriority: PriorityLevel(rawValue: task.value(forKey: "priorityLevel") as? Int16 ?? 1) ?? .medium,
            suggestedPriority: result.priorityLevel,
            originalDueDate: task.value(forKey: "dueDate") as? Date,
            suggestedDueDate: result.suggestedDueDate,
            reason: result.reason
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

// MARK: - Priority Task Cell
class PriorityTaskCell: UITableViewCell {
    static let identifier = "PriorityTaskCell"
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let priorityChangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let dateChangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let reasonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priorityChangeLabel)
        containerView.addSubview(dateChangeLabel)
        containerView.addSubview(reasonLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            priorityChangeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priorityChangeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            priorityChangeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            dateChangeLabel.topAnchor.constraint(equalTo: priorityChangeLabel.bottomAnchor, constant: 8),
            dateChangeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            dateChangeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            reasonLabel.topAnchor.constraint(equalTo: dateChangeLabel.bottomAnchor, constant: 8),
            reasonLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            reasonLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            reasonLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(
        title: String,
        originalPriority: PriorityLevel,
        suggestedPriority: PriorityLevel,
        originalDueDate: Date?,
        suggestedDueDate: Date?,
        reason: String
    ) {
        titleLabel.text = title
        reasonLabel.text = reason
        
        // Configure priority change text
        if originalPriority != suggestedPriority {
            priorityChangeLabel.text = "Priority: \(originalPriority.title) → \(suggestedPriority.title)"
            priorityChangeLabel.textColor = suggestedPriority.color
        } else {
            priorityChangeLabel.text = "Priority: \(originalPriority.title) (unchanged)"
            priorityChangeLabel.textColor = ThemeManager.shared.secondaryTextColor
        }
        
        // Configure date change text
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        if let suggestedDate = suggestedDueDate {
            if let originalDate = originalDueDate {
                if Calendar.current.isDate(originalDate, inSameDayAs: suggestedDate) {
                    dateChangeLabel.text = "Due date: \(dateFormatter.string(from: originalDate)) (unchanged)"
                    dateChangeLabel.textColor = ThemeManager.shared.secondaryTextColor
                } else {
                    dateChangeLabel.text = "Due date: \(dateFormatter.string(from: originalDate)) → \(dateFormatter.string(from: suggestedDate))"
                    dateChangeLabel.textColor = ThemeManager.shared.currentThemeColor
                }
            } else {
                dateChangeLabel.text = "Due date: None → \(dateFormatter.string(from: suggestedDate))"
                dateChangeLabel.textColor = ThemeManager.shared.currentThemeColor
            }
        } else if let originalDate = originalDueDate {
            dateChangeLabel.text = "Due date: \(dateFormatter.string(from: originalDate)) (unchanged)"
            dateChangeLabel.textColor = ThemeManager.shared.secondaryTextColor
        } else {
            dateChangeLabel.text = "Due date: None"
            dateChangeLabel.textColor = ThemeManager.shared.secondaryTextColor
        }
        
        // Apply theme
        applyTheme()
    }
    
    private func applyTheme() {
        let themeManager = ThemeManager.shared
        
        containerView.backgroundColor = themeManager.containerBackgroundColor
        titleLabel.textColor = themeManager.textColor
        reasonLabel.textColor = themeManager.secondaryTextColor
        
        // Apply neumorphic effect
        if containerView.bounds.width > 0 {
            containerView.addNeumorphicEffect(
                cornerRadius: 12,
                backgroundColor: themeManager.containerBackgroundColor
            )
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyTheme()
    }
} 