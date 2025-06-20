import UIKit

class TaskCell: UITableViewCell {
    
    // Идентификатор для переиспользования ячейки
    static let reuseId = "TaskCell"
    
    // UI-элементы ячейки:
    private let titleLabel = UILabel()
    private let priorityView = UIView()
    private let completionButton = UIButton()
    
    // Замыкание, вызываемое при нажатии на кнопку выполнения
    var completionHandler: (() -> Void)?
    
    // Инициализатор ячейки
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.textColor = .white
        
        
        
        // Настройка кнопки выполнения
        completionButton.layer.borderWidth = 1
        completionButton.layer.borderColor = UIColor.systemGray.cgColor
        completionButton.layer.cornerRadius = 12
        completionButton.addTarget(self, action: #selector(completionTapped), for: .touchUpInside)
        
        // Настройка метки
        titleLabel.numberOfLines = 0
        
        // Настройка view приоритета
        priorityView.layer.cornerRadius = 4
        
        // Добавление элементов на ячейку
        contentView.addSubview(priorityView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(completionButton)
        
        // Констрейнты
        priorityView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: completionButton.leadingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with task: Task) {
        titleLabel.text = task.title
        priorityView.backgroundColor = task.priority.color
        
        if task.isCompleted {
            completionButton.backgroundColor = .systemGreen
            completionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completionButton.tintColor = .white
            titleLabel.textColor = .systemGray
        } else {
            completionButton.backgroundColor = .clear
            completionButton.setImage(nil, for: .normal)
            titleLabel.textColor = .label
        }
    }
    
    @objc private func completionTapped() {
        completionHandler?()
    }
}
