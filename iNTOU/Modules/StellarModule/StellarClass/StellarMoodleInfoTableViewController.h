//
//  StellarMoodleInfoTableViewController.h
//  iNTOU
//
//  Created by Jheng-Chi on 2017/1/29.
//  Copyright © 2017年 Lab414. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StellarMoodleInfoTableViewController : UITableViewController {
    UIRefreshControl* refresh;
}


@property (weak,nonatomic)NSDictionary* classData;
@property (strong,nonatomic)NSDictionary* moodleInfoData;

@end
