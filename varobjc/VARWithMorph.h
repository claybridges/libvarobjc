//  VARWithMorph.h
//
//  https://github.com/claybridges/libvarobjc
//
//  Created by Clay Bridges on 26 May 2014.
//  Copyright (c) 2014 Clay Bridges.
//  Released under the MIT license.

#ifndef __OBJC__
    #fail This header is constructed to work only with Objective-C
#endif

// --------------
// public
// --------------

/*
@with( value, codeWithValue...)

# Usage

Replace code like

    MySuperDescriptivelyNamedRequest *request = [[MySuperDescriptivelyNamedRequest alloc] init];
    request.accountId = accountId;
    request.successBlock = successBlock;
    request.failureBlock = failureBlock;
    [self executeRequest:request];

with

    @with([[MySuperDescriptivelyNamedRequest alloc] init], {
        _.accountId = accountId;
        _.successBlock = successBlock;
        _.failureBlock = failureBlock;
        [self executeRequest:_];
    });

# `value` constraints

* subject to usual pass-by-value semantics
* must not contain any commas
* if value is a const primitive type, `_` will also be const, and this will 
  preclude changes to `_`. Can overcome with a cast.

# expansion

Expands to approximately

    {
        typeof(value) _ = value;
        codeWithValue...
    };
*/
#define with(value, codeWithValue...) \
    varlib_keywordify \
    varlib_with(value, codeWithValue)

/*
@morph( expression, morphCode...)

# Usage

Replace code like

    CGRect frame = view.frame;
    frame.size.width += 10;
    view.frame = frame;

with

    @morph(view.frame, _.size.width += 10);

Beyond one-liners, braces add clarity with no runtime penalty.

    @morph(view.frame, {
        _.size.width += 10;
        _.size.height += 20;
    });

# `expression` constraints:

* must be usable as both the left- & right-hand-side of an assigment
  statement, both of the same type

 * must not contain any commas

* take care with call-by/assignment semantics, e.g. just as this is a noop

    view.frame.size.width += 10;

  so is this

    @morph(view.frame.size, _.width += 10;);

# expansion

 Expands to approximately

    {
        typeof(expression) _ = expression;
        morphCode...
        expression = _;
    }
*/
#define morph(expression, morphCode...) \
    varlib_keywordify \
    varlib_morph(expression, morphCode)

// --------------
// private
// !!!!!!!
// NOT INTENDED TO BE USED DIRECTLY
// Use at your own risk :)
// --------------

#define varlib_with(value, codeWithValue...) \
    { \
        typeof(value) _ = value; \
        codeWithValue; \
    }

#define varlib_morph(expression, morphCode...) \
    varlib_with(expression, morphCode; expression = _;)

// varlib_keywordify copied from https://github.com/jspahrsummers/libextobjc ext_keywordify

// Details about the choice of backing keyword:
//
// The use of @try/@catch/@finally can cause the compiler to suppress
// return-type warnings.
// The use of @autoreleasepool {} is not optimized away by the compiler,
// resulting in superfluous creation of autorelease pools.
//
// Since neither option is perfect, and with no other alternatives, the
// compromise is to use @autorelease in DEBUG builds to maintain compiler
// analysis, and to use @try/@catch otherwise to avoid insertion of unnecessary
// autorelease pools.
#if DEBUG
    #define varlib_keywordify autoreleasepool {}
#else
    #define varlib_keywordify try {} @catch (...) {}
#endif

