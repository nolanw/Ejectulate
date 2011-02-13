//
//  NSSet+NWHandy.h
//  NWHandy
//
//  Created by Nolan Waite on 10-12-28.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Foundation/Foundation.h>


#define nw_set(OBJECTS...) ({ \
  id _objects_[] = {OBJECTS}; \
  [NSSet setWithObjects:_objects_ count:(sizeof(_objects_) / sizeof(id))]; \
})

#define nw_mset(OBJECTS...) ({ \
  id _objects_[] = {OBJECTS}; \
  [NSMutableSet setWithObjects:_objects_ \
                         count:(sizeof(_objects_) / sizeof(id))]; \
})
