//  VARMacros.h
//
//  https://github.com/claybridges/libvarobjc
//
//  Created by Clay Bridges on 26 May 2014.
//  Copyright (c) 2014 Clay Bridges.
//  Released under MIT license, see LICENSE.md

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

# Constraints

* No nesting (yet?)
* `value` subject to usual pass-by-value semantics
* `value` must not contain any commas
* if `value` is a const primitive type, `_` will also be const, and this will
  preclude changes to `_` (with compile error). Can overcome with a cast.

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

# Constraints
 
* No nesting (yet?)
* expression must be usable as both the left- & right-hand-side of an assigment
  statement, both of the same type
* expression must not contain any commas
* take care with call-by/assignment semantics, e.g. just as this is essentially a noop

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

/*
@var( varname, expression...)

# Usage

Replace code like

    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    BOOL (^andBlock)(BOOL,BOOL) = 
        ^BOOL(BOOL a, BOOL b) {
            return a && b;
        };

with

    @var(d, [NSMutableDictionary dictionary]);
    @var(andBlock, ^BOOL(BOOL a, BOOL b) {
        return a && b;
    });

# Constraints

* if expression is a const type, varname will also be const, and this will
 preclude changes. Can overcome with a cast.
* does not play well with __block
* more generally, __unsafe, __unretained, __bridged... might contraindicate usage
* cf. next section on blocks
 
 ## Blocks 
 
The common case, void/void blocks, seems to work well. e.g.
 
    @var(voidBlock, ^{ NSLog(@"whee"); });

However, if the block returns a value, I recommend explicitly declaring
the return type, rather than depend on correct inference by the compiler. E.g.
 
   @var(notBlock, ^BOOL(BOOL x) { return !x });  // <-do
   @var(notBlock, ^    (BOOL x) { return !x });  // <-don't

This makes the compiler happy when you try to assign the block to another
variable or pass it to a method that expects a particular type.

# expansion

 Expands to:

     typeof(expression) varname = expression;

*/

#define var(varname, expression...) \
    varlib_keywordify \
    varlib_var(varname, expression)


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

#define varlib_var(varname, expression...) \
    typeof(expression) varname = expression; /**/\

// varlib_keywordify copied from https://github.com/jspahrsummers/libextobjc ext_keywordify

// NOTE:
// This is a trick, and exists only to eat the leading @ sign.
// The scopes of either autoreleasepool or try/catch are always empty.
// This is the same method that is used by e.g. ReactiveCocoa's @weakify/@strongify.

// --- original comment ---
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
    #define varlib_keywordify try {} @finally {}
#endif

