/*
 * @Author: cold-x
 * @Date: 2025-06-12 09:23:56
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-12 09:24:04
 * @FilePath: /fastcreationmaster/lib/core/util/page_helper.dart
 * @Description: 
 */
class PageHelper {
  PageHelper();

  int page = 1;
  int row = 10; //一个请求多少个数据

  void resetPage() {
    page = 1;
  }

  void addPage() {
    page += 1;
  }
}
