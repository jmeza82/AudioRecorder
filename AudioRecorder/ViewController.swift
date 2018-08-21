//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Juan Meza on 1/4/18.
//  Copyright © 2018 Tech-IN. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var titelLabel: UILabel!
    
    @IBOutlet weak var timerlabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet var controls: [UIButton]!
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    var recordSetting = [String : Any]()
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        for button in controls  {
            
            button.layer.cornerRadius = 35
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 5
            button.clipsToBounds = true
            
        }
        titelLabel.text = UserDefaults.standard.object(forKey: "title") as? String
        
        progressView.progress = 0
        
        recordSetting = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue, AVEncoderBitRateKey: 16, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        try? audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try? audioSession.overrideOutputAudioPort(.speaker)
    }

   
    @IBAction func play(_ sender: Any) {
        
        if audioRecorder?.isRecording == true {
            
            audioRecorder?.stop()
            
        }
        
        try? audioPlayer = AVAudioPlayer(contentsOf: getPath())
        
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        progressView.progress = 0
        startTimer()
    }
    
    @IBAction func record(_ sender: Any) {
        
        let alert = UIAlertController(title: "Recording Title", message: "Please enter a name for this recoding", preferredStyle: .alert)
        
        alert.addTextField{ (nameTextField: UITextField) in
            
            nameTextField.textAlignment = .center
            nameTextField.placeholder = "Recording name"
            nameTextField.keyboardAppearance = UIKeyboardAppearance.dark
        }
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: {
            
            (action: UIAlertAction!) -> Void in
            
            let textfield = alert.textFields![0] as UITextField
            
            self.titelLabel.text = textfield.text
            UserDefaults.standard.set(textfield.text, forKey: "title")
            
            try? self.audioRecorder = AVAudioRecorder(url: self.getPath(), settings: self.recordSetting)
            
            self.audioRecorder?.delegate = self
            
            self.audioRecorder?.prepareToRecord()
            self.progressView.progress = 0
            self.audioRecorder?.record()
            
            self.startTimer()
            
        })
       
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        
        present(alert, animated: true)
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        print(recorder.url)
        print(flag)
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    @IBAction func stop(_ sender: Any) {
        
        if audioRecorder?.isRecording == true {
            
            audioRecorder?.stop()
        
        } else {
            
            audioPlayer?.stop()
        }
        
        if timer != nil {
            
            timer?.invalidate()
            timer = nil
        }
    }
    
    func getPath() -> URL {
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let directory = path[0]
        let soundPath = directory.appendingPathComponent("sound.caf")
        
        return soundPath
    }
    
    func startTimer() {
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.increaseProgress), userInfo: nil, repeats: true )
    }
    
    @objc func increaseProgress() {
        progressView.progress = progressView.progress + 0.1
        timerlabel.text = "\(Int(progressView.progress * 10))s"
        
    }
    
}

