//
//  TaskCell.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 03/04/25.
//

import UIKit

class TaskCell: UITableViewCell {
    
    // MARK: - Constants
    static let identifier = "TaskCell"
    private let themeManager = ThemeManager.shared
    
    // Cache formatters for better performance
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let taskNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private let priorityIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let checkboxButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    private var isCompleted: Bool = false {
        didSet {
            updateCheckboxState()
        }
    }
    
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
        
        // Update shadow paths whenever layout changes
        if containerView.layer.shadowOpacity > 0 {
            containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 16).cgPath
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Clean up any existing effects to prevent memory leaks
        cleanupNeumorphicEffects()
        
        // Reset state
        isCompleted = false
        
        // Don't apply styles here - defer until configuration
    }
    
    // MARK: - Setup
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Add and configure UI elements
        contentView.addSubviews(containerView)
        containerView.addSubviews(checkboxButton, taskNameLabel, categoryLabel, dueDateLabel, priorityIndicator)
        
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
        
        checkboxButton.anchor(
            leading: containerView.leadingAnchor,
            paddingLeading: 16,
            width: 24,
            height: 24
        )
        checkboxButton.centerY(in: containerView)
        
        // Fix ambiguous height by adding explicit height constraints
        taskNameLabel.anchor(
            top: containerView.topAnchor,
            leading: checkboxButton.trailingAnchor,
            trailing: priorityIndicator.leadingAnchor,
            paddingTop: 14,
            paddingLeading: 12,
            paddingTrailing: 12,
            height: 22
        )
        
        categoryLabel.anchor(
            top: taskNameLabel.bottomAnchor,
            leading: taskNameLabel.leadingAnchor,
            trailing: taskNameLabel.trailingAnchor,
            paddingTop: 4,
            height: 20
        )
        
        dueDateLabel.anchor(
            top: categoryLabel.bottomAnchor,
            leading: taskNameLabel.leadingAnchor,
            bottom: containerView.bottomAnchor,
            paddingTop: 4,
            paddingBottom: 14,
            height: 18
        )
        
        priorityIndicator.anchor(
            trailing: containerView.trailingAnchor,
            paddingTrailing: 16,
            width: 12,
            height: 12
        )
        priorityIndicator.centerY(in: containerView)
        
        // Add button target
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
    }
    
    private func applyThemeAndStyles() {
        // Clean up existing neumorphic effects
        cleanupNeumorphicEffects()
        
        // Set background color
        containerView.backgroundColor = themeManager.backgroundColor
        containerView.layer.cornerRadius = 16
        
        // Update text colors based on state
        categoryLabel.textColor = themeManager.secondaryTextColor
        dueDateLabel.textColor = themeManager.secondaryTextColor
        
        // Update completion status (which handles taskNameLabel styling)
        updateCheckboxState()
        
        // Apply optimized shadow rendering
        if isCompleted {
            // For completed tasks, use subtle border
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = themeManager.secondaryTextColor.withAlphaComponent(0.2).cgColor
            containerView.layer.shadowOpacity = 0
        } else {
            // For incomplete tasks, use shadow with explicit path
            containerView.layer.borderWidth = 0
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.shadowRadius = 4
            
            // Add shadow path for better performance
            let shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 16).cgPath
            containerView.layer.shadowPath = shadowPath
        }
        
        // Apply optimized style to checkbox
        checkboxButton.layer.cornerRadius = 12
        
        if isCompleted {
            checkboxButton.backgroundColor = themeManager.currentThemeColor
            checkboxButton.layer.borderWidth = 0
        } else {
            checkboxButton.backgroundColor = themeManager.backgroundColor
            checkboxButton.layer.borderWidth = 1
            checkboxButton.layer.borderColor = themeManager.secondaryTextColor.withAlphaComponent(0.3).cgColor
        }
    }
    
    // MARK: - Action
    @objc private func checkboxTapped() {
        isCompleted.toggle()
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Add animation
        UIView.animate(withDuration: 0.3, animations: {
            self.checkboxButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.checkboxButton.transform = .identity
                
                // Completely rebuild the cell appearance
                self.cleanupNeumorphicEffects()
                self.applyThemeAndStyles()
            }
        }
    }
    
    @objc private func handleThemeChanged() {
        // Apply optimized styling
        applyThemeAndStyles()
    }
    
    // Helper method to clean up neumorphic effects
    private func cleanupNeumorphicEffects() {
        // Remove existing visual effects
        containerView.layer.shadowOpacity = 0
        containerView.layer.borderWidth = 0
        checkboxButton.layer.borderWidth = 0
        
        // Remove any existing neumorphic view subviews by tag
        contentView.subviews.forEach { subview in
            if subview.tag == 1001 || subview.tag == 1002 || subview.tag == 2001 {
                subview.removeFromSuperview()
            }
        }
        
        // Clean specific shadow layers
        containerView.layer.sublayers?.filter { $0.name == "neumorphicShadow" || $0.name == "optimizedShadow" }.forEach {
            $0.removeFromSuperlayer()
        }
        
        checkboxButton.layer.sublayers?.filter { $0.name == "neumorphicShadow" || $0.name == "optimizedShadow" }.forEach {
            $0.removeFromSuperlayer()
        }
    }
    
    private func updateCheckboxState() {
        // First remove all styling to start fresh
        checkboxButton.setImage(nil, for: .normal)
        taskNameLabel.attributedText = nil
        
        if isCompleted {
            // Set checkbox appearance for completed state
            checkboxButton.backgroundColor = themeManager.currentThemeColor
            checkboxButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkboxButton.tintColor = .white
            
            // Apply strikethrough with the current theme's color
            let attributedString = NSAttributedString(
                string: taskNameLabel.text ?? "",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: themeManager.textColor.withAlphaComponent(0.6) // Dimmed text
                ]
            )
            taskNameLabel.attributedText = attributedString
        } else {
            // Set checkbox appearance for incomplete state
            checkboxButton.backgroundColor = themeManager.backgroundColor
            checkboxButton.setImage(nil, for: .normal)
            
            // Clean text styling
            if taskNameLabel.attributedText != nil {
                let plainText = taskNameLabel.attributedText?.string ?? taskNameLabel.text ?? ""
                taskNameLabel.attributedText = nil
                taskNameLabel.text = plainText
            }
            taskNameLabel.textColor = themeManager.textColor
        }
    }
    
    // MARK: - Configure
    func configure(with taskName: String, category: String, dueDate: Date?, priority: PriorityLevel, isCompleted: Bool = false) {
        // First reset the cell to a clean state
        self.isCompleted = false // Reset state
        cleanupNeumorphicEffects()
        
        // Reset all text styles
        taskNameLabel.attributedText = nil
        taskNameLabel.text = taskName
        taskNameLabel.textColor = themeManager.textColor
        
        categoryLabel.text = category
        categoryLabel.textColor = themeManager.secondaryTextColor
        
        // Format date
        if let dueDate = dueDate {
            dueDateLabel.text = "Due: \(TaskCell.dateFormatter.string(from: dueDate))"
        } else {
            dueDateLabel.text = "No due date"
        }
        dueDateLabel.textColor = themeManager.secondaryTextColor
        
        // Set priority color
        priorityIndicator.backgroundColor = priority.color
        
        // Set container and checkbox base appearance
        containerView.backgroundColor = themeManager.backgroundColor
        checkboxButton.backgroundColor = themeManager.backgroundColor
        
        // Now set completion state which will trigger updateCheckboxState
        self.isCompleted = isCompleted
        
        // Apply optimized rendering with shadow path
        applyThemeAndStyles()
    }
}
