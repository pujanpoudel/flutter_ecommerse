// ignore_for_file: constant_identifier_names

class AppConstants {
  static const String APP_NAME = "Quick Cart";
  static const int APP_VERSION = 1;

  static const String BASE_URL = "http://192.168.1.113:9000/accounts";

  static const String BASE_URL_PRODUCT =
      "https://jykimvw5nj.execute-api.ap-south-1.amazonaws.com/uat";

  //user and auth endpoints
  static const String SIGNUP_URL = "/signup";
  static const String LOGIN_URL = "/login";
  static const String LOGIN_TOKEN = "/access/token/new";

  //orders
  static const String PLACE_ORDER_URL = "/api/v1/customer/order/place";
  static const String ORDER_LIST_URL = "/api/v1/customer/order/list";

  static const String TOKEN = "";
  static const String CART_LIST = "/cart-list";
  static const String CART_HISTORY_LIST = "/cart-history-list";

  static const String Esewa_Client_Id =
      "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R";
  static const String Esewa_Secret_key =
      "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==";
}
