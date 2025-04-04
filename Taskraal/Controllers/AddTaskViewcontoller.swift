//
//  AddTaskViewController.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 03/04/25.
//

import UIKit
import CoreData

// MARK: - AddTaskViewControllerDelegate Protocol
protocol AddTaskViewControllerDelegate: AnyObject {
    func didAddNewTask()
    func didUpdateTask()
}

// Default implementation for didUpdateTask
extension AddTaskViewControllerDelegate {
    func didUpdateTask() {
        // Default implementation is to call didAddNewTask
        didAddNewTask()
    }
}

class AddTaskViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AddTaskViewControllerDelegate?
    private let neumorphicBackgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1.0)
    private let accentColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0)
    private let titlePlaceholder = "Task title"
    private let detailsPlaceholder = "Task details (optional)"
    private var selectedPriority: PriorityLevel = .medium
    private var selectedCategory: String?
    private var selectedCategoryObject: NSManagedObject?
    private var selectedDate: Date?
    
    // Editing mode properties
    var isEditingTask: Bool = false
    var taskToEdit: NSManagedObject?
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let titleContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        textField.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        return textField
    }()
    
    private let detailsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let detailsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        return textView
    }()
    
    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Priority"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        return label
    }()
    
    private let prioritySegmentedControl: UISegmentedControl = {
        let items = PriorityLevel.allCases.map { $0.title }
        let segment = UISegmentedControl(items: items)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 1 // Medium by default
        segment.backgroundColor = UIColor.clear
        return segment
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Category"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        return label
    }()
    
    private let categoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Select category", for: .normal)
        button.setTitleColor(UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 1.0), for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Due Date"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        return label
    }()
    
    private let dateButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Set date", for: .normal)
        button.setTitleColor(UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 1.0), for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save Task", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0)
        button.layer.cornerRadius = 25
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupScrollView()
        setupTitleField()
        setupDetailsField()
        setupPrioritySection()
        setupCategorySection()
        setupDateSection()
        setupSaveButton()
        setupGestureRecognizers()
        setupTextViewDelegate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyNeumorphicStyles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = neumorphicBackgroundColor
        title = "Add Task"
    }
    
    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        cancelButton.tintColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        navigationItem.leftBarButtonItem = cancelButton
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = accentColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor
        )
        
        contentView.anchor(
            top: scrollView.topAnchor,
            leading: scrollView.leadingAnchor,
            bottom: scrollView.bottomAnchor,
            trailing: scrollView.trailingAnchor,
            width: view.frame.width
        )
        
        // Ensure content view height is at least as tall as the scroll view
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
    }
    
    private func setupTitleField() {
        contentView.addSubview(titleContainer)
        titleContainer.addSubview(titleTextField)
        
        titleContainer.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 24,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 60
        )
        
        titleTextField.anchor(
            top: titleContainer.topAnchor,
            leading: titleContainer.leadingAnchor,
            bottom: titleContainer.bottomAnchor,
            trailing: titleContainer.trailingAnchor,
            paddingTop: 0,
            paddingLeading: 20,
            paddingBottom: 0,
            paddingTrailing: 20
        )
        
        titleTextField.placeholder = titlePlaceholder
    }
    
    private func setupDetailsField() {
        contentView.addSubview(detailsContainer)
        detailsContainer.addSubview(detailsTextView)
        
        detailsContainer.anchor(
            top: titleContainer.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 20,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 120
        )
        
        detailsTextView.anchor(
            top: detailsContainer.topAnchor,
            leading: detailsContainer.leadingAnchor,
            bottom: detailsContainer.bottomAnchor,
            trailing: detailsContainer.trailingAnchor,
            paddingTop: 10,
            paddingLeading: 16,
            paddingBottom: 10,
            paddingTrailing: 16
        )
        
        detailsTextView.text = detailsPlaceholder
        detailsTextView.textColor = UIColor(red: 160/255, green: 170/255, blue: 180/255, alpha: 1.0)
    }
    
    private func setupPrioritySection() {
        contentView.addSubviews(priorityLabel, prioritySegmentedControl)
        
        priorityLabel.anchor(
            top: detailsContainer.bottomAnchor,
            leading: contentView.leadingAnchor,
            paddingTop: 24,
            paddingLeading: 24
        )
        
        prioritySegmentedControl.anchor(
            top: priorityLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 12,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 44
        )
        
        prioritySegmentedControl.addTarget(self, action: #selector(priorityChanged), for: .valueChanged)
    }
    
    private func setupCategorySection() {
        contentView.addSubviews(categoryLabel, categoryButton)
        
        categoryLabel.anchor(
            top: prioritySegmentedControl.bottomAnchor,
            leading: contentView.leadingAnchor,
            paddingTop: 24,
            paddingLeading: 24
        )
        
        categoryButton.anchor(
            top: categoryLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 12,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 44
        )
        
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
    }
    
    private func setupDateSection() {
        contentView.addSubviews(dateLabel, dateButton)
        
        dateLabel.anchor(
            top: categoryButton.bottomAnchor,
            leading: contentView.leadingAnchor,
            paddingTop: 24,
            paddingLeading: 24
        )
        
        dateButton.anchor(
            top: dateLabel.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 12,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 44
        )
        
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
    }
    
    private func setupSaveButton() {
        contentView.addSubview(saveButton)
        
        saveButton.anchor(
            top: dateButton.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 40,
            paddingLeading: 20,
            paddingBottom: 40,
            paddingTrailing: 20,
            height: 50
        )
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextViewDelegate() {
        detailsTextView.delegate = self
    }
    
    private func applyNeumorphicStyles() {
        // Title container
        titleContainer.addNeumorphicEffect(
            cornerRadius: 15,
            backgroundColor: neumorphicBackgroundColor
        )
        
        // Details container
        detailsContainer.addNeumorphicEffect(
            cornerRadius: 15,
            backgroundColor: neumorphicBackgroundColor
        )
        
        // Add neumorphic effect to segmented control
        prioritySegmentedControl.backgroundColor = neumorphicBackgroundColor
        prioritySegmentedControl.layer.cornerRadius = 10
        
        // Use system colors for priority with transparency
        prioritySegmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 160/255, green: 170/255, blue: 180/255, alpha: 1.0)
        ], for: .normal)
        
        prioritySegmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white
        ], for: .selected)
        
        // Set the background color of the selected segment
        let selectedPriorityColor = PriorityLevel(rawValue: Int16(prioritySegmentedControl.selectedSegmentIndex)) ?? .medium
        prioritySegmentedControl.selectedSegmentTintColor = selectedPriorityColor.color
        
        // Category button
        categoryButton.addNeumorphicEffect(
            cornerRadius: 15,
            backgroundColor: neumorphicBackgroundColor
        )
        
        // Date button
        dateButton.addNeumorphicEffect(
            cornerRadius: 15,
            backgroundColor: neumorphicBackgroundColor
        )
        
        // Save button
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        saveButton.layer.shadowOpacity = 0.2
        saveButton.layer.shadowRadius = 5
        
        // Add inner highlight
        let innerGlow = CAGradientLayer()
        innerGlow.frame = CGRect(x: 0, y: 0, width: saveButton.bounds.width, height: saveButton.bounds.height)
        innerGlow.cornerRadius = 25
        innerGlow.colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor
        ]
        innerGlow.startPoint = CGPoint(x: 0, y: 0)
        innerGlow.endPoint = CGPoint(x: 1, y: 1)
        innerGlow.locations = [0.0, 0.5]
        
        // Remove existing inner glow if any
        if let sublayers = saveButton.layer.sublayers {
            for layer in sublayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        // Add new inner glow
        saveButton.layer.insertSublayer(innerGlow, at: 0)
    }
    
    // MARK: - Core Data
    private func fetchCategories() -> [(name: String, object: NSManagedObject)] {
        let context = CoreDataManager.shared.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.map { (name: $0.value(forKey: "name") as? String ?? "Unnamed", object: $0) }
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    private func saveTask() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "Error", message: "Please enter a task title")
            return
        }
        
        let context = CoreDataManager.shared.viewContext
        
        // Create or update task
        if isEditingTask, let taskToEdit = taskToEdit {
            // Update existing task
            taskToEdit.setValue(title, forKey: "title")
            taskToEdit.setValue(
                detailsTextView.text == detailsPlaceholder ? nil : detailsTextView.text,
                forKey: "details"
            )
            taskToEdit.setValue(selectedDate, forKey: "dueDate")
            taskToEdit.setValue(Int16(selectedPriority.rawValue), forKey: "priorityLevel")
            taskToEdit.setValue(selectedCategoryObject, forKey: "category")
            
            // Notify delegate of update
            delegate?.didUpdateTask()
        } else {
            // Create new task
            let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)!
            let task = NSManagedObject(entity: entity, insertInto: context)
            
            // Set properties
            task.setValue(UUID(), forKey: "id")
            task.setValue(title, forKey: "title")
            task.setValue(
                detailsTextView.text == detailsPlaceholder ? nil : detailsTextView.text,
                forKey: "details"
            )
            task.setValue(selectedDate, forKey: "dueDate")
            task.setValue(Date(), forKey: "createdAt")
            task.setValue(false, forKey: "isCompleted")
            task.setValue(Int16(selectedPriority.rawValue), forKey: "priorityLevel")
            task.setValue(selectedCategoryObject, forKey: "category")
            
            // Notify delegate of new task
            delegate?.didAddNewTask()
        }
        
        // Save context
        do {
            try context.save()
            
            // Add haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Notify of data change
            NotificationCenter.default.post(name: NSNotification.Name("TaskDataChanged"), object: nil)
            
            // Dismiss
            dismiss(animated: true)
        } catch {
            print("Error saving task: \(error)")
            showAlert(title: "Error", message: "Failed to save task. Please try again.")
        }
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func priorityChanged(_ sender: UISegmentedControl) {
        selectedPriority = PriorityLevel(rawValue: Int16(sender.selectedSegmentIndex)) ?? .medium
        
        // Update the tint color based on selected priority
        prioritySegmentedControl.selectedSegmentTintColor = selectedPriority.color
        
        // Add haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    @objc private func categoryButtonTapped() {
        // Fetch categories from Core Data
        let categories = fetchCategories()
        
        if categories.isEmpty {
            // If there are no categories, create a new one
            presentCreateCategoryAlert()
            return
        }
        
        // Present category selection
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        
        // Add each category as an action
        for category in categories {
            let action = UIAlertAction(title: category.name, style: .default) { [weak self] _ in
                self?.selectedCategory = category.name
                self?.selectedCategoryObject = category.object
                self?.categoryButton.setTitle(category.name, for: .normal)
                self?.categoryButton.setTitleColor(UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0), for: .normal)
            }
            alert.addAction(action)
        }
        
        // Add option to create a new category
        alert.addAction(UIAlertAction(title: "Create New Category", style: .default) { [weak self] _ in
            self?.presentCreateCategoryAlert()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentCreateCategoryAlert() {
        let alert = UIAlertController(title: "New Category", message: "Enter a name for your category", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Category Name"
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let categoryName = textField.text,
                  !categoryName.isEmpty else { return }
            
            // Create category in Core Data
            let context = CoreDataManager.shared.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
            let category = NSManagedObject(entity: entity, insertInto: context)
            
            // Set properties
            category.setValue(UUID(), forKey: "id")
            category.setValue(categoryName, forKey: "name")
            category.setValue("#0A84FF", forKey: "colorHex") // Default color
            
            // Save context
            do {
                try context.save()
                
                // Update UI
                self.selectedCategory = categoryName
                self.selectedCategoryObject = category
                self.categoryButton.setTitle(categoryName, for: .normal)
                self.categoryButton.setTitleColor(UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0), for: .normal)
                
                // Add haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } catch {
                print("Error creating category: \(error)")
                self.showAlert(title: "Error", message: "Failed to create category. Please try again.")
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func dateButtonTapped() {
        // Create date picker view controller
        let datePickerVC = DatePickerViewController()
        datePickerVC.delegate = self
        datePickerVC.initialDate = selectedDate ?? Date()
        
        // Present date picker
        let navController = UINavigationController(rootViewController: datePickerVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        // Add animation
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.saveButton.transform = .identity
            }
        }
        
        // Save task to Core Data
        saveTask()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Public Methods
    func configureForEditing(with task: NSManagedObject) {
        // Set the task to edit
        self.taskToEdit = task
        self.isEditingTask = true
        
        // Update title
        self.title = "Edit Task"
        
        // Pre-fill fields
        titleTextField.text = task.value(forKey: "title") as? String
        
        if let details = task.value(forKey: "details") as? String, !details.isEmpty {
            detailsTextView.text = details
            detailsTextView.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        }
        
        // Set priority
        if let priorityLevel = task.value(forKey: "priorityLevel") as? Int16 {
            selectedPriority = PriorityLevel(rawValue: priorityLevel) ?? .medium
            prioritySegmentedControl.selectedSegmentIndex = Int(priorityLevel)
        }
        
        // Set category
        if let category = task.value(forKey: "category") as? NSManagedObject {
            selectedCategoryObject = category
            selectedCategory = category.value(forKey: "name") as? String
            
            categoryButton.setTitle(selectedCategory, for: .normal)
            categoryButton.setTitleColor(UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0), for: .normal)
        }
        
        // Set due date
        if let dueDate = task.value(forKey: "dueDate") as? Date {
            selectedDate = dueDate
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            
            dateButton.setTitle(formatter.string(from: dueDate), for: .normal)
            dateButton.setTitleColor(UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0), for: .normal)
        }
        
        // Change the save button title
        saveButton.setTitle("Update Task", for: .normal)
    }
}

// MARK: - UITextViewDelegate
extension AddTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == detailsPlaceholder {
            textView.text = ""
            textView.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = detailsPlaceholder
            textView.textColor = UIColor(red: 160/255, green: 170/255, blue: 180/255, alpha: 1.0)
        }
    }
}

// MARK: - DatePickerViewControllerDelegate
extension AddTaskViewController: DatePickerViewControllerDelegate {
    func didSelectDate(_ date: Date) {
        selectedDate = date
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        dateButton.setTitle(formatter.string(from: date), for: .normal)
        dateButton.setTitleColor(UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0), for: .normal)
    }
}
