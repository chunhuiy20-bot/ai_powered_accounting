// 基于Dio进行二次封装
import 'package:dio/dio.dart';
import 'package:my_first_app/constants/index.dart';
import 'package:my_first_app/stores/TokenManager.dart';

class DioRequest {
  final _dio = Dio(); // dio请求对象
  // 基础地址拦截器
  DioRequest() {
    _dio.options
      ..baseUrl = GlobalConstants.BASE_URL
      ..connectTimeout = Duration(seconds: GlobalConstants.TIME_OUT)
      ..sendTimeout = Duration(seconds: GlobalConstants.TIME_OUT)
      ..receiveTimeout = Duration(seconds: GlobalConstants.TIME_OUT);
    // 拦截器
    _addInterceptor();
  }
  // 添加拦截器
  void _addInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          // 注入token request headers Authorization = "Bearer token"
          if (tokenManager.getToken().isNotEmpty) {
            request.headers = {
              "Authorization": "Bearer ${tokenManager.getToken()}",
            };
          }

          handler.next(request);
        },
        onResponse: (response, handler) {
          // http状态码 200 300
          if (response.statusCode! >= 200 && response.statusCode! < 300) {
            handler.next(response);
            return;
          }

          handler.reject(DioException(requestOptions: response.requestOptions));
        },
        onError: (error, handler) {
          // handler.reject(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              message: error.response?.data["msg"] ?? " ",
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> get(String url, {Map<String, dynamic>? params}) {
    return _handleResponse(_dio.get(url, queryParameters: params));
  }

  // 定义post接口
  Future<dynamic> post(String url, {Map<String, dynamic>? data}) {
    return _handleResponse(_dio.post(url, data: data));
  }

  // 进一步处理返回结果的函数
  Future<dynamic> _handleResponse(Future<Response<dynamic>> task) async {
    try {
      Response<dynamic> res = await task;
      final data = res.data as Map<String, dynamic>; // data才是我们真实的接口返回的数据
      if (data["code"] == GlobalConstants.SUCCESS_CODE) {
        // 才认定 http状态和业务状态均正常 就可以正常的放行通过
        return data["result"]; // 只要result结果
      }
      // 抛出异常
      // throw Exception(data["msg"] ?? "加载数据异常");
      throw DioException(
        requestOptions: res.requestOptions,
        message: data["msg"] ?? "加载数据失败",
      );
    } catch (e) {
      // throw Exception(e);
      rethrow; // 不改变原来抛出的异常类型
    }
  }
}

// 单例对象
final dioRequest = DioRequest(); // 单例对象

// dio请求工具发出请求 返回的数据 Response<dynamic>.data
// 把所有的接口的data解放出来 拿到真正的数据 要判断业务状态码是不是等于1
