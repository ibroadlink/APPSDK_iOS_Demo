//
//  BLAppConfig.h
//  BLLet
//
//  Created by yang on 12/11/13.
//  Copyright (c) 2013 BroadLink. All rights reserved.
//

#ifndef BLAPPCONFIG_h
#define BLAPPCONFIG_h

#include <sys/types.h>

#define CLIENT_TYPE_MIN  1000
#define DEVICE_TYPE_MIN  100
typedef signed char INT8;
typedef signed short INT16;
typedef signed int  INT32;
typedef signed long long INT64;
typedef unsigned char UINT8;
typedef unsigned short  UINT16;
typedef unsigned int    UINT32;
typedef unsigned long long UINT64;

/*Define support message's type*/
enum
{
    RM_GET_STATUS = DEVICE_TYPE_MIN + 1,
    RM_SET_STATUS,
    RM_SET_CONFIG,
    RM_SET_TIME_CONF,
    RM_GET_ENERGY_DATA,
    
    /*Device to client*/
    RM_GET_STATUS_RES = CLIENT_TYPE_MIN + 1,
    RM_SET_STATUS_RES,
    RM_SET_CONFIG_RES,
    RM_SET_TIME_CONF_RES,
    RM_GET_ENERGY_DATA_RES
};

enum
{
    RM_USER = DEVICE_TYPE_MIN + 1,
    RM_USER_STUDY,
    RM_USER_CODE,
    RM_IR_GET_STATUS,
    
    
    RM_USER_RES = CLIENT_TYPE_MIN + 1,
    RM_USER_STUDY_RES,
    RM_USER_CODE_RES,
    RM_IR_GET_STATUS_RES
};

enum
{
    SP2_NAME_STATUS = 0,
    SP2_STATUS_GET,
    SP2_SET_STATUS,
    SP2_SET_CONFIG,
    SP2_ENERGY_CURRENT,
    SP2_ENERGY_DAY,
    SP2_ENERGY_WEEK,
    SP2_ENERGY_MONTH,
    SP2_ENERGY_YEAR,
    SP2_SET_LOW_TIME,
    SP2_SET_STANDBY_POWER,
    SP2_GET_STANDBY_POWER,
    SP2_GET_DEVICE_REALTIME = 100,
    SP2_SET_RONDOMTIMER_PARAM = 101,
    SET_GROUPTIMER_LIST = 103,
    GET_GROUPTIMER_LIST = 107
};

enum
{
    RM2_NAME_STATUS = 0,
    RM2_STATUS_GET,
    RM2_IRDA_SEND,
    RM2_IRDA_STUDY,
    RM2_IRDA_CODE,
    RM2_IRDA_TIMER_LIST,
    RM2_IRDA_TIMER_ADD,
    RM2_IRDA_TIMER_DEL
};

enum
{
    EAIR_NAME_STATUS = 0,
    EAIR_STATUS_GET,
    EAIR_IFTTT_ADD,
    EAIR_IFTTT_GET,
    EAIR_IFTTT_DEL
};

enum
{
    FIRMWARE_INFO_GET = 104,
    FIRMWARE_AUTO_UPDATE = 105,
    FIRMWARE_FORCE_UPDATE = 106
};

typedef struct device_status_t
{
//    UINT32 switch_status;   //Keep the switch's ON/OFF status;
    UInt16 switch_status;
    UInt16 mask;
}__attribute__((packed))device_status_t;

typedef struct irda_control_status_t
{
    INT8 temp_integer;
    UINT8 temp_decimal;
    UINT8 humidity;
    UINT8 other;
}__attribute__((packed))irda_control_status_t;


/*Following define remote control's timer structure. for android and ios is difficult to operate with bit*/
typedef struct rm_timer_t
{
    UINT8 enable;
    UINT8 week;
    UINT8 start; //Whether it starts to excutive
    UINT8 done; //Whether it's done
    UINT8 on_hour;//Switch on time
    UINT8 on_min;//Switch on minute
    UINT8 off_hour;//Switch off hour
    UINT8 off_min; //Switch off minute
}__attribute__((packed))rm_timer_t;

#define MAX_TIME_C      8
typedef struct rm_timer_cfg_t
{
    UINT32 count;
    rm_timer_t timer[MAX_TIME_C];
}__attribute__((packed))rm_timer_cfg_t;

typedef struct device_info_t
{
    UINT8 name[63];
    UINT8 lock;
}__attribute__((packed))device_info_t;

typedef struct mmi_setting_time_t
{
    UINT16 year;      //年
    UINT8 second;     //秒
    UINT8 minute;     //分
    UINT8 hour;       //小时
    UINT8 weekday;    //星期
    UINT8 day;        //日
    UINT8 month;      //月
}mmi_setting_time_t;

typedef struct device_timeconf_t
{
    rm_timer_cfg_t time_cfg;
    device_info_t device_info;
}__attribute__((packed))device_timeconf_t;

typedef struct auth_res_t
{
    union
    {
        device_status_t sp_status;
        irda_control_status_t rm_status;
    }status;
    device_timeconf_t timeconfig;
}__attribute__((packed))auth_res_t;

typedef struct bl2_msg_type_t
{
    UINT32 msg_type;
}__attribute__((packed))bl2_msg_type_t;

#define BL2_TIMER_MAX 8
typedef struct bl2_timer_set_t
{
    mmi_setting_time_t on;
    int on_enable;
    mmi_setting_time_t off;
    int off_enable;
}__attribute__((packed))bl2_timer_set_t;

typedef struct bl2_timer_cfg_t
{
    UINT32 count;
    bl2_timer_set_t timer[BL2_TIMER_MAX];
}__attribute__((packed))bl2_timer_cfg_t;

typedef struct bl2_device_timeconf_t
{
    rm_timer_cfg_t time_cfg;
    device_info_t info;
    bl2_timer_cfg_t bl2_timer;
}__attribute__((packed))bl2_device_timeconf_t;

typedef struct bl2_device_timeconf_req_t
{
    bl2_msg_type_t msg_type;
    bl2_device_timeconf_t conf;
}__attribute__((packed))bl2_device_timeconf_req_t;

typedef struct bl2_set_device_info_t
{
    bl2_msg_type_t msg_type;
    device_info_t info;
}__attribute__((packed))bl2_set_device_info_t;

typedef struct bl2_auth_res_t
{
    bl2_msg_type_t msg_type;
    union
    {
        device_status_t sp_status;
        irda_control_status_t rm_status;
    }status;
    bl2_device_timeconf_t timeconfig;
}__attribute__((packed))bl2_auth_res_t;

typedef struct bl2_device_status_t
{
    bl2_msg_type_t msg_type;
    device_status_t switch_status;
}__attribute__((packed))bl2_device_status_t;

typedef struct bl2_current_power_t
{
    UINT32 power;
}__attribute__((packed))bl2_current_power_t;

typedef struct bl2_energy_day_t
{
    bl2_current_power_t power;	//current w.
    UINT32 energy[24 * 60 / 5]; // 24 hours, every 5 minute, we keep one data
}__attribute__((packed))bl2_energy_day_t;

typedef struct bl2_energy_sta_t
{
    UINT32 peak; 	//Peak energy.
    UINT32 low;		//Low energy.
    UINT32 on_time;	//On time.
    UINT32 standby;	//Standby energy.
}__attribute__((packed))bl2_energy_sta_t;


typedef struct bl2_current_power_res_t
{
    bl2_msg_type_t msg_type;
    bl2_current_power_t power;
}__attribute__((packed))bl2_current_power_res_t;

typedef struct bl2_day_energy_res_t
{
    bl2_msg_type_t msg_type;
    bl2_energy_day_t day_energy;
}__attribute__((packed))bl2_day_energy_res_t;

typedef struct bl2_energy_week_req_t
{
    bl2_msg_type_t msg_type;
    UINT32 week;
}bl2_energy_week_req_t;

typedef struct bl2_energy_month_req_t
{
    bl2_msg_type_t msg_type;
    UINT16 year;
    UINT16 month;
}__attribute__((packed))bl2_energy_month_req_t;

typedef struct bl2_energy_year_req_t
{
    bl2_msg_type_t msg_type;
    UINT32 year;
}__attribute__((packed))bl2_energy_year_req_t;

typedef struct bl2_energy_list_res_t
{
    bl2_msg_type_t msg_type;
    bl2_energy_sta_t energy[0];
}__attribute__((packed))bl2_energy_list_res_t;

typedef struct bl2_energy_list_res2_t
{
    bl2_msg_type_t msg_type;
    UINT32 index;
    bl2_energy_sta_t energy[0];
}__attribute__((packed))bl2_energy_list_res2_t;

typedef struct device_lately_status_t
{
    mmi_setting_time_t open_time;
    UINT32 realtime;
    UINT32 power;
    UINT32 energy;
}__attribute__((packed))device_lately_status_t;

typedef struct randomtimer_t
{
    uint8_t hour;
    uint8_t minute;
}randomtimer_t;

typedef struct randomtimer_attr_t
{
    randomtimer_t start;
    randomtimer_t end;
    uint8_t run_time;
    uint8_t weeks;
    uint8_t enable;
}randomtimer_attr_t;

#define ANKUOO_MAX_TIME_C      16
typedef struct ankuoo_timer_cfg_t
{
    UINT32 count;
    rm_timer_t timer[ANKUOO_MAX_TIME_C];
}__attribute__((packed))ankuoo_timer_cfg_t;

typedef struct ankuoo_device_timeconf_t
{
    ankuoo_timer_cfg_t time_cfg;
    device_info_t info;
    bl2_timer_cfg_t bl2_timer;
    randomtimer_attr_t random;
}__attribute__((packed))ankuoo_device_timeconf_t;

typedef struct ankuoo_auth_res_t
{
    bl2_msg_type_t msg_type;
    device_status_t sp_status;
    ankuoo_device_timeconf_t timeconfig;
}__attribute__((packed))ankuoo_auth_res_t;

typedef struct ankuoo_device_timeconf_req_t
{
    bl2_msg_type_t msg_type;
    ankuoo_device_timeconf_t conf;
}__attribute__((packed))ankuoo_device_timeconf_req_t;

typedef struct efergy_device_timeconf_t
{
    rm_timer_cfg_t time_cfg;
    device_info_t info;
    bl2_timer_cfg_t bl2_timer;
    randomtimer_attr_t random;
}__attribute__((packed))efergy_device_timeconf_t;

typedef struct efergy_auth_res_t
{
    bl2_msg_type_t msg_type;
    device_status_t sp_status;
    efergy_device_timeconf_t timeconfig;
}__attribute__((packed))efergy_auth_res_t;

typedef struct efergy_device_timeconf_req_t
{
    bl2_msg_type_t msg_type;
    efergy_device_timeconf_t conf;
}__attribute__((packed))efergy_device_timeconf_req_t;

typedef struct rm2_timer_t
{
    UINT32 index;
    UINT8 enable;
    UINT8 hour;
    UINT8 minute;
    UINT8 weeks;
    UINT8 name[60];
}__attribute__((packed))rm2_timer_t;

#define RM2_MAX_TIMER   15
typedef struct rm2_timer_list_t
{
    UINT32 count;
    rm2_timer_t timer[RM2_MAX_TIMER];
}__attribute__((packed))rm2_timer_list_t;

typedef struct rm2_frame_info_t
{
    UINT16 len;
    UINT16 delay;   //Unit is ms
}__attribute__((packed))rm2_frame_info_t;

#define MAX_FRAME_COUNT 5
typedef struct rm2_time_frame_t
{
    UINT32 count;
    rm2_frame_info_t frame_info[MAX_FRAME_COUNT];
}__attribute__((packed))rm2_time_frame_t;

typedef struct rm2_timer_set_t
{
    rm2_timer_t timer;
    rm2_time_frame_t time_frame;
}__attribute__((packed))rm2_timer_set_t;



//eAir
//eAir设备支持的传感器种类：
typedef enum sensor_type_e
{
    EAIR_TEMP,     //温湿度传感器
    EAIR_HUMIDITY,
    EAIR_LIGHT,    //光照强度传感器
    EAIR_AIR,      //VOC传感器
    EAIR_VOICE,    //噪声传感器
    EAIR_TYPE_MAX,
}sensor_type_e;

//描述传感器状态（或值）的基础结构体：
typedef struct sensor_value_t
{
    INT8 integer;
    UINT8 decimal;
}__attribute__((packed))sensor_value_t;
//integet字段存储温湿度的整数部分，或者空气质量、噪声、光感的等级；
//decimal字段存储温湿度的小数部分，对于空气质量、噪声、光感值为0。

//描述传感器状态变化趋势：
typedef enum trigger_e
{
    CONDITION_UP,    //上升趋势，比如温度升高，空气质量从良变到优
    CONDITION_DOWN,  //下降趋势，比如温度降低，光照强度从亮变到暗
}trigger_e;

//IFTTT触发源定义：
typedef struct eair_trigger_t
{
    UINT8 sensor;   //设置触发源传感器
    UINT8 trigger;      //设置触发趋势，是上升（CONDITION_UP）到限定值，还是下降（CONDITION_DOWN）到限定值
    sensor_value_t value;   //设置限定值（阈值）
}__attribute__((packed))eair_trigger_t;

//IFTTT其它传感器需要满足的状态：
typedef struct eair_condit_status_t
{
    //0表示该传感器对IFTTT没有作用，1则表示对IFTTT的执行有作用，并且高7位可以用来说明传感器值的范围，比如温度28℃上下浮动5%，那高7位就设为5。
    INT8 valid;
    UINT8 sensor;
    sensor_value_t value;
}__attribute__((packed))eair_condit_status_t;

typedef struct eair_condition_t
{
    eair_trigger_t trigger;
    eair_condit_status_t status[EAIR_TYPE_MAX - 1];
}__attribute__((packed))eair_condition_t;

//eAir设备IFTTT触发条件结构体：
typedef struct ifttt_t
{
    INT8 enable;            //最高位0表示不启用时间，1表示启用时间，最低位0表示ifttt不启用，1表示启用
    uint32_t index;              //因为用户通过APP设置的IFTTT任务存储在eAir本地Flash中，为了删除和查找的方便，所以在结构体中维护了一个index，用来标识IFTTT的序号。
    mmi_setting_time_t timeA;    //设置IFTTT任务可以执行的时间段
    mmi_setting_time_t timeB;
    eair_condition_t condition;
    UINT8 name[56];            //IFTTT的任务名字，用户可以自定义
    UINT32 res[2];
}__attribute__((packed))ifttt_t;

//IFTTT信息结构体（主要用于APP获取IFTTT任务列表）
typedef struct ifttt_info_t
{
    ifttt_t ifttt;
    UINT8 mac[6];  //一个IFTTT任务针对一个设备，如智能插座或者遥控，该字段存储受控设备的MAC地址，方便APP管理。
}__attribute__((packed))ifttt_info_t;

//IFTTT任务列表结构体：
#define EAIR_MAX_IFTTT 8  //eAir设备本地一共可以保存8个IFTTT任务。
typedef struct eair_ifttt_list_t
{
    UINT32 count;
    ifttt_info_t ifttt_info[EAIR_MAX_IFTTT];
}__attribute__((packed))eair_ifttt_list_t;

typedef struct bl2_device_auth_t
{
    INT32 terminal_id; //We allocate a id for every control device.
    UINT8 key[16];  //The public key for AES communication.
}bl2_device_auth_t;

#define IOT_MAX_LEN (1024 - 6 - 16 - 2)
typedef struct iot_commands_t
{
    bl2_device_auth_t auth;
    //int id; //The iot device id.
    //uint8_t aes[16];//Aes public key
    UINT8 mac[6]; //The control device's mac address
    UINT16 len;
    UINT8 data[IOT_MAX_LEN]; //The commands data
}__attribute__((packed)) iot_commands_t;

typedef struct eair_ifttt_t
{
    ifttt_t ifttt;
    iot_commands_t command;
}eair_ifttt_t;

//eAir传感器当前状态：
typedef struct eair_status_t
{
    sensor_value_t tempera;        //温度值
    sensor_value_t humidity;       //湿度值
    sensor_value_t light;          //光照强度等级
    sensor_value_t air_condition;  //空气质量等级
    sensor_value_t voice;          //噪声等级
    device_info_t info;
}__attribute__((packed))eair_status_t;


typedef struct firmware_info_t
{
    INT32 local_version;
    INT32 server_version;
    UINT32 auto_update;
}__attribute__((packed))firmware_info_t;






/*SPMini's timer stucture*/
typedef struct spmini_timer_cfg_t
{
    UINT32 count;
    bl2_timer_set_t timer[BL2_TIMER_MAX];
}__attribute__((packed))spmini_timer_cfg_t;

typedef struct cycletimer_t
{
    uint8_t hour;
    uint8_t minute;
    uint8_t second;
}__attribute__((packed))cycletimer_t;

typedef struct cycletimer_attr_t
{
    cycletimer_t start;  //开启循环任务的起始时间，格式如上
    cycletimer_t end;  //开启循环任务的起始时间，格式如上
    UINT16 on_level; //每个周期开持续时间，单位：秒，范围<1h(3600s)
    UINT16 off_level; //每个周期关持续时间，单位：秒，范围<1h(3600s)
    UINT8 weeks;
    UINT8 enable;
}__attribute__((packed))cycletimer_attr_t;

/**/
#define CYCLETIME_MAX_COUNT     8
typedef struct cycletimer_group_attr_t
{
    UINT32 count;
    cycletimer_attr_t attr[CYCLETIME_MAX_COUNT];
}__attribute__((packed))cycletimer_group_attr_t;

/*Following define remote control's timer structure. for android and ios is difficult to operate with bit*/
typedef struct spmini_period_t
{
    UINT8 enable;
    UINT8 week;
    UINT8 start; //Whether it starts to excutive
    UINT8 done; //Whether it's done
    UINT8 on_hour;//Switch on time
    UINT8 on_min;//Switch on minute
    UINT8 on_sec;
    UINT8 off_hour;//Switch off hour
    UINT8 off_min; //Switch off minute
    UINT8 off_sec;
    UINT8 reserve[2];
}__attribute__((packed))spmini_period_t;

typedef struct spmini_period_cfg_t
{
    UINT32 count;
    spmini_period_t period[MAX_TIME_C];
}__attribute__((packed))spmini_period_cfg_t;

/*SPMini's timeconfig stucture*/
typedef struct spmini_timeconf_t
{
    spmini_period_cfg_t period_cfg;
    device_info_t info;
    spmini_timer_cfg_t timer_cfg;
    cycletimer_group_attr_t cycletimer_group_attr;
}__attribute__((packed))spmini_timeconf_t;

/*SPMini structure*/
typedef struct spmini_auth_res_t
{
    device_status_t status;
    spmini_timeconf_t timeconfig;
}__attribute__((packed))spmini_auth_res_t;



typedef struct randomtimer_list_t
{
    uint8_t live; /* if live = 0, the timer is dead */
    mmi_setting_time_t set_time;
    randomtimer_attr_t param;
    randomtimer_t randomtimer[8];
}randomtimer_list_t;

typedef struct randomtimer_group_t
{
    uint16_t status;
    uint8_t hour;
    uint8_t minute;
}randomtimer_group_t;

typedef struct randomtimer_group_attr_t
{
    UINT32 count;
    randomtimer_attr_t attr[8];
}randomtimer_group_attr_t;

#endif
