

import UIKit

class TodoListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var isTodayButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    
    // TodoViewModel
    let todoListViewModel = TodoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 키보드 디텍션
        
        
        // 디스크에 있는 데이터 불러오기
        todoListViewModel.loadTasks()
        
        
        let todo = TodoManager.shared.createTodo(detail: "히히호호", isToday: true)
        Storage.saveTodo(todo, fileName: "test.json")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let todo = Storage.restoreTodo("test.json")
        print("---> \(todo)")
    }
    
    @IBAction func isTodayButtonTapped(_ sender: Any) {
        // TODO: 투데이 버튼 토글 작업
         
    }
    
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        // TODO: Todo 태스크 추가
        // add task to view model
        // and tableview reload or update
    }
    
    // TODO: BG 탭했을때, 키보드 내려오게 하기
}

extension TodoListViewController {
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        // TODO: 키보드 높이에 따른 인풋뷰 위치 변경
        
    }
}

extension TodoListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //  섹션 몇개
        return todoListViewModel.numOfSection
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 섹션별 아이템 몇개
        
        if section == 0 {//today
            return todoListViewModel.todayTodos.count
        }else{
            return todoListViewModel.upcompingTodos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as? TodoListCell else {
            return UICollectionViewCell()
        }
        return cell
        
        
        // 커스텀 셀
        var todo : Todo
        if indexPath.section == 0 {
            todo = todoListViewModel.todayTodos[indexPath.item]
        } else{
            todo = todoListViewModel.upcompingTodos[indexPath.item]
        }
        cell.updateUI(todo: todo)// todo 를 이용해서 updateUI
        
        
        
        // TODO: doneButtonHandler 작성
        // TODO: deleteButtonHandler 작성
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TodoListHeaderView", for: indexPath) as? TodoListHeaderView else {
                return UICollectionReusableView()
            }
            
            guard let section = TodoViewModel.Section(rawValue: indexPath.section) else {
                return UICollectionReusableView()
            }
            
            header.sectionTitleLabel.text = section.title
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

extension TodoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 사이즈 계산하기
        let width : CGFloat = collectionView.bounds.width
        let height :CGFloat = 50
        return CGSize(width: width, height: height)
    }
}

class TodoListCell: UICollectionViewCell {
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var strikeThroughView: UIView! // strikeThroughView: task 완료했을 때 선 = 크기 1짜리 뷰 셀
    @IBOutlet weak var strikeThroughWidth: NSLayoutConstraint!
    
    var doneButtonTapHandler: ((Bool) -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func updateUI(todo: Todo) {
        // 셀 업데이트 하기
        checkButton.isSelected = todo.isDone
        descriptionLabel.text = todo.detail
        descriptionLabel.alpha = todo.isDone ? 0.2 : 1
        deleteButton.isHidden = todo.isDone == false
        showStrikeThrough(todo.isDone)
    }
    
    private func showStrikeThrough(_ show: Bool) { // task 완료했을 때 찍 긋는 선의 width = 0 -> 안보임 = 완료x, width = 가로길이 = 완료
        if show {
            strikeThroughWidth.constant = descriptionLabel.bounds.width
        } else {
            strikeThroughWidth.constant = 0
        }
    }
    
    func reset() {
        // 각 셀이 재사용 되기 때문에 isSelected 같은 값들을 초기값으로 바꾸는 것이 필요
        
        // reset로직 구현
        descriptionLabel.alpha = 1
        deleteButton.isHidden = true
        showStrikeThrough(false)
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        // checkButton 처리
        // 뷰 업데이트
        checkButton.isSelected = !checkButton.isSelected
        let isDone = checkButton.isSelected
        showStrikeThrough(isDone)
        descriptionLabel.alpha = isDone ? 0.2 : 1
        deleteButton.isHidden = !isDone
        
        doneButtonTapHandler?(isDone) // 데이터 업데이트
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // deleteButton 처리
        deleteButtonTapHandler?() // 데이터 업데이트, 뷰 업데이트
    }
}

class TodoListHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
