/*
 *  NWLog.h
 *  NWHandy
 *
 *  Created by Nolan Waite on 10-12-31.
 *  Copyright 2010 Nolan Waite. All rights reserved.
 *
 */

#ifdef NDEBUG
#define NWLog(...) 
#else
#define NWLog(s, ...) NSLog(@"%s:%d [%@ %@] %@", __FILE__, __LINE__, \
  NSStringFromClass([self class]), NSStringFromSelector(_cmd), \
  [NSString stringWithFormat:s,##__VA_ARGS__] \
)
#endif
