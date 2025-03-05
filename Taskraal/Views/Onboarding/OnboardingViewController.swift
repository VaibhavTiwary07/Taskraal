//
//  OnboardingViewController.swift
//  Taskraal
//
//  Created by Vaibhav  Tiwary on 03/03/25.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var OnboardingCollectionView: UICollectionView!
    var slides :[OnboardingSlide] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OnboardingCollectionView.delegate = self
        OnboardingCollectionView.dataSource = self

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func nextButtonClicked(_ sender: Any) {
    }
    

}
extension OnboardingViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        
        return cell
    }
    
    
    
}
