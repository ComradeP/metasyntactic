// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * Abstract interface implemented by Protocol Message builders.
 */
@protocol PBMessage_Builder<NSObject>
/** Resets all fields to their default values. */
- (id<PBMessage_Builder>) clear;

/**
 * Merge {@code other} into the message being built.  {@code other} must
 * have the exact same type as {@code this} (i.e.
 * {@code getDescriptorForType() == other.getDescriptorForType()}).
 *
 * Merging occurs as follows.  For each field:<br>
 * * For singular primitive fields, if the field is set in {@code other},
 *   then {@code other}'s value overwrites the value in this message.<br>
 * * For singular message fields, if the field is set in {@code other},
 *   it is merged into the corresponding sub-message of this message
 *   using the same merging rules.<br>
 * * For repeated fields, the elements in {@code other} are concatenated
 *   with the elements in this message.
 *
 * This is equivalent to the {@code Message::MergeFrom} method in C++.
 */
- (id<PBMessage_Builder>) mergeFromMessage:(id<PBMessage>) other;

/**
 * Construct the final message.  Once this is called, the Builder is no
 * longer valid, and calling any other method may throw a
 * NullPointerException.  If you need to continue working with the builder
 * after calling {@code build()}, {@code clone()} it first.
 * @throws UninitializedMessageException The message is missing one or more
 *         required fields (i.e. {@link #isInitialized()} returns false).
 *         Use {@link #buildPartial()} to bypass this check.
 */
- (id<PBMessage>) build;

/**
 * Like {@link #build()}, but does not throw an exception if the message
 * is missing required fields.  Instead, a partial message is returned.
 */
- (id<PBMessage>) buildPartial;
- (id<PBMessage_Builder>) clone;

/**
 * Returns true if all required fields in the message and all embedded
 * messages are set, false otherwise.
 */
- (BOOL) isInitialized;

/**
 * Get the message's type's descriptor.
 * See {@link Message#getDescriptorForType()}.
 */
- (PBDescriptor*) descriptor;

/**
 * Get the message's type's default instance.
 * See {@link Message#getDefaultInstanceForType()}.
 */
- (id<PBMessage>) defaultInstance;

/**
 * Like {@link Message#getAllFields()}.  The returned map may or may not
 * reflect future changes to the builder.  Either way, the returned map is
 * itself unmodifiable.
 */
- (NSDictionary*) allFields;

/**
 * Create a Builder for messages of the appropriate type for the given
 * field.  Messages built with this can then be passed to setField(),
 * setRepeatedField(), or addRepeatedField().
 */
- (id<PBMessage_Builder>) createBuilder:(PBFieldDescriptor*) field;

- (BOOL) hasField:(PBFieldDescriptor*) field;
- (id) getField:(PBFieldDescriptor*) field;

/**
 * Sets a field to the given value.  The value must be of the correct type
 * for this field, i.e. the same type that
 * {@link Message#getField(Descriptors.FieldDescriptor)} would return.
 */
- (id<PBMessage_Builder>) setField:(PBFieldDescriptor*) field value:(id) value;
- (id<PBMessage_Builder>) clearField:(PBFieldDescriptor*) field;
- (NSArray*) getRepeatedField:(PBFieldDescriptor*) field;

/**
 * Sets an element of a repeated field to the given value.  The value must
 * be of the correct type for this field, i.e. the same type that
 * {@link Message#getRepeatedField(Descriptors.FieldDescriptor,int)} would
 * return.
 * @throws IllegalArgumentException The field is not a repeated field, or
 *           {@code field.getContainingType() != getDescriptorForType()}.
 */
- (id<PBMessage_Builder>) setRepeatedField:(PBFieldDescriptor*) field index:(int32_t) index value:(id) value;

/**
 * Like {@code setRepeatedField}, but appends the value as a new element.
 * @throws IllegalArgumentException The field is not a repeated field, or
 *           {@code field.getContainingType() != getDescriptorForType()}.
 */
- (id<PBMessage_Builder>) addRepeatedField:(PBFieldDescriptor*) field value:(id) value;

- (PBUnknownFieldSet*) unknownFields;
- (id<PBMessage_Builder>) setUnknownFields:(PBUnknownFieldSet*) unknownFields;

/**
 * Merge some unknown fields into the {@link UnknownFieldSet} for this
 * message.
 */
- (id<PBMessage_Builder>) mergeUnknownFields:(PBUnknownFieldSet*) unknownFields;

/**
 * Parses a message of this type from the input and merges it with this
 * message, as if using {@link Builder#mergeFrom(Message)}.
 *
 * <p>Warning:  This does not verify that all required fields are present in
 * the input message.  If you call {@link #build()} without setting all
 * required fields, it will throw an {@link UninitializedMessageException},
 * which is a {@code RuntimeException} and thus might not be caught.  There
 * are a few good ways to deal with this:
 * <ul>
 *   <li>Call {@link #isInitialized()} to verify that all required fields
 *       are set before building.
 *   <li>Parse the message separately using one of the static
 *       {@code parseFrom} methods, then use {@link #mergeFrom(Message)}
 *       to merge it with this one.  {@code parseFrom} will throw an
 *       {@link InvalidProtocolBufferException} (an {@code IOException})
 *       if some required fields are missing.
 *   <li>Use {@code buildPartial()} to build, which ignores missing
 *       required fields.
 * </ul>
 *
 * <p>Note:  The caller should call
 * {@link CodedInputStream#checkLastTagWas(int)} after calling this to
 * verify that the last tag seen was the appropriate end-group tag,
 * or zero for EOF.
 */
- (id<PBMessage_Builder>) mergeFromCodedInputStream:(PBCodedInputStream*) input;

/**
 * Like {@link Builder#mergeFrom(CodedInputStream)}, but also
 * parses extensions.  The extensions that you want to be able to parse
 * must be registered in {@code extensionRegistry}.  Extensions not in
 * the registry will be treated as unknown fields.
 */
- (id<PBMessage_Builder>) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

/**
 * Parse {@code data} as a message of this type and merge it with the
 * message being built.  This is just a small wrapper around
 * {@link #mergeFrom(CodedInputStream)}.
 */
- (id<PBMessage_Builder>) mergeFromData:(NSData*) data;

/**
 * Parse {@code data} as a message of this type and merge it with the
 * message being built.  This is just a small wrapper around
 * {@link #mergeFrom(CodedInputStream,ExtensionRegistry)}.
 */
- (id<PBMessage_Builder>) mergeFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

/**
 * Parse a message of this type from {@code input} and merge it with the
 * message being built.  This is just a small wrapper around
 * {@link #mergeFrom(CodedInputStream)}.  Note that this method always
 * reads the <i>entire</i> input (unless it throws an exception).  If you
 * want it to stop earlier, you will need to wrap your input in some
 * wrapper stream that limits reading.  Despite usually reading the entire
 * input, this does not close the stream.
 */
- (id<PBMessage_Builder>) mergeFromInputStream:(NSInputStream*) input;

/**
 * Parse a message of this type from {@code input} and merge it with the
 * message being built.  This is just a small wrapper around
 * {@link #mergeFrom(CodedInputStream,ExtensionRegistry)}.
 */
- (id<PBMessage_Builder>) mergeFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end