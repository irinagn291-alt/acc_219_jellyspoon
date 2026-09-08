import UIKit
import AVFoundation

final class ScanVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet private weak var preview: UIView!
    @IBOutlet private weak var codeField: UITextField!
    @IBOutlet private weak var goBtn: UIButton!
    @IBOutlet private weak var hintLbl: UILabel!

    private let sess = AVCaptureSession()
    private let pr = ScanPr()
    private var layer: AVCaptureVideoPreviewLayer?
    private var locked = false
    weak var go: KitchenGo?

    init(go: KitchenGo?, logs: LogMgr) {
        self.go = go
        super.init(nibName: "ScanVC", bundle: nil)
        _ = logs.aim
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan a pack"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        Jelly.paper(view)
        Jelly.dress(hintLbl, size: 15, color: Jelly.mute)
        hintLbl.text = "Point at a barcode or type digits."
        codeField.keyboardType = .numberPad
        codeField.placeholder = "Manual EAN"
        codeField.font = Jelly.type(17, weight: .medium)
        codeField.adjustsFontForContentSizeCategory = false
        codeField.accessibilityLabel = "Manual barcode digits"
        Jelly.pinH(codeField, 48)
        Jelly.dress(goBtn, title: "Use these digits", hint: "Looks up the typed or pasted code")
        goBtn.addTarget(self, action: #selector(tapGo), for: .touchUpInside)
        preview.accessibilityLabel = "Camera preview for barcodes"
        preview.layer.cornerRadius = 16
        preview.clipsToBounds = true
        bootCam()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer?.frame = preview.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if sess.isRunning {
            let box = SendableCapture(sess)
            DispatchQueue.global(qos: .userInitiated).async {
                box.sess.stopRunning()
            }
        }
    }

    @objc private func close() { go?.closeFlow() }

    @objc private func tapGo() {
        guard let code = pr.digest(codeField.text ?? "") else {
            ping("Need 8 to 14 digits.")
            return
        }
        go?.openCode(code)
    }

    private func bootCam() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              sess.canAddInput(input) else {
            hintLbl.text = "No camera here — type an EAN instead."
            return
        }
        sess.addInput(input)
        let out = AVCaptureMetadataOutput()
        if sess.canAddOutput(out) {
            sess.addOutput(out)
            out.setMetadataObjectsDelegate(self, queue: .main)
            out.metadataObjectTypes = [.ean8, .ean13, .upce, .qr, .code128]
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: sess)
        previewLayer.videoGravity = .resizeAspectFill
        preview.layer.addSublayer(previewLayer)
        layer = previewLayer
        let box = SendableCapture(sess)
        DispatchQueue.global(qos: .userInitiated).async {
            box.sess.startRunning()
        }
    }

    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput objects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let obj = objects.first as? AVMetadataMachineReadableCodeObject, let raw = obj.stringValue else { return }
        Task { @MainActor in
            self.got(raw)
        }
    }

    private func got(_ raw: String) {
        guard !locked, let code = pr.digest(raw) else { return }
        locked = true
        codeField.text = code
        go?.openCode(code)
    }

    private func ping(_ msg: String) {
        let a = UIAlertController(title: "Oops", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

private struct SendableCapture: @unchecked Sendable {
    let sess: AVCaptureSession
    init(_ sess: AVCaptureSession) { self.sess = sess }
}
