//
// Copyright (c) 2013 InSeven Limited.
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

#import "ISPageViewController.h"

@interface ISPageViewController ()

@property (nonatomic, strong) NSArray *pages;
@property (nonatomic, strong) UITabBar *tabBar;
@property (nonatomic) NSInteger selectedIndex;


@end

@implementation ISPageViewController

- (id)init
{
  self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
  if (self) {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataSource = self;
    self.delegate = self;
    CGRect defaultFrame = CGRectMake(0.0,
                                     0.0,
                                     100.0,
                                     100.0);
    
    self.tabBar = [[UITabBar alloc] initWithFrame:defaultFrame];
    self.tabBar.delegate = self;
    [self.view addSubview:self.tabBar];
    self.tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self _layoutTabBar];
  }
  return self;
}


- (void)_layoutTabBar
{
  [self.tabBar sizeToFit];
  self.tabBar.frame = CGRectMake(0.0,
                                 self.view.bounds.size.height - self.tabBar.frame.size.height, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [self _layoutTabBar];
}


- (void)setPages:(NSArray *)pages
        animated:(BOOL)animated;
{
  _pages = pages;
  NSMutableArray *tabItems = [NSMutableArray arrayWithCapacity:_pages.count];
  for (UIViewController *viewController in _pages) {
    [tabItems addObject:viewController.tabBarItem];
  }
  [self.tabBar setItems:tabItems
               animated:animated];
  _selectedIndex = 0;
  [self _setTabBarSelectedIndex:_selectedIndex];
}


- (void)_setTabBarSelectedIndex:(NSInteger)index
{
  [self.tabBar setSelectedItem:self.tabBar.items[index]];
}


- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self setViewControllers:@[self.pages[self.selectedIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
  NSInteger index = [self.pages indexOfObject:viewController] - 1;
  return [self viewControllerForIndex:index];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
  NSInteger index = [self.pages indexOfObject:viewController] + 1;
  return [self viewControllerForIndex:index];
}


- (UIViewController *)viewControllerForIndex:(NSInteger)index
{
  if (index >= 0 &&
      index < self.pages.count) {
    UIViewController *page = self.pages[index];
    return page;
  }
  return nil;
}


- (UIView *)rotatingFooterView
{
  return self.tabBar;
}


- (UIViewController *)currentViewController
{
  return self.viewControllers[0];
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
  NSInteger index = [self.pages indexOfObject:[self currentViewController]];
  self.selectedIndex = index;
}


- (void)setSelectedIndex:(NSInteger)selectedIndex
{
  if (_selectedIndex == selectedIndex) {
    return;
  }
  _selectedIndex = selectedIndex;
  [self _setTabBarSelectedIndex:_selectedIndex];
}


- (void)tabBar:(UITabBar *)tabBar
 didSelectItem:(UITabBarItem *)item
{
  NSInteger index = [self.tabBar.items indexOfObject:item];
  if (_selectedIndex == index) {
    
    UIViewController *viewController = [self currentViewController];
    if ([viewController isKindOfClass:[UINavigationController class]]) {
      UINavigationController *navigationController = (UINavigationController *)viewController;
      [navigationController popToRootViewControllerAnimated:YES];
    }
    
    
    return;
  }
  UIPageViewControllerNavigationDirection direction = index < _selectedIndex ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
  [self setViewControllers:@[[self viewControllerForIndex:index]] direction:direction animated:YES completion:NULL];
  _selectedIndex = index;
}



@end
