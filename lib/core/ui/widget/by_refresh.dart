/*
 * @Author: duncy
 * @Date: 2025-09-24 15:36:51
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:22:01
 * @FilePath: /ling_bao/lib/core/ui/widget/by_refresh.dart
 * @Description: 
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../util/page_helper.dart';

class ByRefresh {
  static const String _idleText = '上拉加载更多';
  static const String _canLoadingText = '松手加载更多';
  static const String _loadingText = '加载中...';
  static const String _failedText = '加载失败，请重试';
  static const String _noDataText = '没有更多了';

  static RefreshConfiguration configuration({
    required Widget child,
    IndicatorBuilder? headerBuilder,
    IndicatorBuilder? footerBuilder,
    bool hideFooterWhenNotFull = true,
  }) {
    return RefreshConfiguration(
      headerBuilder: headerBuilder ?? buildDefaultHeader,
      footerBuilder: footerBuilder ?? buildDefaultFooter,
      headerTriggerDistance: 70.0,
      springDescription: const SpringDescription(
        stiffness: 180,
        damping: 20,
        mass: 0.5,
      ),
      maxOverScrollExtent: 100,
      maxUnderScrollExtent: 0,
      enableScrollWhenRefreshCompleted: true,
      enableLoadingWhenFailed: true,
      hideFooterWhenNotFull: hideFooterWhenNotFull,
      enableBallisticLoad: true,
      child: child,
    );
  }

  static Widget refresh({
    required Widget child,
    required RefreshController controller,
    void Function()? onRefresh,
    void Function()? onLoad,
    Key? refresherKey,
    Widget? header,
    Widget? footer,
    bool? enablePullDown,
    bool? enablePullUp,
    bool? hideFooterWhenNotFull,
  }) {
    return Builder(
      builder: (context) {
        final Widget refresher = SmartRefresher(
          key: refresherKey,
          enablePullDown: enablePullDown ?? onRefresh != null,
          enablePullUp: enablePullUp ?? onLoad != null,
          header: header,
          footer: footer,
          controller: controller,
          onRefresh: onRefresh,
          onLoading: onLoad,
          child: child,
        );
        if (hideFooterWhenNotFull == null) {
          return refresher;
        }
        final RefreshConfiguration? ancestor = RefreshConfiguration.of(context);
        if (ancestor == null) {
          return configuration(
            hideFooterWhenNotFull: hideFooterWhenNotFull,
            child: refresher,
          );
        }
        return RefreshConfiguration.copyAncestor(
          context: context,
          hideFooterWhenNotFull: hideFooterWhenNotFull,
          child: refresher,
        );
      },
    );
  }

  static Widget buildDefaultHeader() {
    return const WaterDropHeader();
  }

  static Widget buildDefaultFooter() {
    return const ClassicFooter(
      idleText: _idleText,
      canLoadingText: _canLoadingText,
      loadingText: _loadingText,
      failedText: _failedText,
      noDataText: _noDataText,
    );
  }

  static Widget buildDarkHeader() {
    return const WaterDropHeader(
      waterDropColor: Colors.white70,
      complete: Text(
        '刷新完成',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      failed: Text(
        '刷新失败',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }

  static Widget buildDarkFooter({bool hideNoMore = false}) {
    return CustomFooter(
      builder: (context, mode) {
        Widget child;
        switch (mode) {
          case LoadStatus.loading:
            child = const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  _loadingText,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            );
            break;
          case LoadStatus.failed:
            child = const Text(
              _failedText,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            );
            break;
          case LoadStatus.canLoading:
            child = const Text(
              _canLoadingText,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            );
            break;
          case LoadStatus.noMore:
            child = hideNoMore
                ? const SizedBox.shrink()
                : const Text(
                    _noDataText,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  );
            break;
          default:
            child = const Text(
              _idleText,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            );
        }
        return SizedBox(height: 48, child: Center(child: child));
      },
    );
  }
}

///上下拉刷新控制器
class RefreshManager {
  final RefreshController refreshController = RefreshController();

  final PageHelper _pageHelper = PageHelper();
  PageHelper get pageHelper => _pageHelper;

  bool _isRequesting = false;
  bool get isRequesting => _isRequesting;

  bool beginRequest(bool isRefresh, {required bool hasMore}) {
    if (_isRequesting) {
      if (isRefresh) {
        refreshController.refreshCompleted();
      } else {
        refreshController.loadComplete();
      }
      return false;
    }
    if (!isRefresh && !hasMore) {
      refreshController.loadNoData();
      return false;
    }
    if (isRefresh) {
      pageHelper.resetPage();
      refreshController.resetNoData();
    }
    _isRequesting = true;
    return true;
  }

  void completeSuccess({
    required bool isRefresh,
    required bool hasMore,
    bool notifyRefreshUi = true,
  }) {
    if (hasMore) {
      pageHelper.addPage();
    }
    if (notifyRefreshUi) {
      refreshSuccess(isRefresh, hasMore);
    }
    _isRequesting = false;
  }

  void completeFailed(bool isRefresh, {bool notifyRefreshUi = true}) {
    if (notifyRefreshUi) {
      refreshFailed(isRefresh);
    }
    _isRequesting = false;
  }

  void refreshSuccess(bool isRefresh, bool hasMore) {
    if (isRefresh) {
      refreshController.refreshCompleted(resetFooterState: true);
    }
    if (hasMore) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  void refreshFailed(bool isRefresh) {
    if (isRefresh) {
      refreshController.refreshFailed();
    } else {
      refreshController.loadFailed();
    }
  }

  void dispose() {
    refreshController.dispose();
  }
}
