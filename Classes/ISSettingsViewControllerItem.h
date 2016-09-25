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

#import <UIKit/UIKit.h>

@protocol ISFormItem;

@protocol ISFormItemDelegate <NSObject>

- (void)item:(id<ISFormItem>)item valueDidChange:(id)value;
- (void)itemDidPerformAction:(id<ISFormItem>)item;
- (void)item:(id<ISFormItem>)item pushViewController:(UIViewController *)viewController;
- (void)itemDidEndEditing:(id<ISFormItem>)item;

@end

@protocol ISFormItem <NSObject>
@optional

@property (nonatomic, weak) id<ISFormItemDelegate> settingsDelegate;

- (void)configure:(NSDictionary *)configuration;
- (void)setValue:(id)value;
- (void)setOptions:(NSArray *)options;
- (void)didSelectItem;
- (BOOL)becomeFirstResponder;
+ (CGFloat)heightForValue:(id)value configuration:(NSDictionary *)configuration width:(CGFloat)width;

@end
