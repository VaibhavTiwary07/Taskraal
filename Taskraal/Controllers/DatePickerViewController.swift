//
//  DatePickerViewController.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 03/04/25.
//

//
//  DatePickerViewController.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 03/04/25.
//

import UIKit

// MARK: - DatePickerViewControllerDelegate
protocol DatePickerViewControllerDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

class DatePickerViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: DatePickerViewControllerDelegate?
    var initialDate: Date = Date()
    private let themeManager = ThemeManager.shared
    
    // MARK: - UI Elements
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .inline
        }
        picker.minimumDate = Date()
        return picker
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDatePicker()
        setupNavigationBar()
        
        // Apply styles immediately for smoother appearance
        applyThemeAndStyles()
        
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
        
        // Pre-configure date picker with the correct date
        datePicker.date = initialDate
        
        // Ensure smooth appearance by applying styles again
        DispatchQueue.main.async {
            self.applyThemeAndStyles()
        }
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
        title = "Select Due Date"
    }
    
    private func setupDatePicker() {
        view.addSubview(containerView)
        containerView.addSubview(datePicker)
        
        containerView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            paddingTop: 20,
            paddingLeading: 20,
            paddingTrailing: 20
        )
        
        datePicker.anchor(
            top: containerView.topAnchor,
            leading: containerView.leadingAnchor,
            bottom: containerView.bottomAnchor,
            trailing: containerView.trailingAnchor,
            paddingTop: 16,
            paddingLeading: 16,
            paddingBottom: 16,
            paddingTrailing: 16
        )
        
        datePicker.date = initialDate
        datePicker.tintColor = themeManager.currentThemeColor
    }
    
    private func setupNavigationBar() {
        // Create pre-configured buttons for better performance
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        cancelButton.tintColor = themeManager.currentThemeColor
        navigationItem.leftBarButtonItem = cancelButton
        
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        doneButton.tintColor = themeManager.currentThemeColor
        doneButton.style = .done
        navigationItem.rightBarButtonItem = doneButton
        
        // Configure navigation bar appearance
        let appearance = navigationController?.navigationBar
        appearance?.tintColor = themeManager.currentThemeColor
        appearance?.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: themeManager.textColor
        ]
        
        // Make navigation bar opaque for better performance
        appearance?.isTranslucent = false
        appearance?.backgroundColor = themeManager.backgroundColor
    }
    
    private func applyThemeAndStyles() {
        // Update colors for dark mode, batching UI updates
        UIView.performWithoutAnimation {
            view.backgroundColor = themeManager.backgroundColor
            
            // Apply simplified neumorphic effect to container view
            containerView.backgroundColor = themeManager.backgroundColor
            if containerView.bounds.width > 0 && containerView.bounds.height > 0 {
                containerView.addNeumorphicEffect(
                    cornerRadius: 20,
                    backgroundColor: themeManager.backgroundColor
                )
            }
            
            // Update datePicker appearance
            datePicker.tintColor = themeManager.currentThemeColor
            if #available(iOS 14.0, *) {
                datePicker.backgroundColor = themeManager.backgroundColor
            }
            
            // Update navigation bar
            navigationController?.navigationBar.tintColor = themeManager.currentThemeColor
            navigationController?.navigationBar.backgroundColor = themeManager.backgroundColor
            navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: themeManager.textColor
            ]
        }
    }
    
    @objc private func handleThemeChanged() {
        // Apply theme changes in a batch for better performance
        UIView.animate(withDuration: 0.3) {
            self.applyThemeAndStyles()
        }
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        // Add a subtle haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        dismiss(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        // Add a subtle haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        // Call delegate with current date
        delegate?.didSelectDate(datePicker.date)
        dismiss(animated: true)
    }
}
