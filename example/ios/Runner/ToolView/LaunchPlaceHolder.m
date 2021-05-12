//
//  LaunchPlaceHolder.m
//  MobSDKDemo
//
//  Created by 兵伍 on 2020/5/24.
//  Copyright © 2020 兵伍. All rights reserved.
//

#import "LaunchPlaceHolder.h"

@implementation LaunchPlaceHolder

+ (instancetype)loadViewFromXib {
    NSString *className = NSStringFromClass([self class]);
    NSArray *tmpArray = [[NSBundle mainBundle] loadNibNamed:className owner:nil options:nil];
    if (tmpArray.count > 0)
    {
        return tmpArray[0];
    }
    return nil;
}

@end
