# What is this?

Tiny Objective-C macros, `@with` and `morph`. They use a scoped local variable `_` to
let you replace things like

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

and replace (ever seen this before? :)

```
CGRect frame = view.frame;
frame.size.width += 10;
view.frame = frame;
```

with

```
@morph(view.frame, _.size.width += 10);
```

Code completion and standard Xcode indentation work sanely (recommend braces for
multiple lines). More deets in the header file. 

# How to use?

To use, download [`VARWithMorph.h`](https://raw.githubusercontent.com/claybridges/libvarobjc/master/varobjc/VARWithMorph.h) and put it into your Xcode project.

# License

MIT License. See LICENSE.md.

