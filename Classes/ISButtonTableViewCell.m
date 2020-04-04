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

#import "ISButtonTableViewCell.h"
#import "ISForm.h"

NSString *const ISButtonStyleNormal = @"ISButtonStyleNormal";
NSString *const ISButtonStylePrimary = @"ISButtonStylePrimary";
NSString *const ISButtonStyleSecondary = @"ISButtonStyleSecondary";
NSString *const ISButtonStyleDelete = @"ISButtonStyleDelete";


@implementation ISButtonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return self;
}


#pragma mark - ISSettingsViewControllerItem


- (void)configure:(NSDictionary *)configuration
{
    self.textLabel.text = configuration[ISFormTitle];
    NSString *style = configuration[ISFormStyle];
    if ([style isEqualToString:ISButtonStyleNormal]) {

        self.selectedBackgroundView.backgroundColor = [self darkColor:[UIColor whiteColor]];

    } else if ([style isEqualToString:ISButtonStylePrimary]) {

        self.backgroundColor = self.tintColor;
        self.textLabel.textColor = [UIColor whiteColor];
        self.selectedBackgroundView.backgroundColor = [self darkColor:self.tintColor];

    } else if ([style isEqualToString:ISButtonStyleSecondary]) {

        self.selectedBackgroundView.backgroundColor = [self darkColor:[UIColor lightGrayColor]];

        UIView *borderTop = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                     CGRectGetWidth(self.contentView.bounds), 0.5f)];
        borderTop.backgroundColor = [UIColor colorWithRed:0.737 green:0.737 blue:0.746 alpha:1.000];
        borderTop.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:borderTop];

        UIView *borderBottom = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.contentView.bounds) - 0.5f,
                                                                        CGRectGetWidth(self.contentView.bounds), 0.5f)];
        borderBottom.backgroundColor = [UIColor colorWithRed:0.737 green:0.737 blue:0.746 alpha:1.000];
        borderBottom.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:borderBottom];

    } else if ([style isEqualToString:ISButtonStyleDelete]) {

        self.textLabel.textColor = UIColor.systemRedColor;
        self.selectedBackgroundView.backgroundColor = [self darkColor:[UIColor redColor]];

    }
}


- (void)didSelectItem
{
    [self.settingsDelegate itemDidPerformAction:self];
}


- (UIColor *)darkColor:(UIColor *)color
{
    CGFloat red = 0.0f;
    CGFloat green = 0.0f;
    CGFloat blue = 0.0f;
    CGFloat white = 0.0f;
    CGFloat alpha = 0.0f;
    if ([color getRed:&red
                green:&green
                 blue:&blue
                alpha:&alpha]) {
        return [UIColor colorWithRed:MAX(red - 0.2, 0.0)
                               green:MAX(green - 0.2, 0.0)
                                blue:MAX(blue - 0.2, 0.0)
                               alpha:alpha];
    } else if ([color getWhite:&white
                         alpha:&alpha]) {
        return [UIColor colorWithWhite:MAX(white - 0.2, 0.0)
                                 alpha:alpha];
    }
    return nil;
}


@end
