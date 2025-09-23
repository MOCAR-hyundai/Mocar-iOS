//
//  SinglePhotoPicker.swift
//  Mocar-iOS
//
//  Created by Admin on 9/22/25.
//

import SwiftUI
import PhotosUI

struct SinglePhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var completion: ((UIImage?) -> Void)? // 선택 완료 콜백

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1   // ✅ 1장만 선택
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: SinglePhotoPicker
        init(_ parent: SinglePhotoPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let result = results.first else {
                parent.completion?(nil)
                return
            }

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                    DispatchQueue.main.async {
                        if let img = obj as? UIImage {
                            self.parent.image = img
                            self.parent.completion?(img)
                        } else {
                            self.parent.completion?(nil)
                        }
                    }
                }
            }
        }
    }
}
