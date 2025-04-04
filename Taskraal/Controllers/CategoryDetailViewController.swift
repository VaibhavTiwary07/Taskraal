//
//  CategoryDetailViewController.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 03/04/25.
//

import UIKit

class CategoryDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let neumorphicBackgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1.0)
    private let accentColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0)
    private var categoryName: String
    private var categoryColor: UIColor
    private var tasks: [(title: String, dueDate: Date?, priority: PriorityLevel, isCompleted: Bool)] = []
    
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
    init(categoryName: String, categoryColor: UIColor) {
        self.categoryName = categoryName
        self.categoryColor = categoryColor
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
        createMockData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyNeumorphicStyles()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = neumorphicBackgroundColor
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
            bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor,
            paddingBottom: 24, paddingTrailing: 24,
            width: 56,
            height: 56
        )
        
        addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
    }
    
    private func applyNeumorphicStyles() {
        // Apply neumorphic effect to the header
        headerView.addNeumorphicEffect(
            cornerRadius: 20,
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
            
            self.categoryName = newName
            self.categoryLabel.text = newName
            self.title = newName
        })
        
        present(alert, animated: true)
    }
    
    private func presentColorChangeAlert() {
        let alert = UIAlertController(title: "Choose Color", message: nil, preferredStyle: .actionSheet)
        
        let colors: [(name: String, color: UIColor)] = [
            ("Blue", .systemBlue),
            ("Green", .systemGreen),
            ("Orange", .systemOrange),
            ("Red", .systemRed),
            ("Purple", .systemPurple),
            ("Teal", .systemTeal),
            ("Pink", .systemPink)
        ]
        
        for colorOption in colors {
            let action = UIAlertAction(title: colorOption.name, style: .default) { [weak self] _ in
                self?.categoryColor = colorOption.color
                self?.colorIndicator.backgroundColor = colorOption.color
                self?.navigationController?.navigationBar.tintColor = colorOption.color
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
            // In a real app, you would delete from Core Data
            // For now, just pop back to previous screen
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Data
    private func createMockData() {
        // Create some sample tasks for this category
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)
        
        // Customize tasks based on category name
        switch categoryName.lowercased() {
        case "work":
            tasks = [
                ("Complete project proposal", tomorrow, .high, false),
                ("Schedule team meeting", today, .medium, false),
                ("Update documentation", nextWeek, .low, false),
                ("Send weekly report", today, .high, true),
                ("Review code changes", tomorrow, .medium, false)
            ]
        case "personal":
            tasks = [
                ("Call mom", today, .medium, false),
                ("Schedule dentist appointment", nextWeek, .high, false),
                ("Pay rent", tomorrow, .high, true)
            ]
        case "shopping":
            tasks = [
                ("Buy groceries", today, .medium, false),
                ("Order new headphones", nextWeek, .low, false)
            ]
        case "health":
            tasks = [
                ("Go to the gym", today, .high, false),
                ("Drink 8 glasses of water", today, .medium, true),
                ("Schedule annual checkup", nextWeek, .medium, false)
            ]
        case "education":
            tasks = [
                ("Study Swift programming", today, .high, false),
                ("Complete online course", nextWeek, .medium, false),
                ("Read chapter 5", tomorrow, .medium, false),
                ("Practice coding problems", today, .low, true)
            ]
        default:
            tasks = [
                ("Task 1", today, .medium, false),
                ("Task 2", tomorrow, .high, false),
                ("Task 3", nextWeek, .low, true)
            ]
        }
        
        // Update UI
        let completedCount = tasks.filter { $0.isCompleted }.count
        taskCountLabel.text = "\(completedCount)/\(tasks.count) completed"
        
        // Update empty state visibility
        emptyStateView.isHidden = !tasks.isEmpty
        tableView.reloadData()
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
        cell.configure(
            with: task.title,
            category: categoryName,
            dueDate: task.dueDate,
            priority: task.priority,
            isCompleted: task.isCompleted
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected task at index \(indexPath.row)")
        // This will be implemented later with task details
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            // Remove the task from the array
            self.tasks.remove(at: indexPath.row)
            
            // Update the table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Update the task count
            let completedCount = self.tasks.filter { $0.isCompleted }.count
            self.taskCountLabel.text = "\(completedCount)/\(self.tasks.count) completed"
            
            // Show empty state if needed
            self.emptyStateView.isHidden = !self.tasks.isEmpty
            
            completion(true)
        }
        
        // Configure delete action
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - AddTaskViewControllerDelegate
extension CategoryDetailViewController: AddTaskViewControllerDelegate {
    func didAddNewTask() {
        // In a real app, you would fetch the tasks from Core Data
        // For now, just add a mock task to the beginning of the array
        
        let newTask = ("New Task", Date(), PriorityLevel.medium, false)
        tasks.insert(newTask, at: 0)
        
        // Update UI
        let completedCount = tasks.filter { $0.isCompleted }.count
        taskCountLabel.text = "\(completedCount)/\(tasks.count) completed"
        
        // Hide empty state if needed
        emptyStateView.isHidden = true
        
        // Reload table
        tableView.reloadData()
        
        // Scroll to top
        if !tasks.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}
