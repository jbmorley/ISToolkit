//
//  ISHiddenItemLayout.h
//  Transitions
//
//  Created by Jason Barrie Morley on 18/02/2014.
//  Copyright (c) 2014 InSeven Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISCollectionViewBreakingLayoutProperties : NSObject

@property (nonatomic) BOOL breaksLineBeforeItem;
@property (nonatomic) BOOL breaksLineAfterItem;

@property (nonatomic) CGFloat lineSpacingBeforeItem;
@property (nonatomic) CGFloat lineSpacingAfterItem;

@property (nonatomic) BOOL hidden;

@property (nonatomic) CGSize size;

@end


@protocol ISCollectionViewBreakingLayoutDelegate <NSObject>

- (ISCollectionViewBreakingLayoutProperties *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout propertiesForItemAtIndexPath:(NSIndexPath *)indexPath proposedProperties:(ISCollectionViewBreakingLayoutProperties *)properties;

@end


@interface ISCollectionViewBreakingLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) NSIndexPath *targetIndexPath;

@end
