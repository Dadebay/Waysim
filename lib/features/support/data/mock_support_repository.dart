import '../../../core/utils/result.dart';
import '../domain/entities/chat_message.dart';
import '../domain/repositories/support_repository.dart';

class MockSupportRepository implements SupportRepository {
  MockSupportRepository({this.latency = const Duration(milliseconds: 900)});

  final Duration latency;
  @override
  bool get isLive => false;
  @override
  Future<Result<List<ChatMessage>>> messages({String? after}) async =>
      const Success([]);
  @override
  Future<Result<void>> markRead(String? id) async => const Success(null);

  @override
  Future<Result<ChatMessage>> ask({
    required String text,
    required String language,
  }) async {
    await Future<void>.delayed(latency);
    final q = text.toLowerCase();
    final topic = _topic(q);
    final answers = _answers[topic] ?? _answers['unknown']!;
    return Success(
      ChatMessage(
        role: ChatRole.assistant,
        text: answers[language] ?? answers['en']!,
        offersHuman: topic == 'unknown' || topic == 'network',
      ),
    );
  }

  static String _topic(String q) {
    bool has(List<String> words) => words.any(q.contains);
    if (has(['install', 'установ', 'instal', '安装', 'qr'])) return 'install';
    if (has(['network', 'сет', 'connect', 'подключ', 'red', 'réseau', '网络'])) {
      return 'network';
    }
    if (has(['package', 'plan', 'пакет', 'paquete', 'forfait', '套餐'])) {
      return 'choose';
    }
    return 'unknown';
  }

  static const _answers = <String, Map<String, String>>{
    'install': {
      'en':
          'Connect to Wi-Fi and open your eSIM in "My eSIM". On iOS 17.4 and later tap "Install in one tap". On older versions: Settings → Cellular → Add eSIM → Use QR code.',
      'ru':
          'Подключитесь к Wi-Fi и откройте eSIM в разделе «Мои eSIM». На iOS 17.4 и новее нажмите «Установить в одно нажатие». На более старых версиях: Настройки → Сотовая связь → Добавить eSIM → Использовать QR-код.',
      'es':
          'Conéctate al Wi-Fi y abre tu eSIM en «Mis eSIM». En iOS 17.4 o posterior pulsa «Instalar con un toque». En versiones anteriores: Ajustes → Datos móviles → Añadir eSIM → Usar código QR.',
      'fr':
          'Connectez-vous au Wi-Fi et ouvrez votre eSIM dans « Mes eSIM ». Sur iOS 17.4 ou plus, touchez « Installer en un geste ». Sur les versions plus anciennes : Réglages → Données mobiles → Ajouter une eSIM → Utiliser un code QR.',
      'zh':
          '请先连接 Wi-Fi，在“我的 eSIM”中打开你的 eSIM。iOS 17.4 及以上可点击“一键安装”；较旧版本：设置 → 蜂窝网络 → 添加 eSIM → 使用二维码。',
    },
    'network': {
      'en':
          'Make sure the Waysim line is on, set it for cellular data and turn on Data Roaming for it. Restart the phone if there is still no network.',
      'ru':
          'Убедитесь, что линия Waysim включена, выбрана для сотовых данных и для неё включён роуминг данных. Если сети всё нет — перезагрузите телефон.',
      'es':
          'Comprueba que la línea Waysim esté activada, elegida para datos móviles y con itinerancia de datos. Si sigue sin red, reinicia el teléfono.',
      'fr':
          'Vérifiez que la ligne Waysim est activée, choisie pour les données mobiles et que l’itinérance des données est activée. Redémarrez le téléphone s’il n’y a toujours pas de réseau.',
      'zh': '请确认 Waysim 线路已开启，已选为蜂窝数据，并已打开该线路的数据漫游。若仍无网络，请重启手机。',
    },
    'choose': {
      'en':
          'Pick by trip length and how much you stream: 1–3 GB covers maps and messaging for a week; 5–10 GB suits a couple of weeks with some video; choose unlimited for heavy use.',
      'ru':
          'Выбирайте по длине поездки и тому, сколько вы смотрите видео: 1–3 ГБ хватит на карты и мессенджеры на неделю; 5–10 ГБ — на пару недель с видео; для активного использования берите безлимит.',
      'es':
          'Elige según la duración del viaje y cuánto vídeo veas: 1–3 GB bastan para mapas y mensajería una semana; 5–10 GB para un par de semanas con algo de vídeo; ilimitado para uso intensivo.',
      'fr':
          'Choisissez selon la durée du voyage et votre usage vidéo : 1 à 3 Go suffisent pour cartes et messagerie une semaine ; 5 à 10 Go pour deux semaines avec un peu de vidéo ; illimité pour un usage intensif.',
      'zh': '请根据行程天数和视频用量选择：1–3 GB 足够一周的地图和聊天；5–10 GB 适合两周并少量看视频；重度使用请选无限流量。',
    },
    'unknown': {
      'en':
          'I can help with choosing a plan, installing an eSIM and connecting abroad. For anything else, our team will reply by e-mail.',
      'ru':
          'Я помогу с выбором пакета, установкой eSIM и подключением за границей. По остальным вопросам вам ответит сотрудник по почте.',
      'es':
          'Puedo ayudarte a elegir un plan, instalar la eSIM y conectarte en el extranjero. Para cualquier otra cosa, nuestro equipo te responderá por correo.',
      'fr':
          'Je peux vous aider à choisir un forfait, installer l’eSIM et vous connecter à l’étranger. Pour le reste, notre équipe vous répondra par e-mail.',
      'zh': '我可以帮你选择套餐、安装 eSIM 以及在国外联网。其他问题将由我们的客服通过邮件回复。',
    },
  };
}
