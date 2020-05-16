# XTouchBar
Making proper use of Touchbar inside Xcode.

# How this works?

## TL;DR
Basically keylogger which wil blow up your macbook. and call shortcuts on fly.

## TS;WM

It's really simple. The first thing to do is to class-dump private Touchbar API from `AppKit` I really would love to know what `DFR` Prefix means, but let's put that aside :D
After we got this API, we can do pretty much what we want with the touchbar. We can replace the whole touchbar screen, or just the part we are supposed to, replace the
control buttons, add Nyan cat etc. You can read more inside `TouchBarPresenter`, `TouchBarPrivateAPI.h` and `AppDelegate`.

Okay, so now we have control of touchbar, what we need now is to create some of our view. At first I had some nice approaches in mind, the first one was to use da native approach
with multiple `NSTouchBarItems` and refresh the items every time there is some change in UI. Don't get me wrong, this approach is good. But I don't like it. I have seen MTMR
(Project that inspired me to do this) and I tought I want to do this the other way. Basically the function `presentSystemModal(touchBar:position:identifier)` is called there every single
milisecond because there is always something going on. I don't believe in this approach so I decided that we should probably use some view on it.
We decided to be hipsters af and create SwiftUI View on the touchbar which contains the buttons to call our desired actions. This is probably the simplest approach and the most
powerful one.

The main problem in this project is handling of shortcuts / quick actions / menu actions.
There came 3 ideas into my mind:

1. Hacking `IDEKit` and figuring out how to call actions via some private API.
- This seemed as cool idea, but after week of importing almost whole `IDEKit`  module I decided to gave up. If you look into my class-dump  -> https://github.com/DominikBucher12/IDEKit-Class-dump
You will find there very nice class `IDECommandManager` which should be responsible for caling the actions from random menus. As I acknowledged from Xcode stack trace (SIP off :/)
you need always to call `cacheCommandDefinitionsAndHandlers()` to buffer the commands into memory. Also I figured out I need to run Xcode AKA `IDEApplication` one more 
to store all the commands and get them from different stables.
However there is a lot of more steps to this to finally get `sendActionForCommandWithIdentifier(identifier:from:)` to work. I had a lot of fun with `IDEKeyBindingSet`
and other stuff which is related to the calling of commands. If you are bored, hacking Xcode is great entertainment for you, but don't expect quick results.
Note, if you don't know IDEKit, it's basically framework for Xcode and everything around it :) 
Also for this project you probably don't want to run Xcode twice just to run some app that runs small portion of it.

2. Applescript way AKA Legacy way
- I enjoy writing AppleScript a lot. I would find it most suitable, however I want to keep this clean and consistent and when Xcode changes some menu items, this could lead to
potentional problems. I haven't try this approach because I don't believe in it's sustainbility. I think the shortcuts is the golden way between Too hard and too easy implementation.
However I plan overwrite the shortcuts into the `IDEKit` way someday.

3. Call shortcut keys on the fly.
- This was the second approach we tried after me losing patience with hacking. The whole process is pretty simple, we have some enum `Key` which represents the keys on
the keyboard. Also there are some special keys like `cmd`,`shift`,`control`,`option`(called modifiers) which modify the key press. You can take a look at `Key.swift` for the list of
keys and their addresses. There is this nice object `KeyPresser` which virtually presses the keys. The keys are wrapped in `Shortcut` object which holds the keys which should be pressed
by `KeyPresser`.  Things get pretty interesting when user has his custom keybindings defined at `~/Library/Developer/Xcode/UserData/KeyBindings/`.
Then we need to parse the `idekeybinding` file and map the identifiers with different keys into our system and override the default ones. After we do that, we just call the overriden shortcut
instead of the default one.


## Special thanks to
There goes my special thanks to [JK_Kross](https://twitter.com/JK_Kross) who at that time wasn't employed as iOS Dev but music teacher and did a great job on this project :)
Guys at [MTMR](https://github.com/Toxblh/MTMR) from which I took inspiration, but not the code :)
[Megg](http://instagram.com/meggi_lindova) on Instagram for providing me some icons for some actions. :)   

## TODO:
- [x] Add missing "virtual keys" (like arrow keys) to Key.swift
- [ ] Add more sophisticated handling of setting the keyboard back to its default layout (Multithreading wtf??)
- [x] Finish the PropertyListParser (handle "<key>Text Key Bindings</key>" as well)
- [x] Transform Strings received from the parser into our Shortcut data model
- [x] Detect when Xcode is topmost application (focused), probably AppleScript is our friend :D
- [ ] Create some mechanism that users can change to shortcuts on go.
- [ ] Create some intuitive icon-set for the shortcuts etc like add documentation...
- [x] Create collection for the buttons and assign to the buttons the given shortcuts.
- [x] Figure out how to call shortcuts to desired Xcode features
- [ ] Bonus, should go with previous point: Custom Xcode extensions.
- [ ] Impossible bonus -> Create someUI that user can drag'n'drop items into XTouchBar
- [ ] Restructurize the app so it's readable.
- [x] Add Swiftlint to format a style a bit :)
