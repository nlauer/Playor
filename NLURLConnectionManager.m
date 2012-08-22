//
//  NLURLConnectionManager.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLURLConnectionManager.h"

@implementation NLURLConnectionManager
@synthesize connectionManagerDelegate = _connectionManagerDelegate, data = _data;

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        self.connectionManagerDelegate = delegate;
        _data = [[NSMutableData alloc] init];
    }
    
    return self;
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error requesting youtube data from facebook likes:%@", error);
    [_connectionManagerDelegate receiveFinishedData:nil fromConnection:connection];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_connectionManagerDelegate receiveFinishedData:_data fromConnection:connection];
    _data = nil;
    _connectionManagerDelegate = nil;
}

@end
