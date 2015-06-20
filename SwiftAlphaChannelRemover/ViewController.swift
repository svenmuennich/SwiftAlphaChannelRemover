//
//  ViewController.swift
//  SwiftAlphaChannelRemover
//
//  Copyright (c) 2015 Sven Münnich
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Cocoa

class ViewController: NSViewController, NSCollectionViewDelegate {

	@IBOutlet var arrayController: NSArrayController!
	@IBOutlet var collectionView: NSCollectionView!
	@IBOutlet var infoLabel: NSTextField!
	@IBOutlet var processButton: NSButton!
	dynamic var items: [ImageItem] = []

	private var context = 0

	// MARK: - View lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		// Observe changes in the item selection
		self.arrayController.addObserver(self, forKeyPath: "selectionIndexes", options: .New, context: &(self.context))

		// Fix connection of collection item
		let proto = self.storyboard?.instantiateControllerWithIdentifier("imageItemView") as! NSCollectionViewItem
		self.collectionView.itemPrototype = proto

		// Prepare dropping of items from finder
		let types = [NSFilenamesPboardType]
		self.collectionView!.registerForDraggedTypes(types)
	}

	deinit {
		self.arrayController.removeObserver(self, forKeyPath: "selectionIndexes", context: &(self.context))
	}

	// MARK: - NSCollectionView delegate

	func collectionView(collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndex proposedDropIndex: UnsafeMutablePointer<Int>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
		// Only allow copying if at least one file in the pasteboard is a PNG file
		return self.pasteboardPNGFiles(draggingInfo).count > 0 ? NSDragOperation.Copy : NSDragOperation.None
	}

	func collectionView(collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, index: Int, dropOperation: NSCollectionViewDropOperation) -> Bool {
		// Try to get any PNG file paths from the pasteboard
		let files = self.pasteboardPNGFiles(draggingInfo)
		for f in files {
			let item = ImageItem(url: NSURL.fileURLWithPath(f, isDirectory: false)!)
			if !contains(self.items, item) {
				self.items.append(item)
			}
		}

		// Enable button and hide info label if at least one item is added
		self.processButton.enabled = (self.items.count > 0)
		self.infoLabel.hidden = (self.items.count > 0)

		return files.count > 0
	}

	// MARK: - KVO

	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		if context != &(self.context) {
			super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
			return
		}

		// Update the selected item views
		println("\(self.arrayController.selectionIndexes)")
		self.arrayController.selectionIndexes.enumerateIndexesUsingBlock { (index, stop) -> Void in
			let item = self.collectionView.itemAtIndex(index)
			println("\(item)")
		}
	}

	// MARK: - Public methods

	@IBAction func processImages(sender: NSButton) {
		// Convert all loaded items
		for item in self.items {
			self.removeAlphaChannel(item.fileURL)
		}
	}

	// MARK: - Private methods

	private func pasteboardPNGFiles(draggingInfo: NSDraggingInfo) -> [String] {
		let pb = draggingInfo.draggingPasteboard()
		if (pb.types! as NSArray).containsObject(NSFilenamesPboardType) {
			var files = pb.propertyListForType(NSFilenamesPboardType) as! [String]
			files = files.filter() { (fileName) in
				return NSURL.fileURLWithPath(fileName, isDirectory: false)?.pathExtension == "png"
			}

			return files
		}

		return []
	}

	private func removeAlphaChannel(imageURL: NSURL) {
		// Load the image and check if it still has an alpha channel
		let srcImage = NSImage(contentsOfURL: imageURL)!
		let source = CGImageSourceCreateWithData(srcImage.TIFFRepresentation as! CFDataRef, nil)
		let imageRef = CGImageSourceCreateImageAtIndex(source, 0, [:])
		if CGImageGetAlphaInfo(imageRef) == CGImageAlphaInfo.None {
			return
		}

		// Remove the alpha channel
		let rect = CGRect(x: 0, y: 0, width: CGImageGetWidth(imageRef), height: CGImageGetHeight(imageRef))
		let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.NoneSkipLast.rawValue) | CGBitmapInfo.ByteOrder32Little
		let bitmapContext = CGBitmapContextCreate(nil, Int(rect.size.width), Int(rect.size.height), CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetColorSpace(imageRef), bitmapInfo)
		CGContextDrawImage(bitmapContext, rect, imageRef)
		let decompressedImageRef = CGBitmapContextCreateImage(bitmapContext)

		// Write the new image to the original file path
		let finalImage = NSImage(CGImage: decompressedImageRef, size: NSZeroSize)
		let finalImageRep = NSBitmapImageRep(data: finalImage.TIFFRepresentation!)
		let finalImageData = finalImageRep!.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [
			NSImageCompressionFactor: 0.9
		])
		finalImageData!.writeToFile(imageURL.path!, atomically: false)
	}

}

