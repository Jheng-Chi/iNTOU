//
//  LibraryHistoryTableViewController.h
//  iNTOU
//
//  Created by Jheng-Chi on 2017/2/6.
//  Copyright © 2017年 Lab414. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Library.h"

@interface LibraryHistoryTableViewController : UITableViewController {
    UIRefreshControl* refresh;
    Library* library;
    NSArray* libraryHistoryData;
    int maxSegment;
    Boolean threadLock;
}

@end
