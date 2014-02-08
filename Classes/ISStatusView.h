//
//  ISStatusView.h
//  Shows
//
//  Created by Jason Barrie Morley on 05/02/2014.
//  Copyright (c) 2014 InSeven Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  
  ISStatusViewStateIncomplete,
  ISStatusViewStatePartial,
  ISStatusViewStateComplete,
  
} ISStatusViewState;

@interface ISStatusView : UIView

@property (nonatomic) ISStatusViewState state;

@end
