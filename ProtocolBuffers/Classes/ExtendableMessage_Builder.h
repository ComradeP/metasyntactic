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

#import "GeneratedMessage_Builder.h"

/**
 * Generated message builders for message types that contain extension ranges
 * subclass this.
 *
 * <p>This class implements type-safe accessors for extensions.  They
 * implement all the same operations that you can do with normal fields --
 * e.g. "get", "set", and "add" -- but for extensions.  The extensions are
 * identified using instances of the class {@link GeneratedExtension}; the
 * protocol compiler generates a static instance of this class for every
 * extension in its input.  Through the magic of generics, all is made
 * type-safe.
 *
 * <p>For example, imagine you have the {@code .proto} file:
 *
 * <pre>
 * option java_class = "MyProto";
 *
 * message Foo {
 *   extensions 1000 to max;
 * }
 *
 * extend Foo {
 *   optional int32 bar;
 * }
 * </pre>
 *
 * <p>Then you might write code like:
 *
 * <pre>
 * MyProto.Foo foo =
 *   MyProto.Foo.newBuilder()
 *     .setExtension(MyProto.bar, 123)
 *     .build();
 * </pre>
 *
 * <p>See also {@link ExtendableMessage}.
 */
@interface PBExtendableMessage_Builder : PBGeneratedMessage_Builder {
}

/* @protected */
- (void) mergeExtensionFields:(PBExtendableMessage*) other;

@end