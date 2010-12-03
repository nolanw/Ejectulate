//
//  CollectionUtils.h
//  MYUtilities
//
//  Created by Jens Alfke on 1/5/08.
//  Copyright 2008 Jens Alfke. All rights reserved.
//

#import <Foundation/Foundation.h>
#define _MYUTILITIES_COLLECTIONUTILS_ 1

// Collection creation conveniences:

#define $array(OBJS...) ({ \
  id objs[]={OBJS}; \
  [NSArray arrayWithObjects:objs count:(sizeof(objs) / sizeof(id))]; \
})

#define $marray(OBJS...) ({ \
  id objs[]={OBJS}; \
  [NSMutableArray arrayWithObjects:objs count:(sizeof(objs) / sizeof(id))]; \
})


#define $set(OBJS...) ({ \
  id objs[]={OBJS}; \
  [NSSet setWithObjects:objs count:(sizeof(objs) / sizeof(id))]; \
})


#define $dict(PAIRS...) ({ \
  struct _dictpair pairs[]={PAIRS}; \
  _dictof(pairs, (sizeof(pairs ) /sizeof(struct _dictpair)), NO); \
})

#define $mdict(PAIRS...) ({ \
  struct _dictpair pairs[]={PAIRS}; \
  _dictof(pairs, (sizeof(pairs)/sizeof(struct _dictpair)), YES); \
})


// An array of NSSortDescriptors, one per argument. First character of each 
// argument specifies + (ascending) or - (descending); second-through-end is 
// key.
// For example, the following two sections are equivalent:
//  $sort(@"-priority", @"+date");
//
//  [NSArray arrayWithObjects:
//    [[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:NO]
//    autorelease], 
//    [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] 
//    autorelease], 
//    nil];
#define $sort(DESCRIPTORS...) ({ \
  NSString *descriptors[]={DESCRIPTORS}; \
  _sortof(descriptors, (sizeof(descriptors)/sizeof(NSString *))); \
})


#define $pred(ETC...) [NSPredicate predicateWithFormat:ETC]


// Return type is id so you can cast, but the class will be one of 
// NSValue or NSNumber, as appropriate.
#define $box(VAL) ({ \
  __typeof(VAL) v = (VAL); \
  _box(&v, @encode(__typeof(v))); \
})


// Apply a selector to each array element, returning an array of the results:
NSArray* $apply(NSArray *src, SEL selector, id defaultValue);
NSArray* $applyKeyPath(NSArray *src, NSString *keyPath, id defaultValue);


// Object conveniences:

// Like -isEqual: but works even if either/both are nil
BOOL $equal(id obj1, id obj2);

NSString* $string( const char *utf8Str );

#define $sprintf(FORMAT, ARGS...) [NSString stringWithFormat:(FORMAT), ARGS]

#define $cast(CLASSNAME,OBJ) ((CLASSNAME*)(_cast([CLASSNAME class],(OBJ))))
#define $castNotNil(CLASSNAME,OBJ) ( \
  (CLASSNAME*)(_castNotNil([CLASSNAME class], (OBJ))) \
)
#define $castIf(CLASSNAME,OBJ) ( \
  (CLASSNAME*)(_castIf([CLASSNAME class], (OBJ))) \
)
#define $castArrayOf(ITEMCLASSNAME,OBJ) \
  _castArrayOf([ITEMCLASSNAME class], (OBJ)))

void setObj(id *var, id value);
BOOL ifSetObj(id *var, id value);
void setObjCopy(id *var, id valueToCopy);
BOOL ifSetObjCopy(id *var, id value);

static inline void setString(NSString **var, NSString *value) 
{
  setObjCopy(var,value);
}

static inline BOOL ifSetString(NSString **var, NSString *value)
{
  return ifSetObjCopy(var,value);
}

BOOL kvSetSet(id owner, NSString *property, NSMutableSet *set, NSSet *newSet);
BOOL kvAddToSet(id owner, NSString *property, NSMutableSet *set, id objToAdd);
BOOL kvRemoveFromSet(id owner,
                     NSString *property, 
                     NSMutableSet *set, 
                     id objToRemove);


#define $true   ((NSNumber*)kCFBooleanTrue)
#define $false  ((NSNumber*)kCFBooleanFalse)


@interface NSArray (CollectionUtils)

// Return the first object in this array, or nil if this array is empty.
- (id)firstObject;

@end


@interface NSMutableArray (CollectionUtils)

// Randomize the order of this array's contents. (Fisher-Yates)
- (void)shuffle;

// Remove and return the first object in this array, or nil if there are none.
- (id)popFirstObject;

@end


// Internals (don't use directly)
struct _dictpair { id key; id value; };
NSDictionary* _dictof(const struct _dictpair* pairs, 
                      size_t count, 
                      BOOL mutable);
NSMutableDictionary* _mdictof(const struct _dictpair*, size_t count);
NSArray *_sortof(NSString **directionedKeys, size_t count);
id _box(const void *value, const char *encoding);
id _cast(Class,id);
id _castNotNil(Class,id);
id _castIf(Class,id);
NSArray* _castArrayOf(Class,NSArray*);
