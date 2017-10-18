package com.daemon.viewlp.utils;

/**
 * author: zhaoqiang
 * date:2017/10/18 / 10:35
 * zhaoqiang:zhaoq_hero@163.com
 */

public class MTimeUtils {

    //转换  毫秒   为  hh:m 格式 ：
    public static String formatTime(int currentLong) {

        StringBuffer sb = new StringBuffer();
        //
        int ss = currentLong / 1000;//转换为秒长

        int hh = ss / 60 / 60;//获取小时
        int mm = (ss - (hh * 60 * 60)) / 60;  //获取分钟
        int lass = (ss - (hh * 60 * 60) - mm * 60);//  获取  秒数

        if (hh >= 1) {
            if (mm >= 1) {
                sb.append(hh + ":" + mm + ":" + lass);
            } else {
                sb.append(hh + ":" + "0:" + lass);
            }
        } else {
            if (mm >= 1) {
                sb.append(mm + ":" + lass);
            } else {
                sb.append("0:" + lass);
            }
        }
        return sb.toString();
    }
}
