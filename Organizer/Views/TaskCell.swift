import UIKit

class TaskCell: UITableViewCell {
    
    // MARK: - Properties
    // Идентификатор для переиспользования ячейки
    static let reuseId = "TaskCell"
    
    // UI-элементы ячейки:
    private let titleLabel = UILabel()
    private let priorityView = UIView()
    private let completionButton = UIButton()
    private let descriptionView = UIImageView()
    private let dateLabel = UILabel()
    
    // Замыкание, вызываемое при нажатии на кнопку выполнения
    var completionHandler: (() -> Void)?
    
    // MARK: - Lifecycle
    // Инициализатор ячейки
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .black
    
        // Настройка картинки описания
        descriptionView.isHidden = true
        
        // Настройка кнопки выполнения
        completionButton.layer.borderWidth = 1
        completionButton.layer.borderColor = UIColor.systemGray.cgColor
        completionButton.layer.cornerRadius = 12
        completionButton.addTarget(self, action: #selector(completionTapped), for: .touchUpInside)
        
        // Настройка заметки
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        // Настройка отображения даты
        dateLabel.textColor = .red
        dateLabel.backgroundColor = .black
        dateLabel.font = UIFont.systemFont(ofSize: 10)
        
        
        // Настройка view приоритета
        priorityView.layer.cornerRadius = 4
        
        // Добавление элементов на ячейку
        contentView.addSubview(descriptionView)
        contentView.addSubview(priorityView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(completionButton)
        contentView.addSubview(dateLabel)
        
        // Констрейнты
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        priorityView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            priorityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priorityView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priorityView.widthAnchor.constraint(equalToConstant: 8),
            priorityView.heightAnchor.constraint(equalToConstant: 8),
            
            completionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            completionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completionButton.widthAnchor.constraint(equalToConstant: 24),
            completionButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: priorityView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: completionButton.leadingAnchor, constant: -30),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            descriptionView.trailingAnchor.constraint(equalTo: completionButton.trailingAnchor, constant: -30),
            descriptionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            descriptionView.widthAnchor.constraint(equalToConstant: 24),
            descriptionView.heightAnchor.constraint(equalToConstant: 24),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            dateLabel.leadingAnchor.constraint(equalTo: priorityView.trailingAnchor, constant: 12)
        ])
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    //MARK: - Actions
    // Настройка отображения ячейки под данные заметки
    func configure(with task: Task) {
        titleLabel.text = task.title
        priorityView.backgroundColor = task.priority.color
        
        
        if let description = task.description, !description.isEmpty {
                descriptionView.isHidden = false
                descriptionView.image = UIImage(systemName: "line.horizontal.3")
                descriptionView.backgroundColor = .black
                descriptionView.tintColor = .white
            } else {
                descriptionView.isHidden = true
            }
        
        if task.isCompleted {
            completionButton.backgroundColor = .white
            completionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completionButton.tintColor = .black
            titleLabel.textColor = .systemGray
        } else {
            completionButton.backgroundColor = .clear
            completionButton.setImage(nil, for: .normal)
            titleLabel.textColor = .white
        }
        guard task.date != nil else { return }
        dateLabel.text = formatDate(task.date!)
    }
    
    // Метод для передачи нажатия на кнопку 
    @objc private func completionTapped() {
        completionHandler?()
    }
}
