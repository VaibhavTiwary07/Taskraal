import Foundation
import CoreData
import UIKit

// MARK: - Task Prioritization Model
struct TaskPrioritizationResult {
    let task: NSManagedObject
    let suggestedDueDate: Date?
    let priorityLevel: PriorityLevel
    let reason: String
}

// MARK: - Daily Progress Model
struct DailyProgressSummary {
    let date: Date
    let completedTaskCount: Int
    let totalTaskCount: Int
    let completionRate: Double // 0.0 to 1.0
    let motivationalQuote: String
    let progressAnalysis: String
    let suggestedActions: [String]
}

// MARK: - AI Task Manager Service
class AITaskManager {
    // MARK: - Shared Instance
    static let shared = AITaskManager()
    
    // MARK: - Properties
    private let coreDataManager = CoreDataManager.shared
    private let schedulingService = SchedulingService.shared
    private let userDefaults = UserDefaults.standard
    
    // For tracking progress
    private var lastAnalysisDate: Date? {
        get { userDefaults.object(forKey: "AITaskManager_lastAnalysisDate") as? Date }
        set { userDefaults.set(newValue, forKey: "AITaskManager_lastAnalysisDate") }
    }
    
    // Daily completion history (last 30 days)
    private var completionHistory: [String: [String: Any]] {
        get {
            if let data = userDefaults.data(forKey: "AITaskManager_completionHistory"),
               let history = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
                return history
            }
            return [:]
        }
        set {
            if let data = try? JSONSerialization.data(withJSONObject: newValue) {
                userDefaults.set(data, forKey: "AITaskManager_completionHistory")
            }
        }
    }
    
    // Motivational quotes
    private let motivationalQuotes = [
        "Small progress is still progress.",
        "Focus on progress rather than perfection.",
        "Every task completed is a step forward.",
        "Consistency beats intensity in the long run.",
        "Don't wait for inspiration. Create it through action.",
        "The difference between ordinary and extraordinary is that little extra.",
        "Success is the sum of small efforts repeated day in and day out.",
        "Your future is created by what you do today.",
        "The only way to do great work is to love what you do.",
        "The hardest part of any journey is taking the first step.",
        "Progress isn't always measurable, but it's always valuable.",
        "Productivity isn't about being busy, it's about being effective.",
        "Good habits formed today lead to better outcomes tomorrow.",
        "What you do today can improve all your tomorrows.",
        "Start where you are. Use what you have. Do what you can.",
        "The secret to getting ahead is getting started.",
        "Celebrate small wins to stay motivated for the big ones.",
        "Your time is limited, so don't waste it living someone else's life.",
        "The best way to predict the future is to create it.",
        "Every accomplished task is a stepping stone towards greater achievements."
    ]
    
    // MARK: - Initialization
    private init() {
        // Begin tracking if we haven't already
        if lastAnalysisDate == nil {
            lastAnalysisDate = Date()
            recordDailyProgress()
        }
        
        // Check if we need to record daily progress
        checkAndRecordDailyProgress()
    }
    
    // MARK: - Public Methods
    
    // Analyze and prioritize tasks
    func analyzeAndPrioritizeTasks(completion: @escaping ([TaskPrioritizationResult]) -> Void) {
        // Fetch all incomplete tasks
        let tasks = coreDataManager.fetchTasks(completed: false)
        
        // No tasks to prioritize
        if tasks.isEmpty {
            completion([])
            return
        }
        
        // Get daily progress to understand user's capacity
        let progress = getDailyProgressSummary()
        
        // Start analysis
        var results: [TaskPrioritizationResult] = []
        
        // Process each task
        for task in tasks {
            // Get task details
            let title = task.value(forKey: "title") as? String ?? "Untitled"
            let details = task.value(forKey: "details") as? String
            let currentDueDate = task.value(forKey: "dueDate") as? Date
            let currentPriority = PriorityLevel(rawValue: task.value(forKey: "priorityLevel") as? Int16 ?? 1) ?? .medium
            
            // Calculate task score based on several factors
            var priorityScore = calculatePriorityScore(
                title: title,
                details: details,
                dueDate: currentDueDate,
                currentPriority: currentPriority,
                progressRate: progress.completionRate
            )
            
            // Determine new priority based on score
            let newPriority: PriorityLevel
            if priorityScore >= 8.0 {
                newPriority = .high
            } else if priorityScore >= 5.0 {
                newPriority = .medium
            } else {
                newPriority = .low
            }
            
            // Calculate suggested due date adjustment if needed
            var suggestedDueDate = currentDueDate
            var reason = ""
            
            // If high priority but no due date, suggest one soon
            if newPriority == .high && currentDueDate == nil {
                suggestedDueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                reason = "High priority task requires a deadline. Suggested tomorrow."
            }
            // If high priority with due date far in future, suggest moving it closer
            else if newPriority == .high && currentDueDate != nil && daysBetween(Date(), and: currentDueDate!) > 7 {
                suggestedDueDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())
                reason = "High priority task with distant deadline. Suggested bringing deadline closer."
            }
            // If low priority with imminent deadline, suggest extending it
            else if newPriority == .low && currentDueDate != nil && daysBetween(Date(), and: currentDueDate!) < 2 {
                suggestedDueDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())
                reason = "Low priority task with imminent deadline. Suggested extending deadline."
            }
            // If medium priority with no due date, suggest one within a week
            else if newPriority == .medium && currentDueDate == nil {
                suggestedDueDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())
                reason = "Medium priority task requires a deadline. Suggested within a week."
            }
            
            // If priority changed, add explanation
            if currentPriority != newPriority && reason.isEmpty {
                if newPriority.rawValue > currentPriority.rawValue {
                    reason = "Task priority increased based on deadline proximity and importance."
                } else {
                    reason = "Task priority adjusted based on current workload and other priorities."
                }
            }
            
            // If no changes suggested, provide a generic message
            if reason.isEmpty {
                reason = "Current priority and deadline appear appropriate."
            }
            
            // Create result
            let result = TaskPrioritizationResult(
                task: task,
                suggestedDueDate: suggestedDueDate,
                priorityLevel: newPriority,
                reason: reason
            )
            
            results.append(result)
        }
        
        // Sort results by priority (high to low)
        results.sort { $0.priorityLevel.rawValue > $1.priorityLevel.rawValue }
        
        completion(results)
    }
    
    // Apply suggested changes with user confirmation
    func applyTaskPrioritization(_ results: [TaskPrioritizationResult], approval: Bool, completion: @escaping (Bool) -> Void) {
        guard approval else {
            completion(false)
            return
        }
        
        for result in results {
            // Update task in Core Data
            coreDataManager.updateTask(
                result.task,
                dueDate: result.suggestedDueDate,
                priority: result.priorityLevel
            )
            
            // Update scheduling if due date changed
            if let suggestedDate = result.suggestedDueDate,
               let originalDate = result.task.value(forKey: "dueDate") as? Date,
               !Calendar.current.isDate(suggestedDate, inSameDayAs: originalDate) {
                
                // Remove existing integrations
                schedulingService.removeAllIntegrations(for: result.task)
                
                // Create new integrations with updated date
                schedulingService.setupAllIntegrations(for: result.task) { _, _ in }
            }
        }
        
        // Notify of task data changes
        NotificationCenter.default.post(name: NSNotification.Name("TaskDataChanged"), object: nil)
        
        completion(true)
    }
    
    // Get daily progress summary
    func getDailyProgressSummary() -> DailyProgressSummary {
        // Get today's date (start of day)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get date string for lookup
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        
        // Check if we already have today's data
        if let todayData = completionHistory[todayString] {
            let completedCount = todayData["completedCount"] as? Int ?? 0
            let totalCount = todayData["totalCount"] as? Int ?? 0
            let completionRate = todayData["completionRate"] as? Double ?? 0.0
            let quote = todayData["quote"] as? String ?? getRandomMotivationalQuote()
            let analysis = todayData["analysis"] as? String ?? "No analysis available yet."
            let actions = todayData["actions"] as? [String] ?? ["Start by completing one task today."]
            
            return DailyProgressSummary(
                date: today,
                completedTaskCount: completedCount,
                totalTaskCount: totalCount,
                completionRate: completionRate,
                motivationalQuote: quote,
                progressAnalysis: analysis,
                suggestedActions: actions
            )
        }
        
        // Otherwise, generate a new summary
        return generateDailyProgressSummary()
    }
    
    // Regenerate daily motivation
    func regenerateDailyMotivation(completion: @escaping (DailyProgressSummary) -> Void) {
        // Generate a new summary with fresh data
        let summary = generateDailyProgressSummary()
        
        // Save to history
        saveDailyProgress(summary)
        
        completion(summary)
    }
    
    // MARK: - Private Methods
    
    // Calculate priority score for a task
    private func calculatePriorityScore(
        title: String,
        details: String?,
        dueDate: Date?,
        currentPriority: PriorityLevel,
        progressRate: Double
    ) -> Double {
        var score: Double = 5.0 // Start with middle score
        
        // Factor 1: Due date proximity (0-3 points)
        if let dueDate = dueDate {
            let daysLeft = daysBetween(Date(), and: dueDate)
            if daysLeft <= 1 {
                score += 3.0 // Due very soon
            } else if daysLeft <= 3 {
                score += 2.0 // Due soon
            } else if daysLeft <= 7 {
                score += 1.0 // Due this week
            }
        }
        
        // Factor 2: Current priority (0-2 points)
        score += Double(currentPriority.rawValue)
        
        // Factor 3: Keywords in title (0-2 points)
        let urgentKeywords = ["urgent", "asap", "important", "critical", "deadline", "due", "review"]
        for keyword in urgentKeywords {
            if title.lowercased().contains(keyword) {
                score += 1.0
                break
            }
        }
        
        // Factor 4: Detail complexity (0-1 point)
        if let details = details, !details.isEmpty {
            if details.count > 100 {
                score += 1.0 // Complex task
            } else if details.count > 50 {
                score += 0.5 // Moderate complexity
            }
        }
        
        // Factor 5: User's current progress rate (adjustment -1 to +1)
        if progressRate < 0.3 {
            score -= 1.0 // User is falling behind, don't overwhelm
        } else if progressRate > 0.7 {
            score += 1.0 // User is doing well, can handle more
        }
        
        // Ensure score is in 0-10 range
        return min(max(score, 0), 10)
    }
    
    // Days between two dates
    private func daysBetween(_ startDate: Date, and endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    
    // Check if we need to record daily progress and do so
    private func checkAndRecordDailyProgress() {
        let calendar = Calendar.current
        
        if let lastDate = lastAnalysisDate,
           !calendar.isDateInToday(lastDate) {
            // It's a new day since we last recorded progress
            recordDailyProgress()
            lastAnalysisDate = Date()
        }
    }
    
    // Record daily progress
    private func recordDailyProgress() {
        // Generate summary
        let summary = generateDailyProgressSummary()
        
        // Save it
        saveDailyProgress(summary)
    }
    
    // Generate daily progress summary
    private func generateDailyProgressSummary() -> DailyProgressSummary {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Fetch completed and total tasks
        let completedTasks = coreDataManager.fetchTasks(completed: true)
        let allTasks = coreDataManager.fetchTasks()
        
        // Count tasks completed today
        let todayCompletedTasks = completedTasks.filter { task in
            if let completedDate = task.value(forKey: "completedAt") as? Date {
                return calendar.isDateInToday(completedDate)
            }
            return false
        }
        
        let completedCount = todayCompletedTasks.count
        let totalTaskCount = allTasks.count
        let completionRate = totalTaskCount > 0 ? Double(completedCount) / Double(totalTaskCount) : 0.0
        
        // Get quote
        let quote = getRandomMotivationalQuote()
        
        // Generate analysis
        let analysis: String
        let suggestedActions: [String]
        
        if completedCount == 0 && totalTaskCount > 0 {
            analysis = "You haven't completed any tasks today. Let's get started!"
            suggestedActions = [
                "Begin with the easiest task to build momentum",
                "Set aside 25 minutes of focused work time",
                "Break down a large task into smaller steps"
            ]
        } else if completionRate < 0.25 {
            analysis = "You're making some progress. Keep going!"
            suggestedActions = [
                "Try prioritizing your most important task next",
                "Schedule specific time blocks for focused work",
                "Consider which tasks you can delegate or postpone"
            ]
        } else if completionRate < 0.5 {
            analysis = "You're making steady progress. Good work!"
            suggestedActions = [
                "Take a short break before tackling your next task",
                "Review your remaining tasks and adjust priorities if needed",
                "Consider which tasks align best with your goals"
            ]
        } else if completionRate < 0.75 {
            analysis = "Great job on your progress today! You're on a roll."
            suggestedActions = [
                "Maintain your momentum with another focused work session",
                "Review tomorrow's tasks to prepare mentally",
                "Celebrate your progress so far"
            ]
        } else {
            analysis = "Exceptional progress today! You're crushing your tasks."
            suggestedActions = [
                "Take time to reflect on what worked well today",
                "Plan tomorrow's priorities",
                "Reward yourself for a productive day"
            ]
        }
        
        return DailyProgressSummary(
            date: today,
            completedTaskCount: completedCount,
            totalTaskCount: totalTaskCount,
            completionRate: completionRate,
            motivationalQuote: quote,
            progressAnalysis: analysis,
            suggestedActions: suggestedActions
        )
    }
    
    // Save daily progress to history
    private func saveDailyProgress(_ summary: DailyProgressSummary) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: summary.date)
        
        // Create dictionary for storage
        var historyDict = completionHistory
        historyDict[dateString] = [
            "completedCount": summary.completedTaskCount,
            "totalCount": summary.totalTaskCount,
            "completionRate": summary.completionRate,
            "quote": summary.motivationalQuote,
            "analysis": summary.progressAnalysis,
            "actions": summary.suggestedActions
        ]
        
        // Limit history to 30 days
        if historyDict.count > 30 {
            // Sort keys by date
            let sortedKeys = historyDict.keys.sorted { dateStr1, dateStr2 in
                if let date1 = dateFormatter.date(from: dateStr1),
                   let date2 = dateFormatter.date(from: dateStr2) {
                    return date1 < date2
                }
                return false
            }
            
            // Remove oldest entries
            let keysToRemove = sortedKeys.prefix(historyDict.count - 30)
            for key in keysToRemove {
                historyDict.removeValue(forKey: key)
            }
        }
        
        // Save updated history
        completionHistory = historyDict
    }
    
    // Get random motivational quote
    private func getRandomMotivationalQuote() -> String {
        return motivationalQuotes.randomElement() ?? "Every task completed is a step forward."
    }
} 