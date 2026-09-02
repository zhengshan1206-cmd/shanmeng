/*
 * @Author: duncy
 * @Date: 2025-10-31 18:28:05
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-04-07 14:21:27
 * @FilePath: /ling_bao/lib/core/service/email_service.dart
 * @Description: 
 */

import 'package:url_launcher/url_launcher.dart';

import '../../global/const/consts.dart';

class EmailService {
  // Build email URL
  static String _buildEmailUrl({
    required List<String> to, // 收件人列表
    String? subject, // subject
    String? body, // body
    List<String>? cc, // cc
    List<String>? bcc, // bcc
  }) {
    // Process recipients (join with comma)
    final toStr = to.join(',');
    if (toStr.isEmpty) {
      throw Exception("At least one recipient is required");
    }

    // Build query parameters (subject, body, cc, bcc)
    final queryParams = <String, String>{};
    if (subject != null && subject.isNotEmpty) {
      // Use raw subject and let Uri encode it once when building the URI.
      // Avoid pre-encoding which can lead to double-encoding (e.g. spaces becoming "%20" literals).
      queryParams['subject'] = subject;
    }
    if (body != null && body.isNotEmpty) {
      // Use raw body (with normal newlines). Uri will percent-encode newlines and spaces.
      // If you need CRLF for some mail clients, convert '\n' -> '\r\n' here before assigning.
      queryParams['body'] = body;
    }
    if (cc != null && cc.isNotEmpty) {
      queryParams['cc'] = cc.join(',');
    }
    if (bcc != null && bcc.isNotEmpty) {
      queryParams['bcc'] = bcc.join(',');
    }

    // Assemble final URL
    String? query;
    if (queryParams.isNotEmpty) {
      // Build a raw query string using encodeComponent to ensure spaces are encoded as %20
      // (Uri.encodeQueryComponent encodes spaces as '+', while encodeComponent uses %20)
      query = queryParams.entries
          .map((e) {
            final k = Uri.encodeComponent(e.key);
            final v = Uri.encodeComponent(e.value);
            return '$k=$v';
          })
          .join('&');
    }

    final uri = Uri(scheme: 'mailto', path: toStr, query: query);
    return uri.toString();
  }

  // Launch system email app
  static Future<void> launchEmail({Function? failed}) async {
    try {
      // Build email info
      final emailUrl = _buildEmailUrl(
        to: [Consts.supportEmail], // 多个收件人
        subject: 'Penman Pro feedback', // subject
        body:
            'Hello,\n\nI encountered the following issues while using the app:\n1. ...\n2. ...\n\nPlease reply as soon as possible, thank you!', // body (supports newlines)
      );

      // Check whether the URL can be launched
      final uri = Uri.parse(emailUrl);
      // Try launching the email intent. On some Android devices the externalApplication
      // mode can fail to resolve an activity even if canLaunchUrl returns true
      // (component name is null). We'll try a couple of fallback modes before giving up.
      try {
        // if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
        // }
      } catch (e) {
        failed?.call();
        // continue to fallbacks
        print('launch externalApplication failed: $e');
      }

      // Fallback: try platform default (this may open a chooser on Android)
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          return;
        }
      } catch (e) {
        failed?.call();
        print('launch platformDefault failed: $e');
      }

      // Final fallback: try without specifying a mode
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return;
        }
      } catch (e) {
        failed?.call();
        throw Exception(
          "Unable to open email app, please check if an email client is installed. Error: $e",
        );
      }
      failed?.call();
    } catch (e) {
      failed?.call();
      // Catch errors (e.g., no recipients, no email app, etc.)
      print("Failed to send email: $e");
      // Could show a SnackBar to inform the user
    }
  }
}
