/*
 *  NWPrinting.h
 *  NWHandy
 *
 *  Created by Nolan Waite on 10-12-29.
 *  Copyright 2010 Nolan Waite. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

// Shorten [NSString stringWithFormat:] up a bit.
#define nw_nsprintf(...) [NSString stringWithFormat:__VA_ARGS__]


// forcetype and stringify macros courtesy Mike Ash.
// http://mikeash.com/pyblog/friday-qa-2010-12-31-c-macro-tips-and-tricks.html

// Make the compiler treat x as the given type no matter what.
#define nw_forcetype(x, type) *(type *)(__typeof__(x) []){ x }

// Get the geometry types right for both iOS and OS X.
#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
#define NW_GEOMETRY_PREFIX(x) CG ## x
#define NW_GEOMETRY_STRING(x) NSStringFromCG ## x
#else
#define NW_GEOMETRY_PREFIX(x) NS ## x
#define NW_GEOMETRY_STRING(x) NSStringFrom ## x
#endif

// Turn various structs and data types into strings.
#define nw_stringify(x)                                                        \
  __builtin_choose_expr(                                                       \
    __builtin_types_compatible_p(__typeof__(x), NW_GEOMETRY_PREFIX(Rect)),     \
      NW_GEOMETRY_STRING(Rect)(nw_forcetype(x, NW_GEOMETRY_PREFIX(Rect))),     \
                                                                               \
  __builtin_choose_expr(                                                       \
    __builtin_types_compatible_p(__typeof__(x), NW_GEOMETRY_PREFIX(Size)),     \
      NW_GEOMETRY_STRING(Size)(nw_forcetype(x, NW_GEOMETRY_PREFIX(Size))),     \
                                                                               \
  __builtin_choose_expr(                                                       \
    __builtin_types_compatible_p(__typeof__(x), NW_GEOMETRY_PREFIX(Point)),    \
      NW_GEOMETRY_STRING(Point)(nw_forcetype(x, NW_GEOMETRY_PREFIX(Point))),   \
                                                                               \
  __builtin_choose_expr(                                                       \
    __builtin_types_compatible_p(__typeof__(x), SEL),                          \
      NSStringFromSelector(nw_forcetype(x, SEL)),                              \
                                                                               \
  __builtin_choose_expr(                                                       \
    __builtin_types_compatible_p(__typeof__(x), NSRange),                      \
      NSStringFromRange(nw_forcetype(x, NSRange)),                             \
                                                                               \
  [NSValue valueWithBytes:(__typeof__(x) []){ x }                              \
                 objCType:@encode(__typeof__(x))]                              \
)))))
