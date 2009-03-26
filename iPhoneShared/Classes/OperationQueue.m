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

#import "OperationQueue.h"

#import "Operation.h"
#import "Operation1.h"
#import "Operation2.h"

@interface OperationQueue()
@property (retain) NSOperationQueue* queue;
@property (retain) NSMutableArray* boundedOperations;
@property (retain) NSLock* boundedOperationsGate;
@end


@implementation OperationQueue

static OperationQueue* operationQueue = nil;

@synthesize queue;
@synthesize boundedOperations;
@synthesize boundedOperationsGate;

- (void) dealloc {
    self.queue = nil;
    self.boundedOperations = nil;
    self.boundedOperationsGate = nil;

    [super dealloc];
}


- (id) init {
    if (self = [super init]) {
        self.queue = [[[NSOperationQueue alloc] init] autorelease];
        queue.maxConcurrentOperationCount = 1;
        self.boundedOperations = [NSMutableArray array];
        self.boundedOperationsGate = [[[NSLock alloc] init] autorelease];
    }

    return self;
}


+ (OperationQueue*) operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[OperationQueue alloc] init];
    }

    return operationQueue;
}


- (void) addOperation:(Operation*) operation priority:(QueuePriority) queuePriority {
    operation.queuePriority = queuePriority;
    [queue addOperation:operation];
}


- (Operation*) performSelector:(SEL) selector onTarget:(id) target gate:(id<NSLocking>) gate priority:(QueuePriority) priority {
    Operation* operation = [Operation operationWithTarget:target selector:selector operationQueue:self isBounded:NO gate:gate];
    [self addOperation:operation priority:priority];
    return operation;
}


- (Operation1*) performSelector:(SEL) selector onTarget:(id) target withObject:(id) object gate:(id<NSLocking>) gate priority:(QueuePriority) priority {
    Operation1* operation = [Operation1 operationWithTarget:target selector:selector argument:object operationQueue:self isBounded:NO gate:gate];
    [self addOperation:operation priority:priority];
    return operation;
}


- (Operation2*) performSelector:(SEL) selector onTarget:(id) target withObject:(id) object1 withObject:(id) object2 gate:(id<NSLocking>) gate priority:(QueuePriority) priority {
    Operation2* operation = [Operation2 operationWithTarget:target selector:selector argument:object1 argument:object2 operationQueue:self isBounded:NO gate:gate];
    [self addOperation:operation priority:priority];
    return operation;
}


const NSInteger MAX_BOUNDED_OPERATIONS = 5;
- (void) addBoundedOperation:(Operation*) operation
                    priority:(QueuePriority) priority {
    [boundedOperationsGate lock];
    {
        operation.queuePriority = priority;

        if (boundedOperations.count > MAX_BOUNDED_OPERATIONS) {
            // too many operations.  cancel the oldest one.
            Operation* staleOperation = [boundedOperations objectAtIndex:0];
            [staleOperation cancel];

            [boundedOperations removeObjectAtIndex:0];
        }

        // make the last priority operation dependent on this one.
        if (boundedOperations.count > 0) {
            [(NSOperation*)boundedOperations.lastObject addDependency:operation];
        }

        [boundedOperations addObject:operation];
    }
    [boundedOperationsGate unlock];

    [self addOperation:operation priority:priority];
}


- (Operation*) performBoundedSelector:(SEL) selector onTarget:(id) target gate:(id<NSLocking>) gate priority:(QueuePriority) priority {
    Operation* operation = [Operation operationWithTarget:target selector:selector operationQueue:self isBounded:YES gate:gate];
    [self addBoundedOperation:operation priority:priority];
    return operation;
}


- (Operation1*) performBoundedSelector:(SEL) selector onTarget:(id) target withObject:(id) object gate:(id<NSLocking>) gate priority:(QueuePriority) priority {
    Operation1* operation = [Operation1 operationWithTarget:target selector:selector argument:object operationQueue:self isBounded:YES gate:gate];
    [self addBoundedOperation:operation priority:priority];
    return operation;
}


- (Operation2*) performBoundedSelector:(SEL) selector onTarget:(id) target withObject:(id) object1 withObject:(id) object2 gate:(id<NSLocking>) gate priority:(QueuePriority) priority {
    Operation2* operation = [Operation2 operationWithTarget:target selector:selector argument:object1 argument:object2 operationQueue:self isBounded:YES gate:gate];
    [self addBoundedOperation:operation priority:priority];
    return operation;
}


- (void) onAfterBoundedOperationCompleted:(Operation*) operation {
    [boundedOperationsGate lock];
    {
        [boundedOperations removeObject:operation];
    }
    [boundedOperationsGate unlock];
}


- (void) temporarilySuspend {
    NSLog(@"OperationQueue:temporarilySuspend");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resume) object:nil];
    [queue setSuspended:YES];
    [self performSelector:@selector(resume) withObject:nil afterDelay:1];
}


- (void) resume {
    NSLog(@"OperationQueue:resume");
    [queue setSuspended:NO];
}

@end