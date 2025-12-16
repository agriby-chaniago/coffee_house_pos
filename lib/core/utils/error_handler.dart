import 'package:appwrite/appwrite.dart';

class ErrorHandler {
  /// Convert technical errors into user-friendly messages
  static String getUserFriendlyMessage(Object error) {
    // Handle AppwriteException with specific codes
    if (error is AppwriteException) {
      switch (error.code) {
        case 401:
          return 'Your session has expired. Please login again.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'The requested item was not found.';
        case 409:
          return 'This item already exists. Please use a different value.';
        case 429:
          return 'Too many requests. Please wait a moment and try again.';
        case 500:
          return 'Server error. Please try again later.';
        case 503:
          return 'Service temporarily unavailable. Please try again later.';
        default:
          // Try to extract meaningful message from AppwriteException
          if (error.message != null && error.message!.isNotEmpty) {
            // Clean up technical jargon
            final message = error.message!;
            if (message.contains('network') || message.contains('connection')) {
              return 'Network error. Please check your internet connection.';
            }
            if (message.contains('timeout')) {
              return 'Request timed out. Please try again.';
            }
            // Return cleaned message
            return _cleanErrorMessage(message);
          }
          return 'An error occurred. Please try again.';
      }
    }

    // Handle common Dart exceptions
    if (error is FormatException) {
      return 'Invalid data format. Please check your input.';
    }

    if (error is TypeError) {
      return 'Data type error. Please try again or contact support.';
    }

    // Handle network/connection errors
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return 'Network error. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('permission')) {
      return 'Permission denied. Please contact your administrator.';
    }

    if (errorString.contains('not found')) {
      return 'Item not found. It may have been deleted.';
    }

    // Handle custom Exception messages (from our code)
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        // Our custom exceptions - return as is (already user-friendly)
        return message.substring(11); // Remove "Exception: " prefix
      }
    }

    // Default fallback
    return 'Something went wrong. Please try again.';
  }

  /// Clean technical error messages
  static String _cleanErrorMessage(String message) {
    // Remove common technical prefixes
    message = message
        .replaceAll('AppwriteException: ', '')
        .replaceAll('Exception: ', '')
        .replaceAll('Error: ', '');

    // Capitalize first letter
    if (message.isNotEmpty) {
      message = message[0].toUpperCase() + message.substring(1);
    }

    // Ensure it ends with a period
    if (message.isNotEmpty &&
        !message.endsWith('.') &&
        !message.endsWith('!')) {
      message += '.';
    }

    return message;
  }

  /// Get a user-friendly message with a fallback
  static String getUserFriendlyMessageWithFallback(
    Object error,
    String fallback,
  ) {
    try {
      return getUserFriendlyMessage(error);
    } catch (_) {
      return fallback;
    }
  }
}
