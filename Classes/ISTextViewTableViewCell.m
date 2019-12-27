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

#import "ISTextViewTableViewCell.h"

@implementation ISTextViewTableViewCell

- (id)init
{
  return [self initWithReuseIdentifier:nil];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
  if (self) {
    
    CGRect frame = CGRectInset(self.contentView.frame, 0.0, 0.0);
    self.textView
      = [[UITextView alloc] initWithFrame:frame];
    [self.textView setTextContainerInset:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.font = [UIFont systemFontOfSize:17.0];
    [self.contentView addSubview:self.textView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Observe changes to the text field.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(textViewDidChange:)
                   name:UITextViewTextDidChangeNotification
                 object:self.textView];
    
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textViewDidChange:(NSNotification *)notification
{
  [self.settingsDelegate item:self
               valueDidChange:self.textView.text];
}

#pragma mark - ISSettingsViewControllerItem

- (void)configure:(NSDictionary *)configuration
{
    NSNumber *textAlignment = configuration[@"textAlignment"];
    if (textAlignment) {
        self.textView.textAlignment = [textAlignment integerValue];
    }

    NSNumber *editable = configuration[@"editable"];
    if (editable) {
        self.textView.editable = [editable boolValue];
    }

    NSNumber *selectable = configuration[@"selectable"];
    if (selectable) {
        self.textView.selectable = [selectable boolValue];
    }

    NSNumber *scrollEnabled = configuration[@"scrollEnabled"];
    if (scrollEnabled) {
        self.textView.scrollEnabled = [scrollEnabled boolValue];
    }
}

- (void)setValue:(id)value
{
  self.textView.text = value;
}

+ (CGFloat)heightForValue:(id)value configuration:(NSDictionary *)configuration width:(CGFloat)width
{
    ISTextViewTableViewCell *cell = [[self alloc] init];
    [cell configure:configuration];

    CGRect constrainingRect = CGRectMake(0, 0, width, CGFLOAT_MAX);
    constrainingRect = UIEdgeInsetsInsetRect(constrainingRect, cell.layoutMargins);
    constrainingRect = UIEdgeInsetsInsetRect(constrainingRect, cell.textView.layoutMargins);

    CGRect rect = [(NSString *)value boundingRectWithSize:constrainingRect.size
                                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                                           NSStringDrawingUsesFontLeading)
                                               attributes:@{NSFontAttributeName: cell.textView.font}
                                                  context:nil];

    return (ceilf(CGRectGetHeight(rect)) +
            cell.layoutMargins.top +
            cell.layoutMargins.bottom +
            cell.textView.layoutMargins.top +
            cell.textView.layoutMargins.bottom);
}

@end
