//
//  NSObject+BlockObservation.h
//  Version 1.0
//
//  Andy Matuschak
//  andy@andymatuschak.org
//  Public domain because I love you. Let me know how you use it.
//
 
#import "NSObject+BlockObservation.h"
#import <dispatch/dispatch.h>
#import <objc/runtime.h>
 
@interface AMObserverTrampoline : NSObject
{
	__weak id observee;
	NSString *keyPath;
	AMBlockTask task;
	NSOperationQueue *queue;
  NSKeyValueObservingOptions options;
}
 
- (AMObserverTrampoline*)initObservingObject:(id)obj
                                     keyPath:(NSString*)newKeyPath
                                     options:(NSKeyValueObservingOptions)newOptions
                                     onQueue:(NSOperationQueue*)newQueue
                                        task:(AMBlockTask)newTask;

- (void)cancelObservation;

@end
 
 
@implementation AMObserverTrampoline
 
static NSString *AMObserverTrampolineContext = @"AMObserverTrampolineContext";
 
- (AMObserverTrampoline*)initObservingObject:(id)obj
                                     keyPath:(NSString*)newKeyPath
                                     options:(NSKeyValueObservingOptions)newOptions
                                     onQueue:(NSOperationQueue*)newQueue
                                        task:(AMBlockTask)newTask
{
  self = [super init];
  if (self != nil)
  {
  	task = [newTask copy];
  	keyPath = [newKeyPath copy];
  	queue = [newQueue retain];
  	observee = obj;
    options = newOptions;
  	
  	// Clear out our customized options before passing them on.
  	// From MYUtilities.
    newOptions &= ~MYKeyValueObservingOptionOnce;
  	
  	[observee addObserver:self
               forKeyPath:keyPath
                  options:newOptions
                  context:AMObserverTrampolineContext];
	}
	return self;
}
 
- (void)observeValueForKeyPath:(NSString*)aKeyPath
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
  if (context != AMObserverTrampolineContext)
	{
		[super observeValueForKeyPath:aKeyPath ofObject:object change:change context:context];
    return;
  }
  
	// Not sure if we really need this on the next run loop iteration. Seemed right.
	if (options & MYKeyValueObservingOptionOnce)
    [self performSelector:@selector(cancelObservation) withObject:nil afterDelay:0.0];
  
	if (queue)
		[queue addOperationWithBlock:^{ task(object, change); }];
	else
		task(object, change);
}
 
- (void)cancelObservation
{
	[observee removeObserver:self forKeyPath:keyPath];
}
 
- (void)dealloc
{
	[self cancelObservation];
	[task release];
	[keyPath release];
	[queue release];
	[super dealloc];
}
 
@end
 

static NSString *AMObserverMapKey = @"org.andymatuschak.observerMap";

 
@implementation NSObject (AMBlockObservation)
 
- (AMBlockToken *)addObserverForKeyPath:(NSString *)keyPath task:(AMBlockTask)task
{
	return [self addObserverForKeyPath:keyPath options:0 onQueue:nil task:task];
}

- (AMBlockToken*)addObserverForKeyPath:(NSString*)keyPath
                               options:(NSKeyValueObservingOptions)options
                                  task:(AMBlockTask)task
{
  return [self addObserverForKeyPath:keyPath options:options onQueue:nil task:task];
}

- (AMBlockToken*)addObserverForKeyPath:(NSString*)keyPath
                               onQueue:(NSOperationQueue*)queue
                                  task:(AMBlockTask)task
{
  return [self addObserverForKeyPath:keyPath options:0 onQueue:queue task:task];
}
 
- (AMBlockToken*)addObserverForKeyPath:(NSString*)keyPath
                               options:(NSKeyValueObservingOptions)options
                               onQueue:(NSOperationQueue*)queue
                                  task:(AMBlockTask)task
{
	AMBlockToken *token = [[NSProcessInfo processInfo] globallyUniqueString];
	dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (!objc_getAssociatedObject(self, AMObserverMapKey))
			objc_setAssociatedObject(self, AMObserverMapKey, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN);
		AMObserverTrampoline *trampoline = [[[AMObserverTrampoline alloc] initObservingObject:self keyPath:keyPath options:options onQueue:queue task:task] autorelease];
		[objc_getAssociatedObject(self, AMObserverMapKey) setObject:trampoline forKey:token];
	});
	return token;
}
 
- (void)removeObserverWithBlockToken:(AMBlockToken *)token
{
	NSMutableDictionary *observationDictionary = objc_getAssociatedObject(self, AMObserverMapKey);
	AMObserverTrampoline *trampoline = [observationDictionary objectForKey:token];
	if (!trampoline)
	{
		NSLog(@"Tried to remove non-existent observer on %@ for token %@", self, token);
		return;
	}
	[trampoline cancelObservation];
	[observationDictionary removeObjectForKey:token];
}
 
@end
