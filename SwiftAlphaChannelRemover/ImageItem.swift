//
//  ImageItem.swift
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

class ImageItem: NSObject {

	dynamic var fileURL: NSURL
	dynamic var fileName: NSString {
		return self.fileURL.lastPathComponent!
	}
	dynamic var thumbnailImage: NSImage {
		return NSImage(contentsOfURL: self.fileURL)!
	}

	// MARK: - Initializer

	init(url: NSURL) {
		self.fileURL = url
	}

	// MARK: - Other methods

	override func isEqual(object: AnyObject?) -> Bool {
		if let otherItem = object! as? ImageItem {
			return self.fileURL == otherItem.fileURL
		}

		return false
	}

}
