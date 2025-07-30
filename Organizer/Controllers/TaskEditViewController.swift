

import UIKit

class TaskEditViewController: UIViewController {
    
    // MARK: - Properties
    public var task: Task?
    public var completion: ((Task) -> Void)?
    private let manager = TaskManager.shared
    private let titleTextField = UITextField()
    private let prioritySegmentedControl = UISegmentedControl(items: Task.Priority.allCases.map { $0.rawValue })
    private let saveButton = UIButton(type: .system)
    private let descriptionTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let containerView = UIView()
    private let dateLabel = UILabel()
    private let switchView = UISwitch()
    private let labelForDate = UILabel()
    
    private var containerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupUI()
        setupPlaceholder()
        setupConstraints()
        setupData()
        setupTextViewDelegate()
        setupHideKeyboardOnTap()
        setupKeyboardObservers()
        switchToDatePickerMode()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Настройка заголовка и фона
        title = task == nil ? "Новая задача" : "Редактировать"
        view.backgroundColor = .black
        
        
        // Настройка текстового поля
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "Новая задача..",
            attributes: [
                .foregroundColor: UIColor.lightGray.withAlphaComponent(0.8),
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
        contentView.addSubview(titleTextField)
        
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
        contentView.addSubview(prioritySegmentedControl)
        
        // Настройка даты
        containerView.layer.cornerRadius = 8
        containerView.backgroundColor = .black
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.cgColor
        contentView.addSubview(containerView)
        
        dateLabel.textColor = .white
        dateLabel.font = UIFont.systemFont(ofSize: 16)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "Дата"
        containerView.addSubview(dateLabel)
        
        labelForDate.text = nil
        labelForDate.textColor = .white
        labelForDate.font = UIFont.systemFont(ofSize: 16)
        labelForDate.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(labelForDate)
        
        switchView.isOn = false
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        containerView.addSubview(switchView)
        
        
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = .black
        datePicker.layer.cornerRadius = 4
        datePicker.tintColor = .white
        datePicker.setValue(UIColor.white, forKey: "textColor")
        if #available(iOS 13.0, *) {
            datePicker.overrideUserInterfaceStyle = .dark
        }
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.isHidden = !switchView.isOn
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        containerView.addSubview(datePicker)
        
        
        // Настройка поля описания
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
        contentView.addSubview(descriptionTextView)
        
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
        contentView.addSubview(saveButton)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupConstraints() {
        
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 50)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            prioritySegmentedControl.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            prioritySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            prioritySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            prioritySegmentedControl.heightAnchor.constraint(equalToConstant: 35),
            
            //контейнер с датой
            containerView.topAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerHeightConstraint,
          
            
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            
            labelForDate.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            labelForDate.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8),
            
            
            switchView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            switchView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            
            datePicker.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            datePicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            
            descriptionTextView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 250),
            
            saveButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupPlaceholder() {
        placeholderLabel.text = "Описание задачи.."
        placeholderLabel.textColor = .lightGray.withAlphaComponent(0.8)
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -8)
        ])
        updatePlaceholderVisibility()
    }
    // MARK: - Keyboard Handling
    // Метод для обработки появления и скрытия клавиатуры
      private func setupKeyboardObservers() {
          NotificationCenter.default.addObserver(
              self,
              selector: #selector(keyboardWillShow),
              name: UIResponder.keyboardWillShowNotification,
              object: nil
          )
          
          NotificationCenter.default.addObserver(
              self,
              selector: #selector(keyboardWillHide),
              name: UIResponder.keyboardWillHideNotification,
              object: nil
          )
      }
      
      @objc private func keyboardWillShow(notification: NSNotification) {
          guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
          let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
          scrollView.contentInset = contentInsets
          scrollView.scrollIndicatorInsets = contentInsets
      }
      
      @objc private func keyboardWillHide() {
          scrollView.contentInset = .zero
          scrollView.scrollIndicatorInsets = .zero
      }
    
    // MARK: - Data
    private func setupData() {
        guard let task = task else { return }
        titleTextField.text = task.title
        prioritySegmentedControl.selectedSegmentIndex = Task.Priority.allCases.firstIndex(of: task.priority) ?? 1
        descriptionTextView.text = task.description ?? ""
        
        if let date = task.date {
            datePicker.date = date
            labelForDate.text = formatDate(date)
            switchView.isOn = true
            datePicker.isHidden = false
            containerHeightConstraint.constant = 380
        }
        
        updatePlaceholderVisibility()
    }
    
    // MARK: - Actions
    @objc private func saveTapped() {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите название задачи")
            return
        }
        
        let priority = Task.Priority.allCases[prioritySegmentedControl.selectedSegmentIndex]
        let descriptionText = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = descriptionText.isEmpty ? nil : descriptionText
        let date = switchView.isOn ? datePicker.date : nil
        
        if let task = task {
            // редактирование существующей задачи
            let updateTask = Task(
                id: task.id,
                title: title,
                isCompleted: task.isCompleted,
                priority: priority,
                description: description,
                date: date
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
                date: date
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
    
    private func setupTextViewDelegate() {
        descriptionTextView.delegate = self
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !descriptionTextView.text.isEmpty
    }
    
    // метод для скрытия клавиатуры при тапе на другие элементы экрана
    private func setupHideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    // закрываем все текстовые поля
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func switchToDatePickerMode() {
        datePicker.isHidden = !switchView.isOn
        
        containerHeightConstraint.constant = switchView.isOn ? 380 : 50
        view.layoutIfNeeded()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        labelForDate.text = " - \(formatDate(sender.date))"
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        datePicker.isHidden = !sender.isOn
        
        UIView.animate(withDuration: 0.3) {
            self.containerHeightConstraint.constant = sender.isOn ? 380 : 50
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Delegates
extension TaskEditViewController: UITextViewDelegate, UITextFieldDelegate {
    
    // Метод для видимости placeholdera
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    // Скрытие клавиатуры при нажатии на Return оба метода
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
