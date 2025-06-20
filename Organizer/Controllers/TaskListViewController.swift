
import UIKit

class TaskListViewController: UIViewController {
    
    // MARK: - Properties
    private var tasks: [Task] = []
    private let tableView = UITableView()
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Мои задачи"
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
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        let editVC = TaskEditViewController()
        editVC.completion = { [weak self] newTask in
            self?.tasks.append(newTask)
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func toggleTaskCompletion(at indexPath: IndexPath) {
        tasks[indexPath.row].isCompleted.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
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
            self?.tasks[indexPath.row] = updatedTask
            self?.tableView.reloadData()
        }
        
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
