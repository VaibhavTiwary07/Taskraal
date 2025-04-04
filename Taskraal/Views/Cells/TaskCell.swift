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
    private let neumorphicBackgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1.0)
    private let accentColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0)
    
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
        label.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 1.0)
        return label
    }()
    
    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 1.0)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyNeumorphicStyles()
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
    
    private func applyNeumorphicStyles() {
        // Apply neumorphic effect to container
        containerView.addNeumorphicEffect(
            cornerRadius: 16,
            backgroundColor: neumorphicBackgroundColor
        )
        
        // Apply inset neumorphic effect to checkbox
        checkboxButton.addInsetNeumorphicEffect(
            cornerRadius: 12,
            backgroundColor: neumorphicBackgroundColor
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
            }
        }
    }
    
    private func updateCheckboxState() {
        if isCompleted {
            checkboxButton.backgroundColor = accentColor
            checkboxButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkboxButton.tintColor = .white
            
            // Strike through text
            let attributedString = NSAttributedString(
                string: taskNameLabel.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            taskNameLabel.attributedText = attributedString
        } else {
            checkboxButton.backgroundColor = neumorphicBackgroundColor
            checkboxButton.setImage(nil, for: .normal)
            
            // Remove strike through
            taskNameLabel.attributedText = nil
            taskNameLabel.text = taskNameLabel.text
        }
    }
    
    // MARK: - Configure
    func configure(with taskName: String, category: String, dueDate: Date?, priority: PriorityLevel, isCompleted: Bool = false) {
        taskNameLabel.text = taskName
        categoryLabel.text = category
        
        // Format date
        if let dueDate = dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dueDateLabel.text = "Due: \(formatter.string(from: dueDate))"
        } else {
            dueDateLabel.text = "No due date"
        }
        
        // Set priority color
        priorityIndicator.backgroundColor = priority.color
        
        // Set completion state
        self.isCompleted = isCompleted
    }
}
