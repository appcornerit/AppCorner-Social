//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

typedef NS_ENUM(NSInteger, PAPTabBarControllerViewControllerIndex) {
	PAPHomeTabBarItemIndex = 0,
	PAPEmptyTabBarItemIndex = 1,
	PAPActivityTabBarItemIndex = 2
} ;

extern NSString *const kPAPErrorDomain;

#pragma mark - NSUserDefaults
extern NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kPAPUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs

extern NSString *const kPAPLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const PAPAppDelegateApplicationDidReceivePurchaseRemoteNotification;
extern NSString *const PAPAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const PAPUtilityUserFollowingChangedNotification;
extern NSString *const PAPUtilityUserLikedUnlikedAppCallbackFinishedNotification;
extern NSString *const PAPUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const PAPTabBarControllerDidFinishEditingAppNotification;
extern NSString *const PAPTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const PAPAppDetailsViewControllerUserDeletedAppNotification;
extern NSString *const PAPAppDetailsViewControllerUserLikedUnlikedAppNotification;
extern NSString *const PAPAppDetailsViewControllerUserCommentedOnAppNotification;


#pragma mark - User Info Keys
extern NSString *const PAPAppDetailsViewControllerUserLikedUnlikedAppNotificationUserInfoLikedKey;
extern NSString *const kPAPEditAppViewControllerUserInfoCommentKey;

#pragma mark - Installation Class

// Field keys
extern NSString *const kPAPInstallationUserKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kPAPActivityClassKey;

// Field keys
extern NSString *const kPAPActivityTypeKey;
extern NSString *const kPAPActivityFromUserKey;
extern NSString *const kPAPActivityToUserKey;
extern NSString *const kPAPActivityContentKey;
extern NSString *const kPAPActivityAppIDKey;

// Type values
extern NSString *const kPAPActivityTypeLike;
extern NSString *const kPAPActivityTypeFollow;
extern NSString *const kPAPActivityTypeComment;
extern NSString *const kPAPActivityTypeJoined;
extern NSString *const kPAPActivityTypePriceDrop;

#pragma mark - PFObject Sync Class
extern NSString *const kPAPSyncClassKey;
extern NSString *const kPAPSyncMinVersionKey;
extern NSString *const kPAPSyncDefaultLocaleKey;
extern NSString *const kPAPSyncNumAppsPickerKey;

#pragma mark - PFObject Country Class
extern NSString *const kPAPCountryClassKey;
extern NSString *const kPAPCountry;
extern NSString *const kPAPCountryAutoFollowFacebookIds;

#pragma mark - PFObject User Class
// Field keys
extern NSString *const kPAPUserDisplayNameKey;
extern NSString *const kPAPUserFacebookIDKey;
extern NSString *const kPAPUserFacebookFriendsKey;
extern NSString *const kPAPUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kPAPUserInternal;
extern NSString *const kPAPUserAppStoreCountry;

#pragma mark - PFObject App Class
extern NSString *const kPAPAppClassKey;
// Field keys

extern NSString *const kPAPAppIconKey;
extern NSString *const kPAPAppIconThumbnailKey;
extern NSString *const kPAPAppIDKey;
extern NSString *const kPAPAppUserKey;
extern NSString *const kPAPAppBadges;
extern NSString *const kPAPAppCountryKey;


#pragma mark - Cached App Attributes
// keys
extern NSString *const kPAPAppAttributesIsLikedByCurrentUserKey;
extern NSString *const kPAPAppAttributesLikeCountKey;
extern NSString *const kPAPAppAttributesLikersKey;
extern NSString *const kPAPAppAttributesCommentCountKey;
extern NSString *const kPAPAppAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kPAPUserAttributesAppCountKey;
extern NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kPAPPushPayloadPayloadTypePurchaseKey;
extern NSString *const kPAPPushPayloadPayloadTypeActivityKey;

extern NSString *const kPAPPushPayloadActivityTypeKey;
extern NSString *const kPAPPushPayloadActivityLikeKey;
extern NSString *const kPAPPushPayloadActivityCommentKey;
extern NSString *const kPAPPushPayloadActivityFollowKey;

extern NSString *const kPAPPushPayloadFromUserObjectIdKey;
extern NSString *const kPAPPushPayloadToUserObjectIdKey;
extern NSString *const kPAPPushPayloadAppIdKey;

#pragma mark - WebSocket Notification Payload Keys
extern NSString *const kPAPSocketPayloadNewAppKey;
