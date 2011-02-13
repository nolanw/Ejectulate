//
//  NSObject+NWBlockObservation.m
//  NWHandy
//
//  Created by Nolan Waite on 10-12-12.
//  Copyright 2010 Nolan Waite. All rights reserved.
//
//  Original by Andy Matuschak who is awesome.
//  andy@andymatuschak.org
//

#import "NSObject+NWBlockObservation.h"


#if NS_BLOCKS_AVAILABLE && defined(MAC_OS_X_VERSION_10_6)
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6

#import <dispatch/dispatch.h>
#import <objc/runtime.h>


@interface NWObserverTrampoline : NSObject
{
  __weak id observee;
  NSString *keyPath;
  NWBlockTask task;
  NSOperationQueue *queue;
  dispatch_once_t cancellationPredicate;
}

- (id)initObservingObject:(id)object
                  keyPath:(NSString*)keyPath
                  options:(NSKeyValueObservingOptions)options
                  onQueue:(NSOperationQueue*)queue
                     task:(NWBlockTask)task;

- (void)cancelObservation;

@end


@implementation NWObserverTrampoline

static NSString *NWObserverTrampolineContext = @"NWObserverTrampolineContext";

- (id)initObservingObject:(id)object
                  keyPath:(NSString*)aKeyPath
                  options:(NSKeyValueObservingOptions)options
                  onQueue:(NSOperationQueue*)aQueue
                     task:(NWBlockTask)aTask
{
  if ((self = [super init]))
  {
    observee = object;
    keyPath = [aKeyPath copy];
    task = [aTask copy];
    queue = [aQueue retain];
    cancellationPredicate = 0;
    [observee addObserver:self
               forKeyPath:keyPath
                  options:options
                  context:NWObserverTrampolineContext];
  }
  return self;
}

- (void)dealloc
{
  [self cancelObservation];
  [keyPath release], keyPath = nil;
  [task release], task = nil;
  [queue release], queue = nil;
  [super dealloc];
}

- (void)observeValueForKeyPath:(NSString*)aKeyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
  if (context == NWObserverTrampolineContext)
  {
    if (queue)
      [queue addOperationWithBlock:^{ task(object, change); }];
    else
      task(object, change);
  }
}

- (void)cancelObservation
{
  dispatch_once(&cancellationPredicate, ^{
    [observee removeObserver:self forKeyPath:keyPath];
    observee = nil;
  });
}

@end


static NSString *NWObserverMapKey = @"ca.nolanw.NWHandy.observerMap";
static dispatch_queue_t NWObserverMutationQueue = NULL;

static dispatch_queue_t NWObserverMutationQueueCreatingIfNecessary()
{
  static dispatch_once_t queueCreationPredicate = 0;
  dispatch_once(&queueCreationPredicate, ^{
    const char *label = "ca.nolanw.NWHandy.observationMutationQueue";
    NWObserverMutationQueue = dispatch_queue_create(label, 0);
  });
  return NWObserverMutationQueue;
}


@implementation NSObject (NWBlockObservation)

- (NWBlockToken*)nw_addObserverForKeyPath:(NSString*)keyPath
                                     task:(NWBlockTask)task
{
  return [self nw_addObserverForKeyPath:keyPath
                                options:0
                                onQueue:nil
                                   task:task];
}

- (NWBlockToken*)nw_addObserverForKeyPath:(NSString*)keyPath
                                  options:(NSKeyValueObservingOptions)options
                                     task:(NWBlockTask)task
{
  return [self nw_addObserverForKeyPath:keyPath
                                options:options
                                onQueue:nil
                                   task:task];
}

- (NWBlockToken*)nw_addObserverForKeyPath:(NSString*)keyPath
                                  options:(NSKeyValueObservingOptions)options
                                  onQueue:(NSOperationQueue*)queue
                                     task:(NWBlockTask)task
{
  NWBlockToken *token = [[NSProcessInfo processInfo] globallyUniqueString];
  dispatch_sync(NWObserverMutationQueueCreatingIfNecessary(), ^{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, 
                                                              NWObserverMapKey);
    if (!dict)
    {
      dict = [[NSMutableDictionary alloc] init];
      objc_setAssociatedObject(self, NWObserverMapKey, dict, 
                                                       OBJC_ASSOCIATION_RETAIN);
      [dict release];
    }
    NWObserverTrampoline *trampoline;
    trampoline = [[NWObserverTrampoline alloc] initObservingObject:self
                                                            keyPath:keyPath
                                                            options:options
                                                            onQueue:queue
                                                               task:task];
    [dict setObject:trampoline forKey:token];
    [trampoline release];
  });
  return token;
}

- (void)nw_removeObserverWithBlockToken:(NWBlockToken *)token;
{
  dispatch_sync(NWObserverMutationQueueCreatingIfNecessary(), ^{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, 
                                                              NWObserverMapKey);
    NWObserverTrampoline *trampoline = [dict objectForKey:token];
    if (!trampoline)
    {
      NSLog(@"[NSObject(NWBlockObservation) %@]: Ignoring attempt to remove "
            "nonexistent observer on %@ for token %@.", 
            NSStringFromSelector(_cmd), self, token);
      return;
    }
    [trampoline cancelObservation];
    [dict removeObjectForKey:token];
    if ([dict count] == 0)
    {
      objc_setAssociatedObject(self, NWObserverMapKey, nil, 
                                                       OBJC_ASSOCIATION_RETAIN);
    }
  });
}

@end

#endif
#endif
