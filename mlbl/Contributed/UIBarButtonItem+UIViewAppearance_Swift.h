//
//  UIBarButtonItem+UIViewAppearance_Swift.h
//  moscowfresh
//
//  Created by Valentin Shamardin on 11.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (UIViewAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;

@end