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

#import "ThreadingUtilities.h"

#import "BackgroundInvocation.h"
#import "BackgroundInvocation2.h"
#import "Invocation2.h"
#import "PriorityMutex.h"

@implementation ThreadingUtilities

+ (void) backgroundSelector:(SEL) selector
                   onTarget:(id) target
                 withObject:(id) argument1
                 withObject:(id) argument2
                       gate:(id<NSLocking>) gate
                     daemon:(BOOL) daemon {
  BackgroundInvocation2* invocation = [BackgroundInvocation2 invocationWithTarget:target
                                                                         selector:selector
                                                                       withObject:argument1
                                                                       withObject:argument2
                                                                             gate:gate
                                                                           daemon:daemon];
  [invocation performSelectorInBackground:@selector(run) withObject:nil];
}


+ (void) backgroundSelector:(SEL) selector
                   onTarget:(id) target
                 withObject:(id) argument
                       gate:(id<NSLocking>) gate
                     daemon:(BOOL) daemon {
  BackgroundInvocation* invocation = [BackgroundInvocation invocationWithTarget:target
                                                                       selector:selector
                                                                     withObject:argument
                                                                           gate:gate
                                                                         daemon:daemon];
  [invocation performSelectorInBackground:@selector(run) withObject:nil];
}


+ (void) backgroundSelector:(SEL) selector
                   onTarget:(id) target
                       gate:(id<NSLocking>) gate
                     daemon:(BOOL) daemon {
  [self backgroundSelector:selector
                  onTarget:target
                withObject:nil
                      gate:gate
                    daemon:daemon];
}


+ (void) foregroundSelector:(SEL) selector
                   onTarget:(id) target
                 withObject:(id) argument {
  [target performSelectorOnMainThread:selector withObject:argument waitUntilDone:NO];
}


+ (void) foregroundSelector:(SEL) selector
                   onTarget:(id) target
                 withObject:(id) argument1
                 withObject:(id) argument2 {
  Invocation2* invocation = [Invocation2 invocationWithTarget:target
                                                     selector:selector
                                                   withObject:argument1
                                                   withObject:argument2];
  [invocation performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:NO];
}


+ (BOOL) hasNonDaemonBackgroundTasks {
  return [BackgroundInvocation hasNonDaemonBackgroundTasks];
}

@end
