//
//  FishChat.mm
//  FishChat
//
//  Created by 杨萧玉 on 2017/2/22.
//  Copyright (c) 2017年 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import "WeChatManager.h"
#import <Cycript/Cycript.h>
// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

#define CYCRIPT_PORT 8888

CHDeclareClass(UIApplication)
CHDeclareClass(MicroMessengerAppDelegate)
CHDeclareClass(CMessageMgr)
CHDeclareClass(WCDeviceStepObject)
CHDeclareClass(NewSettingViewController)
CHDeclareClass(MMTableViewInfo)
CHDeclareClass(MMTableViewSectionInfo)
CHDeclareClass(MMTableViewCellInfo)
CHDeclareClass(MMTableView)
CHDeclareClass(UIViewController)

CHOptimizedMethod2(self, void, MicroMessengerAppDelegate, application, UIApplication *, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    CHSuper2(MicroMessengerAppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    // 监听 Cycript 8888 端口
    NSLog(@"## Start Cycript ##");
    CYListenServer(CYCRIPT_PORT);
}

CHDeclareMethod1(void, MicroMessengerAppDelegate, applicationWillResignActive, UIApplication *, application)
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[WeChatManager manager]] forKey:kWechatSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 阻止撤回消息
CHOptimizedMethod1(self, void, CMessageMgr, onRevokeMsg, id, msg)
{
    [WeChatManager manager].revokeMsg = YES;
    CHSuper1(CMessageMgr, onRevokeMsg, msg);
}

CHDeclareMethod3(void, CMessageMgr, DelMsg, id, arg1, MsgList, id, arg2, DelAll, BOOL, arg3)
{
    if ([WeChatManager manager].revokeMsg) {
        [WeChatManager manager].revokeMsg = NO;
    }
    else {
        CHSuper3(CMessageMgr, DelMsg, arg1, MsgList, arg2, DelAll, arg3);
    }
}

// 微信运动步数

CHOptimizedMethod0(self, unsigned int, WCDeviceStepObject, m7StepCount)
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[WeChatManager manager].lastChangeStepCountDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    BOOL modifyToday = NO;
    if([today isEqualToDate:otherDate]) {
        modifyToday = YES;
    }
    if ([WeChatManager manager].stepCount == 0 || !modifyToday) {
        [WeChatManager manager].stepCount = CHSuper0(WCDeviceStepObject, m7StepCount);
    }
    return [WeChatManager manager].stepCount;
}

// 设置

CHDeclareMethod0(void, NewSettingViewController, reloadTableData)
{
    CHSuper0(NewSettingViewController, reloadTableData);
    MMTableViewInfo *tableInfo = [self valueForKeyPath:@"m_tableViewInfo"];
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    MMTableViewCellInfo *stepcountCellInfo = [objc_getClass("MMTableViewCellInfo") editorCellForSel:@selector(recordStepCount:) target:[WeChatManager manager] title:@"微信运动步数" margin:300.0 tip:@"请输入步数" focus:NO text:[NSString stringWithFormat:@"%ld", (long)[WeChatManager manager].stepCount]];
    [sectionInfo addCell:stepcountCellInfo];
    [tableInfo insertSection:sectionInfo At:0];
    MMTableView *tableView = [tableInfo getTableView];
    [tableView reloadData];
}

CHConstructor // code block that runs immediately upon load
{
    @autoreleasepool
    {
        CHLoadLateClass(MicroMessengerAppDelegate);  // load class (that will be "available later")
        CHHook2(MicroMessengerAppDelegate, application, didFinishLaunchingWithOptions); // register hook
        CHLoadLateClass(CMessageMgr);
        CHHook1(CMessageMgr, onRevokeMsg);
        CHLoadLateClass(WCDeviceStepObject);
        CHHook0(WCDeviceStepObject, m7StepCount);
    }
}
