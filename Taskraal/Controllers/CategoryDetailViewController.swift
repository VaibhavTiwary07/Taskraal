//
//  CategoryDetailViewController.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 03/04/25.
//

import UIKit
import CoreData

class CategoryDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let themeManager = ThemeManager.shared
    private var categoryName: String
    private var categoryColor: UIColor
    private var categoryObject: NSManagedObject // Core Data category object
    private var tasks: [NSManagedObject] = [] // Core Data tasks
    
    // MARK: - UI Elements
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let colorIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        return table
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
        imageView.image = UIImage(systemName: "tray")
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No tasks in this category yet"
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
    
    // MARK: - Initialization
    init(categoryObject: NSManagedObject) {
        self.categoryObject = categoryObject
        self.categoryName = categoryObject.value(forKey: "name") as? String ?? "Unknown Category"
        
        // Convert color hex to UIColor
        if let colorHex = categoryObject.value(forKey: "colorHex") as? String {
            self.categoryColor = UIColor.fromHex(colorHex) ?? .systemBlue
        } else {
            self.categoryColor = .systemBlue
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHeader()
        setupTableView()
        setupEmptyState()
        setupAddButton()
        
        // Listen for theme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
        
        // Listen for task data changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTaskDataChanged),
            name: NSNotification.Name("TaskDataChanged"),
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = themeManager.backgroundColor
        title = categoryName
        
        // Configure navigation bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = categoryColor
        
        // Add edit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil"),
            style: .plain,
            target: self,
            action: #selector(editCategoryTapped)
        )
        
        // Modern appearance for iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = themeManager.backgroundColor
            appearance.titleTextAttributes = [.foregroundColor: themeManager.textColor]
            appearance.shadowColor = .clear
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubviews(colorIndicator, categoryLabel, taskCountLabel)
        
        headerView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 60
        )
        
        colorIndicator.anchor(
            leading: headerView.leadingAnchor,
            width: 32,
            height: 32
        )
        colorIndicator.centerY(in: headerView)
        
        categoryLabel.anchor(
            top: headerView.topAnchor,
            leading: colorIndicator.trailingAnchor,
            paddingLeading: 16
        )
        
        taskCountLabel.anchor(
            top: categoryLabel.bottomAnchor,
            leading: colorIndicator.trailingAnchor,
            paddingTop: 4,
            paddingLeading: 16
        )
        
        // Set values
        colorIndicator.backgroundColor = categoryColor
        categoryLabel.text = categoryName
        categoryLabel.textColor = themeManager.textColor
        taskCountLabel.textColor = themeManager.secondaryTextColor
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.anchor(
            top: headerView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 16
        )
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = themeManager.backgroundColor
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
        
        // Set colors
        emptyStateImageView.tintColor = themeManager.secondaryTextColor.withAlphaComponent(0.5)
        emptyStateLabel.textColor = themeManager.secondaryTextColor
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)
        addButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor,
            paddingBottom: 24, paddingTrailing: 24,
            width: 56,
            height: 56
        )
        
        addButton.backgroundColor = themeManager.currentThemeColor
        addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
    }
    
    private func applyThemeAndStyles() {
        // Update background colors
        view.backgroundColor = themeManager.backgroundColor
        tableView.backgroundColor = themeManager.backgroundColor
        
        // Update text colors
        categoryLabel.textColor = themeManager.textColor
        taskCountLabel.textColor = themeManager.secondaryTextColor
        emptyStateLabel.textColor = themeManager.secondaryTextColor
        emptyStateImageView.tintColor = themeManager.secondaryTextColor.withAlphaComponent(0.5)
        
        // Apply neumorphic effect to the header with container background color
        headerView.backgroundColor = themeManager.containerBackgroundColor
        headerView.addNeumorphicEffect(
            cornerRadius: 20,
            backgroundColor: themeManager.containerBackgroundColor
        )
        
        // Apply neumorphic effect to the add button
        addButton.backgroundColor = themeManager.currentThemeColor
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
    
    @objc private func handleThemeChanged() {
        applyThemeAndStyles()
        setupView() // Update navigation bar
        tableView.reloadData() // Update cell appearance
    }
    
    @objc private func handleTaskDataChanged() {
        fetchTasks()
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
        
        // Present Add Task VC with pre-selected category
        let addTaskVC = AddTaskViewController()
        addTaskVC.delegate = self
        
        // Pre-select the current category
        addTaskVC.preSelectCategory(categoryObject)
        
        let navController = UINavigationController(rootViewController: addTaskVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    @objc private func editCategoryTapped() {
        let alert = UIAlertController(title: "Edit Category", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.presentRenameAlert()
        })
        
        alert.addAction(UIAlertAction(title: "Change Color", style: .default) { [weak self] _ in
            self?.presentColorChangeAlert()
        })
        
        alert.addAction(UIAlertAction(title: "Delete Category", style: .destructive) { [weak self] _ in
            self?.presentDeleteConfirmation()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentRenameAlert() {
        let alert = UIAlertController(title: "Rename Category", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = self.categoryName
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newName = textField.text,
                  !newName.isEmpty else { return }
            
            // Update category name in Core Data
            CoreDataManager.shared.updateCategory(self.categoryObject, name: newName)
            
            // Update UI
            self.categoryName = newName
            self.categoryLabel.text = newName
            self.title = newName
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        })
        
        present(alert, animated: true)
    }
    
    private func presentColorChangeAlert() {
        let alert = UIAlertController(title: "Choose Color", message: nil, preferredStyle: .actionSheet)
        
        let colors: [(name: String, color: UIColor, hex: String)] = [
            ("Blue", .systemBlue, "#0A84FF"),
            ("Green", .systemGreen, "#32D74B"),
            ("Orange", .systemOrange, "#FF9F0A"),
            ("Red", .systemRed, "#FF3B30"),
            ("Purple", .systemPurple, "#BF5AF2"),
            ("Teal", .systemTeal, "#64D2FF"),
            ("Pink", .systemPink, "#FF2D55")
        ]
        
        for colorOption in colors {
            let action = UIAlertAction(title: colorOption.name, style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                // Update category color in Core Data
                CoreDataManager.shared.updateCategory(self.categoryObject, colorHex: colorOption.hex)
                
                // Update UI
                self.categoryColor = colorOption.color
                self.colorIndicator.backgroundColor = colorOption.color
                self.navigationController?.navigationBar.tintColor = colorOption.color
                
                // Add haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentDeleteConfirmation() {
        let alert = UIAlertController(
            title: "Delete Category",
            message: "Are you sure you want to delete this category? All tasks in this category will also be deleted.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Get all tasks in this category
            let tasksToDelete = self.tasks
            
            // Delete all tasks in this category
            let context = CoreDataManager.shared.viewContext
            for task in tasksToDelete {
                context.delete(task)
            }
            
            // Then delete the category
            CoreDataManager.shared.deleteCategory(self.categoryObject)
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Pop back to previous screen
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Core Data
    private func fetchTasks() {
        // Use CoreDataManager to fetch tasks for this category
        tasks = CoreDataManager.shared.fetchTasks(category: categoryObject)
        
        // Update UI
        let completedCount = tasks.filter { ($0.value(forKey: "isCompleted") as? Bool) ?? false }.count
        taskCountLabel.text = "\(completedCount)/\(tasks.count) completed"
        
        // Update empty state visibility
        emptyStateView.isHidden = !tasks.isEmpty
        
        // Reload table
        tableView.reloadData()
    }
    
    private func toggleTaskCompletion(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let currentValue = task.value(forKey: "isCompleted") as? Bool ?? false
        
        // Update task in Core Data
        CoreDataManager.shared.updateTask(task, isCompleted: !currentValue)
        
        // Refresh UI
        fetchTasks()
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        let taskToDelete = tasks[indexPath.row]
        
        // Delete task from Core Data
        CoreDataManager.shared.deleteTask(taskToDelete)
        
        // Refresh data and UI
        fetchTasks()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CategoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        
        let task = tasks[indexPath.row]
        
        // Get values from Core Data
        let title = task.value(forKey: "title") as? String ?? "Untitled Task"
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
            
            let task = self.tasks[indexPath.row]
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

// MARK: - AddTaskViewControllerDelegate
extension CategoryDetailViewController: AddTaskViewControllerDelegate {
    func didAddNewTask() {
        fetchTasks()
    }
    
    func didUpdateTask() {
        fetchTasks()
    }
}

// MARK: - UIColor Extension
//extension UIColor {
//    static func fromHex(_ hex: String) -> UIColor? {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//        
//        var rgb: UInt64 = 0
//        
//        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
//        
//        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//        let blue = CGFloat(rgb & 0x0000FF) / 255.0
//        
//        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
//    }
//}
