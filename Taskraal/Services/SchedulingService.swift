//
//  SchedulingService.swift
//  Taskraal
//
//  Created by Vaibhav Tiwary on 12/04/25.
//

import UIKit
import EventKit
import CoreData
import UserNotifications

class SchedulingService {
    
    // MARK: - Shared Instance (Singleton)
    static let shared = SchedulingService()
    
    // MARK: - Properties
    private let eventStore = EKEventStore()
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Keys for UserDefaults
    private enum Keys {
        static let calendarIntegrationEnabled = "calendarIntegrationEnabled"
        static let reminderIntegrationEnabled = "reminderIntegrationEnabled"
        static let notificationsEnabled = "notificationsEnabled"
        static let selectedCalendarIdentifier = "selectedCalendarIdentifier"
        static let reminderListIdentifier = "reminderListIdentifier"
    }
    
    // Notification identifiers
    static let schedulingPermissionsChanged = NSNotification.Name("SchedulingPermissionsChanged")
    
    // MARK: - Initialization
    private init() {
        loadSettings()
    }
    
    // MARK: - Settings
    private(set) var calendarIntegrationEnabled: Bool = false {
        didSet {
            userDefaults.set(calendarIntegrationEnabled, forKey: Keys.calendarIntegrationEnabled)
        }
    }
    
    private(set) var reminderIntegrationEnabled: Bool = false {
        didSet {
            userDefaults.set(reminderIntegrationEnabled, forKey: Keys.reminderIntegrationEnabled)
        }
    }
    
    private(set) var notificationsEnabled: Bool = false {
        didSet {
            userDefaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }
    
    private(set) var selectedCalendarIdentifier: String? {
        didSet {
            userDefaults.set(selectedCalendarIdentifier, forKey: Keys.selectedCalendarIdentifier)
        }
    }
    
    private(set) var reminderListIdentifier: String? {
        didSet {
            userDefaults.set(reminderListIdentifier, forKey: Keys.reminderListIdentifier)
        }
    }
    
    private func loadSettings() {
        calendarIntegrationEnabled = userDefaults.bool(forKey: Keys.calendarIntegrationEnabled)
        reminderIntegrationEnabled = userDefaults.bool(forKey: Keys.reminderIntegrationEnabled)
        notificationsEnabled = userDefaults.bool(forKey: Keys.notificationsEnabled)
        selectedCalendarIdentifier = userDefaults.string(forKey: Keys.selectedCalendarIdentifier)
        reminderListIdentifier = userDefaults.string(forKey: Keys.reminderListIdentifier)
    }
    
    // MARK: - Public Methods
    
    // Toggle calendar integration
    func toggleCalendarIntegration(_ enable: Bool, completion: @escaping (Bool) -> Void) {
        if enable {
            requestCalendarAccess { granted in
                self.calendarIntegrationEnabled = granted
                completion(granted)
            }
        } else {
            calendarIntegrationEnabled = false
            completion(true)
        }
    }
    
    // Toggle reminder integration
    func toggleReminderIntegration(_ enable: Bool, completion: @escaping (Bool) -> Void) {
        if enable {
            requestRemindersAccess { granted in
                self.reminderIntegrationEnabled = granted
                completion(granted)
            }
        } else {
            reminderIntegrationEnabled = false
            completion(true)
        }
    }
    
    // Toggle notifications
    func toggleNotifications(_ enable: Bool, completion: @escaping (Bool) -> Void) {
        if enable {
            requestNotificationPermission { granted in
                self.notificationsEnabled = granted
                completion(granted)
            }
        } else {
            notificationsEnabled = false
            completion(true)
        }
    }
    
    // Set selected calendar
    func setSelectedCalendar(identifier: String?) {
        selectedCalendarIdentifier = identifier
    }
    
    // Set reminder list
    func setReminderList(identifier: String?) {
        reminderListIdentifier = identifier
    }
    
    // MARK: - Calendar Integration
    
    // Request calendar access
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            eventStore.requestAccess(to: .event) { (granted, error) in
                DispatchQueue.main.async {
                    completion(granted)
                    if granted {
                        NotificationCenter.default.post(name: SchedulingService.schedulingPermissionsChanged, object: nil)
                    }
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    // Get available calendars
    func fetchAvailableCalendars() -> [EKCalendar] {
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .authorized else { return [] }
        
        return eventStore.calendars(for: .event).filter { $0.allowsContentModifications }
    }
    
    // Create calendar event for task
    func createCalendarEvent(for task: NSManagedObject, completion: @escaping (Bool, String?) -> Void) {
        guard calendarIntegrationEnabled, let dueDate = task.value(forKey: "dueDate") as? Date else {
            completion(false, "Calendar integration disabled or task has no due date")
            return
        }
        
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .authorized else {
            requestCalendarAccess { granted in
                if granted {
                    self.createCalendarEvent(for: task, completion: completion)
                } else {
                    completion(false, "Calendar access denied")
                }
            }
            return
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = task.value(forKey: "title") as? String ?? "Untitled Task"
        
        if let details = task.value(forKey: "details") as? String {
            event.notes = details
        }
        
        // Set the start and end date
        event.startDate = dueDate
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: dueDate) ?? dueDate
        
        // Add an alert 30 minutes before
        let alarm = EKAlarm(relativeOffset: -30 * 60) // 30 minutes before
        event.addAlarm(alarm)
        
        // Set the calendar
        if let calendarIdentifier = selectedCalendarIdentifier,
           let calendar = eventStore.calendar(withIdentifier: calendarIdentifier) {
            event.calendar = calendar
        } else {
            event.calendar = eventStore.defaultCalendarForNewEvents
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            
            // Save the event identifier to the task
            task.setValue(event.eventIdentifier, forKey: "calendarEventIdentifier")
            try CoreDataManager.shared.viewContext.save()
            
            completion(true, event.eventIdentifier)
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    // Remove calendar event for task
    func removeCalendarEvent(for task: NSManagedObject, completion: @escaping (Bool, String?) -> Void) {
        guard calendarIntegrationEnabled, 
              let eventIdentifier = task.value(forKey: "calendarEventIdentifier") as? String else {
            completion(false, "No calendar event found for this task")
            return
        }
        
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .authorized else {
            completion(false, "Calendar access denied")
            return
        }
        
        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
            // Event already deleted or not found
            task.setValue(nil, forKey: "calendarEventIdentifier")
            try? CoreDataManager.shared.viewContext.save()
            completion(true, "Event not found in calendar")
            return
        }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            
            // Remove the event identifier from the task
            task.setValue(nil, forKey: "calendarEventIdentifier")
            try CoreDataManager.shared.viewContext.save()
            
            completion(true, nil)
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    // MARK: - Reminders Integration
    
    // Request reminders access
    func requestRemindersAccess(completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            eventStore.requestAccess(to: .reminder) { (granted, error) in
                DispatchQueue.main.async {
                    completion(granted)
                    if granted {
                        NotificationCenter.default.post(name: SchedulingService.schedulingPermissionsChanged, object: nil)
                    }
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    // Get available reminder lists
    func fetchAvailableReminderLists() -> [EKCalendar] {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        guard status == .authorized else { return [] }
        
        return eventStore.calendars(for: .reminder)
    }
    
    // Create reminder for task
    func createReminder(for task: NSManagedObject, completion: @escaping (Bool, String?) -> Void) {
        guard reminderIntegrationEnabled else {
            completion(false, "Reminders integration disabled")
            return
        }
        
        let status = EKEventStore.authorizationStatus(for: .reminder)
        guard status == .authorized else {
            requestRemindersAccess { granted in
                if granted {
                    self.createReminder(for: task, completion: completion)
                } else {
                    completion(false, "Reminders access denied")
                }
            }
            return
        }
        
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = task.value(forKey: "title") as? String ?? "Untitled Task"
        
        if let details = task.value(forKey: "details") as? String {
            reminder.notes = details
        }
        
        // Set due date if available
        if let dueDate = task.value(forKey: "dueDate") as? Date {
            let dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            reminder.dueDateComponents = dueDateComponents
            
            // Add an alarm at the due date
            let alarm = EKAlarm(absoluteDate: dueDate)
            reminder.addAlarm(alarm)
        }
        
        // Set the reminder list
        if let listIdentifier = reminderListIdentifier,
           let reminderList = eventStore.calendar(withIdentifier: listIdentifier) {
            reminder.calendar = reminderList
        } else {
            reminder.calendar = eventStore.defaultCalendarForNewReminders()
        }
        
        do {
            try eventStore.save(reminder, commit: true)
            
            // Save the reminder identifier to the task
            task.setValue(reminder.calendarItemIdentifier, forKey: "reminderIdentifier")
            try CoreDataManager.shared.viewContext.save()
            
            completion(true, reminder.calendarItemIdentifier)
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    // Remove reminder for task
    func removeReminder(for task: NSManagedObject, completion: @escaping (Bool, String?) -> Void) {
        guard reminderIntegrationEnabled, 
              let reminderIdentifier = task.value(forKey: "reminderIdentifier") as? String else {
            completion(false, "No reminder found for this task")
            return
        }
        
        let status = EKEventStore.authorizationStatus(for: .reminder)
        guard status == .authorized else {
            completion(false, "Reminders access denied")
            return
        }
        
        // Fetch the reminder
        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { reminders in
            guard let reminders = reminders else {
                DispatchQueue.main.async {
                    completion(false, "Failed to fetch reminders")
                }
                return
            }
            
            guard let reminder = reminders.first(where: { $0.calendarItemIdentifier == reminderIdentifier }) else {
                // Reminder already deleted or not found
                DispatchQueue.main.async {
                    task.setValue(nil, forKey: "reminderIdentifier")
                    try? CoreDataManager.shared.viewContext.save()
                    completion(true, "Reminder not found")
                }
                return
            }
            
            do {
                try self.eventStore.remove(reminder, commit: true)
                
                DispatchQueue.main.async {
                    // Remove the reminder identifier from the task
                    task.setValue(nil, forKey: "reminderIdentifier")
                    try? CoreDataManager.shared.viewContext.save()
                    
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Notifications
    
    // Request notification permission
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    completion(true)
                }
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    DispatchQueue.main.async {
                        completion(granted)
                        if granted {
                            NotificationCenter.default.post(name: SchedulingService.schedulingPermissionsChanged, object: nil)
                        }
                    }
                }
            case .denied, .ephemeral:
                DispatchQueue.main.async {
                    completion(false)
                }
            @unknown default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // Schedule notification for task
    func scheduleNotification(for task: NSManagedObject, completion: @escaping (Bool, String?) -> Void) {
        guard notificationsEnabled,
              let dueDate = task.value(forKey: "dueDate") as? Date,
              dueDate > Date() else {
            completion(false, "Notifications disabled or invalid due date")
            return
        }
        
        requestNotificationPermission { granted in
            guard granted else {
                completion(false, "Notification permission denied")
                return
            }
            
            // Create unique notification ID
            let notificationId = "taskraal-task-\(task.value(forKey: "id") as? UUID ?? UUID())"
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = "Task Due"
            content.body = task.value(forKey: "title") as? String ?? "Task due now"
            content.sound = .default
            content.categoryIdentifier = "TASK_REMINDER" // Set category for action buttons
            
            // Add category name if available
            if let category = task.value(forKey: "category") as? NSManagedObject,
               let categoryName = category.value(forKey: "name") as? String {
                content.subtitle = categoryName
            }
            
            // Create an early reminder (30 minutes before)
            let earlyComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], 
                                                                from: dueDate.addingTimeInterval(-30 * 60))
            let earlyTrigger = UNCalendarNotificationTrigger(dateMatching: earlyComponent, repeats: false)
            
            // Create early reminder request
            let earlyContent = content.mutableCopy() as! UNMutableNotificationContent
            earlyContent.title = "Task Due Soon"
            
            let earlyRequest = UNNotificationRequest(identifier: "\(notificationId)-early", 
                                                    content: earlyContent, 
                                                    trigger: earlyTrigger)
            
            // Create the exact time reminder
            let exactComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], 
                                                               from: dueDate)
            let exactTrigger = UNCalendarNotificationTrigger(dateMatching: exactComponent, repeats: false)
            
            // Update content for exact notification
            let exactContent = content.mutableCopy() as! UNMutableNotificationContent
            exactContent.title = "Task Due Now"
            
            // Create exact time request
            let exactRequest = UNNotificationRequest(identifier: notificationId, 
                                                   content: exactContent, 
                                                   trigger: exactTrigger)
            
            // Add requests to notification center
            self.notificationCenter.add(earlyRequest) { error in
                if let error = error {
                    print("Error scheduling early notification: \(error)")
                }
            }
            
            self.notificationCenter.add(exactRequest) { error in
                if let error = error {
                    completion(false, "Error scheduling notification: \(error.localizedDescription)")
                } else {
                    // Save notification ID to task
                    task.setValue(notificationId, forKey: "notificationIdentifier")
                    try? CoreDataManager.shared.viewContext.save()
                    completion(true, notificationId)
                }
            }
        }
    }
    
    // Remove notification for task
    func removeNotification(for task: NSManagedObject) {
        guard let notificationId = task.value(forKey: "notificationIdentifier") as? String else {
            return
        }
        
        // Remove both notifications
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId, "\(notificationId)-early"])
        
        // Clear notification ID from task
        task.setValue(nil, forKey: "notificationIdentifier")
        try? CoreDataManager.shared.viewContext.save()
    }
    
    // MARK: - Convenience Methods
    
    // Setup all integrations for a task
    func setupAllIntegrations(for task: NSManagedObject, completion: @escaping (Bool, [String]) -> Void) {
        var messages: [String] = []
        let group = DispatchGroup()
        var success = true
        
        // Schedule notification
        if notificationsEnabled {
            group.enter()
            scheduleNotification(for: task) { succeeded, message in
                if !succeeded, let message = message {
                    success = false
                    messages.append("Notification: \(message)")
                }
                group.leave()
            }
        }
        
        // Create calendar event
        if calendarIntegrationEnabled {
            group.enter()
            createCalendarEvent(for: task) { succeeded, message in
                if !succeeded, let message = message {
                    success = false
                    messages.append("Calendar: \(message)")
                }
                group.leave()
            }
        }
        
        // Create reminder
        if reminderIntegrationEnabled {
            group.enter()
            createReminder(for: task) { succeeded, message in
                if !succeeded, let message = message {
                    success = false
                    messages.append("Reminder: \(message)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(success, messages)
        }
    }
    
    // Remove all integrations for a task
    func removeAllIntegrations(for task: NSManagedObject) {
        // Remove notification
        removeNotification(for: task)
        
        // Remove calendar event
        removeCalendarEvent(for: task) { _, _ in }
        
        // Remove reminder
        removeReminder(for: task) { _, _ in }
    }
    
    // Handle task update by updating all integrations
    func handleTaskUpdate(task: NSManagedObject) {
        // First remove all existing integrations
        removeAllIntegrations(for: task)
        
        // Then create new ones if the task is not completed
        if !(task.value(forKey: "isCompleted") as? Bool ?? false) {
            setupAllIntegrations(for: task) { _, _ in }
        }
    }
} 