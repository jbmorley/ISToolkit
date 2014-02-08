//
//  ISRotatingFlowLayout.h
//  ISPhotoLibrary
//
//  Created by Jason Barrie Morley on 06/02/2014.
//  Copyright (c) 2014 InSeven Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISRotatingFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) CGFloat spacing;
@property (nonatomic) CGSize minimumItemSize;
@property (nonatomic) BOOL adjustsItemSize;

@end
