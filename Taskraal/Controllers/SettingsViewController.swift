//
//  SettingsViewController.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 12/03/25.
//

import UIKit
import UserNotifications

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    private let themeManager = ThemeManager.shared
    private let schedulingService = SchedulingService.shared
    
    // Settings state
    private var isDarkModeEnabled = false
    private var isRemindersEnabled = true
    private var isDueDateAlertsEnabled = true
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
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
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHeader()
        setupTableView()
        loadSettings()
        
        // Listen for theme changes
        setupNotificationObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyNeumorphicStyles()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = themeManager.backgroundColor
        title = "Settings"
        
        // Use ThemeManager to configure navigation bar
        themeManager.applyThemeToNavigationBar(navigationController)
    }
    
    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(headerLabel)
        
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
        
        // Set text color
        headerLabel.textColor = themeManager.textColor
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
        
        tableView.register(SettingToggleCell.self, forCellReuseIdentifier: SettingToggleCell.identifier)
        tableView.register(SettingSelectCell.self, forCellReuseIdentifier: SettingSelectCell.identifier)
        tableView.register(SettingInfoCell.self, forCellReuseIdentifier: SettingInfoCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
    }
    
    private func applyNeumorphicStyles() {
        // No additional neumorphic styling needed here as the cells will handle their own styling
    }
    
    // MARK: - Settings Management
    private func loadSettings() {
        // Load settings from UserDefaults
        let defaults = UserDefaults.standard
        isDarkModeEnabled = themeManager.isDarkModeEnabled
        isRemindersEnabled = defaults.bool(forKey: "isRemindersEnabled")
        isDueDateAlertsEnabled = defaults.bool(forKey: "isDueDateAlertsEnabled")
        
        // Set default values if needed
        if !defaults.contains(key: "isRemindersEnabled") {
            isRemindersEnabled = true
        }
        
        if !defaults.contains(key: "isDueDateAlertsEnabled") {
            isDueDateAlertsEnabled = true
        }
    }
    
    private func saveSettings() {
        // Save settings to UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(isRemindersEnabled, forKey: "isRemindersEnabled")
        defaults.set(isDueDateAlertsEnabled, forKey: "isDueDateAlertsEnabled")
        
        // Notify app about settings change
        NotificationCenter.default.post(name: NSNotification.Name("AppSettingsChanged"), object: nil)
    }
    
    private func toggleDarkMode(_ isEnabled: Bool) {
        isDarkModeEnabled = isEnabled
        themeManager.isDarkModeEnabled = isEnabled
        // No need to call applyDarkModeSettings - ThemeManager handles this
    }
    
    private func toggleReminders(_ isEnabled: Bool) {
        isRemindersEnabled = isEnabled
        saveSettings()
        
        if isEnabled {
            // Request notification permission if needed
            requestNotificationPermission()
        }
    }
    
    private func toggleDueDateAlerts(_ isEnabled: Bool) {
        isDueDateAlertsEnabled = isEnabled
        saveSettings()
        
        if isEnabled {
            // Request notification permission if needed
            requestNotificationPermission()
        }
    }
    
    private func requestNotificationPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                DispatchQueue.main.async {
                    notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        // Handle the response
                        if !granted {
                            // Show alert that notifications are disabled
                            self.showNotificationAlert()
                        }
                    }
                }
            }
        }
    }
    
    private func showNotificationAlert() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to use reminders and alerts.",
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
    
    private func showAboutInfo() {
        let alert = UIAlertController(
            title: "About Taskraal",
            message: "Version 1.0\n\nA beautiful task management app with neumorphic design.\n\nDeveloped by Vaibhav Tiwary",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    @objc private func handleThemeChanged() {
        // Update view with ThemeManager
        view.backgroundColor = themeManager.backgroundColor
        headerLabel.textColor = themeManager.textColor
        
        // Apply navigation bar theme
        themeManager.applyThemeToNavigationBar(navigationController)
        
        // Reload table to update cells
        tableView.reloadData()
        
        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func showCalendarSelectionAlert() {
        // First get available calendars
        let calendars = schedulingService.fetchAvailableCalendars()
        
        guard !calendars.isEmpty else {
            showAlert(title: "No Calendars Available", message: "You don't have any editable calendars.")
            return
        }
        
        let alert = UIAlertController(title: "Select Calendar", message: "Choose a calendar for your tasks", preferredStyle: .actionSheet)
        
        // Add each calendar as an option
        for calendar in calendars {
            let action = UIAlertAction(title: calendar.title, style: .default) { [weak self] _ in
                self?.schedulingService.setSelectedCalendar(identifier: calendar.calendarIdentifier)
                self?.tableView.reloadData()
            }
            alert.addAction(action)
        }
        
        // Add a cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad, set the source view for the popover
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showReminderListSelectionAlert() {
        // First get available reminder lists
        let reminderLists = schedulingService.fetchAvailableReminderLists()
        
        guard !reminderLists.isEmpty else {
            showAlert(title: "No Reminder Lists Available", message: "You don't have any reminder lists.")
            return
        }
        
        let alert = UIAlertController(title: "Select Reminder List", message: "Choose a list for your task reminders", preferredStyle: .actionSheet)
        
        // Add each reminder list as an option
        for list in reminderLists {
            let action = UIAlertAction(title: list.title, style: .default) { [weak self] _ in
                self?.schedulingService.setReminderList(identifier: list.calendarIdentifier)
                self?.tableView.reloadData()
            }
            alert.addAction(action)
        }
        
        // Add a cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad, set the source view for the popover
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1  // Only Dark Mode in Appearance section
        case 1: return 2  // Notification settings
        case 2: return 1  // About
        case 3: return 2  // Calendar and Reminder list selection
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = themeManager.secondaryTextColor
        
        switch section {
        case 0: titleLabel.text = "Appearance"
        case 1: titleLabel.text = "Notifications"
        case 2: titleLabel.text = "About"
        case 3: titleLabel.text = "Scheduling"
        default: break
        }
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // Appearance
            // Dark Mode Toggle
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingToggleCell.identifier, for: indexPath) as! SettingToggleCell
            cell.configure(with: "Dark Mode", isOn: isDarkModeEnabled) { [weak self] isOn in
                self?.toggleDarkMode(isOn)
            }
            return cell
            
        case 1: // Notifications
            if indexPath.row == 0 {
                // Reminders Toggle
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingToggleCell.identifier, for: indexPath) as! SettingToggleCell
                cell.configure(with: "Reminders", isOn: isRemindersEnabled) { [weak self] isOn in
                    self?.toggleReminders(isOn)
                }
                return cell
            } else {
                // Due Date Alerts Toggle
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingToggleCell.identifier, for: indexPath) as! SettingToggleCell
                cell.configure(with: "Due Date Alerts", isOn: isDueDateAlertsEnabled) { [weak self] isOn in
                    self?.toggleDueDateAlerts(isOn)
                }
                return cell
            }
            
        case 2: // About
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingInfoCell.identifier, for: indexPath) as! SettingInfoCell
            cell.configure(with: "Version 1.0")
            return cell
            
        case 3: // Scheduling settings section
            switch indexPath.row {
            case 0: // Calendar selection
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingSelectCell.identifier, for: indexPath) as! SettingSelectCell
                
                // Get selected calendar name
                var calendarName = "Default Calendar"
                if let calendarId = schedulingService.selectedCalendarIdentifier,
                   let calendar = schedulingService.fetchAvailableCalendars().first(where: { $0.calendarIdentifier == calendarId }) {
                    calendarName = calendar.title
                }
                
                cell.configure(with: "Calendar", value: calendarName, indicatorColor: .systemBlue)
                return cell
                
            case 1: // Reminder list selection
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingSelectCell.identifier, for: indexPath) as! SettingSelectCell
                
                // Get selected reminder list name
                var listName = "Default List"
                if let listId = schedulingService.reminderListIdentifier,
                   let list = schedulingService.fetchAvailableReminderLists().first(where: { $0.calendarIdentifier == listId }) {
                    listName = list.title
                }
                
                cell.configure(with: "Reminder List", value: listName, indicatorColor: .systemOrange)
                return cell
                
            default:
                return UITableViewCell()
            }
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Handle cell selection
        switch indexPath.section {
        case 2:
            // About app
            showAboutInfo()
        case 3:
            // Scheduling settings
            switch indexPath.row {
            case 0:
                // Calendar selection
                showCalendarSelectionAlert()
            case 1:
                // Reminder list selection
                showReminderListSelectionAlert()
            default:
                break
            }
        default:
            break
        }
    }
}

// MARK: - Custom Setting Cells
class SettingToggleCell: UITableViewCell {
    static let identifier = "SettingToggleCell"
    
    private let themeManager = ThemeManager.shared
    private var toggleCallback: ((Bool) -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyThemeAndStyles()
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews(titleLabel, toggleSwitch)
        
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
        
        titleLabel.anchor(
            leading: containerView.leadingAnchor,
            paddingLeading: 20
        )
        titleLabel.centerY(in: containerView)
        
        toggleSwitch.anchor(
            trailing: containerView.trailingAnchor,
            paddingTrailing: 20
        )
        toggleSwitch.centerY(in: containerView)
        
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    private func applyThemeAndStyles() {
        containerView.addNeumorphicEffect(
            cornerRadius: 15,
            backgroundColor: themeManager.backgroundColor
        )
        
        // Update toggle switch color
        toggleSwitch.onTintColor = themeManager.currentThemeColor
        
        // Update text color
        titleLabel.textColor = themeManager.textColor
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        toggleCallback?(sender.isOn)
    }
    
    func configure(with title: String, isOn: Bool, callback: @escaping (Bool) -> Void) {
        titleLabel.text = title
        toggleSwitch.isOn = isOn
        toggleCallback = callback
        applyThemeAndStyles()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleThemeChanged() {
        applyThemeAndStyles()
    }
}

class SettingSelectCell: UITableViewCell {
    static let identifier = "SettingSelectCell"
    
    private let themeManager = ThemeManager.shared
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 60/255, green: 80/255, blue: 100/255, alpha: 1.0)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 1.0)
        return label
    }()
    
    private let colorIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let disclosureIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor(red: 130/255, green: 140/255, blue: 150/255, alpha: 0.7)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
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
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews(titleLabel, valueLabel, colorIndicator, disclosureIcon)
        
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
        
        titleLabel.anchor(
            leading: containerView.leadingAnchor,
            paddingLeading: 20
        )
        titleLabel.centerY(in: containerView)
        
        colorIndicator.anchor(
            trailing: disclosureIcon.leadingAnchor,
            paddingTrailing: 12,
            width: 20,
            height: 20
        )
        colorIndicator.centerY(in: containerView)
        
        valueLabel.anchor(
            trailing: colorIndicator.leadingAnchor,
            paddingTrailing: 12
        )
        valueLabel.centerY(in: containerView)
        
        disclosureIcon.anchor(
            trailing: containerView.trailingAnchor,
            paddingTrailing: 20,
            width: 12,
            height: 20
        )
        disclosureIcon.centerY(in: containerView)
    }
    
    private func applyNeumorphicStyles() {
        containerView.addNeumorphicEffect(
            cornerRadius: 15,
            backgroundColor: themeManager.backgroundColor
        )
    }
    
    func configure(with title: String, value: String, indicatorColor: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        colorIndicator.backgroundColor = indicatorColor
    }
}

class SettingInfoCell: UITableViewCell {
    static let identifier = "SettingInfoCell"
    
    private let themeManager = ThemeManager.shared
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let infoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "info.circle")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyThemeAndStyles()
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews(titleLabel, infoIcon)
        
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
        
        titleLabel.anchor(
            leading: containerView.leadingAnchor,
            paddingLeading: 20
        )
        titleLabel.centerY(in: containerView)
        
        infoIcon.anchor(
            trailing: containerView.trailingAnchor,
            paddingTrailing: 20,
            width: 24,
            height: 24
        )
        infoIcon.centerY(in: containerView)
    }
    
    private func applyThemeAndStyles() {
        containerView.addNeumorphicEffect(
            cornerRadius: 15,
            backgroundColor: themeManager.backgroundColor
        )
        
        titleLabel.textColor = themeManager.textColor
        infoIcon.tintColor = themeManager.secondaryTextColor
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        applyThemeAndStyles()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleThemeChanged() {
        applyThemeAndStyles()
    }
}
