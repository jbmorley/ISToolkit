//
// Copyright (c) 2013 InSeven Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "ISRotatingFlowLayout.h"

@interface ISRotatingFlowLayout ()

@property (nonatomic) CGRect currentBounds;

@end

@implementation ISRotatingFlowLayout

- (id)init
{
  self = [super init];
  if (self) {
    self.spacing = 0.0f;
    self.inset = 0.0f;
    self.currentBounds = CGRectZero;
    self.minimumItemSize = CGSizeZero;
  }
  return self;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
  if ((self.scrollDirection ==
       UICollectionViewScrollDirectionVertical &&
       self.currentBounds.size.width !=
       newBounds.size.width) ||
      (self.scrollDirection ==
       UICollectionViewScrollDirectionHorizontal &&
       self.currentBounds.size.height !=
       newBounds.size.height)) {
    self.currentBounds = newBounds;
    [self invalidateLayout];
    return YES;
  }
  return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}


- (void)prepareLayout
{
  self.minimumLineSpacing = self.spacing;
  self.minimumInteritemSpacing = self.spacing;
  self.itemSize = [self calculateItemSize];
  self.sectionInset = [self calculateSectionInset];
  [super prepareLayout];
}


- (void)setSpacing:(CGFloat)spacing
{
  _spacing = spacing;
  [self invalidateLayout];
}


- (UIEdgeInsets)calculateSectionInset
{
  if (self.scrollDirection ==
      UICollectionViewScrollDirectionHorizontal) {

    NSInteger count = floor((self.collectionView.frame.size.height + self.spacing) / (self.itemSize.height + self.spacing));
    NSInteger margin = floor((self.collectionView.frame.size.height - (self.itemSize.height * count) - (self.spacing * (count - 1))) / 2);
    return UIEdgeInsetsMake(margin,
                            self.inset,
                            margin,
                            self.inset);
    
  } else if (self.scrollDirection ==
             UICollectionViewScrollDirectionVertical) {
    
    NSInteger count = floor((self.collectionView.frame.size.width + self.spacing) / (self.itemSize.width + self.spacing));
    NSInteger margin = floor((self.collectionView.frame.size.width - (self.itemSize.width * count) - (self.spacing * (count - 1))) / 2);
    return UIEdgeInsetsMake(self.inset,
                            margin,
                            self.inset,
                            margin);
    
  }
  
  return UIEdgeInsetsZero;
}


- (CGSize)calculateItemSize
{
  if (self.adjustsItemSize) {
    
    if (self.scrollDirection ==
        UICollectionViewScrollDirectionVertical) {

      // Work out how many minimum size cells we can fit in.
      NSInteger max = floor((self.collectionView.bounds.size.width + self.spacing) / (self.minimumItemSize.width + self.spacing));
      
      // Work out the how much is given over to spacing.
      if (max == 0) {
        return self.minimumItemSize;
      } else {
        CGFloat dimension = floor((self.collectionView.bounds.size.width - (self.spacing * (max + 1))) / max);
        return CGSizeMake(dimension, self.minimumItemSize.height);
      }
      
    } else if (self.scrollDirection ==
               UICollectionViewScrollDirectionHorizontal) {
      
      // Work out how many minimum size cells we can fit in.
      NSInteger max = floor((self.collectionView.bounds.size.height + self.spacing) / (self.minimumItemSize.height + self.spacing));
      
      // Work out the how much is given over to spacing.
      if (max == 0) {
        return self.minimumItemSize;
      } else {
        CGFloat dimension = floor((self.collectionView.bounds.size.height - (self.spacing * (max + 1))) / max);
        return CGSizeMake(self.minimumItemSize.height, dimension);
      }
      
    } else {
      return self.minimumItemSize;
    }
    
  } else {
  
    return self.minimumItemSize;
    
  }
  
}


@end
