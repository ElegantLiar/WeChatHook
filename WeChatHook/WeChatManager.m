//
//  WeChatManager.m
//  WeChatHook
//
//  Created by EL on 2017/9/18.
//
//

#import "WeChatManager.h"

NSString * const kWechatSaveKey = @"kWechatSaveKey";

@implementation WeChatManager

+ (WeChatManager *)manager{
    static WeChatManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[WeChatManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    if (self == [super init]) {
        NSData *managerData = [[NSUserDefaults standardUserDefaults] objectForKey:kWechatSaveKey];
        WeChatManager *manager = [NSKeyedUnarchiver unarchiveObjectWithData:managerData];
        self.lastChangeStepCountDate = manager.lastChangeStepCountDate;
        self.stepCount = manager.stepCount;
        self.revokeMsg = manager.revokeMsg;
    }
    return self;
}

- (void)recordStepCount:(UITextField *)textfield{
    self.stepCount = textfield.text.integerValue;
    self.lastChangeStepCountDate = [NSDate date];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.stepCount forKey:@"stepCount"];
    [aCoder encodeBool:self.revokeMsg forKey:@"revokeMsg"];
    [aCoder encodeObject:self.lastChangeStepCountDate forKey:@"lastChangeStepCountDate"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.stepCount = [aDecoder decodeIntegerForKey:@"stepCount"];
        self.revokeMsg = [aDecoder decodeBoolForKey:@"revokeMsg"];
        self.lastChangeStepCountDate = [aDecoder decodeObjectForKey:@"lastChangeStepCountDate"];
    }
    return self;
}


@end
