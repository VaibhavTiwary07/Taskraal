//
//  AddTaskViewController.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 03/04/25.
//

import UIKit
import CoreData
import EventKit

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
    private let themeManager = ThemeManager.shared
    private let titlePlaceholder = "Task title"
    private let detailsPlaceholder = "Task details (optional)"
    private var selectedPriority: PriorityLevel = .medium
    private var selectedCategory: String?
    private var selectedCategoryObject: NSManagedObject?
    private var selectedDate: Date?
    
    // Cache categories to avoid repeated fetching
    private var cachedCategories: [(name: String, object: NSManagedObject)] = []
    
    // Editing mode properties
    var isEditingTask: Bool = false
    var taskToEdit: NSManagedObject?
    
    // Keyboard handling
    private var keyboardHeight: CGFloat = 0
    
    // Scheduling properties
    private let schedulingService = SchedulingService.shared
    private var integrateWithCalendar: Bool = false
    private var integrateWithReminders: Bool = false
    private var enableNotifications: Bool = false
    
    // Add property to store datePicker reference
    private var tempDatePicker: UIDatePicker?
    
    // MARK: - UI Elements
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private var contentView: UIView = {
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
        setupSchedulingSection()
        setupSaveButton()
        setupGestureRecognizers()
        setupTextViewDelegate()
        setupKeyboardObservers()
        
        // Fix scrollView issue by setting explicit content size
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: 1200)
        
        // Pre-fetch categories for smoother category selection
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.cachedCategories = self?.fetchCategories() ?? []
        }
        
        // Listen for theme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
        
        // Listen for scheduling permission changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSchedulingPermissionsChanged),
            name: SchedulingService.schedulingPermissionsChanged,
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyThemeAndStyles()
        recalculateScrollViewContentSize()
        
        // Update shadow paths when layout changes
        if titleContainer.bounds.size != .zero {
            titleContainer.layer.shadowPath = UIBezierPath(roundedRect: titleContainer.bounds, cornerRadius: 15).cgPath
        }
        
        if detailsContainer.bounds.size != .zero {
            detailsContainer.layer.shadowPath = UIBezierPath(roundedRect: detailsContainer.bounds, cornerRadius: 15).cgPath
        }
        
        if categoryButton.bounds.size != .zero {
            categoryButton.layer.shadowPath = UIBezierPath(roundedRect: categoryButton.bounds, cornerRadius: 15).cgPath
        }
        
        if dateButton.bounds.size != .zero {
            dateButton.layer.shadowPath = UIBezierPath(roundedRect: dateButton.bounds, cornerRadius: 15).cgPath
        }
        
        if saveButton.bounds.size != .zero {
            saveButton.layer.shadowPath = UIBezierPath(roundedRect: saveButton.bounds, cornerRadius: saveButton.layer.cornerRadius).cgPath
            
            // Also update the inner glow layer
            if let innerGlow = saveButton.layer.sublayers?.first as? CAGradientLayer {
                innerGlow.frame = saveButton.bounds
                innerGlow.cornerRadius = saveButton.layer.cornerRadius
            }
        }
        
        // Update all views with neumorphic effects
        view.updateNeumorphicShadowPaths()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Give time for layout to settle, then force proper content sizing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Force recalculation of content size
            self.recalculateScrollViewContentSize()
            
            // Ensure save button is visible
            let saveButtonFrame = self.saveButton.convert(self.saveButton.bounds, to: self.scrollView)
            let visible = self.scrollView.bounds.contains(saveButtonFrame) || 
                          self.scrollView.bounds.intersects(saveButtonFrame)
            
            if !visible {
                // Scroll to show the save button
                self.scrollView.scrollRectToVisible(CGRect(x: 0, y: self.scrollView.contentSize.height - 200, width: self.scrollView.bounds.width, height: 200), animated: true)
            }
            
            // Set initial focus to title field
            self.titleTextField.becomeFirstResponder()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = themeManager.backgroundColor
        title = isEditingTask ? "Edit Task" : "Add Task"
        setupNavigationBar()
        
        // Initialize integration options from user defaults
        integrateWithCalendar = schedulingService.calendarIntegrationEnabled
        integrateWithReminders = schedulingService.reminderIntegrationEnabled
        enableNotifications = schedulingService.notificationsEnabled
    }
    
    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        cancelButton.tintColor = themeManager.textColor
        navigationItem.leftBarButtonItem = cancelButton
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = themeManager.currentThemeColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: themeManager.textColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        // Modern appearance for iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = themeManager.backgroundColor
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: themeManager.textColor,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
            ]
            appearance.shadowColor = .clear
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
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
        
        // On iPad, center the content with a max width
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Create a width constraint that's either 600 points or 80% of the view width, whichever is smaller
            let maxWidth: CGFloat = min(600, view.bounds.width * 0.8)
            
            contentView.anchor(
                top: scrollView.topAnchor,
                width: maxWidth
            )
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        } else {
            // On iPhone, use full width
            contentView.anchor(
                top: scrollView.topAnchor,
                leading: scrollView.leadingAnchor,
                trailing: scrollView.trailingAnchor
            )
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
        
        // Set initial content size
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: 1200)
        
        // Enable scrolling features
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.delaysContentTouches = false
        scrollView.keyboardDismissMode = .interactive
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
            height: 50
        )
        
        // Enhance visual indication that button is tappable
        categoryButton.isUserInteractionEnabled = true
        categoryButton.backgroundColor = themeManager.containerBackgroundColor
        categoryButton.layer.cornerRadius = 15
        
        // Add right chevron icon to indicate it's tappable
        let chevronImage = UIImage(systemName: "chevron.right")
        
        // Modern approach replacing deprecated imageEdgeInsets
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = chevronImage
            config.imagePlacement = .trailing
            config.imagePadding = 10
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            config.titleAlignment = .leading
            categoryButton.configuration = config
            categoryButton.setTitle("Select category", for: .normal)
        } else {
            // Fallback for iOS 14 and earlier
            categoryButton.setImage(chevronImage, for: .normal)
            categoryButton.semanticContentAttribute = .forceRightToLeft
            categoryButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        
        categoryButton.tintColor = themeManager.secondaryTextColor
        
        // Add target action
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
            height: 50
        )
        
        // Enhance visual indication that button is tappable
        dateButton.isUserInteractionEnabled = true
        dateButton.backgroundColor = themeManager.containerBackgroundColor
        dateButton.layer.cornerRadius = 15
        
        // Add calendar icon to indicate it's tappable
        let calendarImage = UIImage(systemName: "calendar")
        
        // Modern approach replacing deprecated imageEdgeInsets
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = calendarImage
            config.imagePlacement = .trailing
            config.imagePadding = 10
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            config.titleAlignment = .leading
            dateButton.configuration = config
            dateButton.setTitle("Set date", for: .normal)
        } else {
            // Fallback for iOS 14 and earlier
            dateButton.setImage(calendarImage, for: .normal)
            dateButton.semanticContentAttribute = .forceRightToLeft
            dateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        
        dateButton.tintColor = themeManager.secondaryTextColor
        
        // Add target action
//        view.bringSubviewToFront(dateButton)
        dateButton.addTarget(self, action: #selector(datebutton2), for: .touchUpInside)
    }
    
    @objc private func datebutton2(){
        print("tapped datebutton")
    }
    private func setupSchedulingSection() {
        // Create container
        let schedulingContainer = UIView()
        schedulingContainer.translatesAutoresizingMaskIntoConstraints = false
        schedulingContainer.backgroundColor = themeManager.containerBackgroundColor
        schedulingContainer.layer.cornerRadius = 15
        
        contentView.addSubview(schedulingContainer)
        schedulingContainer.anchor(
            top: dateButton.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 20,
            paddingLeading: 20,
            paddingTrailing: 20
        )
        
        // Add a title label
        let schedulingLabel = UILabel()
        schedulingLabel.translatesAutoresizingMaskIntoConstraints = false
        schedulingLabel.text = "Scheduling & Reminders"
        schedulingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        schedulingLabel.textColor = themeManager.textColor
        
        // Create switches for integration options
        let calendarSwitch = createToggleRow(title: "Add to Calendar", isOn: integrateWithCalendar)
        let remindersSwitch = createToggleRow(title: "Create Reminder", isOn: integrateWithReminders)
        let notificationSwitch = createToggleRow(title: "Enable Notifications", isOn: enableNotifications)
        
        // Add components to container
        schedulingContainer.addSubviews(schedulingLabel, calendarSwitch.container, remindersSwitch.container, notificationSwitch.container)
        
        // Layout
        schedulingLabel.anchor(
            top: schedulingContainer.topAnchor,
            leading: schedulingContainer.leadingAnchor,
            paddingTop: 16,
            paddingLeading: 16
        )
        
        calendarSwitch.container.anchor(
            top: schedulingLabel.bottomAnchor,
            leading: schedulingContainer.leadingAnchor,
            trailing: schedulingContainer.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingTrailing: 16,
            height: 40
        )
        
        remindersSwitch.container.anchor(
            top: calendarSwitch.container.bottomAnchor,
            leading: schedulingContainer.leadingAnchor,
            trailing: schedulingContainer.trailingAnchor,
            paddingTop: 8,
            paddingLeading: 16,
            paddingTrailing: 16,
            height: 40
        )
        
        notificationSwitch.container.anchor(
            top: remindersSwitch.container.bottomAnchor,
            leading: schedulingContainer.leadingAnchor,
            bottom: schedulingContainer.bottomAnchor, trailing: schedulingContainer.trailingAnchor,
            paddingTop: 8,
            paddingLeading: 16,
            paddingBottom: 16, paddingTrailing: 16,
            height: 40
        )
        
        // Add actions
        calendarSwitch.toggle.addTarget(self, action: #selector(calendarSwitchChanged(_:)), for: .valueChanged)
        remindersSwitch.toggle.addTarget(self, action: #selector(remindersSwitchChanged(_:)), for: .valueChanged)
        notificationSwitch.toggle.addTarget(self, action: #selector(notificationSwitchChanged(_:)), for: .valueChanged)
        
        // Add neumorphic effect
        schedulingContainer.addNeumorphicEffect(
            cornerRadius: 15,
            backgroundColor: themeManager.containerBackgroundColor
        )
    }
    
    private func createToggleRow(title: String, isOn: Bool) -> (container: UIView, label: UILabel, toggle: UISwitch) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = themeManager.textColor
        
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = isOn
        toggle.onTintColor = themeManager.currentThemeColor
        
        container.addSubviews(label, toggle)
        
        label.anchor(
            leading: container.leadingAnchor
        )
        label.centerY(in: container)
        
        toggle.anchor(
            trailing: container.trailingAnchor
        )
        toggle.centerY(in: container)
        
        return (container, label, toggle)
    }
    
    @objc private func calendarSwitchChanged(_ sender: UISwitch) {
        if sender.isOn && !schedulingService.calendarIntegrationEnabled {
            // Request calendar access if not already granted
            schedulingService.requestCalendarAccess { [weak self] granted in
                DispatchQueue.main.async {
                    sender.isOn = granted
                    self?.integrateWithCalendar = granted
                    
                    if !granted {
                        self?.showPermissionAlert(for: "Calendar")
                    }
                }
            }
        } else {
            integrateWithCalendar = sender.isOn
        }
    }
    
    @objc private func remindersSwitchChanged(_ sender: UISwitch) {
        if sender.isOn && !schedulingService.reminderIntegrationEnabled {
            // Request reminders access if not already granted
            schedulingService.requestRemindersAccess { [weak self] granted in
                DispatchQueue.main.async {
                    sender.isOn = granted
                    self?.integrateWithReminders = granted
                    
                    if !granted {
                        self?.showPermissionAlert(for: "Reminders")
                    }
                }
            }
        } else {
            integrateWithReminders = sender.isOn
        }
    }
    
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        if sender.isOn && !schedulingService.notificationsEnabled {
            // Request notification permission if not already granted
            schedulingService.requestNotificationPermission { [weak self] granted in
                DispatchQueue.main.async {
                    sender.isOn = granted
                    self?.enableNotifications = granted
                    
                    if !granted {
                        self?.showPermissionAlert(for: "Notifications")
                    }
                }
            }
        } else {
            enableNotifications = sender.isOn
        }
    }
    
    private func showPermissionAlert(for service: String) {
        let alert = UIAlertController(
            title: "\(service) Access Denied",
            message: "Please enable \(service) access in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func handleSchedulingPermissionsChanged() {
        // Update switches based on current permissions
        integrateWithCalendar = schedulingService.calendarIntegrationEnabled
        integrateWithReminders = schedulingService.reminderIntegrationEnabled
        enableNotifications = schedulingService.notificationsEnabled
        
        // Force layout refresh
        view.setNeedsLayout()
    }
    
    private func applyThemeAndStyles() {
        // Use ThemeManager to update colors consistently
        view.backgroundColor = themeManager.backgroundColor
        
        // Update navigation bar
        themeManager.applyThemeToNavigationBar(navigationController)
        
        // Update text field colors
        titleTextField.textColor = themeManager.textColor
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: titlePlaceholder,
            attributes: [NSAttributedString.Key.foregroundColor: themeManager.secondaryTextColor]
        )
        
        // Update text view based on state
        if detailsTextView.text == detailsPlaceholder {
            detailsTextView.textColor = themeManager.secondaryTextColor
        } else {
            detailsTextView.textColor = themeManager.textColor
        }
        
        // Update labels
        priorityLabel.textColor = themeManager.textColor
        categoryLabel.textColor = themeManager.textColor
        dateLabel.textColor = themeManager.textColor
        
        // Update buttons based on state
        if categoryButton.title(for: .normal) == "Select category" {
            categoryButton.setTitleColor(themeManager.secondaryTextColor, for: .normal)
        } else {
            categoryButton.setTitleColor(themeManager.textColor, for: .normal)
        }
        
        if dateButton.title(for: .normal) == "Set date" {
            dateButton.setTitleColor(themeManager.secondaryTextColor, for: .normal)
        } else {
            dateButton.setTitleColor(themeManager.textColor, for: .normal)
        }
        
        // Clean up existing neumorphic effects
        [titleContainer, detailsContainer, categoryButton, dateButton].forEach { view in
            view.subviews.forEach { subview in
                if subview.tag == 1001 || subview.tag == 1002 {
                    subview.removeFromSuperview()
                }
            }
        }
        
        // Apply optimized styles to containers
        titleContainer.backgroundColor = themeManager.containerBackgroundColor
        titleContainer.layer.cornerRadius = 15
        titleContainer.layer.shadowColor = UIColor.black.cgColor
        titleContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        titleContainer.layer.shadowOpacity = 0.1
        titleContainer.layer.shadowRadius = 4
        titleContainer.layer.shadowPath = UIBezierPath(roundedRect: titleContainer.bounds, cornerRadius: 15).cgPath
        
        detailsContainer.backgroundColor = themeManager.containerBackgroundColor
        detailsContainer.layer.cornerRadius = 15
        detailsContainer.layer.shadowColor = UIColor.black.cgColor
        detailsContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        detailsContainer.layer.shadowOpacity = 0.1
        detailsContainer.layer.shadowRadius = 4
        detailsContainer.layer.shadowPath = UIBezierPath(roundedRect: detailsContainer.bounds, cornerRadius: 15).cgPath
        
        // Update segmented control
        prioritySegmentedControl.backgroundColor = themeManager.containerBackgroundColor
        prioritySegmentedControl.setTitleTextAttributes([
            .foregroundColor: themeManager.secondaryTextColor
        ], for: .normal)
        prioritySegmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white
        ], for: .selected)
        
        // Set the background color of the selected segment
        let selectedPriorityColor = PriorityLevel(rawValue: Int16(prioritySegmentedControl.selectedSegmentIndex)) ?? .medium
        prioritySegmentedControl.selectedSegmentTintColor = selectedPriorityColor.color
        
        // Apply optimized styles to buttons
        categoryButton.backgroundColor = themeManager.containerBackgroundColor
        categoryButton.layer.cornerRadius = 15
        categoryButton.layer.shadowColor = UIColor.black.cgColor
        categoryButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        categoryButton.layer.shadowOpacity = 0.1
        categoryButton.layer.shadowRadius = 4
        categoryButton.layer.shadowPath = UIBezierPath(roundedRect: categoryButton.bounds, cornerRadius: 15).cgPath
        
        dateButton.backgroundColor = themeManager.containerBackgroundColor
        dateButton.layer.cornerRadius = 15
        dateButton.layer.shadowColor = UIColor.black.cgColor
        dateButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        dateButton.layer.shadowOpacity = 0.1
        dateButton.layer.shadowRadius = 4
        dateButton.layer.shadowPath = UIBezierPath(roundedRect: dateButton.bounds, cornerRadius: 15).cgPath
        
        // Update save button
        saveButton.backgroundColor = themeManager.currentThemeColor
        
        // Refresh save button appearance with optimized shadows
        updateSaveButtonAppearance()
    }
    
    @objc private func handleThemeChanged() {
        // Apply the new theme with optimized rendering
        applyThemeAndStyles()
        
        // Force layout update to ensure shadow paths are correct
        view.layoutIfNeeded()
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
        var createdTask: NSManagedObject? = nil
        
        // Create or update task
        if isEditingTask, let taskToEdit = taskToEdit {
            // First remove any existing integrations
            schedulingService.removeAllIntegrations(for: taskToEdit)
            
            // Update existing task
            taskToEdit.setValue(title, forKey: "title")
            taskToEdit.setValue(
                detailsTextView.text == detailsPlaceholder ? nil : detailsTextView.text,
                forKey: "details"
            )
            taskToEdit.setValue(selectedDate, forKey: "dueDate")
            taskToEdit.setValue(Int16(selectedPriority.rawValue), forKey: "priorityLevel")
            taskToEdit.setValue(selectedCategoryObject, forKey: "category")
            
            createdTask = taskToEdit
            
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
            
            createdTask = task
            
            // Notify delegate of new task
            delegate?.didAddNewTask()
        }
        
        // Save context
        do {
            try context.save()
            
            // Create integrations if due date is set
            if let task = createdTask, selectedDate != nil {
                // Update scheduling service settings based on user choices
                if integrateWithCalendar && !schedulingService.calendarIntegrationEnabled {
                    schedulingService.toggleCalendarIntegration(true) { _ in }
                }
                
                if integrateWithReminders && !schedulingService.reminderIntegrationEnabled {
                    schedulingService.toggleReminderIntegration(true) { _ in }
                }
                
                if enableNotifications && !schedulingService.notificationsEnabled {
                    schedulingService.toggleNotifications(true) { _ in }
                }
                
                // Set up integrations based on user choices
                var activeIntegrations: [String: Bool] = [:]
                
                if integrateWithCalendar {
                    activeIntegrations["calendar"] = true
                }
                
                if integrateWithReminders {
                    activeIntegrations["reminders"] = true
                }
                
                if enableNotifications {
                    activeIntegrations["notifications"] = true
                }
                
                if !activeIntegrations.isEmpty {
                    // Show loading indicator
                    let loadingAlert = UIAlertController(title: "Setting Up Integrations", message: "Please wait...", preferredStyle: .alert)
                    present(loadingAlert, animated: true)
                    
                    schedulingService.setupAllIntegrations(for: task) { success, messages in
                        DispatchQueue.main.async {
                            // Dismiss loading indicator
                            loadingAlert.dismiss(animated: true) {
                                // Show success/failure message if needed
                                if !success && !messages.isEmpty {
                                    self.showAlert(title: "Integration Issues", message: messages.joined(separator: "\n"))
                                }
                                
                                // Dismiss the view controller
                                self.dismiss(animated: true)
                            }
                        }
                    }
                    return // Early return to wait for completion
                }
            }
            
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
        // First dismiss keyboard if showing
        view.endEditing(true)
        
        // Add tap feedback animation
        UIView.animate(withDuration: 0.1, animations: {
            self.categoryButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.categoryButton.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.categoryButton.transform = .identity
                self.categoryButton.alpha = 1.0
            }
        }
        
        // Add haptic feedback
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        
        print("DEBUG: Category button tapped - presenting category selection")
        
        // Use cached categories or load them now
        var categories = self.cachedCategories
        
        if categories.isEmpty {
            // Show loading state
            categoryButton.setTitle("Loading categories...", for: .normal)
            
            // Immediately fetch categories
            categories = fetchCategories()
            self.cachedCategories = categories
        }
        
        if categories.isEmpty {
            // Create a default category if none exist
            createDefaultCategory()
            return
        }
        
        // Create alert controller with appropriate style based on device
        let alertStyle: UIAlertController.Style = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: alertStyle)
        
        // Add menu actions
        for category in categories {
            let action = UIAlertAction(title: category.name, style: .default) { [weak self] _ in
                print("DEBUG: Selected category: \(category.name)")
                self?.selectCategory(name: category.name, object: category.object)
            }
            alert.addAction(action)
        }
        
        // Add option to create a new category
        alert.addAction(UIAlertAction(title: "Create New Category", style: .default) { [weak self] _ in
            print("DEBUG: Create new category selected")
            self?.presentCreateCategoryAlert()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad, set the source view for the popover
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = categoryButton
                popoverController.sourceRect = categoryButton.bounds
                popoverController.permittedArrowDirections = .any
            }
        }
        
        // Present the alert
        present(alert, animated: true) {
            print("DEBUG: Category selection presented successfully")
        }
    }
    
    private func createCategoryMenuActions() -> [UIAction] {
        var actions = [UIAction]()
        
        // Add action for each existing category
        for category in cachedCategories {
            let action = UIAction(title: category.name) { [weak self] _ in
                guard let self = self else { return }
                self.selectCategory(name: category.name, object: category.object)
            }
            actions.append(action)
        }
        
        // Add create new category action
        let createAction = UIAction(title: "Create New Category") { [weak self] _ in
            self?.presentCreateCategoryAlert()
        }
        actions.append(createAction)
        
        return actions
    }
    
    private func selectCategory(name: String, object: NSManagedObject) {
        // Update with animation
        UIView.transition(with: self.categoryButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.selectedCategory = name
            self.selectedCategoryObject = object
            self.categoryButton.setTitle(name, for: .normal)
            self.categoryButton.setTitleColor(self.themeManager.textColor, for: .normal)
        })
        
        // Add subtle haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    private func createDefaultCategory() {
        print("Creating default category since none exist")
        
        // Show loading state
        UIView.transition(with: self.categoryButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.categoryButton.setTitle("Creating default category...", for: .normal)
        })
        
        // Create category in Core Data
        let context = CoreDataManager.shared.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
        let category = NSManagedObject(entity: entity, insertInto: context)
        
        // Set properties
        let defaultName = "General"
        category.setValue(UUID(), forKey: "id")
        category.setValue(defaultName, forKey: "name")
        category.setValue("#0A84FF", forKey: "colorHex") // Default color
        
        // Save context
        do {
            try context.save()
            
            // Update cached categories
            self.cachedCategories.append((name: defaultName, object: category))
            
            // Update UI
            selectCategory(name: defaultName, object: category)
        } catch {
            print("Error creating default category: \(error)")
            
            // Reset button state
            UIView.transition(with: self.categoryButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.categoryButton.setTitle("Select category", for: .normal)
                self.categoryButton.setTitleColor(self.themeManager.secondaryTextColor, for: .normal)
            })
        }
    }
    
    @objc private func dateButtonTapped() {
        // First dismiss keyboard if showing
        print("DEBUG: Date button tapped - presenting date picker")
        view.endEditing(true)
        
        // Add tap feedback animation
        UIView.animate(withDuration: 0.1, animations: {
            self.dateButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            self.dateButton.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.dateButton.transform = .identity
                self.dateButton.alpha = 1.0
            }
        }
        
        // Add haptic feedback
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        
        
        
        // Show loading state with animation
        UIView.transition(with: dateButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.dateButton.setTitle("Opening date picker...", for: .normal)
        })
        
        // Create a date picker view controller for better UX
        let datePickerVC = DatePickerViewController()
        datePickerVC.delegate = self
        datePickerVC.initialDate = selectedDate ?? Date()
        
        let navController = UINavigationController(rootViewController: datePickerVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true) {
            // Reset button text if needed
            if self.selectedDate == nil {
                self.dateButton.setTitle("Set date", for: .normal)
            }
        }
    }
    
    // Helper method to format date consistently
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    @objc private func saveButtonTapped() {
        // First dismiss keyboard if showing
        view.endEditing(true)
        
        // Add animation
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.saveButton.transform = .identity
            }
        }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
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
    
    func preSelectCategory(_ category: NSManagedObject) {
        // Pre-select the category for a new task
        selectedCategoryObject = category
        selectedCategory = category.value(forKey: "name") as? String
        
        // Make sure UI is updated when the view appears
        let updateUI = { [weak self] in
            guard let self = self else { return }
            if let categoryName = self.selectedCategory {
                UIView.transition(with: self.categoryButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.categoryButton.setTitle(categoryName, for: .normal)
                    self.categoryButton.setTitleColor(self.themeManager.textColor, for: .normal)
                })
            }
        }
        
        // If the view is already loaded, update immediately
        if isViewLoaded {
            updateUI()
        } else {
            // Otherwise, update when the view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                updateUI()
            }
        }
    }
    
    private func presentCreateCategoryAlert() {
        // Show alert for creating a new category
        let alert = UIAlertController(title: "New Category", message: "Enter a name for your category", preferredStyle: .alert)
        
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Category Name"
            textField.autocapitalizationType = .words
            textField.returnKeyType = .done
            textField.textColor = self?.themeManager.textColor
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let categoryName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !categoryName.isEmpty else { return }
            
            // Show loading state
            UIView.transition(with: self.categoryButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.categoryButton.setTitle("Creating...", for: .normal)
            })
            
            // Create category
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
                
                // Update cached categories
                self.cachedCategories.append((name: categoryName, object: category))
                
                // Update UI
                self.selectCategory(name: categoryName, object: category)
                
                // Add haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } catch {
                print("Error creating category: \(error)")
                
                // Reset button state
                UIView.transition(with: self.categoryButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.categoryButton.setTitle("Select category", for: .normal)
                    self.categoryButton.setTitleColor(self.themeManager.secondaryTextColor, for: .normal)
                })
                
                // Show error alert
                self.showAlert(title: "Error", message: "Failed to create category. Please try again.")
            }
        }
        
        alert.addAction(createAction)
        alert.preferredAction = createAction
        
        present(alert, animated: true) {
            // Focus the text field
            alert.textFields?.first?.becomeFirstResponder()
        }
    }
    
    // Add this method to handle save button appearance consistently
    private func updateSaveButtonAppearance() {
        // Update shadows with shadowPath for better performance
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        saveButton.layer.shadowOpacity = 0.3
        saveButton.layer.shadowRadius = 5
        
        // Create explicit shadowPath for better performance
        if saveButton.bounds.size != .zero {
            let shadowPath = UIBezierPath(roundedRect: saveButton.bounds, cornerRadius: saveButton.layer.cornerRadius)
            saveButton.layer.shadowPath = shadowPath.cgPath
        }
        
        // Remove existing inner glow if any
        saveButton.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        // Add inner highlight
        let innerGlow = CAGradientLayer()
        innerGlow.frame = saveButton.bounds
        innerGlow.cornerRadius = saveButton.layer.cornerRadius
        innerGlow.colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor
        ]
        innerGlow.startPoint = CGPoint(x: 0, y: 0)
        innerGlow.endPoint = CGPoint(x: 1, y: 1)
        innerGlow.locations = [0.0, 0.5]
        
        // Add new inner glow
        saveButton.layer.insertSublayer(innerGlow, at: 0)
    }
    
    private func setupSaveButton() {
        contentView.addSubview(saveButton)
        
        saveButton.anchor(
            top: contentView.subviews.last?.bottomAnchor ?? dateButton.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            paddingTop: 40,
            paddingLeading: 20,
            paddingTrailing: 20,
            height: 60
        )
        
        // Add bottom constraint with padding
        saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40).isActive = true
        
        // Make the button more easily tappable
        saveButton.isUserInteractionEnabled = true
        saveButton.layer.cornerRadius = 30
        
        // Add target action
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextViewDelegate() {
        detailsTextView.delegate = self
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        self.keyboardHeight = keyboardHeight
        
        // Adjust scroll view insets using modern API
        scrollView.contentInset.bottom = keyboardHeight + 20 // Add extra padding
        
        // Use modern APIs for scrollIndicatorInsets
        if #available(iOS 13.0, *) {
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 20
        } else {
            // Fallback for iOS 12 and earlier
            scrollView.scrollIndicatorInsets.bottom = keyboardHeight + 20
        }
        
        // Find which view is active
        var activeView: UIView?
        if titleTextField.isFirstResponder {
            activeView = titleContainer
        } else if detailsTextView.isFirstResponder {
            activeView = detailsContainer
        }
        
        // If we found an active view, scroll to it
        if let activeView = activeView {
            // Calculate the position of the view in the scroll view
            let rect = scrollView.convert(activeView.frame, from: activeView.superview)
            
            // Create a rect that includes the view and some padding
            let visibleRect = CGRect(
                x: rect.origin.x,
                y: rect.origin.y,
                width: rect.width,
                height: rect.height + 40 // Add more padding
            )
            
            // Calculate if the keyboard would cover this view
            let frameInWindow = activeView.convert(activeView.bounds, to: nil)
            let keyboardTop = UIScreen.main.bounds.height - keyboardHeight
            
            if frameInWindow.maxY > keyboardTop {
                // Scroll to make the view visible above the keyboard
                scrollView.scrollRectToVisible(visibleRect, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        // Reset content inset
        scrollView.contentInset.bottom = 0
        
        // Use modern APIs for scrollIndicatorInsets
        if #available(iOS 13.0, *) {
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        } else {
            // Fallback for iOS 12 and earlier
            scrollView.scrollIndicatorInsets.bottom = 0
        }
        
        self.keyboardHeight = 0
    }
    
    // Helper method to recalculate content size
    private func recalculateScrollViewContentSize() {
        // Find the bottom-most view in the contentView
        var maxY: CGFloat = 0
        
        for subview in contentView.subviews {
            let subviewMaxY = subview.frame.maxY
            if subviewMaxY > maxY {
                maxY = subviewMaxY
            }
        }
        
        // Add extra padding to ensure the save button is well above the bottom
        maxY += 100
        
        // Ensure content size is at least as tall as the scrollView frame plus extra
        let minHeight = scrollView.frame.height + 200
        let newHeight = max(maxY, minHeight)
        
        // Update content size
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: newHeight)
        
        // Always enable scrolling
        scrollView.isScrollEnabled = true
        
        print("DEBUG: ScrollView content size updated to height: \(newHeight)")
    }
    
    // Helper function to improve logging for debugging
    private func logViewHierarchy() {
        print("DEBUG: Scrollview frame: \(scrollView.frame), contentSize: \(scrollView.contentSize)")
        print("DEBUG: ContentView frame: \(contentView.frame)")
        
        // Log all contentView subviews
        for (index, subview) in contentView.subviews.enumerated() {
            print("DEBUG: Subview \(index): \(type(of: subview)), frame: \(subview.frame)")
        }
    }
    
    // Function to enable/disable scrolling (useful for debugging)
    private func setScrollingEnabled(_ enabled: Bool) {
        scrollView.isScrollEnabled = enabled
        if enabled {
            print("DEBUG: Scrolling enabled")
        } else {
            print("DEBUG: Scrolling disabled")
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Ensure proper size after rotation or initial layout
        DispatchQueue.main.async {
            self.recalculateScrollViewContentSize()
        }
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
        
        // Update button with animation
        UIView.transition(with: dateButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.dateButton.setTitle(self.formatDate(date), for: .normal)
            self.dateButton.setTitleColor(self.themeManager.textColor, for: .normal)
        })
        
        // Add subtle haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// Override viewWillLayoutSubviews to ensure proper content sizing
