# What is this?

Tiny Objective-C macros, `@with` and `@morph`, devoted to [DRYness][dry] and
 concision. Via a scoped local variable `_`, they replace code like

```
MySuperDescriptivelyNamedRequest *request = [[MySuperDescriptivelyNamedRequest alloc] init];
request.accountId = accountId;
request.successBlock = successBlock;
request.failureBlock = failureBlock;
[self executeRequest:request];
```

with 

```
@with([[MySuperDescriptivelyNamedRequest alloc] init], {
    _.accountId = accountId;
    _.successBlock = successBlock;
    _.failureBlock = failureBlock;
    [self executeRequest:_];
});
```

or replace common

```
CGRect frame = view.frame;
frame.size.width += 10;
view.frame = frame;
```

with

```
@morph(view.frame, _.size.width += 10);
```

Code completion and Xcode indentation work sanely. More deets in the header file. 

# How to use?

Download [`VARWithMorph.h`][file], add to your Xcode project, and `#import`.

# License

MIT License. See [LICENSE.md][lic].

[file]: https://raw.githubusercontent.com/claybridges/libvarobjc/master/varobjc/VARWithMorph.h
[dry]: http://en.wikipedia.org/wiki/Don't_repeat_yourself
[lic]: https://github.com/claybridges/libvarobjc/blob/master/LICENSE.md

