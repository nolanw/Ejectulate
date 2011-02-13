//
//  NSArray+NWHandy.h
//  NWHandy
//
//  Created by Nolan Waite on 10-12-12.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Foundation/Foundation.h>


#define nw_array(OBJECTS...) ({\
  id _objects_[] = {OBJECTS}; \
  [NSArray arrayWithObjects:_objects_ count:sizeof(_objects_) / sizeof(id)]; \
})

#define nw_marray(OBJECTS...) ({\
  id _objects_[] = {OBJECTS}; \
  [NSMutableArray arrayWithObjects:_objects_ \
                             count:sizeof(_objects_) / sizeof(id)]; \
})


@interface NSArray (NWHandy)

- (id)nw_firstObject;

@end
