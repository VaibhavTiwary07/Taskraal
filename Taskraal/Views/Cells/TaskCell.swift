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
            name: NSNotification.Name("AppThemeChanged"),
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
        
        taskNameLabel.anchor(
            top: containerView.topAnchor,
            leading: checkboxButton.trailingAnchor,
            trailing: priorityIndicator.leadingAnchor,
            paddingTop: 14,
            paddingLeading: 12,
            paddingTrailing: 12
        )
        
        categoryLabel.anchor(
            top: taskNameLabel.bottomAnchor,
            leading: taskNameLabel.leadingAnchor,
            trailing: taskNameLabel.trailingAnchor,
            paddingTop: 4
        )
        
        dueDateLabel.anchor(
            top: categoryLabel.bottomAnchor,
            leading: taskNameLabel.leadingAnchor,
            bottom: containerView.bottomAnchor,
            paddingTop: 4,
            paddingBottom: 14
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
        // Apply text colors
        if !isCompleted {
            taskNameLabel.textColor = themeManager.textColor
        }
        categoryLabel.textColor = themeManager.secondaryTextColor
        dueDateLabel.textColor = themeManager.secondaryTextColor
        
        // Set background color
        containerView.backgroundColor = themeManager.backgroundColor
        
        // Clean up existing neumorphic effects before applying new ones
        cleanupNeumorphicEffects()
        
        // Apply neumorphic effects based on completion state
        if isCompleted {
            // For completed tasks, use inset effect to make it look "pushed in"
            containerView.addInsetNeumorphicEffect(
                cornerRadius: 16,
                backgroundColor: themeManager.backgroundColor
            )
        } else {
            // For incomplete tasks, use standard neumorphic effect
            containerView.addNeumorphicEffect(
                cornerRadius: 16,
                backgroundColor: themeManager.backgroundColor
            )
        }
        
        // Apply inset neumorphic effect to checkbox
        checkboxButton.addInsetNeumorphicEffect(
            cornerRadius: 12,
            backgroundColor: themeManager.backgroundColor
        )
        
        updateCheckboxState()
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
                self.applyThemeAndStyles() // Apply the correct neumorphic style after animation
            }
        }
    }
    
    @objc private func handleThemeChanged() {
        // Immediately update all colors based on the new theme
        containerView.backgroundColor = themeManager.backgroundColor
        
        // Update text colors
        if !isCompleted {
            taskNameLabel.textColor = themeManager.textColor
        } else {
            // Update strikethrough text with new theme color
            let attributedString = NSAttributedString(
                string: taskNameLabel.text ?? "",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: themeManager.textColor.withAlphaComponent(0.6)
                ]
            )
            taskNameLabel.attributedText = attributedString
        }
        
        categoryLabel.textColor = themeManager.secondaryTextColor
        dueDateLabel.textColor = themeManager.secondaryTextColor
        
        // Update checkbox state
        if isCompleted {
            checkboxButton.backgroundColor = themeManager.currentThemeColor
        } else {
            checkboxButton.backgroundColor = themeManager.backgroundColor
        }
        
        // Clean up existing neumorphic effects to rebuild with new theme colors
        cleanupNeumorphicEffects()
        
        // Force full redraw on next layout pass
        setNeedsLayout()
        layoutIfNeeded()
        
        // Important: Apply theme styles immediately
        applyThemeAndStyles()
    }
    
    // Helper method to clean up neumorphic effects
    private func cleanupNeumorphicEffects() {
        // Remove any existing neumorphic view subviews by tag
        contentView.subviews.forEach { subview in
            if subview.tag == 1001 || subview.tag == 1002 {
                subview.removeFromSuperview()
            }
        }
        
        // Clean specific shadow layers instead of removing all sublayers
        containerView.layer.sublayers?.filter { $0.name == "neumorphicShadow" }.forEach {
            $0.removeFromSuperlayer()
        }
        
        checkboxButton.layer.sublayers?.filter { $0.name == "neumorphicShadow" }.forEach {
            $0.removeFromSuperlayer()
        }
    }
    
    private func updateCheckboxState() {
        if isCompleted {
            checkboxButton.backgroundColor = themeManager.currentThemeColor
            checkboxButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkboxButton.tintColor = .white
            
            // Strike through text
            let attributedString = NSAttributedString(
                string: taskNameLabel.text ?? "",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: themeManager.textColor.withAlphaComponent(0.6) // Dimmed text
                ]
            )
            taskNameLabel.attributedText = attributedString
        } else {
            checkboxButton.backgroundColor = themeManager.backgroundColor
            checkboxButton.setImage(nil, for: .normal)
            
            // Remove strike through
            taskNameLabel.attributedText = nil
            taskNameLabel.text = taskNameLabel.text
            taskNameLabel.textColor = themeManager.textColor
        }
    }
    
    // MARK: - Configure
    func configure(with taskName: String, category: String, dueDate: Date?, priority: PriorityLevel, isCompleted: Bool = false) {
        // Clean up any existing neumorphic effects
        cleanupNeumorphicEffects()
        
        // Set task data
        taskNameLabel.text = taskName
        categoryLabel.text = category
        
        // Format date
        if let dueDate = dueDate {
            dueDateLabel.text = "Due: \(TaskCell.dateFormatter.string(from: dueDate))"
        } else {
            dueDateLabel.text = "No due date"
        }
        
        // Set priority color
        priorityIndicator.backgroundColor = priority.color
        
        // Set completion state
        self.isCompleted = isCompleted
        
        // Apply theme and styles - use setNeedsLayout instead of immediate layout
        applyThemeAndStyles()
        setNeedsLayout()
    }
}
