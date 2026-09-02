/*
 * @Author: duncy
 * @Date: 2025-11-19 15:02:56
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-13 09:40:44
 * @FilePath: /ling_bao/lib/global/pay/controller/pay_style_manager.dart
 * @Description: 
 */

import 'package:ling_bao/global/pay/bean/vip_type_bean.dart';

class PayStyleManager {
  int type = 0; //付费 0: 横屏, 1: 竖屏
  int style = 1;

  ///  1: 默认黑色样式, 2:黑色背景样式, 3:白色背景样式   4：9.0.7-白色样式  5；9.0.7-黑色样式  6；9.0.

  PayStyleManager({required this.type, required this.style});

  ///获取每日均价 type: 0 每日  1: 每周  2: 每月
  String getDayPrice(dynamic package, {bool isDiscount = false, int type = 0}) {
    final VipTypeBean bean = package as VipTypeBean;
    if (type == 0) {
      final String rawDayMoney = (bean.dayMoney ?? '').trim();
      if (rawDayMoney.isNotEmpty) {
        final String normalized = rawDayMoney.replaceAll(
          RegExp(r'[^\d\.\-]'),
          '',
        );
        final double? parsed = double.tryParse(normalized);

        // 接口有值且大于 0 时优先展示接口下发的 dayMoney，避免本地计算误差。
        if (parsed != null && parsed > 0) {
          return normalized;
        }
      }
    }
    String localprice = getPrice(package, isDiscount: isDiscount);
    int rate = type == 0
        ? 1
        : type == 1
        ? 7
        : 30;
    try {
      double price = double.parse(localprice.replaceAll(bean.localSymbol!, ''));
      return '${(price / bean.day! * 100 * rate).round() / 100}';
    } catch (e) {
      return '${(double.parse(localprice.replaceAll(getLocalSymbol(package), '')) / bean.day! * 100 * rate).round() / 100}';
    }
  }

  ///获取本地符号
  String getLocalSymbol(VipTypeBean bean) {
    return '￥';
  }

  ///获取均价描述
  String getAveragePriceDes() {
    return '/天';
  }

  ///获取价格
  String getPrice(dynamic package, {bool isDiscount = false}) {
    return '￥${package.money}';
  }

  ///获取对应位置的显示名称
  String getPayTypeName(VipTypeBean bean, int position) {
    int boldPostion = 3;
    if (bean.boldArea != null && bean.boldArea!.isNotEmpty) {
      boldPostion = int.parse(bean.boldArea!.first);
    }

    ///标题位置
    if (position == 1) {
      ///标题加粗
      if (boldPostion == 2) {
        return getPrice(bean);
      } else {
        return bean.title;
      }
    }
    ///套餐价格位置
    else if (position == 2) {
      ///套餐均价被加粗
      if (boldPostion == 3) {
        return getPrice(bean);
      } else {
        return '${getLocalSymbol(bean)}${getDayPrice(bean)}${getAveragePriceDes()}';
      }
    }
    ///均价位置
    ///钱符号
    else if (position == 3) {
      return boldPostion != 2 ? getLocalSymbol(bean) : '';
    }
    ///套餐价
    else if (position == 4) {
      ///标题被加粗
      if (boldPostion == 2) {
        return bean.title;
      } else if (boldPostion == 1) {
        return getPrice(bean).replaceAll(getLocalSymbol(bean), '');
      } else {
        return getDayPrice(bean);
      }
    }
    ///套餐价位置后缀如/天、/月等
    else if (position == 5) {
      return boldPostion == 3 ? getAveragePriceDes() : '';
    }
    return '';
  }
}
