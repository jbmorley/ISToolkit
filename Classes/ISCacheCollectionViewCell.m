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

#import "ISCacheCollectionViewCell.h"

@interface ISCacheCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic) ISCacheItemState state;

@end

@implementation ISCacheCollectionViewCell


- (void)awakeFromNib
{
  [super awakeFromNib];
  self.button.enabled = NO;
  self.state = -1;
}


- (void)dealloc
{
  [self.cacheItem removeCacheItemObserver:self];
}


- (void)setCacheItem:(ISCacheItem *)cacheItem
{
  if (_cacheItem != cacheItem) {
    [_cacheItem removeCacheItemObserver:self];
    _cacheItem = cacheItem;
    if (_cacheItem) {
      self.button.enabled = YES;
      [_cacheItem addCacheItemObserver:self options:ISCacheItemObserverOptionsInitial];
    }
  }
}


- (void)setTitle:(NSString *)title
{
  if (title) {
    self.label.text = title;
  } else {
    self.label.text = @"Untitled item";
  }
}


- (void)setState:(ISCacheItemState)state
{
  if (_state != state) {
    _state = state;
    
    if (_state == ISCacheItemStateInProgress) {
      UIImage *image = [UIImage imageNamed:@"ISToolkit.bundle/Stop.png"];
      [self.button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                   forState:UIControlStateNormal];
      self.button.enabled = YES;
      self.label.textColor = [UIColor darkGrayColor];
      self.detailLabel.textColor = [UIColor darkGrayColor];
    } else if (_state == ISCacheItemStateNotFound) {
      UIImage *image = [UIImage imageNamed:@"ISToolkit.bundle/Refresh.png"];
      [self.button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                   forState:UIControlStateNormal];
      self.button.enabled = YES;
      self.label.textColor = [UIColor lightGrayColor];
      self.detailLabel.textColor = [UIColor lightGrayColor];
    } else if (_state == ISCacheItemStateFound) {
      UIImage *image = [UIImage imageNamed:@"ISToolkit.bundle/Trash.png"];
      [self.button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                   forState:UIControlStateNormal];
      self.button.enabled = YES;
      self.label.textColor = [UIColor darkGrayColor];
      self.detailLabel.textColor = [UIColor darkGrayColor];

    }    
  }
}


- (void)updateProgress
{
  self.state = self.cacheItem.state;
  self.progressView.progress = self.cacheItem.progress;
  
  if (self.cacheItem.state ==
      ISCacheItemStateNotFound) {
    
    if (self.cacheItem.lastError) {
      if (self.cacheItem.lastError.domain ==
          ISCacheErrorDomain &&
          self.cacheItem.lastError.code ==
          ISCacheErrorCancelled) {
        self.detailLabel.text = @"Download cancelled";
      } else {
        self.detailLabel.text = @"Download failed";
      }
    } else {
      self.detailLabel.text = @"Download missing";
    }
    
  } else if (self.cacheItem.state ==
             ISCacheItemStateInProgress) {
    
    NSTimeInterval timeRemainingEstimate = self.cacheItem.timeRemainingEstimate;
    if (timeRemainingEstimate != 0) {
      
      NSString *duration;
      NSUInteger seconds = self.cacheItem.timeRemainingEstimate;
      if (timeRemainingEstimate > 60*60) {
        NSUInteger hours = floor(seconds/(60*60));
        duration = [NSString stringWithFormat:
                    @"%lu hours remaining...",
                    (unsigned long)hours];
      } else if (timeRemainingEstimate > 60) {
        NSUInteger minutes = floor(seconds/60);
        duration = [NSString stringWithFormat:
                    @"%lu minutes remaining...",
                    (unsigned long)minutes];
      } else {
        duration = [NSString stringWithFormat:
                    @"%lu seconds remaining...",
                    (unsigned long)seconds];
      }
      self.detailLabel.text = duration;
      
    } else {
      self.detailLabel.text = @"Remaining time unknown";
    }
    
  } else if (self.cacheItem.state ==
             ISCacheItemStateFound) {
    
    self.detailLabel.text = @"Download complete";
    
  }
}


- (IBAction)buttonClicked:(id)sender
{
  if (self.cacheItem) {
    
    if (self.cacheItem.state ==
        ISCacheItemStateInProgress) {
      
      [self.delegate cell:self
            didCancelItem:self.cacheItem];
      
    } else if (self.cacheItem.state ==
               ISCacheItemStateNotFound) {
      
      [self.delegate cell:self
             didFetchItem:self.cacheItem];
      
    } else if (self.cacheItem.state ==
               ISCacheItemStateFound) {
      
      [self.delegate cell:self
            didRemoveItem:self.cacheItem];
      
    }
  }
}


#pragma mark - ISCacheItemObserver


- (void)cacheItemDidChange:(ISCacheItem *)cacheItem
{
  [self updateProgress];
}


- (void)cacheItemDidProgress:(ISCacheItem *)cacheItem
{
  [self updateProgress];
}

@end
