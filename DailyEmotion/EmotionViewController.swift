//
//  EmotionViewController.swift
//  DailyEmotion
//
//  Created by 이충현 on 2021/03/08.
//

import UIKit
import SwipeCellKit



class EmotionViewController: UIViewController, SwipeCollectionViewCellDelegate{
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        guard orientation == .right else { return nil }

         let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            (self.collectionView.cellForItem(at: indexPath) as? EmotionListCell)?.deleteButtonTapHandler?()
         
         }
          deleteAction.image = UIImage(named: "delete")

         return [deleteAction]
    }
    
    
    @IBOutlet var addBtnView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
        
    let emotionListViewModel = EmotionViewModel()
  
    override func viewDidLoad() {
        
          super.viewDidLoad()
        
        addBtnView.layer.cornerRadius = addBtnView.frame.width / 2
        addBtnView.layer.cornerRadius = addBtnView.frame.height / 2
        
        let plist = UserDefaults.standard
        let darkModeSelect = plist.integer(forKey: "darkModeSelect")
        
        if darkModeSelect == 0 {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .unspecified
                }
        } else if darkModeSelect == 1 {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        } else {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        }
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
                if launchedBefore
                {
                    print("Not first launch.")
                }
                else
                {
                    print("First launch")
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                    
                }
        emotionListViewModel.loadTasks()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        collectionView.reloadData()
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController = segue.destination as? DetailViewController else {
            return
        }

        
        guard let indexp: [IndexPath]? = collectionView.indexPathsForSelectedItems else {
            return
        }
        
        //for id in indexp! {
        var cc = (collectionView.cellForItem(at: indexp![0]) as? EmotionListCell)
        nextViewController.detailViewText = cc?.descriptionLabel.text
        //}
        
        
//
//        selectedCell = collectionView.cellForItem(at: indexp) as? EmotionListCell
//
//
//        nextViewController.detailViewText = selectedCell?.descriptionLabel.text
        
    }
    
    
}

extension EmotionViewController {
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
    }
}

extension EmotionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emotionListViewModel.numOfSection
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emotionListViewModel.todayEmotions.count
        } else {
            return emotionListViewModel.beforeEmotions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmotionListCell", for: indexPath) as? EmotionListCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
    
        var emotion: Emotion
        if indexPath.section == 0 {
            emotion = emotionListViewModel.todayEmotions[indexPath.item]
        } else {
            emotion = emotionListViewModel.beforeEmotions[indexPath.item]
        }
        cell.updateUI(emotion: emotion)
        
        cell.deleteButtonTapHandler = {
            self.emotionListViewModel.deleteEmotion(emotion)
            self.collectionView.reloadData()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmotionListHeaderView", for: indexPath) as? EmotionListHeaderView else {
                return UICollectionReusableView()
            }
            
            guard let section = EmotionViewModel.Section(rawValue: indexPath.section) else {
                return UICollectionReusableView()
            }
            
            header.sectionTitleLabel.text = section.title
            return header
        default:
            return UICollectionReusableView()
        }
    
    }
    
}

extension EmotionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 70
        return CGSize(width: width, height: height)
    }
}








class EmotionListCell: SwipeCollectionViewCell {
    
    @IBOutlet weak var myEmotion: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var deleteButtonTapHandler: (() -> Void)?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    
    func updateUI(emotion: Emotion) {
        
        descriptionLabel.text = emotion.detail
        dateLabel.text = emotion.isToday
        
        
        if emotion.isSad {
            myEmotion.text = "🟪"
        } else if emotion.isBad{
            myEmotion.text = "🟦"
        } else if emotion.isUsually{
            myEmotion.text = "⬛️"
        } else if emotion.isPleasure{
            myEmotion.text = "🟩"
        } else if emotion.isHappy{
            myEmotion.text = "🟥"
        }else {
            myEmotion.text = "⬛️"
        }
    }
    
    
    func reset() {
        descriptionLabel.alpha = 1
//        deleteButton.isHidden = true
    }
//    @IBAction func deleteButtonTapped(_ sender: Any) {
//        print("삭제가되나요")
//        //여기 얼럿을 띄워 삭제할건지 물어보기
//
//        deleteButtonTapHandler?()
//    }

    
}
// MARK - SwipeCollectionViewCellDelegate
extension EmotionListCell: SwipeCollectionViewCellDelegate{
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

         let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
         
            
         }

         // customize the action appearance
         deleteAction.image = UIImage(named: "delete")
        
         return [deleteAction]
    }

    //셀액션에 대한 옵션 설정
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .drag
        return options
    }
    
    

}

class EmotionListHeaderView: UICollectionReusableView {

    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

