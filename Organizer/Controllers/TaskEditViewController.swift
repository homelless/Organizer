

import UIKit

class TaskEditViewController: UIViewController {
    
    var task: Task?
    var completion: ((Task) -> Void)?
    private let manager = TaskManager.shared
    
    private let titleTextField = UITextField()
    private let prioritySegmentedControl = UISegmentedControl(items: Task.Priority.allCases.map { $0.rawValue })
    private let saveButton = UIButton(type: .system)
    private let descriptionTextView = UITextView()
    private let placeholderLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlaceholder()
        setupConstraints()
        setupData()
        setupTextViewDelegate()
    }
    
    private func setupUI() {
        title = task == nil ? "Новая задача" : "Редактировать"
        view.backgroundColor = .black
        
        
        // Настройка текстового поля
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "Новая задача..",
            attributes: [
                .foregroundColor: UIColor.lightGray.withAlphaComponent(0.8), // Прозрачность = яркость
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        titleTextField.borderStyle = .roundedRect
        titleTextField.layer.cornerRadius = 8
        titleTextField.textColor = .white
        titleTextField.layer.borderColor = UIColor.white.cgColor
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.masksToBounds = true
        titleTextField.backgroundColor = .black
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.returnKeyType = .done
        titleTextField.delegate = self
        view.addSubview(titleTextField)
        
        // Настройка сегментированного контрола
        prioritySegmentedControl.selectedSegmentIndex = 1
        prioritySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        prioritySegmentedControl.selectedSegmentTintColor = .black
        prioritySegmentedControl.backgroundColor = .black
        prioritySegmentedControl.tintColor = .white
        prioritySegmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14)
        ], for: .normal)
        prioritySegmentedControl.layer.borderColor = UIColor.white.cgColor
        prioritySegmentedControl.layer.borderWidth = 1
        prioritySegmentedControl.layer.masksToBounds = true
        view.addSubview(prioritySegmentedControl)
        
        
        descriptionTextView.isScrollEnabled = true
        descriptionTextView.textColor = .white
        descriptionTextView.backgroundColor = .black
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderColor = UIColor.white.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.delegate = self
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.returnKeyType = .done
        view.addSubview(descriptionTextView)
        
        // Настройка кнопки сохранения
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.backgroundColor = .black
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.borderWidth = 1
        saveButton.layer.masksToBounds = true
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            prioritySegmentedControl.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            prioritySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            prioritySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            prioritySegmentedControl.heightAnchor.constraint(equalToConstant: 35),
            
            descriptionTextView.topAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 250),
            
            saveButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTextViewDelegate() {
           descriptionTextView.delegate = self
       }
    
    
    private func setupPlaceholder() {
        placeholderLabel.text = "Описание задачи.."
        placeholderLabel.textColor = .lightGray.withAlphaComponent(0.8)
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -8)
        ])
        
        updatePlaceholderVisibility()
    }

    private func setupData() {
        guard let task = task else { return }
        titleTextField.text = task.title
        prioritySegmentedControl.selectedSegmentIndex = Task.Priority.allCases.firstIndex(of: task.priority) ?? 1
        descriptionTextView.text = task.description ?? ""
        placeholderLabel.isHidden = !descriptionTextView.text.isEmpty
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите название задачи")
            return
        }
    
        
        let priority = Task.Priority.allCases[prioritySegmentedControl.selectedSegmentIndex]
           let descriptionText = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
           let description = descriptionText.isEmpty ? nil : descriptionText
           
        
        if let task = task {
            // редактирование существующей задачи
           let updateTask = Task(
            id: task.id,
            title: title,
            isCompleted: task.isCompleted,
            priority: priority,
            description: description
           )
            
            manager.updateTask(updateTask)
            completion?(updateTask)
        } else {
            // создание новой задачи
            let newTask = Task(
                title: title,
                isCompleted: false,
                priority: priority,
                description: description?.isEmpty ?? true ? nil : description,
            )
            manager.addTask(newTask)
            completion?(newTask)
        }
       
        navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updatePlaceholderVisibility() {
            placeholderLabel.isHidden = !descriptionTextView.text.isEmpty
        }
    
    

}

extension TaskEditViewController: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
