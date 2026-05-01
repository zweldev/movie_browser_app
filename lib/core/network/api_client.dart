import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/constants.dart';
import 'network_exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['TMDB_READ_ACCESS_TOKEN']}',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['api_key'] = dotenv.env['TMDB_API_KEY']; //! TO CHECK
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<CustomResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio
          .get(
            path,
            queryParameters: queryParameters,
            options: headers != null ? Options(headers: headers) : null,
          )
          .timeout(const Duration(seconds: 30));

      final customResponse = CustomResponse(
        data: response.data,
        statusCode: response.statusCode ?? 500,
      );

      return _handleResponse(customResponse);
    } on TimeoutException catch (_) {
      throw ConnectionTimeoutException();
    } on SocketException catch (_) {
      throw NoInternetConnectionException();
    } on DioException catch (dioException) {
      if (dioException.type == DioExceptionType.connectionTimeout ||
          dioException.type == DioExceptionType.sendTimeout ||
          dioException.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else if (dioException.type == DioExceptionType.badResponse) {
        throw CustomException(
          dioException.message ?? 'Request failed',
          statusCode: dioException.response?.statusCode,
        );
      } else if (dioException.type == DioExceptionType.connectionError) {
        throw NoInternetConnectionException();
      } else {
        throw CustomException(
          dioException.message ?? 'Something went wrong',
          statusCode: dioException.response?.statusCode,
        );
      }
    } catch (_) {
      throw CustomException("An unexpected error occurred");
    }
  }

  CustomResponse _handleResponse(CustomResponse response) {
    if (response.statusCode.toString().startsWith('2')) {
      return response;
    } else if (response.statusCode == 500) {
      throw InternalServerErrorException();
    } else {
      throw CustomException(
        response.data.toString(),
        statusCode: response.statusCode,
      );
    }
  }
}
