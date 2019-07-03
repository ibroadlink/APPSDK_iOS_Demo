//
//  BLESMDataParser.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/7/1.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLESMDataParser.h"

#import <BLLetBase/BLLetBase.h>

#define REQUEST_BYTES_LENGTH 128
#define PLOY 0X1021

const uint16_t fcstab[256] = {
    0x0000,    0x1189,    0x2312,    0x329b,    0x4624,    0x57ad,    0x6536,    0x74bf,
    0x8c48,    0x9dc1,    0xaf5a,    0xbed3,    0xca6c,    0xdbe5,    0xe97e,    0xf8f7,
    0x1081,    0x0108,    0x3393,    0x221a,    0x56a5,    0x472c,    0x75b7,    0x643e,
    0x9cc9,    0x8d40,    0xbfdb,    0xae52,    0xdaed,    0xcb64,    0xf9ff,    0xe876,
    0x2102,    0x308b,    0x0210,    0x1399,    0x6726,    0x76af,    0x4434,    0x55bd,
    0xad4a,    0xbcc3,    0x8e58,    0x9fd1,    0xeb6e,    0xfae7,    0xc87c,    0xd9f5,
    0x3183,    0x200a,    0x1291,    0x0318,    0x77a7,    0x662e,    0x54b5,    0x453c,
    0xbdcb,    0xac42,    0x9ed9,    0x8f50,    0xfbef,    0xea66,    0xd8fd,    0xc974,
    0x4204,    0x538d,    0x6116,    0x709f,    0x0420,    0x15a9,    0x2732,    0x36bb,
    0xce4c,    0xdfc5,    0xed5e,    0xfcd7,    0x8868,    0x99e1,    0xab7a,    0xbaf3,
    0x5285,    0x430c,    0x7197,    0x601e,    0x14a1,    0x0528,    0x37b3,    0x263a,
    0xdecd,    0xcf44,    0xfddf,    0xec56,    0x98e9,    0x8960,    0xbbfb,    0xaa72,
    0x6306,    0x728f,    0x4014,    0x519d,    0x2522,    0x34ab,    0x0630,    0x17b9,
    0xef4e,    0xfec7,    0xcc5c,    0xddd5,    0xa96a,    0xb8e3,    0x8a78,    0x9bf1,
    0x7387,    0x620e,    0x5095,    0x411c,    0x35a3,    0x242a,    0x16b1,    0x0738,
    0xffcf,    0xee46,    0xdcdd,    0xcd54,    0xb9eb,    0xa862,    0x9af9,    0x8b70,
    0x8408,    0x9581,    0xa71a,    0xb693,    0xc22c,    0xd3a5,    0xe13e,    0xf0b7,
    0x0840,    0x19c9,    0x2b52,    0x3adb,    0x4e64,    0x5fed,    0x6d76,    0x7cff,
    0x9489,    0x8500,    0xb79b,    0xa612,    0xd2ad,    0xc324,    0xf1bf,    0xe036,
    0x18c1,    0x0948,    0x3bd3,    0x2a5a,    0x5ee5,    0x4f6c,    0x7df7,    0x6c7e,
    0xa50a,    0xb483,    0x8618,    0x9791,    0xe32e,    0xf2a7,    0xc03c,    0xd1b5,
    0x2942,    0x38cb,    0x0a50,    0x1bd9,    0x6f66,    0x7eef,    0x4c74,    0x5dfd,
    0xb58b,    0xa402,    0x9699,    0x8710,    0xf3af,    0xe226,    0xd0bd,    0xc134,
    0x39c3,    0x284a,    0x1ad1,    0x0b58,    0x7fe7,    0x6e6e,    0x5cf5,    0x4d7c,
    0xc60c,    0xd785,    0xe51e,    0xf497,    0x8028,    0x91a1,    0xa33a,    0xb2b3,
    0x4a44,    0x5bcd,    0x6956,    0x78df,    0x0c60,    0x1de9,    0x2f72,    0x3efb,
    0xd68d,    0xc704,    0xf59f,    0xe416,    0x90a9,    0x8120,    0xb3bb,    0xa232,
    0x5ac5,    0x4b4c,    0x79d7,    0x685e,    0x1ce1,    0x0d68,    0x3ff3,    0x2e7a,
    0xe70e,    0xf687,    0xc41c,    0xd595,    0xa12a,    0xb0a3,    0x8238,    0x93b1,
    0x6b46,    0x7acf,    0x4854,    0x59dd,    0x2d62,    0x3ceb,    0x0e70,    0x1ff9,
    0xf78f,    0xe606,    0xd49d,    0xc514,    0xb1ab,    0xa022,    0x92b9,    0x8330,
    0x7bc7,    0x6a4e,    0x58d5,    0x495c,    0x3de3,    0x2c6a,    0x1ef1,    0x0f78
};

uint16_t gen_crc16(uint8_t *cp, int16_t len) {
    uint16_t fcs= 0xffff;
    while (len--)
        fcs = (uint16_t)((fcs >> 8) ^ fcstab[(fcs ^ *cp++) & 0xff]);
    fcs ^= 0xffff;
    return fcs;
}

@implementation BLESMDataParser

+ (NSData *)addressToData:(NSString *)address {

    if (address.length % 2 == 1) {
        address = [NSString stringWithFormat:@"0%@", address];
    }
    
    NSMutableString *addr = [[NSMutableString alloc] init];
    for (int i = (int)(address.length - 2); i >= 0; i -= 2) {
        [addr appendString:[address substringWithRange:NSMakeRange(i, 2)]];
    }
    
    return [BLCommonTools hexString2Bytes:addr];
}

//uint16_t gen_crc16(const uint8_t *data, uint16_t size) {
//    uint16_t crc = 0;
//    uint8_t i;
//    for (; size > 0; size--) {
//        crc = crc ^ (*data++ <<8);
//        for (i = 0; i < 8; i++) {
//            if (crc & 0X8000) {
//                crc = (crc << 1) ^ PLOY;
//            }else {
//                crc <<= 1;
//            }
//        }
//        crc &= 0XFFFF;
//    }
//    return crc;
//}

int bytes2Int(Byte bytes[4]) {
    int ret = (bytes[0] & 0xff)
        | ((bytes[1] & 0xff) << 8)
        | ((bytes[2] & 0xff) << 16)
        | ((bytes[3] & 0xff) << 24);
    
    return ret;
}

/**
 获取表号,通信地址
 
 @return
 */
+ (NSData *)genGetAddress {
    
    Byte bytes[REQUEST_BYTES_LENGTH] = {0};
    int offset = 0;
    
    bytes[offset++] = 0x02;
    bytes[offset++] = 0x80;
    bytes[offset++] = 0x03;
    bytes[offset++] = 0xa1;
    
//    bytes[offset++] = 0xcb;
//    bytes[offset++] = 0x54;
    uint16_t crc = gen_crc16(bytes+1 ,offset-1);
    bytes[offset++] = (Byte)(crc & 0xff);
    bytes[offset++] = (Byte)((crc >> 8) & 0xff);
    
    NSData *data = [NSData dataWithBytes:bytes length:offset];
    
    return data;
}

/**
 生成充值命令 HEX String
 
 @param token 用户输入的20位数字token字符串
 @param address 通讯地址
 @return
 */
+ (NSData *)genRechargeStringWithToken:(NSString *)token address:(NSString *)address {
    
    Byte bytes[REQUEST_BYTES_LENGTH] = {0};
    int offset = 0;
    
    bytes[offset++] = 0x02;
    bytes[offset++] = 0x80;
    bytes[offset++] = 0x25;
    bytes[offset++] = 0x55;
    bytes[offset++] = 0x68;
    
    NSData *addrData = [self addressToData:address];
    if (addrData) {
        Byte *testByte = (Byte *)[addrData bytes];
        for (int i = 0; i < [addrData length]; i++) {
            bytes[offset++] = testByte[i];
        }
    }
    
    bytes[offset++] = 0x68;
    bytes[offset++] = 0x00;
    bytes[offset++] = 0x16;
    bytes[offset++] = 0x34;
    bytes[offset++] = 0x13;
    
    for (int i = 0; i < token.length; i++) {
        unichar ch = [token characterAtIndex:i];
        ch += 0x33;
        bytes[offset++] = (Byte) ch;
    }
    
    for (int i = 4; i <= offset - 1; i++) {
        bytes[offset] += bytes[i];
    }
    offset++;
    
    bytes[offset++] = 0x16;
    
    uint16_t crc = gen_crc16(bytes+1 ,offset-1);
    bytes[offset++] = (Byte)(crc & 0xff);
    bytes[offset++] = (Byte)((crc >> 8) & 0xff);
    
    NSData *data = [NSData dataWithBytes:bytes length:offset];

    return data;
}

/**
 生成余额查询命令 HEX String
 
 @param address 通讯地址
 @return
 */
+ (NSData *)genBalanceWithAddress:(NSString *)address {
    
    Byte bytes[REQUEST_BYTES_LENGTH] = {0};
    int offset = 0;
    
    bytes[offset++] = 0x02;
    bytes[offset++] = 0x80;
    bytes[offset++] = 0x14;
    bytes[offset++] = 0x55;
    bytes[offset++] = 0x68;
    
    NSData *addrData = [self addressToData:address];
    if (addrData) {
        Byte *testByte = (Byte *)[addrData bytes];
        for (int i = 0; i < [addrData length]; i++) {
            bytes[offset++] = testByte[i];
        }
    }
    
    bytes[offset++] = 0x68;
    bytes[offset++] = 0x00;
    bytes[offset++] = 0x05;
    bytes[offset++] = 0x35;
    bytes[offset++] = 0x13;
    bytes[offset++] = 0x63;
    bytes[offset++] = 0x63;
    bytes[offset++] = 0x6C;
    bytes[offset++] = 0xB6;
    bytes[offset++] = 0x16;
    
    uint16_t crc = gen_crc16(bytes+1 ,offset-1);
    bytes[offset++] = (Byte)(crc & 0xff);
    bytes[offset++] = (Byte)((crc >> 8) & 0xff);
    
    NSData *data = [NSData dataWithBytes:bytes length:offset];

    return data;
}

/**
 生成参数查询命令 HEX String
 
 @param address 通讯地址
 @return
 */
+ (NSData *)genInquiryWithAddress:(NSString *)address {
    
    Byte bytes[REQUEST_BYTES_LENGTH] = {0};
    int offset = 0;
    
    bytes[offset++] = 0x02;
    bytes[offset++] = 0x80;
    bytes[offset++] = 0x14;
    bytes[offset++] = 0x55;
    bytes[offset++] = 0x68;
    
    NSData *addrData = [self addressToData:address];
    if (addrData) {
        Byte *testByte = (Byte *)[addrData bytes];
        for (int i = 0; i < [addrData length]; i++) {
            bytes[offset++] = testByte[i];
        }
    }
    
    bytes[offset++] = 0x68;
    bytes[offset++] = 0x00;
    bytes[offset++] = 0x05;
    bytes[offset++] = 0x35;
    bytes[offset++] = 0x13;
    bytes[offset++] = 0x63;
    bytes[offset++] = 0x6A;
    bytes[offset++] = 0x6B;
    bytes[offset++] = 0xBC;
    bytes[offset++] = 0x16;
    
    uint16_t crc = gen_crc16(bytes+1 ,offset-1);
    bytes[offset++] = (Byte)(crc & 0xff);
    bytes[offset++] = (Byte)((crc >> 8) & 0xff);
    
    NSData *data = [NSData dataWithBytes:bytes length:offset];

    return data;
}

+ (id)parseBytes:(NSData *)data {
    
    Byte *bytes = (Byte*)malloc(data.length);
    memcpy(bytes, [data bytes], data.length);
    
    if (bytes[0] == 0x02 && bytes[1] == 0x80 && bytes[3] == 0xa0 && bytes[4] == 0x00 && bytes[5] == 0x0b) {    // 获取表号
        AddressInfo *info = [AddressInfo new];
        
        int len = (int) bytes[6];
        
        NSData *addrData = [NSData dataWithBytes:(bytes+7) length:len];
        Byte *aBytes = (Byte *)[addrData bytes];
        NSMutableString *addr = [NSMutableString new];
        for (int i = (int)(addrData.length - 1); i >= 0; i--) {
            Byte ch = aBytes[i] - 0x30;
            [addr appendString:[NSString stringWithFormat:@"%d", ch]];
        }
        
        info.state = 0;
        info.address = [addr copy];
        
        free(bytes);
        return info;
    } else if (bytes[14] == 0x34 && bytes[15] == 0x13 && bytes[16] == 0x33) { //充值操作
        
        RechargeInfo *info = [RechargeInfo new];
        
        if (bytes[17] == 0x33) {
            
            Byte rechargeValueBytes[4] = {0};
            rechargeValueBytes[0] = bytes[20] - 0x33;
            rechargeValueBytes[1] = bytes[21] - 0x33;
            rechargeValueBytes[2] = bytes[22] - 0x33;
            rechargeValueBytes[3] = bytes[23] - 0x33;
            double rechargeValue = bytes2Int(rechargeValueBytes) * 0.01;
            
            //余额，低位在前
            Byte balanceBytes[4] = {0};
            balanceBytes[0] = bytes[26] - 0x33;
            balanceBytes[1] = bytes[27] - 0x33;
            balanceBytes[2] = bytes[28] - 0x33;
            balanceBytes[3] = bytes[29] - 0x33;
            double balance = bytes2Int(balanceBytes) * 0.01;
            
            info.state = 0;
            info.rechargeValue = rechargeValue;
            info.balance = balance;
        } else {
            info.state = -1;
        }
        
        free(bytes);
        return info;
    } else if (bytes[14] == 0x35 && bytes[15] == 0x13 && bytes[16] == 0x63
               && bytes[17] == 0x63 && bytes[18] == 0x6C) {
        //查询余额操作
        BalanceInfo *info = [BalanceInfo new];
        
        if (bytes[19] == 0x33) {
            Byte balanceBytes[4] = {0};
            balanceBytes[0] = bytes[22] - 0x33;
            balanceBytes[1] = bytes[23] - 0x33;
            balanceBytes[2] = bytes[24] - 0x33;
            balanceBytes[3] = bytes[25] - 0x33;
            double balance = bytes2Int(balanceBytes) * 0.01;
            
            info.state = 0;
            info.balance = balance;
        } else {
            info.state = -1;
        }
        
        free(bytes);
        return info;
    } else if (bytes[14] == 0x35 && bytes[15] == 0x13 && bytes[16] == 0x63
               && bytes[17] == 0x6A && bytes[18] == 0x6B) {
        //查询电表参数操作
        MeterInfo *info = [MeterInfo new];
        
        if (bytes[19] == 0x33) {
            //余额，低位在前
            Byte balanceBytes[4] = {0};
            balanceBytes[0] = bytes[26] - 0x33;
            balanceBytes[1] = bytes[27] - 0x33;
            balanceBytes[2] = bytes[28] - 0x33;
            balanceBytes[3] = bytes[29] - 0x33;
            double balance = bytes2Int(balanceBytes) * 0.01;
            
            //时间
            int minute = bytes[33] - 0x33;
            int hour = bytes[34] - 0x33;
            int day = bytes[35] - 0x33;
            int month = bytes[36] - 0x33;
            int year = bytes[37] - 0x33;
            NSString *time = [NSString stringWithFormat:@"%02d-%02d-%02d %02d:%02d", day, month, year, hour, minute];
            
            //电表状态
            
            //继电器状态
            Byte brs = bytes[45] - 0x33;
            int relayState = RELAY_STATE_CONNECTED;
            if (brs == 0x5F) {
                relayState = RELAY_STATE_DISCONNECTED;
            }
            
            //电表模式
            
            //正向有功总功率
            Byte bpapBytes[4] = {0};
            bpapBytes[0] = bytes[54] - 0x33;
            bpapBytes[1] = bytes[55] - 0x33;
            bpapBytes[2] = bytes[56] - 0x33;
            bpapBytes[3] = bytes[57] - 0x33;
            double positiveActivePower = bytes2Int(bpapBytes) * 0.01;
            
            //正向有功总能量
            Byte bpaeBytes[4] = {0};
            bpaeBytes[0] = bytes[60] - 0x33;
            bpaeBytes[1] = bytes[61] - 0x33;
            bpaeBytes[2] = bytes[62] - 0x33;
            bpaeBytes[3] = bytes[63] - 0x33;
            double positiveActiveEnergy = bytes2Int(bpaeBytes) * 0.01;
            
            //正向有功费率1能量
            Byte bpaerBytes[4] = {0};
            bpaerBytes[0] = bytes[64] - 0x33;
            bpaerBytes[1] = bytes[65] - 0x33;
            bpaerBytes[2] = bytes[66] - 0x33;
            bpaerBytes[3] = bytes[67] - 0x33;
            double positiveActiveEnergyRate1 = bytes2Int(bpaerBytes) * 0.01;
            
            //正向有功费率2能量
            bpaerBytes[0] = bytes[68] - 0x33;
            bpaerBytes[1] = bytes[69] - 0x33;
            bpaerBytes[2] = bytes[70] - 0x33;
            bpaerBytes[3] = bytes[71] - 0x33;
            double positiveActiveEnergyRate2 = bytes2Int(bpaerBytes) * 0.01;
            
            //正向有功费率3能量
            bpaerBytes[0] = bytes[72] - 0x33;
            bpaerBytes[1] = bytes[73] - 0x33;
            bpaerBytes[2] = bytes[74] - 0x33;
            bpaerBytes[3] = bytes[75] - 0x33;
            double positiveActiveEnergyRate3 = bytes2Int(bpaerBytes) * 0.01;
            
            //正向有功费率4能量
            bpaerBytes[0] = bytes[76] - 0x33;
            bpaerBytes[1] = bytes[77] - 0x33;
            bpaerBytes[2] = bytes[78] - 0x33;
            bpaerBytes[3] = bytes[79] - 0x33;
            double positiveActiveEnergyRate4 = bytes2Int(bpaerBytes) * 0.01;
            
            //秘钥版本号
            int secretKeyVision = bytes[86] - 0x33;
            
            //费率
            double rate = (double) (bytes[89] - 0x33);
            
            info.state = 0;
            info.balance = balance;
            info.time = time;
            info.relayState = relayState;
            info.positiveActivePower = positiveActivePower;
            info.positiveActiveEnergy = positiveActiveEnergy;
            info.positiveActiveEnergyRate1 = positiveActiveEnergyRate1;
            info.positiveActiveEnergyRate2 = positiveActiveEnergyRate2;
            info.positiveActiveEnergyRate3 = positiveActiveEnergyRate3;
            info.positiveActiveEnergyRate4 = positiveActiveEnergyRate4;
            info.secretKeyVision = secretKeyVision;
            info.rate = rate;
        } else {
            info.state = -1;
        }
        
        free(bytes);
        return info;
    }
    
    free(bytes);
    return nil;
}


@end
