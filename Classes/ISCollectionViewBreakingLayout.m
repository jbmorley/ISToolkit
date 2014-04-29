//
// Copyright (c) 2013-2014 InSeven Limited.
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

#import "ISCollectionViewBreakingLayout.h"

@implementation ISCollectionViewBreakingLayoutProperties

@end;

@interface ISCollectionViewBreakingLayout ()

@property (nonatomic, strong) NSMutableArray *attributes;
@property (nonatomic) CGSize contentSize;

@end

@implementation ISCollectionViewBreakingLayout

- (void)prepareLayout
{
  [super prepareLayout];
  
  CGFloat offsetX = 0;
  CGFloat offsetY = 0;
  CGFloat rowHeight = 0;
  
  CGFloat maxWidth = CGRectGetWidth(self.collectionView.bounds);
  
  CGPoint previousCenter = CGPointZero;
  ISCollectionViewBreakingLayoutProperties *previousProperties =
  [self defaultProperties];
  
  NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
  self.attributes = [NSMutableArray arrayWithCapacity:itemCount];
  for (NSInteger i = 0; i < itemCount; i++) {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i
                                                 inSection:0];

    UICollectionViewLayoutAttributes *attributes =
    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    ISCollectionViewBreakingLayoutProperties *properties =
    [self propertiesForItemAtIndexPath:indexPath];
    
    if (!properties.hidden) {
      
      // Work out if we need to wrap.
      if (offsetX + properties.size.width > maxWidth ||
          previousProperties.breaksLineAfterItem ||
          properties.breaksLineBeforeItem) {
        CGFloat lineSpacing =
        MAX(previousProperties.lineSpacingAfterItem,
            properties.lineSpacingBeforeItem);
        offsetX = 0;
        offsetY += rowHeight;
        offsetY += lineSpacing;
        rowHeight = 0;
      }
      
      CGFloat centerX = offsetX + (properties.size.width / 2);
      CGFloat centerY = offsetY + (properties.size.height / 2);
      CGPoint center = CGPointMake(centerX, centerY);
      
      offsetX += properties.size.width;
      offsetX += self.minimumInteritemSpacing;
      rowHeight = MAX(rowHeight, properties.size.height);
      
      attributes.size = properties.size;
      attributes.center = center;
      
      previousCenter = center;
      attributes.zIndex = 10;
      previousProperties = properties;
      
    } else {
      attributes.size = CGSizeZero;
      attributes.center = previousCenter;
      attributes.alpha = 0.0f;
      attributes.zIndex = 0;
    }
    [self.attributes addObject:attributes];
    
  }
  self.contentSize = CGSizeMake(maxWidth, offsetY + rowHeight);
}

- (CGSize)collectionViewContentSize
{
  return self.contentSize;
}


- (ISCollectionViewBreakingLayoutProperties *)defaultProperties
{
  ISCollectionViewBreakingLayoutProperties *properites = [ISCollectionViewBreakingLayoutProperties new];
  properites.breaksLineBeforeItem = NO;
  properites.breaksLineAfterItem = NO;
  properites.lineSpacingBeforeItem = self.minimumInteritemSpacing;
  properites.lineSpacingAfterItem = self.minimumInteritemSpacing;
  properites.hidden = NO;
  return properites;
}


- (ISCollectionViewBreakingLayoutProperties *)propertiesForItemAtIndexPath:(NSIndexPath *)indexPath
{
  ISCollectionViewBreakingLayoutProperties *properties = [self defaultProperties];
  properties.size = [self sizeForIndexPath:indexPath];
  
  if ([self.collectionView.delegate conformsToProtocol:@protocol(ISCollectionViewBreakingLayoutDelegate)]) {
    id <ISCollectionViewBreakingLayoutDelegate> delegate = (id <ISCollectionViewBreakingLayoutDelegate>)self.collectionView.delegate;
    properties = [delegate collectionView:self.collectionView layout:self propertiesForItemAtIndexPath:indexPath proposedProperties:properties];
  }
  
  return properties;
}


- (CGSize)sizeForIndexPath:(NSIndexPath *)indexPath
{
  if ([self.collectionView.delegate conformsToProtocol:@protocol(UICollectionViewDelegateFlowLayout)]) {
    id <UICollectionViewDelegateFlowLayout> delegate = (id <UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
      return [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
    }
  }
  return self.itemSize;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.attributes objectAtIndex:indexPath.item];
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:3];
  for (UICollectionViewLayoutAttributes *attributes in
       self.attributes) {
    CGRect position =
    CGRectMake(attributes.center.x - attributes.size.width/2.0,
               attributes.center.y - attributes.size.height/2.0,
               attributes.size.width,
               attributes.size.height);
    if (CGRectIntersectsRect(position, rect)) {
      [result addObject:attributes];
    }
  }
  return result;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
  if (self.targetIndexPath) {
    UIEdgeInsets edgeInsets = self.collectionView.contentInset;
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:self.targetIndexPath];
    CGPoint contentOffset =
    CGPointMake(0.0,
                (attributes.center.y - attributes.size.height/2) - edgeInsets.top);
    self.targetIndexPath = nil;
    return contentOffset;
  } else {
    return [super targetContentOffsetForProposedContentOffset:proposedContentOffset];
  }
}

@end
