import 'package:flutter/material.dart';

class LocalizationService {
  static String currentLanguage = 'en'; // 'en' or 'fa'

  static bool get isPersian => currentLanguage == 'fa';
  static TextDirection get direction => isPersian ? TextDirection.rtl : TextDirection.ltr;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'CPRay Gaming',
      'app_subtitle': 'GAMING DESKTOP',
      'dashboard': 'Dashboard',
      'game_optimizer': 'Game Optimizer (Per-App)',
      'game_ping_tester': 'Game Ping Tester (100+ Games)',
      'servers': 'Servers & Nodes',
      'split_tunneling': 'Split Tunneling',
      'settings': 'Settings & Routing',
      'engine_logs': 'Engine Logs',
      'tunnel_active': 'TUNNEL ACTIVE',
      'disconnected': 'DISCONNECTED',
      'ready_to_connect': 'READY TO CONNECT',
      'connecting': 'ESTABLISHING TUNNEL...',
      'connected_secure': 'CONNECTED SECURELY',
      'gaming_tun': 'GAMING TUN',
      'proxy_mode': 'PROXY MODE',
      'anti_sanction': 'ANTI-SANCTION DNS',
      'update_sub': 'UPDATE SUB',
      'ping_latency': 'Ping Latency',
      'duration': 'Duration',
      'download_speed': 'Download Speed',
      'upload_speed': 'Upload Speed',
      'iran_bypass': 'Iranian Domestic Traffic Bypass',
      'iran_bypass_desc': 'Local banking, Snapp, Varzesh3, and .ir websites bypass the VPN automatically.',
      'mini_hud': 'Mini In-Game HUD',
      'test_all_pings': 'Test All Pings',
      'search_nodes': 'Search by node name, server address, or protocol...',
      'sound_effects': 'Cyberpunk Sound Effects',
      'auto_failover': 'Auto Failover & Anti-Disconnect',
      'language': 'Language / زبان',
      'cs2_profile': 'Counter-Strike 2 Low Latency',
      'valorant_profile': 'Valorant Anti-Sanction & Vanguard',
      'dota2_profile': 'Dota 2 Europe Low Jitter',
      'discord_profile': 'Discord Voice Priority & Streaming',
      'warzone_profile': 'Warzone & Apex Legends Smooth Routing',
    },
    'fa': {
      'app_title': 'سی پی ری گیمینگ',
      'app_subtitle': 'کلاینت گیمینگ دسکتاپ',
      'dashboard': 'داشبورد',
      'game_optimizer': 'شتاب‌دهنده بازی‌ها (انتخابی)',
      'game_ping_tester': 'تست پینگ ۱۰۰ بازی',
      'servers': 'سرورها و نودهای گیمینگ',
      'split_tunneling': 'اسپلیت تانلینگ',
      'settings': 'تنظیمات و مسیریابی',
      'engine_logs': 'لاگ‌های هسته',
      'tunnel_active': 'تانل فعال است',
      'disconnected': 'قطع شد',
      'ready_to_connect': 'آماده اتصال',
      'connecting': 'در حال اتصال به تانل...',
      'connected_secure': 'متصل شد (امن)',
      'gaming_tun': 'حالت گیمینگ TUN',
      'proxy_mode': 'حالت پروکسی سیستم',
      'anti_sanction': 'تحریم‌شکن بازی (DNS)',
      'update_sub': 'بروزرسانی لینک',
      'ping_latency': 'پینگ و تاخیر',
      'duration': 'مدت اتصال',
      'download_speed': 'سرعت دانلود',
      'upload_speed': 'سرعت آپلود',
      'iran_bypass': 'دور زدن سایت‌های ایرانی (بای‌پس)',
      'iran_bypass_desc': 'سایت‌های بانکی، اسنپ، ورزش ۳ و دامنه .ir بدون افت سرعت از اینترنت مستقیم عبور می‌کنند.',
      'mini_hud': 'ویجت شناور داخل بازی (HUD)',
      'test_all_pings': 'تست پینگ همه سرورها',
      'search_nodes': 'جستجوی نام سرور، آدرس یا پروتکل...',
      'sound_effects': 'افکت‌های صوتی گیمینگ',
      'auto_failover': 'جایگزینی خودکار سرور در صورت قطعی',
      'language': 'زبان / Language',
      'cs2_profile': 'پروفایل کانتر استرایک ۲ (کمترین پینگ)',
      'valorant_profile': 'پروفایل ولورانت و وانگارد (ضد تحریم)',
      'dota2_profile': 'پروفایل دوتا ۲ اروپا (کمترین جیتر)',
      'discord_profile': 'پروفایل دیسکورد و استریمینگ',
      'warzone_profile': 'پروفایل وارزون و اپکس لجندز',
    },
  };

  static String tr(String key) {
    return _localizedValues[currentLanguage]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
