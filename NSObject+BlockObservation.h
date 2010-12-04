//
//  NSObject+BlockObservation.h
//  Version 1.0
//
//  Andy Matuschak
//  andy@andymatuschak.org
//  Public domain because I love you. Let me know how you use it.
//
//  NTW 2009-Oct-21: Added selectors with an options argument.
//  NTW 2009-Oct-30: Transplanted new observation key from MYUtilities's 
//                   KVUtils.
 
#import <Cocoa/Cocoa.h>
 
typedef NSString AMBlockToken;

typedef void (^AMBlockTask)(id obj, NSDictionary *change);

// Or MYKeyValueObservingOptionOnce with your observation options to cause the 
// observer to remove itself upon the first change notification.
// Idea and line of code from MYUtilities.
enum {
    MYKeyValueObservingOptionOnce = 1<<31
};
 
@interface NSObject (AMBlockObservation)

- (AMBlockToken*)addObserverForKeyPath:(NSString*)keyPath
                                  task:(AMBlockTask)task;

- (AMBlockToken*)addObserverForKeyPath:(NSString*)keyPath
                               options:(NSKeyValueObservingOptions)options
                                  task:(AMBlockTask)task;

- (AMBlockToken*)addObserverForKeyPath:(NSString*)keyPath
                               onQueue:(NSOperationQueue*)queue
                                  task:(AMBlockTask)task;

- (AMBlockToken*)addObserverForKeyPath:(NSString*)keyPath
                               options:(NSKeyValueObservingOptions)options
                               onQueue:(NSOperationQueue*)queue
                                  task:(AMBlockTask)task;

- (void)removeObserverWithBlockToken:(AMBlockToken *)token;

@end
