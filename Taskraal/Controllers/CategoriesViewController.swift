//
//  CategoriesViewController.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 12/03/25.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController {
    
    // MARK: - Properties
    private let themeManager = ThemeManager.shared
    private var categories: [NSManagedObject] = []
    
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
        label.text = "Categories"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let categoryCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 28
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHeader()
        setupTableView()
        setupAddButton()
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
        fetchCategories()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyThemeAndStyles()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = themeManager.backgroundColor
        title = "Categories"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubviews(headerLabel, categoryCountLabel)
        
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
        
        categoryCountLabel.anchor(
            top: headerView.topAnchor,
            trailing: headerView.trailingAnchor
        )
        
        // Set text colors
        headerLabel.textColor = themeManager.textColor
        categoryCountLabel.textColor = themeManager.secondaryTextColor
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
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 90
        tableView.backgroundColor = themeManager.backgroundColor
    }
    
    private func setupAddButton() {
        view.addSubview(addButton)
        addButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor,
            paddingBottom: 24, paddingTrailing: 24,
            width: 56,
            height: 56
        )
        
        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
    }
    
    private func setupNotificationObservers() {
        // Listen for task data changes to update category task counts
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTaskDataChanged),
            name: NSNotification.Name("TaskDataChanged"),
            object: nil
        )
    }
    
    private func applyThemeAndStyles() {
        // Update view colors
        view.backgroundColor = themeManager.backgroundColor
        tableView.backgroundColor = themeManager.backgroundColor
        
        // Update text colors
        headerLabel.textColor = themeManager.textColor
        categoryCountLabel.textColor = themeManager.secondaryTextColor
        
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
        tableView.reloadData()
    }
    
    @objc private func handleTaskDataChanged() {
        // Refresh category task counts
        fetchCategories()
    }
    
    // MARK: - Actions
    @objc private func addCategoryTapped() {
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
        
        // Show add category dialog
        presentAddCategoryAlert()
    }
    
    private func presentAddCategoryAlert() {
        let alert = UIAlertController(title: "New Category", message: "Enter a name for your category", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Category Name"
            textField.autocapitalizationType = .words
        }
        
        // Add color selection options
        let colorOptions = [
            ("Blue", "#0A84FF"),
            ("Green", "#32D74B"),
            ("Orange", "#FF9F0A"),
            ("Red", "#FF3B30"),
            ("Purple", "#BF5AF2"),
            ("Teal", "#64D2FF"),
            ("Pink", "#FF2D55")
        ]
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let categoryName = textField.text,
                  !categoryName.isEmpty else { return }
            
            // Use a random color for now (in a real app, you'd allow selection)
            let randomColorHex = colorOptions.randomElement()?.1 ?? "#0A84FF"
            
            // Create category in Core Data
            if let _ = CoreDataManager.shared.createCategory(name: categoryName, colorHex: randomColorHex) {
                // Refresh categories
                self.fetchCategories()
                
                // Add success feedback
                let successGenerator = UINotificationFeedbackGenerator()
                successGenerator.notificationOccurred(.success)
            }
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Core Data
    private func fetchCategories() {
        // Use CoreDataManager to fetch categories
        categories = CoreDataManager.shared.fetchCategories()
        
        // Update category count label
        categoryCountLabel.text = "\(categories.count) categories"
        
        // Reload table view
        tableView.reloadData()
    }
    
    private func getTaskCount(for category: NSManagedObject) -> Int {
        // Create a predicate to count tasks for this category
        let predicate = NSPredicate(format: "category == %@", category)
        
        // Use CoreDataManager to count tasks
        return CoreDataManager.shared.count(for: "Task", predicate: predicate)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        
        // Get category properties from Core Data object
        let name = category.value(forKey: "name") as? String ?? "Unnamed"
        let colorHex = category.value(forKey: "colorHex") as? String ?? "#0A84FF"
        let color = UIColor.fromHex(colorHex) ?? .systemBlue
        
        // Get task count for this category
        let taskCount = getTaskCount(for: category)
        
        cell.configure(with: name, color: color, taskCount: taskCount)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected category object
        let selectedCategory = categories[indexPath.row]
        
        // Create and configure the detail view controller with Core Data object
        let categoryDetailVC = CategoryDetailViewController(categoryObject: selectedCategory)
        
        // Push the detail view controller onto the navigation stack
        navigationController?.pushViewController(categoryDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Get the category
        let category = categories[indexPath.row]
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            // Show delete confirmation
            self.confirmDeleteCategory(category) {
                // Refresh categories
                self.fetchCategories()
                completion(true)
            }
        }
        
        // Configure delete action
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        // Edit action
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            self?.presentEditCategoryAlert(for: category)
            completion(true)
        }
        
        // Configure edit action
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func confirmDeleteCategory(_ category: NSManagedObject, completion: @escaping () -> Void) {
        // Get category name
        let categoryName = category.value(forKey: "name") as? String ?? "this category"
        
        let alert = UIAlertController(
            title: "Delete \(categoryName)?",
            message: "This will also delete all tasks in this category. This cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Get all tasks for this category
            let tasksToDelete = CoreDataManager.shared.fetchTasks(category: category)
            
            // Delete all related tasks
            let context = CoreDataManager.shared.viewContext
            for task in tasksToDelete {
                context.delete(task)
            }
            
            // Delete the category
            CoreDataManager.shared.deleteCategory(category)
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Call completion handler
            completion()
        })
        
        present(alert, animated: true)
    }
    
    private func presentEditCategoryAlert(for category: NSManagedObject) {
        let categoryName = category.value(forKey: "name") as? String ?? ""
        
        let alert = UIAlertController(title: "Edit Category", message: "Update the category name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = categoryName
            textField.placeholder = "Category Name"
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newName = textField.text,
                  !newName.isEmpty else { return }
            
            // Update category name
            CoreDataManager.shared.updateCategory(category, name: newName)
            
            // Refresh categories
            self.fetchCategories()
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - CategoryCell
class CategoryCell: UITableViewCell {
    // MARK: - Constants
    static let identifier = "CategoryCell"
    private let themeManager = ThemeManager.shared
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let colorIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let disclosureIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        
        // Listen for theme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyThemeAndStyles()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Ensure styling is reset for reused cells
        applyThemeAndStyles()
    }
    
    // MARK: - Setup
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Add and configure UI elements
        contentView.addSubview(containerView)
        containerView.addSubviews(colorIndicator, nameLabel, taskCountLabel, disclosureIcon)
        
        // Set up constraints
        containerView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 8,
            paddingLeading: 16,
            paddingBottom: 8,
            paddingTrailing: 16
        )
        
        colorIndicator.anchor(
            leading: containerView.leadingAnchor,
            paddingLeading: 16,
            width: 24,
            height: 24
        )
        colorIndicator.centerY(in: containerView)
        
        nameLabel.anchor(
            top: containerView.topAnchor,
            leading: colorIndicator.trailingAnchor,
            trailing: disclosureIcon.leadingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingTrailing: 8
        )
        
        taskCountLabel.anchor(
            top: nameLabel.bottomAnchor,
            leading: colorIndicator.trailingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: disclosureIcon.leadingAnchor,
            paddingTop: 4,
            paddingLeading: 16,
            paddingBottom: 16,
            paddingTrailing: 8
        )
        
        disclosureIcon.anchor(
            trailing: containerView.trailingAnchor,
            paddingTrailing: 16,
            width: 12
        )
        disclosureIcon.centerY(in: containerView)
    }
    
    private func applyThemeAndStyles() {
        // Apply neumorphic effect to container with white background
        if containerView.bounds.width > 0 && containerView.bounds.height > 0 {
            containerView.addNeumorphicEffect(
                cornerRadius: 16,
                backgroundColor: themeManager.backgroundColor
            )
        }
        
        // Update text colors
        nameLabel.textColor = themeManager.textColor
        taskCountLabel.textColor = themeManager.secondaryTextColor
        disclosureIcon.tintColor = themeManager.secondaryTextColor
    }
    
    @objc private func handleThemeChanged() {
        applyThemeAndStyles()
    }
    
    // MARK: - Configure
    func configure(with name: String, color: UIColor, taskCount: Int) {
        nameLabel.text = name
        colorIndicator.backgroundColor = color
        taskCountLabel.text = "\(taskCount) task\(taskCount == 1 ? "" : "s")"
        
        // Apply styling after layout is complete
        DispatchQueue.main.async {
            self.applyThemeAndStyles() 
        }
    }
}

// MARK: - UIColor Extension
extension UIColor {
    static func fromHex(_ hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
