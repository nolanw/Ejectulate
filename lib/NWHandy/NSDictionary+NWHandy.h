//
//  NSDictionary+NWHandy.h
//  NWHandy
//
//  Created by Nolan Waite on 10-12-12.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Foundation/Foundation.h>


#define nw_dict(OBJECTS...) ({ \
  id _objects_[] = {OBJECTS}; \
  [NSDictionary nw_dictionaryWithKeysAndObjects:_objects_ \
    count:(sizeof(_objects_) / sizeof(id))]; \
})

#define nw_mdict(OBJECTS...) ({ \
  id _objects_[] = {OBJECTS}; \
  [NSMutableDictionary nw_dictionaryWithKeysAndObjects:_objects_ \
    count:(sizeof(_objects_) / sizeof(id))]; \
})


@interface NSDictionary (NWHandy)

+ (id)nw_dictionaryWithKeysAndObjects:(id*)keysAndObjects
                                count:(NSUInteger)count;

@end
