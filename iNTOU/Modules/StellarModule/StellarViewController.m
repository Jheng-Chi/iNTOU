//
//  StellarViewController.m
//  iNTOU
//
//  Created by Jheng-Chi on 2017/4/12.
//  Copyright © 2017年 Lab414. All rights reserved.
//

#import "StellarViewController.h"
#import "Moodle.h"
@interface StellarViewController ()

@end

@implementation StellarViewController
static NSArray* dayTag;

-(instancetype)initWithCoder:(NSCoder *)c {
    self = [super initWithCoder:c];
    if(self) {
        if(!dayTag)
            dayTag = @[@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat",@"Sun"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBaseViewHeightAndWidth];
    
    //設定weekBar
    self.stellarWeekBar = [StellarWeekBar new];
    self.stellarWeekBar.baseViewHeight = self.baseViewHeight.constant;
    self.stellarWeekBar.baseViewWidth = self.baseViewWidth.constant;
    self.weekScrollView.dataSource = self.stellarWeekBar;
    self.weekScrollView.delegate = self.stellarWeekBar;
    
    //設定classBar
    self.stellarClassBar = [StellarClassBar new];
    self.stellarClassBar.baseViewHeight = self.baseViewHeight.constant * 2;
    self.stellarClassBar.baseViewWidth = self.baseViewWidth.constant;
    self.classScrollView.dataSource = self.stellarClassBar;
    self.classScrollView.delegate = self.stellarClassBar;
    
    //設定layout cell size
    ((StellarViewLayout*)self.mainScrollView.collectionViewLayout).baseViewHeight = self.baseViewHeight.constant * 2;
    ((StellarViewLayout*)self.mainScrollView.collectionViewLayout).baseViewWidth = self.baseViewWidth.constant;
    
    stellarData = [[NSUserDefaults standardUserDefaults] objectForKey:@"StellarModule"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setBaseViewHeightAndWidth {
    if(((self.view.bounds.size.height - 15)/15.5)/2 < 20)
        self.baseViewHeight.constant = 20;
    else
        self.baseViewHeight.constant = ((self.view.bounds.size.height - 15)/15.5)/2;
    
    if((self.view.bounds.size.width - 7)/8 < 60)
        self.baseViewWidth.constant = 60;
    else
        self.baseViewWidth.constant = (self.view.bounds.size.width - 7)/8;
    
}

- (IBAction)refresh:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Moodle* moodle = [Moodle sharedInstance];
        if([moodle checkLogin]) {
            stellarData = [self makeDataEasyToShow:[moodle getCourse]];
            [[NSUserDefaults standardUserDefaults] setObject:stellarData forKey:@"StellarModule"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainScrollView reloadData];
            });
        }
    });
}


-(NSDictionary*)makeDataEasyToShow:(NSDictionary*)data {
    NSMutableDictionary* returnTemp = [NSMutableDictionary new];
    for(NSDictionary*day in data[@"list"])
    {
        NSMutableArray* dayTemp = [NSMutableArray new];
        for(int i=0;i<[day[@"course"] count];i++)
        {
            int length = 1;
            while(i+length < [day[@"course"] count] && [day[@"course"][i][@"name"] isEqualToString: day[@"course"][i + length][@"name"] ])
                    length++;
            
            NSMutableDictionary* classTemp = [day[@"course"][i] mutableCopy];
            [classTemp setObject:[NSNumber numberWithInteger:length] forKey:@"length"];
            [dayTemp addObject:[classTemp copy]];
            i += length - 1;
        }
        [returnTemp setObject:[dayTemp copy] forKey:day[@"day"]];
    }
    return [returnTemp copy];
}

#pragma mark - stellar view layout

-(unsigned int)cellLengthAtIndexPath:(NSIndexPath *)indexPath {
    //當天沒有課程
    if(!stellarData[dayTag[indexPath.section]])
        return 0;
    NSArray* day = stellarData[dayTag[indexPath.section]];
    int i = 0;
    //小於第一個課程
    if(indexPath.row < [day[i][@"time"] intValue] - 1)
        return 0;
    //尋找小於課程時間最大值
    while(i + 1 < [day count] && indexPath.row >= [day[i+1][@"time"] intValue] - 1)
        i++;
    //檢查兩者是否相同
    if(indexPath.row == [day[i][@"time"] intValue] - 1)
        return [day[i][@"length"] intValue];
    else
    //檢查是否在區間內
    if(indexPath.row < [day[i][@"time"] intValue] - 1 + [day[i][@"length"] intValue])
        return -1;
    return 0;
}

#pragma mark - uicollection data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 7;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 14;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MainCells" forIndexPath:indexPath];
    
    ((UILabel*)[cell viewWithTag:101]).text = @"";
    NSArray* day = stellarData[dayTag[indexPath.section]];
    for(int i = 0 ; i < [day count] ; i++)
        if(indexPath.row == [day[i][@"time"] intValue] - 1)
            ((UILabel*)[cell viewWithTag:101]).text = day[i][@"name"];
    
    return cell;
}

#pragma mark - uicollection

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* day = stellarData[dayTag[indexPath.section]];
    for(int i = 0 ; i < [day count] ; i++)
        if(indexPath.row == [day[i][@"time"] intValue] - 1)
            [self performSegueWithIdentifier:@"Action" sender:day[i]];
}

#pragma mark - scroll view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint pointRow = self.weekScrollView.contentOffset;
    CGPoint pointColumn = self.classScrollView.contentOffset;
    pointRow.x = scrollView.contentOffset.x;
    pointColumn.y = scrollView.contentOffset.y;
    
    [self.weekScrollView setContentOffset:pointRow];
    [self.classScrollView setContentOffset:pointColumn];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id page = [segue destinationViewController];
    [page setValue:(NSDictionary*)sender forKey:@"classData"];
}

@end