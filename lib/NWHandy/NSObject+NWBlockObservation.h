//
//  NSObject+NWBlockObservation.h
//  NWHandy
//
//  Created by Nolan Waite on 10-12-12.
//  Copyright 2010 Nolan Waite. All rights reserved.
//
//  Original by Andy Matuschak who is awesome.
//  andy@andymatuschak.org
//  https://gist.github.com/153676
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE && defined(MAC_OS_X_VERSION_10_6)
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6

typedef NSString NWBlockToken;

typedef void (^NWBlockTask)(id obj, NSDictionary *change);


@interface NSObject (NWBlockObservation)

- (NWBlockToken*)nw_addObserverForKeyPath:(NSString*)keyPath
                                     task:(NWBlockTask)task;

- (NWBlockToken*)nw_addObserverForKeyPath:(NSString*)keyPath
                                  options:(NSKeyValueObservingOptions)options
                                     task:(NWBlockTask)task;

- (NWBlockToken*)nw_addObserverForKeyPath:(NSString*)keyPath
                                  options:(NSKeyValueObservingOptions)options
                                  onQueue:(NSOperationQueue*)queue
                                     task:(NWBlockTask)task;

- (void)nw_removeObserverWithBlockToken:(NWBlockToken *)token;

@end

#endif
#endif
