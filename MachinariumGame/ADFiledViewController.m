//
//  ADFiledViewController.m
//  MachinariumGame
//
//  Created by Александр Дудырев on 05.08.17.
//  Copyright © 2017 Александр Дудырев. All rights reserved.
//

#import "ADFiledViewController.h"
#import "ADSquare.h"

@interface ADFiledViewController ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;


@property (nonatomic, strong) NSArray *fields;


@property (nonatomic, strong) NSMutableArray *allSquares;
@property (nonatomic, strong) NSArray <ADSquare *> *squares;

@property (nonatomic, strong) ADSquare *lastSquare;



@property (nonatomic, strong) NSArray *result;
@property (nonatomic, strong) NSMutableArray *results;

@property (nonatomic, strong) NSMutableDictionary *blocks;

@property (nonatomic, strong) UIButton *back;
@property (nonatomic, strong) UIButton *restartButton;
@property (nonatomic, strong) UIButton *update;
@property (nonatomic, strong) UIButton *setShowPath;
@property (nonatomic, strong) UIStepper *stepper;


@property (nonatomic, assign) BOOL stopTouches;

@end

@implementation ADFiledViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitle:@"Update" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reloadView) forControlEvents:UIControlEventTouchUpInside];
    self.update = button;
    [self.view addSubview:button];
    
    button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitle:@"show path" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showPath) forControlEvents:UIControlEventTouchUpInside];
    
    self.setShowPath = button;
    [self.view addSubview:button];
    
    
    button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitle:@"restart" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];
    
    self.restartButton = button;
    [self.view addSubview:button];
    
    button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitle:@"back" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissVC:) forControlEvents:UIControlEventTouchUpInside];
    
    self.back = button;
    [self.view addSubview:button];
    
    self.allSquares = [NSMutableArray array];
    self.results = [NSMutableArray array];
    self.blocks = [NSMutableDictionary dictionary];
    
    UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectZero];
    [stepper addTarget:self action:@selector(changeStep:) forControlEvents:UIControlEventValueChanged];
    self.stepper = stepper;
    [self.view addSubview:stepper];
    

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"%@", paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"x.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) {
        
        NSLog(@"ERROR 1");
        
        //path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"x.plist"] ];
    }
    
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path]) {
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else {
        NSLog(@"ERROR 2");
//        // If the file doesn’t exist, create an empty dictionary
//        data = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *mArr = [NSMutableArray array];
    for (int i = 0; i < pow(self.order, 2); i++) {
        ADSquare *sqr = [[ADSquare alloc] init];
        sqr.index = i;
        
        CGPoint coordinate = CGPointMake(i % self.order, i / self.order);
        
        sqr.coordinate = coordinate;
        sqr.layer.borderColor = [UIColor blackColor].CGColor;
        sqr.layer.borderWidth = 1;
        [self.contentView addSubview:sqr];
        
        [mArr addObject:sqr];
    }
    
    self.squares = [NSArray arrayWithArray:mArr];
    
    if (data) {
        NSDictionary *dict = [data objectForKey:[NSString stringWithFormat:@"%ld", self.order]];
//        NSDictionary *dict = [data objectForKey:[NSString stringWithFormat:@"%ld", self.limitBlocks]];
        NSArray *fields = [dict objectForKey:[NSString stringWithFormat:@"%ld", self.limitBlocks]];
        self.fields = fields;
    }
}

- (void)viewWillLayoutSubviews {
    
    self.lastSquare = nil;
    self.stopTouches = NO;
    [self.shapeLayer removeFromSuperlayer];
    
    NSInteger order = self.order;
    
    CGRect bounds = [self.view bounds];
    CGFloat insets = 20;
    __block CGFloat x = insets;
    __block CGFloat width = CGRectGetWidth(bounds) - 2 * insets;
    __block CGFloat y = CGRectGetMidY(bounds) - width / 2;
    
    self.contentView.frame = CGRectMake(x, y, width, width);
    self.restartButton.frame = CGRectMake(x, y - 50, width, 50);
    self.back.frame = CGRectMake(x, CGRectGetMinY(self.restartButton.frame) - 100, width, 100);
    self.update.frame = CGRectMake(x, CGRectGetMaxY(bounds) - 50, width, 50);
    self.setShowPath.frame = CGRectMake(x, CGRectGetMinY(self.update.frame) - 50, width, 50);
    self.stepper.frame = CGRectMake(x, CGRectGetMaxY(bounds) - 130, width, 30);
    
    bounds = self.contentView.bounds;
    bounds = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(2, 2, 2, 2));
    width = CGRectGetWidth(bounds) / order;
    y = CGRectGetMinY(bounds);
    x = CGRectGetMinX(bounds);
    
    if (self.stepper.value >= [self.fields count]) {
        // нет такого уровня
        return;
    }
    
    NSDictionary *dict = [self.fields objectAtIndex:self.stepper.value];
    NSArray *result = [dict objectForKey:@"result"];
    NSArray *squares = [dict valueForKey:@"squares"];
    
    [self.squares enumerateObjectsUsingBlock:^(ADSquare *square, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *tempDict = [squares objectAtIndex:idx];
        
        if ([[tempDict valueForKey:@"border"] boolValue]) {
            square.backgroundColor = [UIColor blueColor];
            square.border = YES;
        } else {
            square.backgroundColor = [UIColor grayColor];
            square.border = NO;
        }
        
        square.isSelected = NO;
        
        
        if (idx && !(idx % order)) {
            y += width;
            x = CGRectGetMinX(bounds);
        }
        
        square.frame = CGRectMake(x, y, width, width);
        x += width;
    }];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (int i = 0; i < [result count]; i++) {
        
        NSNumber *num = [result objectAtIndex:i];
        ADSquare *sqr = [self.squares objectAtIndex:num.integerValue];
        
        CGRect frame = sqr.frame;
        CGPoint point = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        
        if (!i) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    [layer setPath:path.CGPath];
    [layer setLineWidth:1];
//    [layer setStrokeColor:[UIColor blackColor].CGColor];
    [layer setFillColor:[UIColor clearColor].CGColor];
    
    self.shapeLayer = layer;
    
    [self.contentView.layer addSublayer:layer];
}

#pragma mark - Getters

- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
        contentView.backgroundColor = [UIColor redColor];
        
        [self.view addSubview:contentView];
        
        UISwipeGestureRecognizer *up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        up.direction = UISwipeGestureRecognizerDirectionUp;
        
        UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        down.direction = UISwipeGestureRecognizerDirectionDown;
        
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        right.direction = UISwipeGestureRecognizerDirectionRight;
        
        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        
        [contentView addGestureRecognizer:up];
        [contentView addGestureRecognizer:down];
        [contentView addGestureRecognizer:right];
        [contentView addGestureRecognizer:left];
        
        _contentView = contentView;
    }
    
    return _contentView;
}

#pragma mark - Setters

- (void)setOrder:(NSInteger)order {
    _order = order;
}


#pragma mark - SaveOnDist

- (void)saveDict {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"%@", paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"x.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) {
        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"x.plist"] ];
    }
    
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path]) {
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableArray *fields = [NSMutableArray array];
    NSArray *tempArr;
    NSDictionary *dict;
    NSMutableArray *squares;
    NSMutableArray *result;
    
    
    ADSquare *tempSqr;
    
    for (int i = 0; i < [self.results count]; i++) {
        
        squares = [NSMutableArray array];
        result = [NSMutableArray array];
        tempArr = [self.results objectAtIndex:i];
        
        for (tempSqr in tempArr) {
            [result addObject:@(tempSqr.index)];
        }
        
        tempArr = [self.allSquares objectAtIndex:i];
        
        for (tempSqr in tempArr) {
            dict = @{@"border" : @(tempSqr.border),
                     @"index" : @(tempSqr.index)
                     };
            [squares addObject:dict];
        }
        
        dict = @{@"squares" : squares,
                 @"result" : result
                 };
        
        [fields addObject:dict];
    }
    
    //To insert the data into the plist
    dict = [NSDictionary dictionaryWithObject:fields forKey:[NSString stringWithFormat:@"%ld", self.limitBlocks]];
    [data setObject:dict forKey:[NSString stringWithFormat:@"%ld", self.order]];
//    [data setObject:data forKey:[NSString stringWithFormat:@"%ld", self.order]];
    if ([data writeToFile:path atomically:NO]) {
        NSLog(@"write");
    };
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.stopTouches) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.contentView];
    UIView *sqr = [self.contentView hitTest:touchPoint withEvent:event];
    
    for (ADSquare *square in self.squares) {
        if (square.border) {
            continue;
        }
        if ([sqr isEqual:square]) {
            square.backgroundColor = [UIColor greenColor];
            self.lastSquare = square;
            self.lastSquare.isSelected = YES;
            self.stopTouches = YES;
        }
    }
}


#pragma mark - Swipe

- (void)swipeAction:(UISwipeGestureRecognizer *)swipe {
    ADSquare *lastSquare = self.lastSquare;
    ADSquare *tempSqr = nil;
    
    if (!lastSquare) {
        // еще не тапнули на квадрат
        return;
    }
    
    NSInteger index;
    NSInteger compareIndex;
    NSInteger counter;
    NSInteger bounds;
    
    switch (swipe.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            index = lastSquare.coordinate.y;
            compareIndex = 0;
            counter = - self.order;
            bounds = index;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            index = lastSquare.coordinate.y;
            compareIndex = self.order - 1;
            counter = self.order;
            bounds = compareIndex - index;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            index = lastSquare.coordinate.x;
            compareIndex = self.order - 1;
            counter = 1;
            bounds = compareIndex - index;
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            index = lastSquare.coordinate.x;
            compareIndex = 0;
            counter = - 1;
            bounds = index;
            break;
        default:
            // непонятно что
            return;
    }
    if (index == compareIndex) {
        // стоим на краю
        return;
    }
    index = lastSquare.index;
    for (int i = 0; i < bounds; i++) {
        index += counter;
        tempSqr = [self.squares objectAtIndex:index];
        // блок
        if (tempSqr.border) {
            break;
        }
        // уже выбрали
        if (tempSqr.isSelected) {
            break;
        }
        // выбираем
        tempSqr.backgroundColor = [UIColor greenColor];
        tempSqr.isSelected = YES;
        self.lastSquare = tempSqr;
    }
    
    if ([self checkSquares]) {
        // нашли путь (закрашиваем и обновляем уровень)
        for (ADSquare *sqr in self.squares) {
            [UIView animateWithDuration:1.5 animations:^{
                sqr.backgroundColor = [UIColor grayColor];
            } completion:^(BOOL finished) {
                [self.view setNeedsLayout];
            }];
        }
        self.stepper.value++;
        
    } else if ([self checkDeadLock]) {
        // зашли в тупик (закрашиваем и перерисовываем уровень)
        for (ADSquare *sqr in self.squares) {
            if (sqr.isSelected) {
                [UIView animateWithDuration:1.5 animations:^{
                    sqr.backgroundColor = [UIColor redColor];
                } completion:^(BOOL finished) {
                    [self.view setNeedsLayout];
                }];
            }
        }
    }
}

#pragma mark - Actions

- (void)dismissVC:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)restart {
    [self.view setNeedsLayout];
}

- (void)showPath {
    self.shapeLayer.strokeColor = [UIColor blackColor].CGColor;
}

- (void)reloadView {
        
    [self.results removeAllObjects];
    [self.blocks removeAllObjects];
    
    NSArray *arr;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    for (int i = 0; i < self.countFields; i++) {
        arr = nil;
        while (![arr count]) {
            [self createField];
            
            if ([self checkBlocks]) {
                break;
            }
            
            arr = [self createPathWithArray:self.squares];
            if (arr) {
                [self.results addObject:arr];
                [self.allSquares addObject:self.squares];
                self.squares = nil;
            }
        }
        
        if ([self checkBlocks]) {
            break;
        }
        
        NSLog(@"%d", i);
    }
    [self saveDict];
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self viewDidLoad];
    
    //[self.view setNeedsLayout];
}

- (void)changeStep:(UIStepper *)stepper {
//    NSInteger step = stepper.value;
//    
//    if (step < [self.results count]) {
//        self.squares = [self.allSquares objectAtIndex:step];
//        self.result = [self.results objectAtIndex:step];
//    }

    [self.view setNeedsLayout];
}


#pragma mark - Path

- (NSArray *)createPathWithArray:(NSArray <ADSquare *> *)squares {
    NSMutableArray *arr;
    self.result = nil;
    
    for (ADSquare *square in squares) {
        // если это блок (граница)
        if (square.border) {
            continue;
        }
        // ищем путь для текущего квадрата
        arr = [self findPathForSquare:square inArray:squares];
        // сбрасываем выбранные квадраты для следующего прохода
        if (arr) {
            [arr insertObject:square atIndex:0];
            break;
        }
        [self resetSelectForArray:squares];
    }
    return arr;
}

- (NSMutableArray *)findPathForSquare:(ADSquare *)square inArray:(NSArray *)array {
    
    // сразу отметим квадрат
    square.isSelected = YES;
    
    ADSquare *tempSquare;
    NSMutableArray *mArr = [NSMutableArray array];
    NSArray *result;
    NSInteger index = square.index;
    
    if (square.coordinate.x < self.order - 1) {
        // можем попасть вправо
        NSInteger condition = self.order - 1 - square.coordinate.x;
        // максимум будет order - 1 проходов
        for (NSInteger i = 0; i < condition; i++) {
            // берем квадрат справа
            tempSquare = [array objectAtIndex:index + 1];
            index++;
            
            // проверка на возможность использования
            if (tempSquare.isSelected || tempSquare.border) {
                // если дошли до блока или этот элемент уже выбирали
                break;
            }
            tempSquare.isSelected = YES;
            [mArr addObject:tempSquare];
        }
        if ([mArr count]) {
            tempSquare = [mArr lastObject];
            result = [self findPathForSquare:tempSquare inArray:array];
            if (result) {
                //[mArr insertObject:square atIndex:0];
                [mArr addObjectsFromArray:result];
                
                // нашли путь и возвращаем его наверх
                return mArr;
            } else {
                // если не наши путь, то нужно очистить все нижние квадраты
                [self resetSelectForArray:mArr];
            }
        } else {
            // просто идем в другую сторону
        }
    }
    
    // очищаем массив перед последующим использованием
    [mArr removeAllObjects];
    index = square.index;
    
    if (square.coordinate.y < self.order - 1) {
        // можем попасть в нижний квадрат
        NSInteger condition = self.order - 1 - square.coordinate.y;
        // максимум будет order - 1 проходов
        for (NSInteger i = 0; i < condition; i++) {
            // берем квадрат справа
            tempSquare = [array objectAtIndex:index + self.order];
            index+=self.order;
            
            // проверка на возможность использования
            if (tempSquare.isSelected || tempSquare.border) {
                // если дошли до блока или этот элемент уже выбирали
                break;
            }
            tempSquare.isSelected = YES;
            [mArr addObject:tempSquare];
        }
        if ([mArr count]) {
            tempSquare = [mArr lastObject];
            result = [self findPathForSquare:tempSquare inArray:array];
            if (result) {
                //[mArr insertObject:square atIndex:0];
                [mArr addObjectsFromArray:result];
                
                // нашли путь и возвращаем его наверх
                return mArr;
            } else {
                // если не наши путь, то нужно очистить все нижние квадраты
                [self resetSelectForArray:mArr];
            }
        } else {
            // просто идем в другую сторону
        }
    }
    [mArr removeAllObjects];
    index = square.index;
    
    
    if (square.coordinate.x > 0) {
        // можем попасть налево
        NSInteger condition = square.coordinate.x;
        // максимум будет order - 1 проходов
        for (NSInteger i = 0; i < condition; i++) {
            // берем квадрат справа
            tempSquare = [array objectAtIndex:index - 1];
            index--;
            
            // проверка на возможность использования
            if (tempSquare.isSelected || tempSquare.border) {
                // если дошли до блока или этот элемент уже выбирали
                break;
            }
            tempSquare.isSelected = YES;
            [mArr addObject:tempSquare];
        }
        if ([mArr count]) {
            tempSquare = [mArr lastObject];
            result = [self findPathForSquare:tempSquare inArray:array];
            if (result) {
                //[mArr insertObject:square atIndex:0];
                [mArr addObjectsFromArray:result];
                
                // нашли путь и возвращаем его наверх
                return mArr;
            } else {
                // если не наши путь, то нужно очистить все нижние квадраты
                [self resetSelectForArray:mArr];
            }
        } else {
            // просто идем в другую сторону
        }
    }
    [mArr removeAllObjects];
    index = square.index;
    
    if (square.coordinate.y > 0) {
        // можем попасть наверх
        NSInteger condition = square.coordinate.y;
        // максимум будет order - 1 проходов
        for (NSInteger i = 0; i < condition; i++) {
            // берем квадрат справа
            tempSquare = [array objectAtIndex:index - self.order];
            index-=self.order;
            
            // проверка на возможность использования
            if (tempSquare.isSelected || tempSquare.border) {
                // если дошли до блока или этот элемент уже выбирали
                break;
            }
            tempSquare.isSelected = YES;
            [mArr addObject:tempSquare];
        }
        if ([mArr count]) {
            tempSquare = [mArr lastObject];
            result = [self findPathForSquare:tempSquare inArray:array];
            if (result) {
                //[mArr insertObject:square atIndex:0];
                [mArr addObjectsFromArray:result];
                
                // нашли путь и возвращаем его наверх
                return mArr;
            } else {
                // если не наши путь, то нужно очистить все нижние квадраты
                [self resetSelectForArray:mArr];
            }
        } else {
            // просто идем в другую сторону
        }
    }
    
    if ([mArr count] > 1) {
        // значит добавили еще какие то элементы в массив
    } else {
        // ничего не добавляли - значит что дошли до последнего элемента
        // и надо проверить основной массив на isSelected
    }
    
    // если дошли до узла, из которого никуда не выйти, то проверим все квадраты на isSelected
    if ([self checkSquares]) {
        // выбраны все квадраты, значит нашли путь
        return mArr;
    }
    
    // возвращаем nil, так как не все квадраты выбраны
    return nil;
}

- (void)resetSelectForArray:(NSArray *)arr {
    [arr enumerateObjectsUsingBlock:^(ADSquare *square, NSUInteger idx, BOOL * _Nonnull stop) {
        square.isSelected = NO;
    }];
}

- (BOOL)checkDeadLock {
    
    ADSquare *lastSquare = self.lastSquare;
    ADSquare *tempSqr = nil;
    
    NSInteger index = lastSquare.index;
    
    if (lastSquare.coordinate.x != 0) {
        // проверяем левый
        tempSqr = [self.squares objectAtIndex:index - 1];
        if (!tempSqr.isSelected && !tempSqr.border) {
            return NO;
        }
    }
    
    if (lastSquare.coordinate.x != self.order - 1) {
        // проверяем правый
        tempSqr = [self.squares objectAtIndex:index + 1];
        if (!tempSqr.isSelected && !tempSqr.border) {
            return NO;
        }
    }
    
    if (lastSquare.coordinate.y != 0) {
        // проверяем верхний
        tempSqr = [self.squares objectAtIndex:index - self.order];
        if (!tempSqr.isSelected && !tempSqr.border) {
            return NO;
        }
    }
    
    if (lastSquare.coordinate.y != self.order - 1) {
        // проверяем нижний
        tempSqr = [self.squares objectAtIndex:index + self.order];
        if (!tempSqr.isSelected && !tempSqr.border) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)checkSquares {
    for (ADSquare *square in self.squares) {
        if (square.border) {
            // идем дальше
            continue;
        }
        if (!square.isSelected) {
            // если узел не выбран
            return NO;
        }
    }
    // выбраны все узлы - значит нашли путь
    return YES;
}

- (BOOL)checkBlocks {
    unsigned long long limit = 0;//[self factorial:order2] / ([self factorial:self.limitBlocks] * [self factorial:(order2 - self.limitBlocks)]);
    
    if ([self.blocks count] == limit) {
                
        NSLog(@"Достигнуто максимальное колличество блоков:%llu", limit);
        
        return YES;
    } else {
        return NO;
    }
}

- (unsigned long long)factorial:(unsigned long long)fact {
    if (fact == 1) {
        return 1;
    } else {
        unsigned long long fact2 = fact - 1;
        return fact * [self factorial:fact2];
    }
}


- (void)createField {
    NSInteger count = pow(self.order, 2);
    NSInteger limit;
    NSMutableDictionary *blocks;// = [NSMutableDictionary dictionaryWithCapacity:limit];
    
    
    begin:
    
    limit = self.limitBlocks;
    blocks = [NSMutableDictionary dictionaryWithCapacity:limit];
    
    // строим массив индексов
    while (limit) {
        NSInteger index = arc4random() % count;
        if (![blocks objectForKey:@(index)]) {
            [blocks setObject:@(index) forKey:@(index)];
            limit--;
        }
    }
    // строим строку для будущего сравнения
//    __block NSMutableString *ascedString = [[NSMutableString alloc] initWithCapacity:limit * 2];
    NSSortDescriptor *sortDescr = [NSSortDescriptor sortDescriptorWithKey:@"integerValue" ascending:YES];
    NSArray *arr = [blocks.allValues sortedArrayUsingDescriptors:@[sortDescr]];
    
    NSInteger number = 0;
    for (int i = 0; i < [arr count]; i++) {
        
        number += [[arr objectAtIndex:i] integerValue] * pow(100, i);
    }
    
    if ([self includeBlocks:@(number)]) {
//        [self.blocks addObject:ascedString];
//        [self.blocks setObject:@1 forKey:ascedString];
        [self.blocks setObject:@1 forKey:@(number)];
    } else {
        // уже есть строка с такими же блоками. Идем обратно
//        ascedString = nil;
        sortDescr = nil;
        arr = nil;
//        limit = self.limitBlocks;
//        [blocks removeAllObjects];
        
        if ([self checkBlocks]) {
            return;
        }
        
        goto begin;
    }
    
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:count];
    
    for (NSInteger i = 0; i < count; i++) {
        
        ADSquare *square = [[ADSquare alloc] initWithFrame:CGRectZero];
        square.index = i;
        CGPoint coordinate = CGPointMake(i % self.order, i / self.order);
        square.coordinate = coordinate;
        
        if ([blocks objectForKey:@(i)]) {
            square.backgroundColor = [UIColor blueColor];
            square.border = YES;
        } else {
            square.backgroundColor = [UIColor grayColor];
        }
        
        square.layer.borderColor = [UIColor blackColor].CGColor;
        square.layer.borderWidth = 1;
        
        [mArr addObject:square];
    }
    
    self.squares = [NSArray arrayWithArray:mArr];
}

- (BOOL)includeBlocks:(NSNumber *)string {
    if ([self.blocks objectForKey:string]) {
        return NO;
    }
    return YES;
}

















@end
