//
//  BLNetworkImp.m
//  Let
//
//  Created by junjie.zhu on 2016/11/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLNetworkImp.h"
//#import "BLReachability.h"

#import <sys/sysctl.h>
#import <netinet/in.h>
#import <net/if.h>
#import <netdb.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#if !TARGET_IPHONE_SIMULATOR
#include "BLRoute.h"
#endif

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

@implementation BLNetworkImp

+ (NSArray *)getCurrentWifiList {
    NSMutableArray *wifiArray = [NSMutableArray arrayWithCapacity:0];

    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    for (NSString *ifnam in ifs) {
        
        NSDictionary *info = CFBridgingRelease(CNCopyCurrentNetworkInfo((CFStringRef)ifnam));
        if (info && [info count])
        {
            NSDictionary *wifi = [NSDictionary dictionaryWithObjectsAndKeys:info[(__bridge  NSString *)kCNNetworkInfoKeySSID], @"ssid", info[(__bridge NSString *)kCNNetworkInfoKeyBSSID], @"bssid", nil];
            [wifiArray addObject:wifi];
        }
    }
    
    return [wifiArray copy];
}

+ (NSString *)getCurrentSSIDInfo {
    
    NSArray *wifiList = [self getCurrentWifiList];
    if (wifiList && wifiList.count > 0) {
        NSDictionary *wifi = wifiList.firstObject;
        return [wifi objectForKey:@"ssid"];
    }
    
    return nil;
}

+ (NSString *)getIpAddrFromHost:(NSString *)host {
    NSString *ipaddr = nil;
    struct addrinfo *result;
    struct addrinfo *res;
    char buf[128];
    int error;
    
    if ((error = getaddrinfo(host.UTF8String, NULL, NULL, &result)) != 0) {
        NSLog(@"parse domain fail");
        return ipaddr;
    }
    
    memset(buf, 0, sizeof(buf));
    for (res=result; res!=NULL; res=res->ai_next) {
        struct sockaddr *sa = res->ai_addr;
        switch (sa->sa_family) {
            case AF_INET:
                inet_ntop(AF_INET, &(((struct sockaddr_in *)sa)->sin_addr), buf, sizeof(buf));
                break;
            case AF_INET6:
                inet_ntop(AF_INET6, &(((struct sockaddr_in6 *)sa)->sin6_addr), buf, sizeof(buf));
                break;
            default:
                break;
        }
    }
    ipaddr = [NSString stringWithUTF8String:buf];
    freeaddrinfo(result);
    
    return ipaddr;
}

+ (NSString *)getCurrentGatewayAddress {
    int ret = -1;
    uint8_t octet[4] = {0, 0, 0, 0};

#if !TARGET_IPHONE_SIMULATOR
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_GATEWAY};
    size_t len;
    char *buf, *ptr;
    struct rt_msghdr *rt;
    struct sockaddr *sa;
    struct sockaddr *sa_tab[RTAX_MAX];
    int i;
    if (sysctl(mib, sizeof(mib) / sizeof(int), 0, &len, 0, 0) < 0)
        return @"255.255.255.255";
    if (len > 0) {
        buf = malloc(len);
        if (sysctl(mib, sizeof(mib) / sizeof(int), buf, &len, 0, 0) < 0) {
            free(buf);
            return @"255.255.255.255";
        }
        for (ptr=buf; ptr<buf+len; ptr+=rt->rtm_msglen) {
            rt = (struct rt_msghdr *)ptr;
            sa = (struct sockaddr *)(rt + 1); for (i = 0; i<RTAX_MAX; i++) {
                if (rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if (((rt->rtm_addrs & (RTA_DST | RTA_GATEWAY)) \
                 == (RTA_DST | RTA_GATEWAY)) \
                && sa_tab[RTAX_DST]->sa_family == AF_INET \
                && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                
                for (int a=0; a<4; a++) {
                    octet[a] = (((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr >> (a * 8)) & 0xff;
                }
            }
            
            if (((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                ret = 0;
            }
        }
        
        free(buf);
    }

#endif
    
    if (ret < 0)
        return @"255.255.255.255";
    return [[NSString alloc] initWithFormat:@"%i.%i.%i.%i", octet[0], octet[1], octet[2], octet[3]];

}

+ (NSString *)getCurrentNetworkCarriername {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    NSString *carriername = [carrier carrierName];
    
    return carriername;
}

//+ (NSString *)getCurrentNetworkType {
//    BLReachability *reach = [BLReachability reachabilityWithHostName:@"www.baidu.com"];
//    BLNetworkStatus networkStatus = [reach currentReachabilityStatus];
//    NSString *networkType = @"wifi";
//    switch (networkStatus) {
//        case BLNotReachable:
//            networkType = @"notReachable";
//            break;
//        case BLReachableViaWiFi:
//            networkType = @"wifi";
//            break;
//        case BLReachableViaWWAN: {
//            CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
//            NSString *net = [networkInfo currentRadioAccessTechnology];
//            
//            if ([net isEqualToString:CTRadioAccessTechnologyLTE]) {
//                networkType = @"4G";
//            }
//            else if ([net isEqualToString:CTRadioAccessTechnologyEdge] || [net isEqualToString:CTRadioAccessTechnologyGPRS]) {
//                networkType = @"2G";
//            }
//            else {
//                networkType = @"3G";
//            }
//        }
//            break;
//    }
//    
//    return networkType;
//}


@end
