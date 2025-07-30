import Foundation

class TaskManager {
    // MARK: - Properties
    static let shared = TaskManager()
    private let taskKey = "savedTask"
    private init () {}
    
    // MARK: - Actions
    // сохранение заметки
    func saveTasks(_ task: [Task]) {
        if let data = try? JSONEncoder().encode(task) {
            UserDefaults.standard.set(data, forKey: taskKey)
        }
    }
    // загрузка заметки
    func loadTasks() -> [Task] {
        if let data = UserDefaults.standard.data(forKey: taskKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            return decodedTasks
        }
        return []
    }
    // добавление новой заметки
    func addTask(_ newTask: Task) {
        var tasks = loadTasks()
        tasks.append(newTask)
        saveTasks(tasks)
    }
    // редактирование существующей заметки
    func updateTask(_ updateTask: Task) {
        var tasks = loadTasks()
        if let index = tasks.firstIndex(where: { $0.id == updateTask.id }) {
            tasks[index] = updateTask
            saveTasks(tasks)
        }
    }
    // удаление заметки
    func deleteTask(withId id: UUID) {
        var tasks = loadTasks()
        tasks.removeAll { $0.id == id }
        saveTasks(tasks)
    }
    // отметить задачу как выполненную/невыполненную
    func toggleTaskCompletion(withId id: UUID) {
        var tasks = loadTasks()
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
            saveTasks(tasks)
        }
    }
}

