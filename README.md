# PHFRefreshControl

**YAPTR**™: Yet another pull-to-refresh. (Compose bar not included. See [PHFComposeBarView](https://github.com/fphilipe/PHFComposeBarView) if you like it.)

![image](https://raw.github.com/fphilipe/PHFRefreshControl/master/demo.gif)

## Why?

- Other existing solutions were quite complex and often implement an infinite scroll thingy and a last refresh date which I don't need.
- These also often don't work correctly if you use a top `contentInset` on the scroll view which I need. Heck not even Apple's own UIRefreshControl respects that property.

## Features

- No need to pull and release. Just pull far enough and a refresh will trigger. You'll see much more of these soon.
- Adjust tint color of arrow.
- No support for last refresh date.
- Built on top of `UIControl`. When triggered it sends a `UIControlEventValueChanged` event to targets.
- View has a magical height of 44 points.
- iOS 5 and up (yeah, that's a feature).

## Installation

The prefered way is to use [CococaPods](http://cocoapods.org).

```ruby
pod 'PHFRefreshControl', '~> 1.0.0'
```

If you can't use CocoaPods for some reason (you really should though, it's the cool kid on the block), then grab the `PHFRefreshControl.{h,m}` files and put it in your project. Make sure to add `QuartzCore` framework if you haven't already.

## Usage

Adding a refresh control to a scroll view:

```objectivec
PHFRefreshControl *refreshControl = [PHFRefreshControl new];
[refreshControl setTintColor:tintColor];
[refreshControl addTarget:dataController
                   action:@selector(reload)
         forControlEvents:UIControlEventValueChanged];
[scrollView setRefreshControl:refreshControl];
```

Triggering a refresh programmatically:

```objectivec
[[scrollView refreshControl] beginRefreshing];
work();
[[scrollView refreshControl] endRefreshing];
```

## Small Print

### License

`PHFRefreshControl` is released under the MIT license.

### Author

Philipe Fatio ([@fphilipe](http://twitter.com/fphilipe))

### Credits

The arrow drawing code was adapted from Sam Vermette's [SVPullToRefresh](https://github.com/samvermette/SVPullToRefresh). 
