//
//  GroupManager.m
//  EaseMob-Example
//
//  Created by zzg on 2018/7/11.
//  Copyright © 2018年. All rights reserved.
//

#import "GroupManager.h"
#import <Hyphenate/Hyphenate.h>
#import "NSString+Util.h"
#import "NSObject+Util.h"
#import "Constant.h"

@implementation GroupManager

DEFINE_SINGLETON_FOR_CLASS(GroupManager);

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(createGroup:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] createGroup_local:params resolver:resolve rejecter:reject];
}

- (void)createGroup_local:(NSString *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    EMError *error = nil;
    EMGroupOptions *setting = [[EMGroupOptions alloc] init];
    setting.maxUsersCount = 500;
    setting.IsInviteNeedConfirm = NO; //邀请群成员时，是否需要发送邀请通知.若NO，被邀请的人自动加入群组
    setting.style = EMGroupStylePublicOpenJoin;// 创建不同类型的群组，这里需要才传入不同的类型
    NSDictionary *options = [allParams objectForKey:@"setting"];
    NSString *subject = [allParams objectForKey:@"subject"];
    NSString *description = [allParams objectForKey:@"description"];
    NSArray *invitees = [allParams objectForKey:@"invitees"];
    NSString *message = [allParams objectForKey:@"message"];
    if ([[options allKeys] count] > 0) {
        [setting updateWithDictionary:options];
    }
    EMGroup *group = [[EMClient sharedClient].groupManager createGroupWithSubject:subject description:description invitees:invitees message:message setting:setting error:&error];
    if(!error){
        resolve([group objectToJSONString]);
    } else {
        reject([NSString stringWithFormat:@"%ld", (NSInteger)error.code], error.errorDescription, nil);
    }
}

RCT_EXPORT_METHOD(getJoinedGroups:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] getJoinedGroups_local:resolve rejecter:reject];
}

- (void)getJoinedGroups_local:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject {
    NSArray *groupList = [[EMClient sharedClient].groupManager getJoinedGroups];
    NSMutableArray *dicArray = [NSMutableArray array];
    [groupList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dicArray addObject:[obj objectToDictionary]];
    }];
    resolve(JSONSTRING(dicArray));
}

RCT_EXPORT_METHOD(getGroupMemberList:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] getGroupMemberList_local:params resolver:resolve rejecter:reject];
}

- (void)getGroupMemberList_local:(NSString *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    EMError *error = nil;
    NSString *groupId = [allParams objectForKey:@"groupId"];
    NSString *cursor = [allParams objectForKey:@"cursor"];
    int pageSize = [[allParams objectForKey:@"pageSize"] intValue];
    
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:groupId cursor:cursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
        if (!aError) {
            resolve([aResult objectToJSONString]);
        } else {
            reject([NSString stringWithFormat:@"%ld", (NSInteger)error.code], error.errorDescription, nil);
        }
    }];
}

RCT_EXPORT_METHOD(getGroupSpecification:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] getGroupSpecification_local:params resolver:resolve rejecter:reject];
}

- (void)getGroupSpecification_local:(NSString *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    EMError *error = nil;
    NSString *groupId = [allParams objectForKey:@"groupId"];
    EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:groupId error:&error];
    if(!error){
        resolve([group objectToJSONString]);
    } else {
        reject([NSString stringWithFormat:@"%ld", (NSInteger)error.code], error.errorDescription, nil);
    }
}

RCT_EXPORT_METHOD(addOccupants:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] addOccupants_local:params resolver:resolve rejecter:reject];
}

- (void)addOccupants_local:(NSString *)params
                           resolver:(RCTPromiseResolveBlock)resolve
                           rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    EMError *error = nil;
    NSString *groupId = [allParams objectForKey:@"groupId"];
    NSArray *members = [allParams objectForKey:@"members"];
    EMGroup *group = [[EMClient sharedClient].groupManager addOccupants:members toGroup:groupId welcomeMessage:@"" error:&error];
    if(!error){
        resolve([group objectToJSONString]);
    } else {
        reject([NSString stringWithFormat:@"%ld", (NSInteger)error.code], error.errorDescription, nil);
    }
}

RCT_EXPORT_METHOD(removeOccupants:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] removeOccupants_local:params resolver:resolve rejecter:reject];
}

- (void)removeOccupants_local:(NSString *)params
                    resolver:(RCTPromiseResolveBlock)resolve
                    rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    EMError *error = nil;
    NSString *groupId = [allParams objectForKey:@"groupId"];
    NSArray *members = [allParams objectForKey:@"members"];
    EMGroup *group = [[EMClient sharedClient].groupManager removeOccupants:members fromGroup:groupId error:&error];
    if(!error){
        resolve([group objectToJSONString]);
    } else {
        reject([NSString stringWithFormat:@"%ld", (NSInteger)error.code], error.errorDescription, nil);
    }
}

RCT_EXPORT_METHOD(changeGroupSubject:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] changeGroupSubject_local:params resolver:resolve rejecter:reject];
}

- (void)changeGroupSubject_local:(NSString *)params
                     resolver:(RCTPromiseResolveBlock)resolve
                     rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    EMError *error = nil;
    NSString *groupId = [allParams objectForKey:@"groupId"];
    NSString *subject = [allParams objectForKey:@"subject"];
    EMGroup *group = [[EMClient sharedClient].groupManager changeGroupSubject:subject forGroup:groupId error:&error];
    if(!error){
        resolve([group objectToJSONString]);
    } else {
        reject([NSString stringWithFormat:@"%ld", (NSInteger)error.code], error.errorDescription, nil);
    }
}

RCT_EXPORT_METHOD(destroyGroup:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] destroyGroup_local:params resolver:resolve rejecter:reject];
}

- (void)destroyGroup_local:(NSString *)params
                        resolver:(RCTPromiseResolveBlock)resolve
                        rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    NSString *groupId = [allParams objectForKey:@"groupId"];
    EMError *error  = [[EMClient sharedClient].groupManager destroyGroup:groupId];
    if(!error){
        resolve(@"{}");
    } else {
        reject([NSString stringWithFormat:@"%ld", (NSInteger)error.code], error.errorDescription, nil);
    }
}

RCT_EXPORT_METHOD(updateGroupOwner:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] updateGroupOwner_local:params resolver:resolve rejecter:reject];
}

- (void)updateGroupOwner_local:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    NSString *groupId = [allParams objectForKey:@"groupId"];
    NSString *newOwner = [allParams objectForKey:@"newOwner"];
    EMError *error = nil;
    EMGroup *group = [[EMClient sharedClient].groupManager updateGroupOwner:groupId newOwner:newOwner error:&error];
    if(!error){
        resolve([group objectToJSONString]);
    } else {
        reject([NSString stringWithFormat:@"%ld", (NSInteger)error.code], error.errorDescription, nil);
    }
}

RCT_EXPORT_METHOD(updateGroupExt:(NSString *)params
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    [[GroupManager sharedGroupManager] updateGroupExt_local:params resolver:resolve rejecter:reject];
}

- (void)updateGroupExt_local:(NSString *)params
                        resolver:(RCTPromiseResolveBlock)resolve
                        rejecter:(RCTPromiseRejectBlock)reject {
    NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:[params jsonStringToDictionary]];
    EMError *error = nil;
    NSString *groupId = [allParams objectForKey:@"groupId"];
    NSDictionary *ext = [allParams objectForKey:@"ext"];
    NSString *extString = JSONSTRING(ext);
    EMGroup *group = [[EMClient sharedClient].groupManager updateGroupExtWithId:groupId ext:extString error:&error];
    if(!error){
        resolve([group objectToJSONString]);
    } else {
        reject([NSString stringWithFormat:@"%ld", (NSInteger)error.code], error.errorDescription, nil);
    }
}

@end
