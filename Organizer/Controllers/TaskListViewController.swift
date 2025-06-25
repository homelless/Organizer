
import UIKit

class TaskListViewController: UIViewController {
    
    // MARK: - Properties
    private var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }
    private let tableView = UITableView()
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private var titleLabel = UILabel()
    private var manager = TaskManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadTasks()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        // Оформление заголовка
        navigationItem.title = "Мои задачи"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        navigationController?.navigationBar.barTintColor = .black
        
        
        
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        addButton.tintColor = .white
        
        
        // Настройка таблицы
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        
        // Настройка кнопки добавления
        navigationItem.rightBarButtonItem = addButton
        addButton.target = self
        addButton.action = #selector(addButtonTapped)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Management
    private func loadTasks() {
        tasks = manager.loadTasks()
        tableView.reloadData()
    }
    
    private func saveTasks() {
        manager.saveTasks(tasks)
    }
    
    private func addTask(_ task: Task) {
        let newIndexPath = IndexPath(row: tasks.count, section: 0)
        tasks.append(task)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    private func updateTask(_ task: Task, at indexPath: IndexPath) {
        tasks[indexPath.row] = task
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    private func toggleTaskCompletion(at indexPath: IndexPath) {
        tasks[indexPath.row].isCompleted.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        if tasks[indexPath.row].isCompleted {
            //задежка перед удалением кнопки после анимации
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.deleteTask(at: indexPath)
            }
        }
    }
    
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let editVC = TaskEditViewController()
        editVC.completion = { [weak self] newTask in
            self?.addTask(newTask)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate
extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseId, for: indexPath) as! TaskCell
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        
        cell.completionHandler = { [weak self] in
            self?.toggleTaskCompletion(at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = tasks[indexPath.row]
        let editVC = TaskEditViewController()
        editVC.task = task
        
        editVC.completion = { [weak self] updatedTask in
            self?.updateTask(updatedTask, at: indexPath)
        }
        
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteTask(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
