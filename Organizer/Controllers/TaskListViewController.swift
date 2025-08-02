import UIKit

class TaskListViewController: UIViewController {
    
    // MARK: - Properties
    private var tasks: [Task] = []
    private let tableView = UITableView()
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private var titleLabel = UILabel()
    private var prioritySegmentedControl = UISegmentedControl()
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
        navigationController?.navigationBar.isTranslucent = false
        
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
        
        // Настройка сегментов приоритета
        prioritySegmentedControl.insertSegment(withTitle: "Все", at: 0, animated: false)
        prioritySegmentedControl.insertSegment(withTitle: "Когда-то", at: 1, animated: false)
        prioritySegmentedControl.insertSegment(withTitle: "Надо бы", at: 2, animated: false)
        prioritySegmentedControl.insertSegment(withTitle: "Срочно", at: 3, animated: false)
        prioritySegmentedControl.selectedSegmentIndex = 0
        prioritySegmentedControl.backgroundColor = .darkGray
        prioritySegmentedControl.tintColor = .white
        prioritySegmentedControl.apportionsSegmentWidthsByContent = true
        prioritySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        prioritySegmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(prioritySegmentedControl)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            prioritySegmentedControl.topAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.topAnchor, constant: 8),
            prioritySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            prioritySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            prioritySegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            tableView.topAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        manager.saveTasks(tasks)
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        saveTasks()
        tableView.reloadData()
    }
    
    private func toggleTaskCompletion(at indexPath: IndexPath) {
        tasks[indexPath.row].isCompleted.toggle()
        
        if tasks[indexPath.row].isCompleted {
            //Анимация заверешения
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                if let cell = self.tableView.cellForRow(at: indexPath) as? TaskCell {
                    cell.configure(with: self.tasks[indexPath.row])
                }
            } completion: { [weak self] _ in
                self?.deleteTask(at: indexPath)
            }
        } else{
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        manager.deleteTask(withId: tasks[indexPath.row].id)
    }


    // MARK: - Actions
    private func filterTasks(by priority: Task.Priority? = nil) {
        let allTasks = manager.loadTasks()
        tasks = priority == nil ? allTasks : allTasks.filter { $0.priority == priority!
        }
        tableView.reloadData()
    }
    
    // Метод для добавления новой заметки
    @objc private func addButtonTapped() {
        let editVC = TaskEditViewController()
        editVC.completion = { [weak self] newTask in
            self?.addTask(newTask)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    // Метод для перехода к списку задач с одинаковым приоритетом
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let priority: Task.Priority? = {
            switch sender.selectedSegmentIndex {
            case 0: return nil
            case 1: return .low
            case 2: return .medium
            case 3: return .high
            default: return nil
            }
        }()
        filterTasks(by: priority)
    }
}

// MARK: - UITableView DataSource & Delegate
extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    // Отображение ячейки в таблице
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseId, for: indexPath) as! TaskCell
        let task = tasks[indexPath.row]
        cell.configure(with: task)
        cell.selectionStyle = .none
        
        // Обработчик завершения задачи
        cell.completionHandler = { [weak self, weak cell] in
            guard
                let self = self,
                let cell = cell,
                let indexPath = self.tableView.indexPath(for: cell)
            else { return }
            self.toggleTaskCompletion(at: indexPath)
        }
        return cell
    }
    
    // Метод для редактирования ячейки при нажатии на нее
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = tasks[indexPath.row]
        let editVC = TaskEditViewController()
        editVC.task = task
        
        // замыкание, которое сработает после редактирования и обновит задачу
        editVC.completion = { [weak self] updatedTask in
            self?.updateTask(updatedTask, at: indexPath)
        }
        
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    // Удаление заметки по свайпу влево
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteTask(at: indexPath)
            
        }
    }
    
    // Метод для редактирования строк таблицы 
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
