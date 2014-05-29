//
//  VARMacrosTests.m
//  varobjc
//
//  Created by Clay Bridges on 26 May 2014.
//  Copyright (c) 2014 Clay Bridges.
//  Released under the MIT license.

#import <XCTest/XCTest.h>
#import "VARMacros.h"
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

@interface VARMacroTests : XCTestCase

@property BOOL gotBanana;
@property BOOL gotCow;
@property BOOL requestExecuted;

@end

@implementation VARMacroTests

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

    @var(banana, @"Banana!");
    @var(mooooo, @"MOOOOO!");

    @with([NSNotificationCenter defaultCenter], {
        [_ addObserver:self selector:@selector(handleBanana) name:banana object:nil];
        [_ addObserver:self selector:@selector(handleInterruptingCow) name:mooooo object:nil]; });

    // later in that app...

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

    @var(accountId, @"ACCT123");
    @var(successBlock, ^{});
    @var(failureBlock, ^{});

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

// the usual way of doing business
- (void)testVarControl
{
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    d[@"Bigbootie"] = @"John";
    T([d isKindOfClass:[NSMutableDictionary class]]);
    T([d[@"Bigbootie"] isEqualToString:@"John"]);

    BOOL (^andBlock)(BOOL a, BOOL b) = ^BOOL(BOOL a, BOOL b) {
        return (BOOL)a && b;
    };

    [self andTest:andBlock];
}

// using @var
- (void)testVar
{
    @var(d, [NSMutableDictionary dictionary]);

    d[@"Bigbootie"] = @"John";
    T([d isKindOfClass:[NSMutableDictionary class]]);
    T([d[@"Bigbootie"] isEqualToString:@"John"]);

    BOOL (^assignTestVar)(BOOL a, BOOL b);

    @var(andBlock, ^BOOL(BOOL a, BOOL b) {
        return a && b;
    });

    assignTestVar = andBlock;

    [self andTest:andBlock];
    [self andTest:assignTestVar];

    __block BOOL success = NO;
    @var(block, ^{
        success = YES;
    });
    block();

    XCTAssertTrue(success, @"block was successfully called");

    __unused void (^assignTestVar2)(void) = block; // test compiler type match with assignment
}

- (void)testVarExamples
{
    @var(arr, [NSMutableArray array]);

    @var(sillyString, @"Flibberty Slazzozalmockle!!");
    @var(set, [NSMutableSet set]);
    @var(count, 1);

    // sorta, kinda a test; also gets rid of unused warnings
    [arr addObject:sillyString];
    [arr addObject:set];
    [arr addObject:@(count)];
}

- (void)andTest:(BOOL (^)(BOOL, BOOL))andBlock
{
    T(!andBlock(NO,  NO));
    T(!andBlock(YES, NO));
    T(!andBlock(NO,  YES));
    T( andBlock(YES, YES));
}

// Is there a way to (XC)test for *desired* compiler errors?
// Meanwhile, this might be instructive for the curious.
//
- (void)compilerErrorsAndStuff
{
    // uncomment to see compiler errors

    // invalid as RHS in @morph
    // -> Expression not assignable
    //
    //    NSView *view = [[NSView alloc] init];
    //    @morph(view.frame.size, _.width = 10);

    // commas in @with value
    // -> Expected expression
    //
    //    @with(@[@1, @2], int i = _.count);

    // const-ness...
    // -> Read-only variable not assignable
    //    @with(CGRectZero, _.size.width++;);

    // ...but this works
    @with((CGRect)CGRectZero, _.size.width++;);

    // _ doesn't survive scope
    // -> use of undeclared identifier '_'
    //    @with([@[] mutableCopy], [_ addObject:@1]);
    //    NSLog(@"%@", _);

    // If don't use _, you'll get a warning
    // -> Unusued variable '_'
    //    int i = 0;
    //    @with(i, i++);

    // @var must be with valid RHS varname
    // these generate various errors
    //
    // @var(void, 1);
    // @var(1, 2);
    // @var(@[], @"");
}

@end
