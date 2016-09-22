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

#import "ISTextFieldTableViewCell.h"
#import "ISForm.h"

@interface ISTextFieldTableViewCell ()

@property (strong, nonatomic) NSString *identifier;

- (void)textFieldDidChange:(NSNotification *)notification;

@end

@implementation ISTextFieldTableViewCell

+ (ISTextFieldTableViewCell *)textFieldCell
{
    NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"ISToolkit"
                                                                       withExtension:@"bundle"]];
    UINib *nib = [UINib nibWithNibName:@"ISTextFieldTableViewCell" bundle:bundle];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    return objects[0];
}


+ (ISTextFieldTableViewCell *) textFieldCellWithIdentifier:(NSString *)identifier
{
    ISTextFieldTableViewCell *cell = [self textFieldCell];
    cell.identifier = identifier;
    return cell;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textField.textColor = [UIColor colorWithRed:0.607 green:0.607 blue:0.620 alpha:1.000];

    // Observe changes to the text field.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(textFieldDidChange:)
                   name:UITextFieldTextDidChangeNotification
                 object:self.textField];

    [self.textField addTarget:self
                       action:@selector(textFieldDidEndEditing:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)textFieldDidChange:(NSNotification *)notification
{
    [self.delegate textFieldCellDidChange:self];
    [self.settingsDelegate item:self valueDidChange:self.textField.text];
}

- (void)textFieldDidEndEditing:(id)sender
{
    [self.settingsDelegate itemDidEndEditing:self];
}

- (NSString *)reuseIdentifier
{
    return self.identifier;
}

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

#pragma mark - ISSettingsViewControllerItem

- (void)configure:(NSDictionary *)configuration
{
    self.label.text = configuration[ISFormTitle];
    self.textField.placeholder = configuration[ISFormPlaceholderText];

    NSNumber *secureTextEntry = configuration[@"secureTextEntry"];
    if (secureTextEntry) {
        self.textField.secureTextEntry = [secureTextEntry boolValue];
    }

    NSNumber *clearButtonMode = configuration[@"clearButtonMode"];
    if (clearButtonMode) {
        self.textField.clearButtonMode = [clearButtonMode integerValue];
    }

    NSNumber *autocorrectionType = configuration[@"autocorrectionType"];
    if (autocorrectionType) {
        self.textField.autocorrectionType = [autocorrectionType integerValue];
    }

    NSNumber *autocapitalizationType = configuration[@"autocapitalizationType"];
    if (autocapitalizationType) {
        self.textField.autocapitalizationType = [autocapitalizationType integerValue];
    }

    NSNumber *returnKeyType = configuration[@"returnKeyType"];
    if (returnKeyType) {
        self.textField.returnKeyType = [returnKeyType integerValue];
    }

    NSNumber *enabled = configuration[@"enabled"];
    if (enabled) {
        self.textField.enabled = [enabled boolValue];
    }

    NSNumber *textAlignment = configuration[@"textAlignment"];
    if (textAlignment) {
        self.textField.textAlignment = [textAlignment integerValue];
    }
}

- (void)setValue:(id)value
{
    self.textField.text = value;
}

@end
