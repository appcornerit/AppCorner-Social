//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//
// Extends the UIImage class to support making rounded corners

// http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/

@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;
@end