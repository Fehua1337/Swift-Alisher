//
//  ViewController.swift
//  WarriorGame
//
//  Created by Alisher Tulembekov on 19.03.2024.
//

import UIKit
import SnapKit
import RealmSwift

class ViewController: UIViewController {
    
    var FirstActionWarrior = 0
    var SecondActionWarrior = 1
    
    
    let realm = try! Realm()
    
    var warriors = [warrior]() {
        didSet {
            tableViewName.reloadData()
        }
    }
    
    lazy var textFieldName: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter name of warrior"
        field.borderStyle = .roundedRect
        return field
    }()
    
    lazy var nameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Enter", for: .normal)
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(enterName), for: .touchUpInside)
        return button
    }()
    
    lazy var tableViewName: UITableView = {
        let field = UITableView()
        field.delegate = self
        field.dataSource = self
        return field
    }()
    
    lazy var textLabelAction: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .systemGray4
        label.numberOfLines = 0
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("START", for: .normal)
        button.backgroundColor = .systemPurple
        button.addTarget(self, action: #selector(fightAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(textFieldName)
        view.addSubview(nameButton)
        view.addSubview(tableViewName)
        view.addSubview(textLabelAction)
        view.addSubview(actionButton)
        getWarriors()
        setUI()
    }
    
    func setUI() {
        textFieldName.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().inset(140)
            make.height.equalTo(80)
        }
        nameButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalTo(textFieldName.snp.trailing).offset(20)
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        tableViewName.snp.makeConstraints { make in
            make.top.equalTo(textFieldName.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(100)
        }
        textLabelAction.snp.makeConstraints { make in
            make.top.equalTo(tableViewName.snp.bottom).offset(60)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(150)
        }
        actionButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(80)
            make.height.equalTo(80)
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    @objc func enterName() {
        lazy var warrior = warrior()
        lazy var randomHealth = Int.random(in: 100...300)
        lazy var randomDamage = Int.random(in: 20...40)
        if textFieldName.text == "" {
            print ("Print name")
        } else {
            warrior.name = textFieldName.text ?? ""
            warrior.health = randomHealth
            warrior.damage = randomDamage
            textFieldName.text = ""
            try! realm.write {
                realm.add(warrior)
            }
            print (warrior)
        }
        getWarriors()
    }
    @objc func fightAction() {
        if realm.isInWriteTransaction {
            return
        }
        
        try! realm.write {
            guard warriors.count >= 2 else {
                textLabelAction.text = "\(warriors[0].name) остался один и победил в этом жестоком бою. У него осталось \(warriors[0].health) хп!"
                return
            }
            
            if SecondActionWarrior > warriors.count - 1 {
                FirstActionWarrior = 0
                SecondActionWarrior = 1
                warriors[FirstActionWarrior].health -= warriors[warriors.count - 1].damage
                if warriors[FirstActionWarrior].health <= 0 {
                    textLabelAction.text = "\(warriors[warriors.count - 1].name) нанес \(warriors[warriors.count - 1].damage) урона войну с именем \(warriors[FirstActionWarrior].name) и теперь его HP \(warriors[FirstActionWarrior].health). К сожалению, этот воин погиб в жестоком бою."
                    realm.delete(warriors[FirstActionWarrior])
                    getWarriors()
                } else {
                    textLabelAction.text = "\(warriors[warriors.count - 1].name) нанес \(warriors[warriors.count - 1].damage) урона войну с именем \(warriors[FirstActionWarrior].name) и теперь его HP \(warriors[FirstActionWarrior].health)"
                }
            } else {
                warriors[SecondActionWarrior].health -= warriors[FirstActionWarrior].damage
                if warriors[SecondActionWarrior].health <= 0 {
                    textLabelAction.text = "\(warriors[FirstActionWarrior].name) нанес \(warriors[FirstActionWarrior].damage) урона войну с именем \(warriors[SecondActionWarrior].name) и теперь его HP \(warriors[SecondActionWarrior].health). К сожалению, этот воин погиб в жестоком бою."
                    realm.delete(warriors[SecondActionWarrior])
                    getWarriors()
                } else {
                    textLabelAction.text = "\(warriors[FirstActionWarrior].name) нанес \(warriors[FirstActionWarrior].damage) урона войну с именем \(warriors[SecondActionWarrior].name) и теперь его HP \(warriors[SecondActionWarrior].health)"
                }
                FirstActionWarrior += 1
                SecondActionWarrior += 1
            }
        }
        print(warriors.count - 1)
        print(warriors)
    }
    private func getWarriors() {
        let warriors = realm.objects(warrior.self)
        
        self.warriors = warriors.map({ warrior in
            warrior
        })
    }
    private func editNameWarrior(name: String?, at index: Int) {
        let warrior = realm.objects(warrior.self)[index]
        try! realm.write({
            if let name = name, !name.isEmpty {
                warrior.name = name
            }
        })
    }
    private func deleteWarrior(_ warrior: warrior) {
        try! realm.write {
            realm.delete(warrior)
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        warriors.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = warriors[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            // Handle edit action
            self?.editWarriorsName(at: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            // Handle delete action
            self?.deleteWarrior(at: indexPath)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    private func editWarriorsName(at indexPath: IndexPath) {
        editNameWarrior(name: textFieldName.text, at: indexPath.row)
        textFieldName.text = ""
        getWarriors()
    }
    private func deleteWarrior(at indexPath: IndexPath){
        let warrior = warriors[indexPath.row]
        deleteWarrior(warrior)
        getWarriors()
    }
    
}
    

