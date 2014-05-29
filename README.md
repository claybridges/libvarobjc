# What's this?

A tiny library of Objective-C macros to aid concision, `@morph`, `@var` and
`@with`. When using, code completion and Xcode indentation work sanely.
Examples of use follow. You'll find more details in the header file.The unit
tests are also instructive.

Submission of issues & pull requests on *technical* objections or problems
strongly encouraged.

# Examples

## @morph

Because there's really no better way, you see this a lot in iOS code

```
CGRect frame = view.frame;
frame.size.width += 10;
view.frame = frame;
```

With `@morph`, you replace it with a one-liner

```
@morph(view.frame, _.size.width += 10);
```

For more complex manipulations

```
@morph(view.frame, {
    _.size.width += 10;
    _.origin.y = 15;
 });

```

## @var

Normally, you declare and initialize a local variable like this:

```
NSMutableArray *arr = [NSMutableArray array];
```

But do you _need_ to specify `NSMutableArray` twice? Usually, the `typeof` is
indentical for both expressions. Instead, we can use what the compiler already
knows to do this

```
@var(arr, [NSMutableArray array]);
```

Bonus: variable declarations line up a little better:

```
@var(sillyString, @"Flibberty Slazzozalmockle!!");
@var(set, [NSMutableSet set]);
@var(count, 1);
```

## @with

Sometimes you want to do a bunch of things _with_ one object. Like this request:

```
MySuperDescriptivelyNamedRequest *request = [[MySuperDescriptivelyNamedRequest alloc] init];
request.accountId = accountId;
request.successBlock = successBlock;
request.failureBlock = failureBlock;
[self executeRequest:request];
```

Using `@with`, this would be

```
@with([[MySuperDescriptivelyNamedRequest alloc] init], {
    _.accountId = accountId;
    _.successBlock = successBlock;
    _.failureBlock = failureBlock;
    [self executeRequest:_];
});
```

# How to use?

Download [`VARMacros.h`][file], add to your Xcode project, and `#import`. 

A CocoaPod is on the way, or feel free to create one & pull request.

# Questions, objections, ...

**What's `_`?**  
It's a local variable. Yes, it's allowed.

**Does this use blocks?**   
No. When required, the macros use normal C scoping using curly braces. The
braces in the macro call in the examples are also just C scoping.

**MACROS BAD!!**  
1. [Apple][block.h] uses them.  
2. These are pretty simple macros.  
3. I disagree, but OK, don't use them.

**This hides behavior**  
You mean like the ones and zeros you are reading right now?

**This is {ugly, confusing, unclear}**  
Tastes vary. So far, aesthetically, I like code using these macros better.
It's almost always objectively shorter. To me, once you know what the macros
do, the code is also clearer.

**This is {inadvisable, dangerous, crazy}**  
Possibly, to be determined.

> The reasonable man adapts himself to the world; 
> the unreasonable one persists in trying to adapt the world to himself. 
> Therefore all progress depends on the unreasonable man.

# License

MIT License. See [LICENSE.md][lic].

[block.h]: http://www.opensource.apple.com/source/libclosure/libclosure-59/Block.h
[file]: https://raw.githubusercontent.com/claybridges/libvarobjc/master/varobjc/VARMacros.h
[lic]: https://github.com/claybridges/libvarobjc/blob/master/LICENSE.md

