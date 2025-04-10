//
//  TasksViewController.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 03/04/25.
//

import UIKit
import CoreData
import EventKit

class TasksViewController: UIViewController {
    
    // MARK: - Properties
    private let themeManager = ThemeManager.shared
    private var tasks: [NSManagedObject] = []
    private var filteredTasks: [NSManagedObject] = []
    private var isSearching: Bool = false
    private let schedulingService = SchedulingService.shared
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    private let mainContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "My Tasks"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        return label
    }()
    
    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 1.0)
        return label
    }()
    
    private let searchIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Search tasks..."
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        return textField
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 180/255, green: 190/255, blue: 200/255, alpha: 0.5)
        imageView.image = UIImage(systemName: "checklist")
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 160/255, green: 170/255, blue: 180/255, alpha: 1.0)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHeader()
        setupTableView()
        setupEmptyState()
        setupAddButton()
        setupRefreshControl()
        setupNotificationObservers()
        
        // Listen for theme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTasks()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyThemeAndStyles()
        
        // Update shadow paths when layout changes
        if addButton.bounds.size != .zero {
            addButton.layer.shadowPath = UIBezierPath(roundedRect: addButton.bounds, cornerRadius: 28).cgPath
            
            // Update gradient layer if it exists
            if let innerGlow = addButton.layer.sublayers?.first as? CAGradientLayer {
                innerGlow.frame = addButton.bounds
                innerGlow.cornerRadius = 28
            }
        }
        
        if mainContainerView.bounds.size != .zero {
            mainContainerView.layer.shadowPath = UIBezierPath(roundedRect: mainContainerView.bounds, cornerRadius: 25).cgPath
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ensure neumorphic effects are applied after view appears
        applyThemeAndStyles()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = themeManager.backgroundColor
        title = "Tasks"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.largeTitleDisplayMode = .never
        
        // Ensure navigation bar uses correct colors
        navigationController?.navigationBar.tintColor = themeManager.currentThemeColor
        navigationController?.navigationBar.barTintColor = themeManager.backgroundColor
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = themeManager.backgroundColor
            appearance.shadowColor = .clear
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupHeader() {
        view.addSubview(mainContainerView)
        mainContainerView.addSubviews(headerLabel, taskCountLabel, searchIconView, searchTextField)
        
        mainContainerView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 20,
            paddingTrailing: 20
        )
        
        headerLabel.anchor(
            top: mainContainerView.topAnchor,
            leading: mainContainerView.leadingAnchor,
            paddingTop: 16,
            paddingLeading: 16
        )
        
        taskCountLabel.anchor(
            top: mainContainerView.topAnchor,
            trailing: mainContainerView.trailingAnchor,
            paddingTop: 16,
            paddingTrailing: 16
        )
        
        searchIconView.anchor(
            top: headerLabel.bottomAnchor,
            leading: mainContainerView.leadingAnchor,
            paddingTop: 20,
            paddingLeading: 16,
            width: 20,
            height: 20
        )
        
        searchTextField.anchor(
            leading: searchIconView.trailingAnchor,
            trailing: mainContainerView.trailingAnchor,
            paddingLeading: 12,
            paddingTrailing: 16,
            height: 44
        )
        searchTextField.centerY(in: searchIconView)
        
        // Add bottom constraint to ensure proper sizing
        searchTextField.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor, constant: -16).isActive = true
        
        // Set text colors
        headerLabel.textColor = themeManager.textColor
        taskCountLabel.textColor = themeManager.secondaryTextColor
        
        // Set up search field
        searchIconView.tintColor = themeManager.secondaryTextColor
        searchTextField.textColor = themeManager.textColor
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search tasks...",
            attributes: [NSAttributedString.Key.foregroundColor: themeManager.secondaryTextColor]
        )
        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.anchor(
            top: mainContainerView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Set explicit row height to avoid ambiguity
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.backgroundColor = themeManager.backgroundColor
        tableView.separatorStyle = .none
        
        // Extra settings to avoid ambiguous content size
        tableView.alwaysBounceVertical = true
        tableView.contentInsetAdjustmentBehavior = .automatic
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.addSubviews(emptyStateImageView, emptyStateLabel)
        
        emptyStateView.anchor(
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            height: 200
        )
        emptyStateView.centerY(in: tableView)
        
        emptyStateImageView.anchor(
            top: emptyStateView.topAnchor,
            width: 80,
            height: 80
        )
        emptyStateImageView.centerX(in: emptyStateView)
        
        emptyStateLabel.anchor(
            top: emptyStateImageView.bottomAnchor,
            leading: emptyStateView.leadingAnchor,
            bottom: emptyStateView.bottomAnchor,
            trailing: emptyStateView.trailingAnchor,
            paddingTop: 16,
            paddingBottom: 16
        )
        emptyStateLabel.centerX(in: emptyStateView)
        
        // Set a preferred content size for the label text
        emptyStateLabel.text = "No tasks yet\nTap + to add your first task"
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.sizeToFit()
        
        // Set colors
        emptyStateImageView.tintColor = themeManager.secondaryTextColor.withAlphaComponent(0.5)
        emptyStateLabel.textColor = themeManager.secondaryTextColor
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)
        addButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingBottom: 24,
            paddingTrailing: 24,
            width: 56,
            height: 56
        )
        
        // Configure the button using modern API when available
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "plus")
            config.baseForegroundColor = .white
            config.background.backgroundColor = themeManager.currentThemeColor
            config.cornerStyle = .capsule
            addButton.configuration = config
        } else {
            // Fallback for iOS 14 and earlier
            addButton.backgroundColor = themeManager.currentThemeColor
            addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            addButton.tintColor = .white
            addButton.layer.cornerRadius = 28
        }
        
        addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = themeManager.currentThemeColor
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChanged),
            name: NSNotification.Name("TaskDataChanged"),
            object: nil
        )
        
        // Use ThemeManager's notification name constant
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    private func applyThemeAndStyles() {
        // Update colors based on theme
        view.backgroundColor = themeManager.backgroundColor
        tableView.backgroundColor = themeManager.backgroundColor
        
        // Update main container with proper background color
        mainContainerView.backgroundColor = themeManager.containerBackgroundColor
        mainContainerView.layer.cornerRadius = 25
        
        // Apply shadow with explicit path for better performance
        if mainContainerView.bounds.width > 0 && mainContainerView.bounds.height > 0 {
            mainContainerView.layer.shadowColor = UIColor.black.cgColor
            mainContainerView.layer.shadowOffset = CGSize(width: 2, height: 2)
            mainContainerView.layer.shadowOpacity = 0.1
            mainContainerView.layer.shadowRadius = 4
            mainContainerView.layer.shadowPath = UIBezierPath(roundedRect: mainContainerView.bounds, cornerRadius: 25).cgPath
            
            // Clean up old shadow layers
            for subview in mainContainerView.subviews {
                if subview.tag == 1001 || subview.tag == 1002 {
                    subview.removeFromSuperview()
                }
            }
        }
        
        // Update header and text colors
        headerLabel.textColor = themeManager.textColor
        taskCountLabel.textColor = themeManager.secondaryTextColor
        
        // Update search bar
        searchIconView.tintColor = themeManager.secondaryTextColor
        searchTextField.textColor = themeManager.textColor
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search tasks...",
            attributes: [NSAttributedString.Key.foregroundColor: themeManager.secondaryTextColor]
        )
        
        // Update empty state
        emptyStateImageView.tintColor = themeManager.secondaryTextColor.withAlphaComponent(0.5)
        emptyStateLabel.textColor = themeManager.secondaryTextColor
        
        // Update add button
        updateAddButtonAppearance()
        
        // Ensure the table content size is explicitly set to avoid ambiguity
        tableView.contentSize = CGSize(width: tableView.bounds.width, height: max(tableView.contentSize.height, 1))
    }
    
    private func updateAddButtonAppearance() {
        // Update add button appearance based on iOS version
        if #available(iOS 15.0, *) {
            // For iOS 15+ use configuration
            guard var config = addButton.configuration else {
                // Create configuration if it doesn't exist
                var newConfig = UIButton.Configuration.plain()
                newConfig.image = UIImage(systemName: "plus")
                newConfig.baseForegroundColor = .white
                newConfig.background.backgroundColor = themeManager.currentThemeColor
                newConfig.cornerStyle = .capsule
                addButton.configuration = newConfig
                return
            }
            
            // Update existing configuration
            config.background.backgroundColor = themeManager.currentThemeColor
            addButton.configuration = config
            
            // Add shadow directly to layer
            addButton.layer.shadowColor = UIColor.black.cgColor
            addButton.layer.shadowOffset = CGSize(width: 4, height: 4)
            addButton.layer.shadowOpacity = 0.3
            addButton.layer.shadowRadius = 5
            if addButton.bounds.size != .zero {
                addButton.layer.shadowPath = UIBezierPath(roundedRect: addButton.bounds, cornerRadius: 28).cgPath
            }
        } else {
            // For iOS 14 and earlier
            addButton.backgroundColor = themeManager.currentThemeColor
            
            // Remove existing gradient layers
            addButton.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
            
            // Set up shadow with explicit path
            addButton.layer.shadowColor = UIColor.black.cgColor
            addButton.layer.shadowOffset = CGSize(width: 4, height: 4)
            addButton.layer.shadowOpacity = 0.3
            addButton.layer.shadowRadius = 5
            if addButton.bounds.size != .zero {
                addButton.layer.shadowPath = UIBezierPath(roundedRect: addButton.bounds, cornerRadius: 28).cgPath
            }
            
            // Add inner highlight using a simpler approach to avoid CAShapeLayer
            let innerGlow = CAGradientLayer()
            innerGlow.frame = addButton.bounds
            innerGlow.cornerRadius = 28
            innerGlow.colors = [
                UIColor.white.withAlphaComponent(0.5).cgColor,
                UIColor.clear.cgColor
            ]
            innerGlow.startPoint = CGPoint(x: 0, y: 0)
            innerGlow.endPoint = CGPoint(x: 1, y: 1)
            innerGlow.locations = [0.0, 0.5]
            
            // Add new inner glow
            addButton.layer.insertSublayer(innerGlow, at: 0)
        }
        
        // Update refresh control color
        refreshControl.tintColor = themeManager.currentThemeColor
    }
    
    @objc private func handleThemeChanged() {
        // Use ThemeManager to update navigation bar
        themeManager.applyThemeToNavigationBar(navigationController)
        
        // Update all styling through a single method
        applyThemeAndStyles()
        
        // Force a complete reload of the table view
        tableView.reloadData()
        
        // Ensure visible cells are properly updated
        for cell in tableView.visibleCells {
            if let taskCell = cell as? TaskCell {
                // Force each visible cell to refresh fully
                taskCell.setNeedsLayout()
                taskCell.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Actions
    @objc private func addTaskTapped() {
        // Add animation
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = .identity
            }
        }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Present Add Task VC
        let addTaskVC = AddTaskViewController()
        addTaskVC.delegate = self
        let navController = UINavigationController(rootViewController: addTaskVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    @objc private func refreshData() {
        fetchTasks()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func handleDataChanged() {
        fetchTasks()
    }
    
    @objc private func searchTextChanged() {
        if let searchText = searchTextField.text, !searchText.isEmpty {
            isSearching = true
            filterTasks(with: searchText)
        } else {
            isSearching = false
            tableView.reloadData()
        }
        
        updateEmptyStateVisibility()
    }
    
    // MARK: - Core Data
    private func fetchTasks() {
        let context = CoreDataManager.shared.viewContext
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        // Configure sort descriptors
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isCompleted", ascending: true),
            NSSortDescriptor(key: "dueDate", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        do {
            tasks = try context.fetch(fetchRequest)
            
            // Update task count label
            let completedCount = tasks.filter { $0.value(forKey: "isCompleted") as? Bool ?? false }.count
            taskCountLabel.text = "\(completedCount)/\(tasks.count) completed"
            
            // Update empty state visibility
            updateEmptyStateVisibility()
            
            // Reload table view
            tableView.reloadData()
        } catch {
            print("Error fetching tasks: \(error)")
            showErrorAlert(message: "Failed to load tasks. Please try again.")
        }
    }
    
    private func filterTasks(with searchText: String) {
        let lowercasedSearchText = searchText.lowercased()
        filteredTasks = tasks.filter { task in
            return ((task.value(forKey: "title") as? String)?.lowercased().contains(lowercasedSearchText) ?? false) ||
                   ((task.value(forKey: "details") as? String)?.lowercased().contains(lowercasedSearchText) ?? false) ||
                   (((task.value(forKey: "category") as? NSManagedObject)?.value(forKey: "name") as? String)?.lowercased().contains(lowercasedSearchText) ?? false)
        }
        
        tableView.reloadData()
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        let context = CoreDataManager.shared.viewContext
        
        // Get the task to delete
        let taskToDelete = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        
        // Remove any scheduling integrations
        schedulingService.removeAllIntegrations(for: taskToDelete)
        
        // Delete the task
        context.delete(taskToDelete)
        
        // Save the context
        do {
            try context.save()
            
            // Remove from arrays
            if isSearching {
                filteredTasks.remove(at: indexPath.row)
                
                // Also remove from the main tasks array
                if let mainIndex = tasks.firstIndex(where: { $0 === taskToDelete }) {
                    tasks.remove(at: mainIndex)
                }
            } else {
                tasks.remove(at: indexPath.row)
            }
            
            // Update UI
            let completedCount = tasks.filter { $0.value(forKey: "isCompleted") as? Bool ?? false }.count
            taskCountLabel.text = "\(completedCount)/\(tasks.count) completed"
            
            // Update empty state
            updateEmptyStateVisibility()
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Notify of data change
            NotificationCenter.default.post(name: NSNotification.Name("TaskDataChanged"), object: nil)
        } catch {
            print("Error deleting task: \(error)")
            showErrorAlert(message: "Failed to delete task. Please try again.")
        }
    }
    
    private func toggleTaskCompletion(at indexPath: IndexPath) {
        let context = CoreDataManager.shared.viewContext
        
        // Get the task to update
        let taskToUpdate = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        
        // Toggle completion status
        let currentValue = taskToUpdate.value(forKey: "isCompleted") as? Bool ?? false
        taskToUpdate.setValue(!currentValue, forKey: "isCompleted")
        
        // Handle scheduling integrations based on completion state
        if !currentValue == true {
            // Task is being marked as completed, remove all integrations
            schedulingService.removeAllIntegrations(for: taskToUpdate)
        } else {
            // Task is being marked as incomplete, recreate integrations if it has a due date
            if let dueDate = taskToUpdate.value(forKey: "dueDate") as? Date, dueDate > Date() {
                schedulingService.setupAllIntegrations(for: taskToUpdate) { _, _ in }
            }
        }
        
        // Save the context
        do {
            try context.save()
            
            // Update UI
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            // Update task count
            let completedCount = tasks.filter { $0.value(forKey: "isCompleted") as? Bool ?? false }.count
            taskCountLabel.text = "\(completedCount)/\(tasks.count) completed"
            
            // Add haptic feedback
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            
            // Notify of data change
            NotificationCenter.default.post(name: NSNotification.Name("TaskDataChanged"), object: nil)
        } catch {
            print("Error updating task: \(error)")
            showErrorAlert(message: "Failed to update task. Please try again.")
        }
    }
    
    // MARK: - Helper Methods
    private func updateEmptyStateVisibility() {
        if isSearching {
            emptyStateView.isHidden = !filteredTasks.isEmpty
            emptyStateLabel.text = "No matching tasks found"
        } else {
            emptyStateView.isHidden = !tasks.isEmpty
            emptyStateLabel.text = "No tasks yet\nTap + to add your first task"
        }
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
extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        
        let task = isSearching ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        
        // Get values from the NSManagedObject
        let title = task.value(forKey: "title") as? String ?? "Untitled Task"
        let categoryObj = task.value(forKey: "category") as? NSManagedObject
        let categoryName = categoryObj?.value(forKey: "name") as? String ?? "No Category"
        let dueDate = task.value(forKey: "dueDate") as? Date
        let priorityLevel = task.value(forKey: "priorityLevel") as? Int16 ?? 1
        let isCompleted = task.value(forKey: "isCompleted") as? Bool ?? false
        
        let priority = PriorityLevel(rawValue: priorityLevel) ?? .medium
        
        cell.configure(
            with: title,
            category: categoryName,
            dueDate: dueDate,
            priority: priority,
            isCompleted: isCompleted
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle task completion when tapped
        toggleTaskCompletion(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            self?.deleteTask(at: indexPath)
            completion(true)
        }
        
        // Configure delete action
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        // Edit action
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            let task = self.isSearching ? self.filteredTasks[indexPath.row] : self.tasks[indexPath.row]
            self.presentEditTask(task)
            
            completion(true)
        }
        
        // Configure edit action
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func presentEditTask(_ task: NSManagedObject) {
        let editTaskVC = AddTaskViewController()
        editTaskVC.delegate = self
        editTaskVC.configureForEditing(with: task)
        
        let navController = UINavigationController(rootViewController: editTaskVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension TasksViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - AddTaskViewControllerDelegate
extension TasksViewController: AddTaskViewControllerDelegate {
    func didAddNewTask() {
        fetchTasks()
    }
    
    func didUpdateTask() {
        fetchTasks()
    }
}
