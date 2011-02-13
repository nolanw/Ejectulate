//
//  NWBox.h
//  NWHandy
//
//  Created by Nolan Waite on 10-12-27.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

// Box VALUE into an NSNumber or NSString if possible, or an NSValue otherwise. 
#define nw_box(VALUE) ({ \
  __typeof(VALUE) v = (VALUE); \
  _nw_box(&v, @encode(__typeof(v))); \
})

// Does the actual work of boxing the value. You'll want to use the above 
// macro, not this function.
id _nw_box(const void *value, const char *encoding);
