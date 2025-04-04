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
    private let neumorphicBackgroundColor = UIColor(red: 240/255, green: 243/255, blue: 245/255, alpha: 1.0)
    private let accentColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0)
    
    // MARK: - UI Elements
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .inline
        }
        picker.minimumDate = Date()
        picker.tintColor = UIColor(red: 94/255, green: 132/255, blue: 226/255, alpha: 1.0)
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyNeumorphicStyles()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = neumorphicBackgroundColor
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
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        
        // Configure navigation bar appearance
        navigationController?.navigationBar.tintColor = accentColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        ]
    }
    
    private func applyNeumorphicStyles() {
        // Apply neumorphic effect to container view
        containerView.addNeumorphicEffect(
            cornerRadius: 20,
            backgroundColor: neumorphicBackgroundColor
        )
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didSelectDate(datePicker.date)
        dismiss(animated: true)
    }
}
