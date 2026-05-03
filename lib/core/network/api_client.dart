import 'dart:async';
import 'dart:developer';
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
    } on TimeoutException {
      throw ConnectionTimeoutException();
    } on SocketException {
      throw NoInternetConnectionException();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e, stackTrace) {
      log('Unexpected error: $e', stackTrace: stackTrace);
      throw CustomException("An unexpected error occurred");
    }
  }

  CustomResponse _handleResponse(CustomResponse response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      return response;
    }

    throw _mapStatusCodeToException(statusCode, response.data);
  }

  Exception _mapStatusCodeToException(int statusCode, dynamic data) {
    switch (statusCode) {
      case 400:
        return BadRequestException();

      case 401:
        return UnauthorizedException();

      case 403:
        return ForbiddenException();

      case 404:
        return NotFoundException();

      case 408:
        return ConnectionTimeoutException();

      case 429:
        return TooManyRequestsException();

      case 500:
      case 502:
      case 503:
      case 504:
        return InternalServerErrorException();

      default:
        return CustomException(
          "Unexpected error occurred",
          statusCode: statusCode,
        );
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConnectionTimeoutException();

      case DioExceptionType.connectionError:
        return NoInternetConnectionException();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        return _mapStatusCodeToException(
          statusCode,
          e.response?.data,
        );

      case DioExceptionType.cancel:
        return CustomException("Request was cancelled");

      case DioExceptionType.unknown:
      default:
        return CustomException(
          e.message ?? "Something went wrong",
          statusCode: e.response?.statusCode,
        );
    }
  }
}
