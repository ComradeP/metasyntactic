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
 * A {@link Rope} is a highly tuned implementation of an {@link NSString} that is
 * more suitable when one wants to perform common string operations on long
 * strings.  Like {@link NSString}, a {@link Rope} is an immutable structure that
 * produces new {@link Rope}s when operated upon.  {@link Rope}s created in
 * this manner will share much of the same data with the original, keeping
 * memory requirements low.  Because they are immutable they are threadsafe and
 * well suited to environments containing concurrency.
 *
 * <p>Note: if all you are doing is adding to the end of a string, and you do
 * not need to support immutability or other modification types, then you should
 * consider possibly using an {@link NSMutableString} instead if it will be faster
 * for you.
 *
 * <p>BAP95
 * A {@link Rope} is represented as an ordered tree, with each internal node
 * representing the concatenation of its children, and the leaves consisting
 * of flat strings, usually represented as contiguous arrays of characters.
 *
 * <p>Cyrusn:
 * Because ropes are not a single contiguous block of memory, it is feasible
 * for them to grow quite large without a problem.  As we may want to represent
 * a file by using a rope, this class was written to use 64 bit integers
 * everywhere in its implementation.
 *
 * @see
 * <a href="http://www.cs.ubc.ca/local/reading/proceedings/spe91-95/spe/vol25/issue12/spe986.pdf">
 * BAP95 </a>
 * Ropes: an Alternative to Strings
 * hans-j. boehm, russ atkinson and michael plass
 */
@interface Rope : NSObject {
  
}

/**
 * Ropes cannot be instantiated directly.  Instead use the factory method
 * {@link #createRope}.
 */
+ (Rope*) createRope:(NSString*) value;

+ (Rope*) emptyRope;

+ (NSUInteger) hashString:(NSString*) string;

+ (NSInteger) coalesceLeafLength;

- (unichar) characterAtIndex:(NSInteger) index;

- (NSInteger) length;
- (BOOL) isEmpty;
- (NSInteger) indexOf:(unichar) c;

- (Rope*) ropeByReplacingOccurrencesOfChar:(unichar) oldChar withChar:(unichar) newChar;

- (Rope*) subRope:(NSInteger) beginIndex;
- (Rope*) subRope:(NSInteger) beginIndex endIndex:(NSInteger) endIndex;

- (Rope*) ropeByAppendingCharacter:(unichar) c;
- (Rope*) ropeByAppendingString:(NSString*) string;
- (Rope*) ropeByAppendingRope:(Rope*) rope;

- (Rope*) prependChar:(unichar) c;
- (Rope*) prependString:(NSString*) string;
- (Rope*) prependRope:(Rope*) rope;

- (Rope*) insertChar:(unichar) c index:(NSInteger) index;
- (Rope*) insertString:(NSString*) string index:(NSInteger) index;
- (Rope*) insertRope:(Rope*) rope index:(NSInteger) index;

- (Rope*) replace:(NSInteger) beginIndex endIndex:(NSInteger) endIndex withChar:(unichar) c;
- (Rope*) replace:(NSInteger) beginIndex endIndex:(NSInteger) endIndex withString:(NSString*) string;
- (Rope*) replace:(NSInteger) beginIndex endIndex:(NSInteger) endIndex withRope:(Rope*) rope;

- (BOOL) isEqualToRope:(Rope*) other;

- (NSString*) stringValue;

@end
