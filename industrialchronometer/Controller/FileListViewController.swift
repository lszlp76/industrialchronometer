//
//  FileListViewController.swift
//  industrialchronometer
//
//  Created by ulas özalp on 10.02.2022.
//  Updated for Button Actions on 24.11.2025
//

import UIKit

class FileListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    var fileListArray: [String] = []
    @IBOutlet weak var fileList: UITableView!
   
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("📂 FileList Görüntülendi - Liste Yenileniyor...")
        reloadFiles()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        fileList.delegate = self
        fileList.dataSource = self
        // --- EKLENMESİ GEREKEN KISIM BAŞLANGIÇ ---
                // Xib dosyasını (Tasarımı) TableView'a tanıtıyoruz.
                // Dosya adı: "FileTableViewCell", Reuse Identifier: "fileNameCell"
                let nib = UINib(nibName: "FileTableViewCell", bundle: nil)
        
        
                fileList.register(nib, forCellReuseIdentifier: "fileNameCell")
                // --- EKLENMESİ GEREKEN KISIM BİTİŞ ---
        // İlk yükleme
        fileList.backgroundColor = .clear
        fileList.backgroundView?.backgroundColor = .clear
        tableView.backgroundView?.backgroundColor = .clear
        reloadFiles()
        
        // Pull to Refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        fileList.rowHeight = 60
        fileList.addSubview(refreshControl)
        // TEMA DİNLEYİCİSİ
                NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { [weak self] _ in
                    self?.fileList.reloadData()
                }
    }
    
    // MARK: - Data Loading
    
    func reloadFiles() {
        fileListArray = TransferService.sharedInstance.getSavedFile()
        DispatchQueue.main.async {
            self.fileList.reloadData()
        }
    }
    
    @objc func refresh() {
        print("Manuel yenileme yapılıyor...")
        reloadFiles()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Actions Logic
    
    func shareFile(at index: Int) {
        let fileNameSelected = fileListArray[index]
        let title = fileNameSelected
        let icon = UIImage(named: "logo1") ?? UIImage(systemName: "doc.text")
        let subText = "Your file is ready to share!"
        
        let pathString = TransferService.sharedInstance.shareFileWith(fileNameSelected: fileNameSelected)
//        let fileURL = URL(String: TransferService.sharedInstance
//                .shareFileWith(fileNameSelected: fileNameSelected)
//        )
        let fileURL = URL(string: (TransferService.sharedInstance.shareFileWith(fileNameSelected: fileNameSelected)))

        let itemSource : [Any] = [ MyActivityItemSource(
            title: title,
            text: subText,
            icon: icon,
            file:fileURL
        )]
        // Activity View Controller'ı başlat
            let activityViewController = UIActivityViewController(activityItems: itemSource, applicationActivities: nil)
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func deleteFile(at indexPath: IndexPath) {
        let fileName = fileListArray[indexPath.row]
        
        let alert = UIAlertController(title: "Delete File", message: "Delete '\(fileName)' permanently?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Dosyayı sil
            TransferService.sharedInstance.deleteDataFile(fileNameSelected: fileName)
            
            // Listeden ve Tablodan sil
            self.fileListArray.remove(at: indexPath.row)
            self.fileList.deleteRows(at: [indexPath], with: .fade)
            
            // Eğer liste boşalırsa veya indexler kayarsa diye reload atmak bazen daha güvenlidir ama animasyon için deleteRows iyidir.
            // self.fileList.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Standart cell yerine Custom Cell (FileTableViewCell) kullanıyoruz
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "fileNameCell", for: indexPath) as? FileTableViewCell else {
            return UITableViewCell() // Hata durumunda boş hücre
        }
        
        // Label'ı ayarla
        cell.fileNameLabel.text = fileListArray[indexPath.row]
        
        // 1. Share Butonuna Tıklanınca Ne Olsun?
        cell.onShareTapped = { [weak self] in
            self?.shareFile(at: indexPath.row)
        }
        
        // 2. Delete Butonuna Tıklanınca Ne Olsun?
        cell.onDeleteTapped = { [weak self] in
            self?.deleteFile(at: indexPath)
        }
        
        return cell
    }
    
    // MARK: - Interaction Control
    
    // Short Press (Tıklama) İptali
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Hiçbir şey yapma, sadece seçimi kaldır (görsel efekt kalmasın diye)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // Long Press / Swipe İptali
    // Swipe action fonksiyonlarını sildiğimiz için (trailingSwipeActionsConfigurationForRowAt vb.)
    // ve didSelectRow'u boşalttığımız için etkileşimler sadece butonlar üzerinden olacaktır.
    
    // Hücrenin "Highlight" (Basılı tutunca kararma) özelliğini kapatmak için:
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
