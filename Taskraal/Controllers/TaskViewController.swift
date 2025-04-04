//
//  TasksViewController.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 03/04/25.
//

import UIKit
import CoreData

class TasksViewController: UIViewController {
    
    // MARK: - Properties
    private let neumorphicBackgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1.0)
    private let accentColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0)
    private var tasks: [NSManagedObject] = []
    private var filteredTasks: [NSManagedObject] = []
    private var isSearching: Bool = false
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    private let headerView: UIView = {
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
    
    private let searchContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        label.text = "No tasks yet\nTap + to add your first task"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 160/255, green: 170/255, blue: 180/255, alpha: 1.0)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0) // Accent color
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 28
        return button
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHeader()
        setupSearchBar()
        setupTableView()
        setupEmptyState()
        setupAddButton()
        setupRefreshControl()
        setupNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTasks()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyNeumorphicStyles()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = neumorphicBackgroundColor
        title = "Tasks"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubviews(headerLabel, taskCountLabel)
        
        headerView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 40
        )
        
        headerLabel.anchor(
            top: headerView.topAnchor,
            leading: headerView.leadingAnchor
        )
        
        taskCountLabel.anchor(
            top: headerView.topAnchor,
            trailing: headerView.trailingAnchor
        )
    }
    
    private func setupSearchBar() {
        view.addSubview(searchContainer)
        searchContainer.addSubviews(searchIconView, searchTextField)
        
        searchContainer.anchor(
            top: headerView.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 50
        )
        
        searchIconView.anchor(
            leading: searchContainer.leadingAnchor,
            paddingLeading: 16,
            width: 20,
            height: 20
        )
        searchIconView.centerY(in: searchContainer)
        
        searchTextField.anchor(
            leading: searchIconView.trailingAnchor,
            trailing: searchContainer.trailingAnchor,
            paddingLeading: 12,
            paddingTrailing: 16
        )
        searchTextField.centerY(in: searchContainer)
        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.anchor(
            top: searchContainer.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
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
            trailing: emptyStateView.trailingAnchor,
            paddingTop: 16
        )
        emptyStateLabel.centerX(in: emptyStateView)
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
        
        addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = accentColor
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
    }
    
    private func applyNeumorphicStyles() {
        // Apply neumorphic effect to the search container
        searchContainer.addNeumorphicEffect(
            cornerRadius: 25,
            backgroundColor: neumorphicBackgroundColor
        )
        
        // Apply neumorphic effect to the add button
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        addButton.layer.shadowOpacity = 0.3
        addButton.layer.shadowRadius = 5
        
        // Apply inner highlight to add button
        let innerGlow = CAGradientLayer()
        innerGlow.frame = CGRect(x: 0, y: 0, width: addButton.bounds.width, height: addButton.bounds.height)
        innerGlow.cornerRadius = 28
        innerGlow.colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor
        ]
        innerGlow.startPoint = CGPoint(x: 0, y: 0)
        innerGlow.endPoint = CGPoint(x: 1, y: 1)
        innerGlow.locations = [0.0, 0.5]
        
        // Remove existing inner glow if any
        if let sublayers = addButton.layer.sublayers {
            for layer in sublayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        // Add new inner glow
        addButton.layer.insertSublayer(innerGlow, at: 0)
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
