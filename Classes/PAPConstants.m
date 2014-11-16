//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPConstants.h"

NSString *const kPAPErrorDomain = @"AppErrorDomain";

NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"it.appcorner.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsCacheFacebookFriendsKey                     = @"it.appcorner.userDefaults.cache.facebookFriends";


#pragma mark - Launch URLs

NSString *const kPAPLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const PAPAppDelegateApplicationDidReceivePurchaseRemoteNotification   = @"it.appcorner.appDelegate.applicationDidReceivePurchaseRemoteNotification";
NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification           = @"it.appcorner.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const PAPUtilityUserFollowingChangedNotification                      = @"it.appcorner.utility.userFollowingChanged";
NSString *const PAPUtilityUserLikedUnlikedAppCallbackFinishedNotification     = @"it.appcorner.utility.userLikedUnlikedAppCallbackFinished";
NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification         = @"it.appcorner.utility.didFinishProcessingProfilePictureNotification";
NSString *const PAPTabBarControllerDidFinishEditingAppNotification            = @"it.appcorner.tabBarController.didFinishEditingApp";
NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification         = @"it.appcorner.tabBarController.didFinishImageFileUploadNotification";
NSString *const PAPAppDetailsViewControllerUserDeletedAppNotification       = @"it.appcorner.appDetailsViewController.userDeletedApp";
NSString *const PAPAppDetailsViewControllerUserLikedUnlikedAppNotification  = @"it.appcorner.appDetailsViewController.userLikedUnlikedAppInDetailsViewNotification";
NSString *const PAPAppDetailsViewControllerUserCommentedOnAppNotification   = @"it.appcorner.appDetailsViewController.userCommentedOnAppInDetailsViewNotification";


#pragma mark - User Info Keys
NSString *const PAPAppDetailsViewControllerUserLikedUnlikedAppNotificationUserInfoLikedKey = @"liked";
NSString *const kPAPEditAppViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kPAPInstallationUserKey = @"userChannel";


#pragma mark - PFObject Sync Class
NSString *const kPAPSyncClassKey = @"sync";
NSString *const kPAPSyncMinVersionKey = @"minAppVersion";
NSString *const kPAPSyncDefaultLocaleKey = @"defaultLocale";
NSString *const kPAPSyncNumAppsPickerKey = @"numAppsPicker";

#pragma mark - PFObject Country Class
NSString *const kPAPCountryClassKey = @"country";
NSString *const kPAPCountry = @"country";
NSString *const kPAPCountryAutoFollowFacebookIds = @"autoFollowFacebookIds";

#pragma mark - Activity Class
// Class key
NSString *const kPAPActivityClassKey = @"activity";

// Field keys
NSString *const kPAPActivityTypeKey        = @"type";
NSString *const kPAPActivityFromUserKey    = @"fromUser";
NSString *const kPAPActivityToUserKey      = @"toUser";
NSString *const kPAPActivityContentKey     = @"content";
NSString *const kPAPActivityAppIDKey       = @"appId";

// Type values
NSString *const kPAPActivityTypeLike       = @"l"; //like
NSString *const kPAPActivityTypeFollow     = @"f"; //follow
NSString *const kPAPActivityTypeComment    = @"c"; //comment
NSString *const kPAPActivityTypeJoined     = @"j"; //joined
NSString *const kPAPActivityTypePriceDrop  = @"d"; //price drop

#pragma mark - User Class
// Field keys
NSString *const kPAPUserDisplayNameKey                          = @"displayName";
NSString *const kPAPUserFacebookIDKey                           = @"facebookId";
NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kPAPUserInternal = @"internal";
NSString *const kPAPUserAppStoreCountry = @"appStoreCountry";

#pragma mark - App Class
NSString *const kPAPAppClassKey            = @"app";
// Field keys
NSString *const kPAPAppIconKey             = @"icon"; //fakeKey
NSString *const kPAPAppIconThumbnailKey    = @"iconThumbnail";  //fakeKey
NSString *const kPAPAppIDKey               = @"appId";
NSString *const kPAPAppUserKey             = @"user";
NSString *const kPAPAppBadges              = @"badges";
NSString *const kPAPAppCountryKey          = @"appCountry";

#pragma mark - Cached App Attributes
// keys
NSString *const kPAPAppAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kPAPAppAttributesLikeCountKey            = @"likeCount";
NSString *const kPAPAppAttributesLikersKey               = @"likers";
NSString *const kPAPAppAttributesCommentCountKey         = @"commentCount";
NSString *const kPAPAppAttributesCommentersKey           = @"commenters";


#pragma mark - Cached User Attributes
// keys
NSString *const kPAPUserAttributesAppCountKey                 = @"appCount";
NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kPAPPushPayloadPayloadTypePurchaseKey  = @"p";
NSString *const kPAPPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kPAPPushPayloadActivityTypeKey     = @"t";
NSString *const kPAPPushPayloadActivityLikeKey     = @"l";
NSString *const kPAPPushPayloadActivityCommentKey  = @"c";
NSString *const kPAPPushPayloadActivityFollowKey   = @"f";

NSString *const kPAPPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kPAPPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kPAPPushPayloadAppIdKey    = @"pid";

#pragma mark - WebSocket Notification Payload Keys
NSString *const kPAPSocketPayloadNewAppKey = @"app.follow.post";

