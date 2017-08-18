//
//  ADSquare.m
//  MachinariumGame
//
//  Created by Александр Дудырев on 05.08.17.
//  Copyright © 2017 Александр Дудырев. All rights reserved.
//

#import "ADSquare.h"

@implementation ADSquare

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _border = NO;
        _isSelected = NO;
        _index = 0;
        
        _coordinate = CGPointZero;
    }
    return self;
}

- (void)layoutSubviews {
    
}


+ (NSInteger)getIndexForX:(NSInteger)x andY:(NSInteger)y withOrder:(NSInteger)order {
    return x + y * order;
}



@end
