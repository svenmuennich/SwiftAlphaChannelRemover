//
//  ImageCollectionViewItem.swift
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

import Foundation
import Cocoa

class ImageBackgroundView: NSView {}

class ImageCollectionViewItem: NSCollectionViewItem {

	override var selected: Bool {
		get {
			return super.selected
		}
		set {
			super.selected = newValue
			self.updateSelectedBackground()
		}
	}

	// MARK: - Private methods

	private func updateSelectedBackground() {
		// Fetch the image background view
		var backgroundView: NSView?
		for view in self.view.subviews {
			if view.isKindOfClass(ImageBackgroundView) {
				backgroundView = view as? ImageBackgroundView
				break;
			}
		}

		// Add round corners and a border
		if let background = backgroundView {
			background.wantsLayer = true
			background.layer?.masksToBounds = true
			background.layer?.cornerRadius = (self.selected) ? 2.0 : 0.0
			background.layer?.borderWidth = (self.selected) ? 2.0 : 0.0
			background.layer?.borderColor = (self.selected) ? NSColor.selectedMenuItemColor().CGColor : NSColor.clearColor().CGColor
		}
	}

}
