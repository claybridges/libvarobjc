//
//  VARWithMorphTests.m
//  varobjc
//
//  Created by Clay Bridges on 26 May 2014.
//  Copyright (c) 2014 Clay Bridges.
//  Released under the MIT license.

#import <XCTest/XCTest.h>
#import "VARWithMorph.h"
#import <AppKit/AppKit.h>

// I love pith. Namespace collision possible.
#ifdef T
   #error Rename T macro to proceed
#endif

#define T(expression) \
    XCTAssertTrue(expression, @ #expression)

#define TNotNil(expression) \
    T(expression != nil)

#pragma mark - MySuperDescriptivelyNamedRequest

@interface MySuperDescriptivelyNamedRequest : NSObject

@property (readwrite, copy) NSString *accountId;
@property (readwrite, copy) void(^successBlock)();
@property (readwrite, copy) void(^failureBlock)();

@end

@implementation MySuperDescriptivelyNamedRequest

@end

#pragma mark - VARWithMorphTests

@interface VARWithMorphTests : XCTestCase

@property BOOL gotBanana;
@property BOOL gotCow;
@property BOOL requestExecuted;

@end

@implementation VARWithMorphTests

- (void)testNoops
{
    // compiles, but does nothing
    @with(1, {
        _++;
    })

    // pass by value doesn't change original
    int i = 0;
    @with(i, ++_);
    T(i == 0);

    NSRect r;
    T(r.size.width == 0);
    @with(r, _.size.width += 10);
    T(r.size.width == 0);
}

- (void)testMorph
{
    // stupid usage, but should still work
    NSUInteger i = 0;
    @morph(i, ++_);
    T(i == 1);

    // morph will change view.frame
    NSView *view = [[NSView alloc] init];
    T(view.frame.size.width == 0);
    @morph(view.frame, _.size.width = 10);
    T(view.frame.size.width == 10);

}

- (void)testNotifications
{
    T(!_gotBanana);
    T(!_gotCow);

    NSString * const banana = @"Banana!";
    NSString * const mooooo = @"MOOOOO!";

    @with([NSNotificationCenter defaultCenter], {
        [_ addObserver:self selector:@selector(handleBanana) name:banana object:nil];
        [_ addObserver:self selector:@selector(handleInterruptingCow) name:mooooo object:nil]; });

    @with([NSNotificationCenter defaultCenter], {
        [_ postNotificationName:banana object:nil];
        [_ postNotificationName:mooooo object:nil];
    });

    @with([NSNotificationCenter defaultCenter], {
        [_ postNotificationName:banana object:nil];
        [_ postNotificationName:mooooo object:nil];
    });

    T(_gotBanana);
    T(_gotCow);
}

- (void)handleBanana
{
    _gotBanana = YES;
}

- (void)handleInterruptingCow
{
    _gotCow = YES;
}

// I use this as an example of why @with is useful. Better to test it, right?
- (void)testRequestExample
{
    T(!_requestExecuted);

    NSString *accountId = @"ACCT123";
    void(^successBlock)() = ^{};
    void(^failureBlock)() = ^{};

    MySuperDescriptivelyNamedRequest *request = [[MySuperDescriptivelyNamedRequest alloc] init];
    request.accountId = accountId;
    request.successBlock = successBlock;
    request.failureBlock = failureBlock;
    [self executeRequest:request];

    T(_requestExecuted);

    _requestExecuted = NO;
    T(!_requestExecuted); // uselessly burn, cycles, burn! Muahahah!

    @with([[MySuperDescriptivelyNamedRequest alloc] init], {
        _.accountId = accountId;
        _.successBlock = successBlock;
        _.failureBlock = failureBlock;
        [self executeRequest:_];
    });

    T(_requestExecuted);
}

- (void)executeRequest:(MySuperDescriptivelyNamedRequest *)request
{
    T(request.accountId);
    T(request.successBlock);
    T(request.failureBlock);
    _requestExecuted = YES;
}


// Is there a way to (XC)test for *desired* compiler errors?
// Meanwhile, this might be instructive for the curious.
//
- (void)compilerErrorsAndStuff
{
    // uncomment to see compiler errors

    // -> Expression not assignable
    //    NSView *view = [[NSView alloc] init];
    //    @morph(view.frame.size, _.width = 10);

    // -> Expected expression
    //    @with(@[@1, @2], int i = _.count);

    // const-ness...
    // -> Read-only variable not assignable
    //    @with(CGRectZero, _.size.width++;);

    // ...but this works
    @with((CGRect)CGRectZero, _.size.width++;);

    // _ doesn't survice scope
    // -> use of undeclared identifier '_'
    //    @with([@[] mutableCopy], [_ addObject:@1]);
    //    NSLog(@"%@", _);

    // If don't use _, you'll get a warning
    // -> Unusued variable '_'
    //    int i = 0;
    //    @with(i, i++);
}

@end
