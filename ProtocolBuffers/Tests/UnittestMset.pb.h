// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

@class PBExtendableMessage_Builder;
@class PBGeneratedMessage_Builder;
@class RawMessageSet;
@class RawMessageSet_Builder;
@class RawMessageSet_Item;
@class RawMessageSet_Item_Builder;
@class TestMessageSet;
@class TestMessageSetContainer;
@class TestMessageSetContainer_Builder;
@class TestMessageSetExtension1;
@class TestMessageSetExtension1_Builder;
@class TestMessageSetExtension2;
@class TestMessageSetExtension2_Builder;
@class TestMessageSet_Builder;

@interface UnittestMsetRoot : NSObject {
}
@end

@interface TestMessageSet : PBExtendableMessage {
@private
}

+ (TestMessageSet*) defaultInstance;
- (TestMessageSet*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TestMessageSet_Builder*) builder;
+ (TestMessageSet_Builder*) builder;
+ (TestMessageSet_Builder*) builderWithPrototype:(TestMessageSet*) prototype;

+ (TestMessageSet*) parseFromData:(NSData*) data;
+ (TestMessageSet*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TestMessageSet*) parseFromInputStream:(NSInputStream*) input;
+ (TestMessageSet*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TestMessageSet*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TestMessageSet*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TestMessageSet_Builder : PBExtendableMessage_Builder {
@private
  TestMessageSet* result;
}

- (TestMessageSet*) defaultInstance;

- (TestMessageSet_Builder*) clear;
- (TestMessageSet_Builder*) clone;

- (TestMessageSet*) build;
- (TestMessageSet*) buildPartial;

- (TestMessageSet_Builder*) mergeFrom:(TestMessageSet*) other;
- (TestMessageSet_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TestMessageSet_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TestMessageSetContainer : PBGeneratedMessage {
@private
  BOOL hasMessageSet;
  TestMessageSet* messageSet;
}
- (BOOL) hasMessageSet;
@property (readonly, retain) TestMessageSet* messageSet;

+ (TestMessageSetContainer*) defaultInstance;
- (TestMessageSetContainer*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TestMessageSetContainer_Builder*) builder;
+ (TestMessageSetContainer_Builder*) builder;
+ (TestMessageSetContainer_Builder*) builderWithPrototype:(TestMessageSetContainer*) prototype;

+ (TestMessageSetContainer*) parseFromData:(NSData*) data;
+ (TestMessageSetContainer*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TestMessageSetContainer*) parseFromInputStream:(NSInputStream*) input;
+ (TestMessageSetContainer*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TestMessageSetContainer*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TestMessageSetContainer*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TestMessageSetContainer_Builder : PBGeneratedMessage_Builder {
@private
  TestMessageSetContainer* result;
}

- (TestMessageSetContainer*) defaultInstance;

- (TestMessageSetContainer_Builder*) clear;
- (TestMessageSetContainer_Builder*) clone;

- (TestMessageSetContainer*) build;
- (TestMessageSetContainer*) buildPartial;

- (TestMessageSetContainer_Builder*) mergeFrom:(TestMessageSetContainer*) other;
- (TestMessageSetContainer_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TestMessageSetContainer_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasMessageSet;
- (TestMessageSet*) messageSet;
- (TestMessageSetContainer_Builder*) setMessageSet:(TestMessageSet*) value;
- (TestMessageSetContainer_Builder*) setMessageSetBuilder:(TestMessageSet_Builder*) builderForValue;
- (TestMessageSetContainer_Builder*) mergeMessageSet:(TestMessageSet*) value;
- (TestMessageSetContainer_Builder*) clearMessageSet;
@end

@interface TestMessageSetExtension1 : PBGeneratedMessage {
@private
  BOOL hasI;
  int32_t i;
}
- (BOOL) hasI;
@property (readonly) int32_t i;

+ (TestMessageSetExtension1*) defaultInstance;
- (TestMessageSetExtension1*) defaultInstance;

+ (id<PBExtensionField>) messageSetExtension;
- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TestMessageSetExtension1_Builder*) builder;
+ (TestMessageSetExtension1_Builder*) builder;
+ (TestMessageSetExtension1_Builder*) builderWithPrototype:(TestMessageSetExtension1*) prototype;

+ (TestMessageSetExtension1*) parseFromData:(NSData*) data;
+ (TestMessageSetExtension1*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TestMessageSetExtension1*) parseFromInputStream:(NSInputStream*) input;
+ (TestMessageSetExtension1*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TestMessageSetExtension1*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TestMessageSetExtension1*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TestMessageSetExtension1_Builder : PBGeneratedMessage_Builder {
@private
  TestMessageSetExtension1* result;
}

- (TestMessageSetExtension1*) defaultInstance;

- (TestMessageSetExtension1_Builder*) clear;
- (TestMessageSetExtension1_Builder*) clone;

- (TestMessageSetExtension1*) build;
- (TestMessageSetExtension1*) buildPartial;

- (TestMessageSetExtension1_Builder*) mergeFrom:(TestMessageSetExtension1*) other;
- (TestMessageSetExtension1_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TestMessageSetExtension1_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasI;
- (int32_t) i;
- (TestMessageSetExtension1_Builder*) setI:(int32_t) value;
- (TestMessageSetExtension1_Builder*) clearI;
@end

@interface TestMessageSetExtension2 : PBGeneratedMessage {
@private
  BOOL hasStr;
  NSString* str;
}
- (BOOL) hasStr;
@property (readonly, retain) NSString* str;

+ (TestMessageSetExtension2*) defaultInstance;
- (TestMessageSetExtension2*) defaultInstance;

+ (id<PBExtensionField>) messageSetExtension;
- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (TestMessageSetExtension2_Builder*) builder;
+ (TestMessageSetExtension2_Builder*) builder;
+ (TestMessageSetExtension2_Builder*) builderWithPrototype:(TestMessageSetExtension2*) prototype;

+ (TestMessageSetExtension2*) parseFromData:(NSData*) data;
+ (TestMessageSetExtension2*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TestMessageSetExtension2*) parseFromInputStream:(NSInputStream*) input;
+ (TestMessageSetExtension2*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (TestMessageSetExtension2*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (TestMessageSetExtension2*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface TestMessageSetExtension2_Builder : PBGeneratedMessage_Builder {
@private
  TestMessageSetExtension2* result;
}

- (TestMessageSetExtension2*) defaultInstance;

- (TestMessageSetExtension2_Builder*) clear;
- (TestMessageSetExtension2_Builder*) clone;

- (TestMessageSetExtension2*) build;
- (TestMessageSetExtension2*) buildPartial;

- (TestMessageSetExtension2_Builder*) mergeFrom:(TestMessageSetExtension2*) other;
- (TestMessageSetExtension2_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (TestMessageSetExtension2_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasStr;
- (NSString*) str;
- (TestMessageSetExtension2_Builder*) setStr:(NSString*) value;
- (TestMessageSetExtension2_Builder*) clearStr;
@end

@interface RawMessageSet : PBGeneratedMessage {
@private
  NSMutableArray* mutableItemList;
}
- (NSArray*) itemList;
- (RawMessageSet_Item*) itemAtIndex:(int32_t) index;

+ (RawMessageSet*) defaultInstance;
- (RawMessageSet*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RawMessageSet_Builder*) builder;
+ (RawMessageSet_Builder*) builder;
+ (RawMessageSet_Builder*) builderWithPrototype:(RawMessageSet*) prototype;

+ (RawMessageSet*) parseFromData:(NSData*) data;
+ (RawMessageSet*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RawMessageSet*) parseFromInputStream:(NSInputStream*) input;
+ (RawMessageSet*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RawMessageSet*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RawMessageSet*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RawMessageSet_Item : PBGeneratedMessage {
@private
  BOOL hasTypeId;
  BOOL hasMessage;
  int32_t typeId;
  NSData* message;
}
- (BOOL) hasTypeId;
- (BOOL) hasMessage;
@property (readonly) int32_t typeId;
@property (readonly, retain) NSData* message;

+ (RawMessageSet_Item*) defaultInstance;
- (RawMessageSet_Item*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (RawMessageSet_Item_Builder*) builder;
+ (RawMessageSet_Item_Builder*) builder;
+ (RawMessageSet_Item_Builder*) builderWithPrototype:(RawMessageSet_Item*) prototype;

+ (RawMessageSet_Item*) parseFromData:(NSData*) data;
+ (RawMessageSet_Item*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RawMessageSet_Item*) parseFromInputStream:(NSInputStream*) input;
+ (RawMessageSet_Item*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (RawMessageSet_Item*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (RawMessageSet_Item*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface RawMessageSet_Item_Builder : PBGeneratedMessage_Builder {
@private
  RawMessageSet_Item* result;
}

- (RawMessageSet_Item*) defaultInstance;

- (RawMessageSet_Item_Builder*) clear;
- (RawMessageSet_Item_Builder*) clone;

- (RawMessageSet_Item*) build;
- (RawMessageSet_Item*) buildPartial;

- (RawMessageSet_Item_Builder*) mergeFrom:(RawMessageSet_Item*) other;
- (RawMessageSet_Item_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RawMessageSet_Item_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasTypeId;
- (int32_t) typeId;
- (RawMessageSet_Item_Builder*) setTypeId:(int32_t) value;
- (RawMessageSet_Item_Builder*) clearTypeId;

- (BOOL) hasMessage;
- (NSData*) message;
- (RawMessageSet_Item_Builder*) setMessage:(NSData*) value;
- (RawMessageSet_Item_Builder*) clearMessage;
@end

@interface RawMessageSet_Builder : PBGeneratedMessage_Builder {
@private
  RawMessageSet* result;
}

- (RawMessageSet*) defaultInstance;

- (RawMessageSet_Builder*) clear;
- (RawMessageSet_Builder*) clone;

- (RawMessageSet*) build;
- (RawMessageSet*) buildPartial;

- (RawMessageSet_Builder*) mergeFrom:(RawMessageSet*) other;
- (RawMessageSet_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (RawMessageSet_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (NSArray*) itemList;
- (RawMessageSet_Item*) itemAtIndex:(int32_t) index;
- (RawMessageSet_Builder*) replaceItemAtIndex:(int32_t) index with:(RawMessageSet_Item*) value;
- (RawMessageSet_Builder*) addItem:(RawMessageSet_Item*) value;
- (RawMessageSet_Builder*) addAllItem:(NSArray*) values;
- (RawMessageSet_Builder*) clearItemList;
@end

