//
//  UIBarButtonItem+UIViewAppearance_Swift.m
//  moscowfresh
//
//  Created by Valentin Shamardin on 11.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

#import "UIBarButtonItem+UIViewAppearance_Swift.h"

@implementation UIBarButtonItem (UIViewAppearance_Swift)

+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}

@end