//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Apr  3 2020 20:00:10).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <objc/NSObject.h>

@class NSArray, NSIndexSet;

@interface IDESourceEditorExtensionTextChange : NSObject
{
    long long _kind;
    NSIndexSet *_indexes;
    NSArray *_lines;
}

- (void).cxx_destruct;
@property(readonly, copy) NSArray *lines; // @synthesize lines=_lines;
@property(readonly, copy) NSIndexSet *indexes; // @synthesize indexes=_indexes;
@property(readonly) long long kind; // @synthesize kind=_kind;
- (id)description;
- (id)initWithDictionaryRepresentation:(id)arg1;
- (id)initWithKind:(long long)arg1 indexes:(id)arg2 lines:(id)arg3;

@end

