//
//  ADSquare.h
//  MachinariumGame
//
//  Created by Александр Дудырев on 05.08.17.
//  Copyright © 2017 Александр Дудырев. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ADSquare : UIView

@property (nonatomic, assign) BOOL border;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGPoint coordinate;

@end
