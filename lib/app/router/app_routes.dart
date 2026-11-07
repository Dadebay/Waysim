enum AppRoute {
  home('/home'),
  myEsim('/my-esim'),
  profile('/profile'),
  search('/search'),
  destination('/destination/:code'),
  purchase('/purchase'),
  esim('/esim/:id'),
  esimTopUp('/esim/:id/top-up'),
  login('/login'),
  balanceTopUp('/balance/top-up'),
  orders('/orders'),
  orderDetail('/orders/:id'),
  paymentDetail('/payments/:id'),
  activityDetail('/activity/:id'),
  referral('/referral'),
  devices('/devices'),
  deleteAccount('/delete-account'),
  settings('/settings'),
  legal('/legal'),
  legalDocument('/legal/:id'),
  supportChat('/support/chat'),
  invite('/r/:code'),
  payReturn('/pay/return'),
  gallery('/gallery');

  const AppRoute(this.path);

  final String path;

  String get routeName => name;

  String withParams(Map<String, String> params) {
    var result = path;
    params.forEach(
      (key, value) =>
          result = result.replaceAll(':$key', Uri.encodeComponent(value)),
    );
    return result;
  }
}
