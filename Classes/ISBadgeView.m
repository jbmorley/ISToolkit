//
//  ISBadgeView.m
//  Pods
//
//  Created by Jason Barrie Morley on 08/02/2014.
//
//

#import "ISBadgeView.h"

@interface ISBadgeView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic) UIEdgeInsets insets;

@end

@implementation ISBadgeView


- (void)awakeFromNib
{
  [super awakeFromNib];
  self.backgroundColor = [UIColor clearColor];
  self.label = [[UILabel alloc] initWithFrame:self.bounds];
  self.label.textAlignment = NSTextAlignmentCenter;
  self.insets = UIEdgeInsetsMake(2.0f,
                                 5.0f,
                                 2.0f,
                                 5.0f);
  self.label.textColor = [UIColor whiteColor];
  [self addSubview:self.label];
}


- (void)layoutSubviews
{
  self.label.frame =
  CGRectMake(self.insets.left,
             self.insets.top,
             CGRectGetWidth(self.bounds) - self.insets.left - self.insets.right,
             CGRectGetHeight(self.bounds) - self.insets.top - self.insets.bottom);
}


- (CGSize)sizeThatFits:(CGSize)size
{
  CGSize labelSize = [self.label sizeThatFits:size];
  labelSize = CGSizeMake(MAX(labelSize.width, labelSize.height),
                         labelSize.height);
  return CGSizeMake(labelSize.width + self.insets.left + self.insets.right,
                    labelSize.height + self.insets.top + self.insets.bottom);
}


- (void)sizeToFit
{
  [super sizeToFit];
  [self setNeedsDisplay];
}


- (void)setInsets:(UIEdgeInsets)insets
{
  if (!UIEdgeInsetsEqualToEdgeInsets(_insets, insets)) {
    _insets = insets;
    [self setNeedsLayout];
  }
}


- (void)drawRect:(CGRect)rect
{
  if (self.text == nil ||
      [self.text isEqualToString:@""]) {
    return;
  }
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColor(context,
                        CGColorGetComponents([self.tintColor CGColor]));
  CGContextSetStrokeColor(context,
                          CGColorGetComponents([self.tintColor CGColor]));
  
  CGRect target = self.bounds;
  CGFloat radius = CGRectGetHeight(target) / 2.0f;
  
  CGContextBeginPath(context);
  CGContextAddArc(context,
                  CGRectGetWidth(target) - radius,
                  radius,
                  radius,
                  -M_PI_2,
                  M_PI_2,
                  0);
  CGContextAddArc(context,
                  radius,
                  radius,
                  radius,
                  M_PI_2,
                  -M_PI_2,
                  0);
  CGContextFillPath(context);
}

- (void)setText:(NSString *)text
{
  self.label.text = text;
}


- (NSString *)text
{
  return self.label.text;
}


@end
