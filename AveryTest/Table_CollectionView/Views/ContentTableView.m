//
//  ContentTableView.m
//  AveryTest
//
//  Created by Avery An on 2020/1/10.
//  Copyright © 2020 Avery. All rights reserved.
//

#import "ContentTableView.h"

@implementation ContentTableView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

@end
