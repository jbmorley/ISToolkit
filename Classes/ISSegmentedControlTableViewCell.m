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

#import "ISSegmentedControlTableViewCell.h"
#import "ISForm.h"

@interface ISSegmentedControlTableViewCell ()

@property (strong, nonatomic) NSString *identifier;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end;

@implementation ISSegmentedControlTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (NSString *) reuseIdentifier
{
    return self.identifier;
}

- (IBAction)segmentedControlChanged:(id)sender
{
    [self.settingsDelegate item:self valueDidChange:@(self.segmentedControl.selectedSegmentIndex)];
}

#pragma mark - ISSettingsViewControllerItem

- (void)configure:(NSDictionary *)configuration
{
    NSArray<NSString *> *options = configuration[ISFormItems];
    if (options) {
        [self.segmentedControl removeAllSegments];
        [options enumerateObjectsUsingBlock:^(NSString *option, NSUInteger index, __unused BOOL *stop) {
            [self.segmentedControl insertSegmentWithTitle:option atIndex:index animated:NO];
        }];
    }
}

- (void)setValue:(id)value
{
    self.segmentedControl.selectedSegmentIndex = [value integerValue];
}

@end
