//import Cocoa
//
//class FBrowserController: NSViewController {
//    @IBOutlet weak var collectionView: NSCollectionView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
////        imageDirectoryLoader.loadDataForFolderWithUrl(initialFolderUrl)
//        
//        configureCollectionView()
//    }
//    
//    func loadDataForNewFolderWithUrl(_ folderURL: URL) {
////        imageDirectoryLoader.loadDataForFolderWithUrl(folderURL)
//        collectionView.reloadData()
//    }
//    
//    fileprivate func configureCollectionView() {
//        let flowLayout = NSCollectionViewFlowLayout()
//        flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
//        flowLayout.sectionInset = NSEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0)
//        flowLayout.minimumInteritemSpacing = 20.0
//        flowLayout.minimumLineSpacing = 20.0
//        flowLayout.sectionHeadersPinToVisibleBounds = true
//        
//        
//        
//        
//        collectionView.collectionViewLayout = flowLayout
//        view.wantsLayer = true
//        collectionView.layer?.backgroundColor = NSColor.black.cgColor
//        
//        collectionView.allowsMultipleSelection = true
//    }
//    
//    @IBAction func showHideSections(sender: NSButton) {
//        let show = sender.state
////        imageDirectoryLoader.singleSectionMode = (show == NSControl.StateValue.off)
////        imageDirectoryLoader.setupDataForUrls(nil)
//        collectionView.reloadData()
//    }
//}
//
//extension FBrowserController : NSCollectionViewDataSource {
////
////    func numberOfSections(in collectionView: NSCollectionView) -> Int {
////        return 1
////    }
////
////    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
////        return imageDirectoryLoader.numberOfItemsInSection(section)
////    }
//    
//    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
//        
//        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"), for: indexPath)
//        
//        guard let collectionViewItem = item as? CollectionViewItem else {return item}
//        
////        let imageFile = imageDirectoryLoader.imageFileForIndexPath(indexPath)
////        collectionViewItem.imageFile = imageFile
//        
//        return item
//    }
//    
//    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
//        let view = collectionView.makeSupplementaryView(ofKind: NSCollectionView.elementKindSectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderView"), for: indexPath) as! HeaderView
//        view.sectionTitle.stringValue = "Section \(indexPath.section)"
////        let numberOfItemsInSection = imageDirectoryLoader.numberOfItemsInSection(indexPath.section)
////        view.imageCount.stringValue = "\(numberOfItemsInSection) image files"
//        return view
//    }
//    
//}
//
////extension FBrowserController : NSCollectionViewDelegateFlowLayout {
////  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
////    return imageDirectoryLoader.singleSectionMode ? NSZeroSize : NSSize(width: 1000, height: 40)
////  }
////}
