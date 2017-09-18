//
//  WeChatManager.h
//  WeChatHook
//
//  Created by EL on 2017/9/18.
//
//

#import <UIKit/UIKit.h>

extern NSString * const kWechatSaveKey;

@interface WeChatManager : NSObject<NSCoding>

+ (WeChatManager *)manager;

@property (nonatomic, assign) NSInteger stepCount;
@property (nonatomic, assign) BOOL revokeMsg;
@property (nonatomic, strong) NSDate *lastChangeStepCountDate;

- (void)recordStepCount:(UITextField *)textfield;
@end
