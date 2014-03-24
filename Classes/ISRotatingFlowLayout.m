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
//  return YES;
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
  return YES;
//  return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}


- (void)prepareLayout
{
  self.minimumLineSpacing = self.spacing;
  self.minimumInteritemSpacing = self.spacing;
  self.itemSize = [self calculateItemSize];
  self.sectionInset = [self calculateSectionInset];
  [super prepareLayout];
}


- (CGSize)collectionViewContentSize
{
  CGSize contentSize = [super collectionViewContentSize];
  return CGSizeMake(contentSize.width,
                    contentSize.height + self.padding);
}


- (void)setSpacing:(CGFloat)spacing
{
  _spacing = spacing;
  [self invalidateLayout];
}


- (void)setPadding:(CGFloat)padding
{
  _padding = padding;
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


#pragma mark STICKY HEADERS CODE BELOW
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
  CGRect targetRect = CGRectMake(rect.origin.x,
                                 rect.origin.y - self.padding,
                                 rect.size.width,
                                 rect.size.height);
  NSMutableArray *answer = [[super layoutAttributesForElementsInRect:targetRect] mutableCopy];
  
  NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
  for (NSUInteger idx=0; idx<[answer count]; idx++) {
    UICollectionViewLayoutAttributes *layoutAttributes = answer[idx];
    
    if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell || layoutAttributes.representedElementCategory == UICollectionElementCategorySupplementaryView) {
      [missingSections addIndex:(NSUInteger) layoutAttributes.indexPath.section];  // remember that we need to layout header for this section
    }
    if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
      [answer removeObjectAtIndex:idx];  // remove layout of header done by our super, we will do it right later
      idx--;
    }
  }
  
  //    layout all headers needed for the rect using self code
  [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
    UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
    if (layoutAttributes) {
      [answer addObject:layoutAttributes];
    }
  }];
  
  for (UICollectionViewLayoutAttributes *attrs in answer) {
    attrs.center = CGPointMake(attrs.center.x,
                               attrs.center.y + self.padding);
  }
  
  return answer;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    UICollectionView * const cv = self.collectionView;
    
    CGFloat topOffset = 0;
    if ([self.collectionView.dataSource isKindOfClass:[UIViewController class]]) {
      UIViewController *collectionViewParentViewController = (UIViewController *)self.collectionView.dataSource;
      topOffset = collectionViewParentViewController.topLayoutGuide.length;
    }
    topOffset -= self.padding;
    
    CGPoint const contentOffset = CGPointMake(cv.contentOffset.x, cv.contentOffset.y + topOffset);
    CGPoint nextHeaderOrigin = CGPointMake(INFINITY, INFINITY);
    
    if (indexPath.section+1 < [cv numberOfSections]) {
      UICollectionViewLayoutAttributes *nextHeaderAttributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section+1]];
      nextHeaderOrigin = nextHeaderAttributes.frame.origin;
    }
    
    CGRect frame = attributes.frame;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
      frame.origin.y = MIN(MAX(contentOffset.y, frame.origin.y), nextHeaderOrigin.y - CGRectGetHeight(frame));
    }
    else {
      frame.origin.x = MIN(MAX(contentOffset.x, frame.origin.x), nextHeaderOrigin.x - CGRectGetWidth(frame));
    }
    attributes.zIndex = 1024;
    attributes.frame = frame;
  }
  
  return attributes;
}


- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
  return attributes;
}


- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
  return attributes;
}



@end
