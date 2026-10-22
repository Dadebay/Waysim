// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Waysim';

  @override
  String get tabHome => '首页';

  @override
  String get tabMyEsim => '我的 eSIM';

  @override
  String get tabProfile => '我的';

  @override
  String greetingNamed(String name) {
    return '你好，$name！';
  }

  @override
  String get greeting => '你好！';

  @override
  String get signIn => '登录';

  @override
  String get searchHint => '你需要在哪里使用 eSIM？';

  @override
  String get supportFabLabel => '客服';

  @override
  String get homeLocal => '单国';

  @override
  String get homeRegional => '区域';

  @override
  String priceFrom(String price) {
    return '起价 $price';
  }

  @override
  String get myEsimTitle => '我的 eSIM';

  @override
  String get myEsimCurrent => '使用中';

  @override
  String get myEsimArchive => '已归档';

  @override
  String get myEsimEmptyTitle => '还没有 eSIM';

  @override
  String get myEsimEmptyBody => '为你的旅行购买套餐，只需几分钟。';

  @override
  String get buyEsim => '获取 eSIM';

  @override
  String get howEsimWorks => 'eSIM 使用方法';

  @override
  String get profileTitle => '我的';

  @override
  String get profileGuestTitle => '登录后购买 eSIM';

  @override
  String get profileGuestBody => '购买记录、余额和 eSIM 都会保存在你的账户中。';

  @override
  String get signUp => '注册';

  @override
  String get settings => '设置';

  @override
  String get more => '更多';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsTheme => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get actionRetry => '重试';

  @override
  String get offlineBanner => '无网络连接';

  @override
  String get errorNetwork => '无法连接到互联网，请检查网络后重试。';

  @override
  String get errorTimeout => '请求超时，请重试。';

  @override
  String get errorServer => '我们这边出了点问题，请稍后再试。';

  @override
  String get errorUnauthorized => '登录已过期，请重新登录。';

  @override
  String get signedOutOnDevice => '此设备上的账号已退出。请重新登录。';

  @override
  String get errorNotFound => '未找到你要查找的内容。';

  @override
  String get errorUnknown => '出错了，请重试。';

  @override
  String get comingSoon => '即将推出';

  @override
  String get actionCopy => '复制';

  @override
  String get toastCopied => '已复制';

  @override
  String get actionContinue => '继续';

  @override
  String get actionCancel => '取消';

  @override
  String get actionClose => '关闭';

  @override
  String get actionGotIt => '知道了';

  @override
  String get actionLater => '稍后';

  @override
  String get actionPasteCode => '粘贴验证码';

  @override
  String get settingsGallery => '设计图库（调试）';

  @override
  String unitGb(String value) {
    return '$value GB';
  }

  @override
  String unitMb(String value) {
    return '$value MB';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
    );
    return '$_temp0';
  }

  @override
  String get dataUnlimited => '无限流量';

  @override
  String dailyAllowance(String size) {
    return '每天 $size';
  }

  @override
  String unlimitedPlan(String daily, String days) {
    return '无限流量 · $daily · $days';
  }

  @override
  String regionCountries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个国家/地区',
    );
    return '$_temp0';
  }

  @override
  String get bannerEsimTitle => '什么是 eSIM？';

  @override
  String get bannerEsimBody => '数字 SIM 卡：几分钟即可设置，无需实体卡';

  @override
  String get bannerEsimAction => '使用方法 →';

  @override
  String bannerInviteTitle(String reward) {
    return '邀请好友，获得 $reward';
  }

  @override
  String get bannerInviteAction => '去邀请 →';

  @override
  String get bannerTravelTitle => '每次旅行都在线';

  @override
  String get bannerTravelBody => '热门目的地的本地套餐';

  @override
  String get bannerTravelAction => '查看国家 →';

  @override
  String get catalogEmpty => '暂无目的地';

  @override
  String get searchRecent => '最近搜索';

  @override
  String get searchClear => '清除';

  @override
  String get searchCountries => '国家/地区';

  @override
  String get searchRegions => '区域';

  @override
  String searchNoResults(String query) {
    return '未找到“$query”';
  }

  @override
  String get searchNoResultsHint => '试试国家名称或代码，例如“土耳其”或“US”。';

  @override
  String get searchBack => '返回';

  @override
  String get compatLabel => '设备支持 eSIM：';

  @override
  String get compatYes => '是';

  @override
  String get compatNo => '否';

  @override
  String get compatUnknown => '未知';

  @override
  String get compatHowToCheck => '如何检查';

  @override
  String get compatSheetTitle => '我的手机支持 eSIM 吗？';

  @override
  String get compatSheetIos =>
      'iPhone XS、XR 及更新机型支持 eSIM。请在 设置 → 通用 → 关于本机 中查看是否有“数字 SIM 卡”或 EID 号码。手机还必须未锁定运营商。';

  @override
  String get compatSheetAndroid =>
      '打开拨号盘并输入 *#06#。如果显示 EID 号码，说明你的手机支持 eSIM。也可在 设置 → 连接 → SIM 卡管理 中查看。手机必须未锁定运营商。';

  @override
  String get compatWarningTitle => '你的手机可能不支持 eSIM';

  @override
  String get compatWarningBody => '你仍可购买此套餐，但在不支持 eSIM 的手机上无法使用。仍要继续吗？';

  @override
  String get actionContinueAnyway => '仍然继续';

  @override
  String get packagesUnlimited => '无限流量';

  @override
  String get packagesLimited => '限量流量';

  @override
  String get packagesChoose => '选择套餐';

  @override
  String get packagesEmpty => '此类别暂无套餐';

  @override
  String get packageDetailsLink => '套餐详情';

  @override
  String buyFor(String price) {
    return '$price 购买';
  }

  @override
  String get purchaseDisclaimer => '下单即表示你确认设备支持 eSIM 且未锁定运营商。';

  @override
  String get oneTimePurchase => '一次性购买，无订阅，不自动续费。';

  @override
  String get detailCoverage => '覆盖范围';

  @override
  String get detailData => '流量';

  @override
  String detailDataFull(String size) {
    return '$size 全速流量';
  }

  @override
  String detailDataUnlimited(String size) {
    return '无限流量，每天 $size 全速';
  }

  @override
  String get detailValidity => '有效期';

  @override
  String get detailValidityNote => '自 eSIM 首次连接到目的地网络时开始计算';

  @override
  String get detailNetwork => '网络';

  @override
  String get detailHotspot => '热点共享';

  @override
  String get detailTopUp => '续充';

  @override
  String get detailCalls => '通话和短信';

  @override
  String get detailInstall => '安装';

  @override
  String get detailAvailable => '支持';

  @override
  String get detailUnavailable => '不支持';

  @override
  String get detailDataOnly => '仅数据';

  @override
  String get detailCallsIncluded => '包含';

  @override
  String detailInstallWithin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天内',
    );
    return '$_temp0';
  }

  @override
  String get coverageCountries => '覆盖国家/地区';

  @override
  String get confirmTitle => '确认购买';

  @override
  String get confirmPrice => '价格';

  @override
  String get confirmBalanceNow => '当前余额';

  @override
  String get confirmBalanceAfter => '购买后余额';

  @override
  String get confirmConsent => '我要求立即开通 eSIM，并了解安装后无法取消购买。一次性购买，无订阅，不自动续费。';

  @override
  String confirmPay(String price) {
    return '支付 $price';
  }

  @override
  String get insufficientTitle => '余额不足';

  @override
  String insufficientBody(String missing) {
    return '购买此套餐还差 $missing。';
  }

  @override
  String insufficientAction(String amount) {
    return '充值 $amount';
  }

  @override
  String get orderPreparing => '正在开通你的 eSIM…';

  @override
  String get orderPreparingHint => '通常只需几秒钟。';

  @override
  String get orderSlow => '耗时比平时长。eSIM 准备好后我们会通知你。';

  @override
  String get orderFailedTitle => '无法完成订单';

  @override
  String get orderFailedBody => '如已扣款，款项已退回你的余额。';

  @override
  String orderPriceChanged(String price) {
    return '价格已变为 $price，请确认后重试。';
  }

  @override
  String get orderBackToPlans => '返回套餐';

  @override
  String get actionGoToMyEsim => '前往“我的 eSIM”';

  @override
  String get esimReadyTitle => 'eSIM 已准备好！';

  @override
  String get esimReadyBody => '趁有 Wi-Fi 现在就安装。套餐天数仅在你到达目的地并联网后才开始计算。';

  @override
  String get esimInstall => '安装 eSIM';

  @override
  String get maintenanceBanner => '购买和充值暂时停用。';

  @override
  String get errorMaintenance => '购买暂时停用，请稍后再试。';

  @override
  String get errorPackageUnavailable => '此套餐已不可用。';

  @override
  String get errorOrderFailed => '无法完成订单。如已扣款，款项已退回你的余额。';

  @override
  String get errorTooManyRequests => '请求过多，请稍候。';

  @override
  String get errorBoundToOtherDevice => '此 eSIM 已绑定到其他设备。';

  @override
  String get agoJustNow => '刚刚';

  @override
  String agoMinutes(int count) {
    return '$count 分钟前';
  }

  @override
  String agoHours(int count) {
    return '$count 小时前';
  }

  @override
  String agoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天前',
    );
    return '$_temp0';
  }

  @override
  String get balanceLabel => '余额';

  @override
  String get statusProvisioning => '处理中';

  @override
  String get statusNotInstalled => '未安装';

  @override
  String get statusInstalled => '已安装';

  @override
  String get statusActive => '使用中';

  @override
  String get statusUsedUp => '已用完';

  @override
  String get statusExpired => '已过期';

  @override
  String get statusFailedRefunded => '未完成，已退款';

  @override
  String get myEsimArchiveEmpty => '归档为空';

  @override
  String esimLeftOf(String left, String total) {
    return '共 $total，剩余 $left';
  }

  @override
  String esimDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '剩余 $count 天',
    );
    return '$_temp0';
  }

  @override
  String esimInstallBy(String date) {
    return '请在 $date 前安装';
  }

  @override
  String get esimValidityFromFirst => '自首次联网起计算有效期';

  @override
  String esimDeviceUpdated(String device, String ago) {
    return '$device · $ago更新';
  }

  @override
  String esimUpdated(String ago) {
    return '$ago更新';
  }

  @override
  String esimRegionTitle(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个国家/地区',
    );
    return '$name（$_temp0）';
  }

  @override
  String esimPackageLine(String volume, String duration) {
    return '$volume · $duration';
  }

  @override
  String get actionInstall => '安装';

  @override
  String get howTitle => 'eSIM 使用方法';

  @override
  String get howStep1Title => '选择套餐';

  @override
  String get howStep1Body => '找到你的目的地，选择所需流量和天数。';

  @override
  String get howStep2Title => '用余额支付';

  @override
  String get howStep2Body => '通过 PayPal 或加密货币充值余额，一键购买套餐。';

  @override
  String get howStep3Title => '出发前安装';

  @override
  String get howStep3Body => '趁有 Wi-Fi 时扫描二维码或一键安装，之后请勿删除 eSIM。';

  @override
  String get howStep4Title => '到达后开启';

  @override
  String get howStep4Body => '将 Waysim eSIM 选为移动数据，并为其开启数据漫游。';

  @override
  String get esimDetailTitle => 'eSIM 信息';

  @override
  String get installOneTap => '一键安装';

  @override
  String installOneTapNote(String date) {
    return '适用于 iOS 17.4 及以上的 iPhone · 请在 $date 前安装';
  }

  @override
  String get installByQr => '二维码安装';

  @override
  String get installQrNote => '用你出行时使用的手机摄像头扫描二维码：可在另一台设备上打开此页面或打印二维码。';

  @override
  String get installManual => '手动安装';

  @override
  String get esimSmdp => 'SM-DP+ 地址';

  @override
  String get esimActivationCode => '激活码';

  @override
  String get esimIccid => 'ICCID';

  @override
  String get esimKeepWarning => '套餐有效期间请勿从手机中删除 eSIM，只能在同一部手机上重新安装。';

  @override
  String get esimRoamingWarning => '为避免产生本国运营商的漫游费用，请关闭主 SIM 卡的数据漫游。';

  @override
  String get instructionsTitle => '安装步骤';

  @override
  String get tabIphone => 'iPhone';

  @override
  String get tabAndroid => 'Android';

  @override
  String get iosStep1 => '连接 Wi-Fi。';

  @override
  String get iosStep2 => '打开 设置 → 蜂窝网络 → 添加 eSIM。';

  @override
  String get iosStep3 => '选择“使用二维码”或“手动输入详细信息”。';

  @override
  String get iosStep4 => '将该线路命名为“Waysim”，主号码保留用于通话和 iMessage。';

  @override
  String get iosStep5 => '到达后开启 Waysim 线路和“数据漫游”，并将其选为蜂窝数据。';

  @override
  String get androidStep1 => '连接 Wi-Fi。';

  @override
  String get androidStep2 => '打开 设置 → 网络和互联网 → SIM 卡 → 添加 eSIM（不同手机名称略有差异）。';

  @override
  String get androidStep3 => '选择“扫描二维码”或手动输入信息。';

  @override
  String get androidStep4 => '将该线路命名为“Waysim”，主 SIM 卡保留用于通话。';

  @override
  String get androidStep5 => '到达后开启 Waysim 线路和数据漫游，并将其用于移动数据。';

  @override
  String get usageTitle => '流量使用';

  @override
  String get usageUnlimitedNote => '无限流量套餐，用量以运营商显示为准';

  @override
  String get topUpPackage => '续充套餐';

  @override
  String get topUpPlansTitle => '追加流量';

  @override
  String get topUpPlansSubtitle => '选择要追加到此 eSIM 的套餐';

  @override
  String get topUpPlansEmpty => '此 eSIM 暂无可追加的套餐。';

  @override
  String get topUpAddedTitle => '套餐已追加';

  @override
  String get topUpAddedBody => '新增的流量和天数已加到你的 eSIM。';

  @override
  String get loginTitle => '登录或注册';

  @override
  String get loginBody => '我们会向你的邮箱发送 6 位验证码，无需密码。';

  @override
  String get emailLabel => '电子邮箱';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get demoAccounts => '测试账号';

  @override
  String get demoNewAccount => '新账号';

  @override
  String get demoExistingAccount => '有历史记录的账号';

  @override
  String demoCodeHint(String code) {
    return '测试验证码：$code（不会发送邮件）';
  }

  @override
  String get inviteLabel => '邀请码（选填）';

  @override
  String get termsConsent => '我已年满 18 周岁并接受使用条款。数据处理方式见隐私政策。';

  @override
  String get termsConsentStart => '我已年满 18 周岁并接受';

  @override
  String get termsOfUseLink => '使用条款';

  @override
  String get termsConsentMiddle => '。数据处理方式见';

  @override
  String get privacyPolicyLink => '隐私政策';

  @override
  String get termsConsentEnd => '。';

  @override
  String get loginErrorEmail => '请输入有效的邮箱地址';

  @override
  String get loginErrorTerms => '请先接受条款以继续';

  @override
  String get codeTitle => '输入验证码';

  @override
  String get codeInstructions => '输入 6 位验证码以继续。';

  @override
  String codeBody(String email) {
    return '我们已向 $email 发送 6 位验证码';
  }

  @override
  String get codeLabel => '邮件中的验证码';

  @override
  String resendIn(String time) {
    return '$time 后可重新发送';
  }

  @override
  String get resendNow => '重新发送';

  @override
  String get changeEmail => '更改邮箱';

  @override
  String get checkSpam => '没收到邮件？请检查垃圾邮件文件夹。';

  @override
  String get codeErrorWrong => '验证码错误，请重试。';

  @override
  String get codeErrorExpired => '验证码已过期，请重新获取。';

  @override
  String get codeErrorTooMany => '尝试次数过多，请稍后再试。';

  @override
  String get nameTitle => '我们该怎么称呼你？';

  @override
  String get nameBody => '选填，用于问候你。';

  @override
  String get nameHint => '你的名字';

  @override
  String get actionSkip => '跳过';

  @override
  String profileId(String id) {
    return 'ID $id';
  }

  @override
  String get actionTopUp => '充值';

  @override
  String get orders => '订单';

  @override
  String get inviteFriends => '邀请好友';

  @override
  String get myDevices => '我的设备';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get signOut => '退出登录';

  @override
  String get signOutConfirmTitle => '退出登录？';

  @override
  String get signOutConfirmBody => '确定要退出当前账户吗？';

  @override
  String get settingsNotifications => '通知';

  @override
  String get notifEsimTitle => '通知';

  @override
  String get notifEsimBody => 'eSIM 状态、余额和流量使用';

  @override
  String get notifNewsTitle => '新闻和优惠';

  @override
  String get notifNewsBody => '折扣和新增国家';

  @override
  String aboutVersion(String version, String build) {
    return '版本 $version（$build）';
  }

  @override
  String get aboutTagline => '旅行移动网络';

  @override
  String get aboutApp => '关于应用';

  @override
  String get devicesTitle => '我的设备';

  @override
  String get devicesNote => '管理已登录您账户的设备。';

  @override
  String get deviceRemove => '移除设备';

  @override
  String get deviceRemoveTitle => '移除此设备？';

  @override
  String deviceRemoveBody(String device) {
    return '要在 $device 上退出 Waysim 吗？您可以在该设备上重新登录。';
  }

  @override
  String get deviceRemoved => '设备已移除。';

  @override
  String get deviceThis => '当前设备';

  @override
  String deviceLastSeen(String ago) {
    return '最近活动：$ago';
  }

  @override
  String get deleteTitle => '删除账户';

  @override
  String get deleteWarnTitle => '此操作无法撤销';

  @override
  String deleteBullet1(String balance) {
    return '你的余额（$balance）和奖励将被清零。';
  }

  @override
  String get deleteBullet2 => '尚未安装的套餐将被取消且不予退款。';

  @override
  String get deleteBullet3 => '已安装的 eSIM 在套餐到期前仍可使用。';

  @override
  String get deleteBullet4 => '个人数据将在 30 天内匿名化。支付记录将按法律要求的期限保留。';

  @override
  String get deleteRefundNote => '想退回未使用的充值？请在删除前联系客服。';

  @override
  String get deleteSupportLink => '联系客服';

  @override
  String deleteCodeBody(String email) {
    return '请输入发送到 $email 的 6 位验证码以确认。';
  }

  @override
  String get deleteConfirm => '删除我的账户';

  @override
  String get deleteDone => '账户已删除';

  @override
  String get topUpTitle => '充值余额';

  @override
  String get topUpCurrentBalance => '当前余额';

  @override
  String get topUpChooseAmount => '选择金额';

  @override
  String get topUpOtherAmount => '其他金额';

  @override
  String get topUpAmountHint => '美元金额';

  @override
  String topUpAmountRange(String min, String max) {
    return '$min 至 $max';
  }

  @override
  String topUpAmountInvalid(String min, String max) {
    return '请输入 $min 至 $max 之间的金额';
  }

  @override
  String get topUpMethod => '支付方式';

  @override
  String get topUpPaypalTitle => 'PayPal';

  @override
  String get topUpPaypalBody => 'PayPal 余额或通过 PayPal 使用银行卡';

  @override
  String get topUpCryptoTitle => '加密货币';

  @override
  String get topUpCryptoBody => '选择币种和网络';

  @override
  String get topUpNote => '余额仅可用于购买 eSIM 套餐，不可提现。未使用的充值可按退款政策退还。支付服务商可能收取手续费。';

  @override
  String topUpButton(String amount) {
    return '充值 $amount';
  }

  @override
  String get topUpPaypalWaitingTitle => '等待 PayPal 确认';

  @override
  String get topUpPaypalWaitingBody => '请在 PayPal 窗口中完成支付，此页面会自动更新。';

  @override
  String get topUpReopenPaypal => '重新打开 PayPal';

  @override
  String get cryptoTitle => '加密货币支付';

  @override
  String get cryptoCoin => '币种';

  @override
  String get cryptoNetwork => '网络';

  @override
  String get cryptoWaitingPayment => '等待付款';

  @override
  String get cryptoStepWaiting => '等待';

  @override
  String get cryptoStepConfirmations => '确认数';

  @override
  String get cryptoStepCredited => '已到账';

  @override
  String cryptoConfirmationsOf(int n, int m) {
    return '$n/$m';
  }

  @override
  String get cryptoSendExactly => '请准确转账';

  @override
  String get cryptoToAddress => '收款地址';

  @override
  String cryptoRateLocked(String rate, String amount) {
    return '汇率已锁定：$rate · 充值 $amount';
  }

  @override
  String cryptoWarning(String coin, String network) {
    return '仅发送 $network 网络上的 $coin，一次性转入准确金额。钱包手续费另计，我们必须收到全额。';
  }

  @override
  String get cryptoCloseNote => '可以关闭此页面，付款到账后我们会通知你。';

  @override
  String get cryptoChangeAmountAction => '更改金额';

  @override
  String get cryptoChangeAmountTitle => '选择其他金额？';

  @override
  String get cryptoChangeAmountBody =>
      '当前付款请求在倒计时结束前仍然有效。如果你已转出加密货币，请等待这笔付款处理完成；否则可以选择其他金额并创建新的付款请求。';

  @override
  String get cryptoChangeCurrencyTitle => '更换币种或网络？';

  @override
  String get cryptoChangeCurrencyBody =>
      '更换币种或网络需要新的付款地址。当前付款请求在到期前仍然有效。如果你已转出加密货币，请等待这笔付款处理完成。';

  @override
  String get cryptoChangeCurrencyAction => '创建新付款';

  @override
  String cryptoExpiresIn(String time) {
    return '$time 后过期';
  }

  @override
  String get topUpDoneTitle => '余额已充值';

  @override
  String topUpDoneBody(String amount) {
    return '$amount 已加入你的余额。';
  }

  @override
  String get actionDone => '完成';

  @override
  String get topUpExpiredTitle => '支付已过期';

  @override
  String get topUpExpiredBody => '如果你已转账，款项将在核查后到账；否则请重新开始。';

  @override
  String get actionTryAgain => '重试';

  @override
  String get ordersTitle => '订单';

  @override
  String get ordersTabPurchases => '购买';

  @override
  String get ordersTabTopUps => '充值';

  @override
  String get ordersTabActivity => '明细';

  @override
  String get ordersEmptyPurchases => '暂无购买记录';

  @override
  String get ordersEmptyTopUps => '暂无充值记录';

  @override
  String get ordersEmptyActivity => '暂无余额变动记录';

  @override
  String orderNumberDate(String number, String date) {
    return '订单 $number · $date';
  }

  @override
  String get orderCompleted => '已完成';

  @override
  String orderPurchaseTitle(String place, String plan) {
    return '$place · $plan';
  }

  @override
  String orderAddOnTitle(String place, String plan) {
    return '套餐追加 · $place +$plan';
  }

  @override
  String get orderTopUpPaypal => '余额充值 · PayPal';

  @override
  String get orderTopUpCrypto => '余额充值 · 加密货币';

  @override
  String get referralTitle => '邀请好友';

  @override
  String referralHeroTitle(String reward) {
    return '每邀请一位好友可得 $reward';
  }

  @override
  String referralHeroBody(String reward) {
    return '好友使用你的邀请码注册后，你的余额将增加 $reward。';
  }

  @override
  String get referralYourCode => '你的邀请码';

  @override
  String get referralShare => '分享邀请';

  @override
  String referralShareText(String code) {
    return '准备出行？看看 Waysim 的 eSIM 套餐。注册时使用我的邀请码：\n$code';
  }

  @override
  String referralShareLinkText(String link, String code) {
    return '准备出行？看看 Waysim 的 eSIM 套餐。通过我的邀请链接注册：\n$link\n\n邀请码：$code';
  }

  @override
  String get referralStatInvited => '已邀请';

  @override
  String get referralStatCredited => '已到账';

  @override
  String get referralStatPending => '审核中';

  @override
  String get referralStatRejected => '已拒绝';

  @override
  String get referralRulesTitle => '规则';

  @override
  String get referralRule1 => '奖励仅可用于购买 eSIM 套餐，不可提现。';

  @override
  String get referralRule2 => '仅限 Waysim 新用户，每台设备只计一次奖励。';

  @override
  String get referralRule3 => '每月最多 10 次奖励。';

  @override
  String get referralRule4 => '邀请会被自动审核，自我邀请和虚假账户将被拒绝。';

  @override
  String get referralRule5 => '奖励金额在好友注册时确定。';

  @override
  String get referralFullTerms => '完整条款';

  @override
  String get referralYourInvites => '你的邀请';

  @override
  String referralInviteCredited(String reward) {
    return '已到账 +$reward';
  }

  @override
  String referralInviteSignedUp(String date) {
    return '注册：$date';
  }

  @override
  String get referralEmpty => '暂无邀请';

  @override
  String get supportSheetTitle => '需要什么帮助？';

  @override
  String get supportAiTitle => '在线 AI 聊天';

  @override
  String get supportAiBody => '全天候即时回复';

  @override
  String get supportMailTitle => '给我们写信';

  @override
  String get supportMailBody => '客服人员将通过邮件回复';

  @override
  String supportMailSubject(String id) {
    return 'Waysim — 咨询，ID $id';
  }

  @override
  String supportMailTemplate(String id, String app, String system) {
    return '请在此描述你的问题。\n\n— 技术信息 —\nID：$id\n应用：$app\n系统：$system';
  }

  @override
  String supportMailFallback(String email) {
    return '未找到邮件应用。我们的邮箱：$email。';
  }

  @override
  String get actionCopyAddress => '复制邮箱地址';

  @override
  String get chatTitle => 'Waysim 助手';

  @override
  String get chatBadge => '由 AI 回复';

  @override
  String get chatDisclaimer => 'AI 可能出错。它看不到你的付款，也不会修改余额。请勿发送密码或银行卡信息。';

  @override
  String get chatGreeting => '你好！我是 Waysim 的 AI 助手。你可以问我如何选择套餐、安装 eSIM 或在国外联网。';

  @override
  String get chatChipInstall => '如何安装 eSIM？';

  @override
  String get chatChipChoose => '该选哪个套餐？';

  @override
  String get chatChipNetwork => '我的 eSIM 无法联网';

  @override
  String get chatNotHelped => '没解决问题？';

  @override
  String get chatContactHuman => '联系客服';

  @override
  String get chatInputHint => '输入消息';

  @override
  String get chatHistoryNote => '聊天记录保存 30 天';

  @override
  String get legalSectionTitle => '文件';

  @override
  String get updateRequiredTitle => '请更新应用';

  @override
  String get updateRequiredBody => '此版本已不再支持。请更新 Waysim 以继续购买和使用 eSIM。';

  @override
  String get updateRequiredAction => '更新';

  @override
  String get integrityWarningTitle => '此设备无法获得邀请奖励';

  @override
  String get integrityWarningBody => '你的手机似乎被修改过（root、越狱或模拟器）。其他功能不受影响。';

  @override
  String get noConnectionTitle => '当前无网络';

  @override
  String get noConnectionBody =>
      'Waysim 需要联网才能加载套餐和你的 eSIM。请检查 Wi‑Fi 或移动数据后重试。';

  @override
  String get noConnectionWaiting => '正在等待网络连接…';

  @override
  String get noConnectionContinue => '离线继续';

  @override
  String get statusSuspended => '已暂停';

  @override
  String get statusCancelled => '已取消';

  @override
  String get statusRevoked => '已撤销';

  @override
  String get statusFailed => '失败';

  @override
  String get paymentReview => '付款审核中';

  @override
  String get paymentPending => '处理中';

  @override
  String get paymentMemo => '备注 / 目标标签';

  @override
  String get supportTeam => '客服团队';

  @override
  String get supportLiveDisclaimer => '您的消息将发送给 Waysim 客服团队。';

  @override
  String get supportLiveGreeting => '请发送您有关 Waysim 或 eSIM 的问题。';

  @override
  String get inviteCodeInvalid => '邀请码无效，请检查后重试。';

  @override
  String get paymentFailed => '付款未完成';

  @override
  String get paymentFailedBody => '付款未完成。如果您已转账，请联系客服。';

  @override
  String get activationOnInstall => '有效期从安装 eSIM 时开始。';
}
