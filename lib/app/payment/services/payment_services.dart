// services/payment_service.dart
import '../models/payment_models.dart';

class PaymentService {
  // Simulate API call - replace with actual API implementation
  Future<List<PaymentTransaction>> getAllTransactions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data with Indian delivery companies and realistic earnings
    return [
      PaymentTransaction(
        companyName: 'Swiggy',
        deliveryAddress: 'Connaught Place, New Delhi',
        status: PaymentStatus.paid,
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        amount: 280.00, // ₹280 for 4 orders average
      ),
      PaymentTransaction(
        companyName: 'Zomato',
        deliveryAddress: 'Koramangala, Bangalore',
        status: PaymentStatus.processing,
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
        amount: 420.00, // ₹420 for 6 orders
      ),
      PaymentTransaction(
        companyName: 'Dunzo',
        deliveryAddress: 'Bandra West, Mumbai',
        status: PaymentStatus.pending,
        dateTime: DateTime.now().subtract(const Duration(days: 7)),
        amount: 350.00, // ₹350 for grocery deliveries
      ),
      PaymentTransaction(
        companyName: 'BigBasket',
        deliveryAddress: 'Hinjewadi, Pune',
        status: PaymentStatus.paid,
        dateTime: DateTime.now().subtract(const Duration(days: 10)),
        amount: 520.00, // ₹520 for grocery slot
      ),
      PaymentTransaction(
        companyName: 'Swiggy',
        deliveryAddress: 'Sector 29, Gurgaon',
        status: PaymentStatus.paid,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        amount: 315.00, // ₹315 for 5 orders
      ),
      PaymentTransaction(
        companyName: 'Zomato',
        deliveryAddress: 'Salt Lake, Kolkata',
        status: PaymentStatus.pending,
        dateTime: DateTime.now().subtract(const Duration(days: 3)),
        amount: 245.00, // ₹245 for 3 orders
      ),
      PaymentTransaction(
        companyName: 'Blinkit',
        deliveryAddress: 'Jayanagar, Bangalore',
        status: PaymentStatus.processing,
        dateTime: DateTime.now().subtract(const Duration(days: 15)),
        amount: 380.00, // ₹380 for quick commerce
      ),
      PaymentTransaction(
        companyName: 'Zepto',
        deliveryAddress: 'Powai, Mumbai',
        status: PaymentStatus.paid,
        dateTime: DateTime.now().subtract(const Duration(days: 20)),
        amount: 295.00, // ₹295 for instant delivery
      ),
      PaymentTransaction(
        companyName: 'Swiggy Instamart',
        deliveryAddress: 'HSR Layout, Bangalore',
        status: PaymentStatus.paid,
        dateTime: DateTime.now().subtract(const Duration(days: 4)),
        amount: 410.00, // ₹410 for grocery orders
      ),
      PaymentTransaction(
        companyName: 'Amazon Fresh',
        deliveryAddress: 'Cyber City, Gurgaon',
        status: PaymentStatus.processing,
        dateTime: DateTime.now().subtract(const Duration(days: 8)),
        amount: 465.00, // ₹465 for premium delivery
      ),
      PaymentTransaction(
        companyName: 'Flipkart Quick',
        deliveryAddress: 'Andheri East, Mumbai',
        status: PaymentStatus.paid,
        dateTime: DateTime.now().subtract(const Duration(days: 12)),
        amount: 180.00, // ₹180 for 2 orders
      ),
      PaymentTransaction(
        companyName: 'Uber Eats',
        deliveryAddress: 'CP, New Delhi',
        status: PaymentStatus.paid,
        dateTime: DateTime.now().subtract(const Duration(days: 6)),
        amount: 225.00, // ₹225 for 3 orders
      ),
    ];
  }

  Future<List<String>> getCompanies() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    return [
      'All Companies',
      'Swiggy',
      'Zomato',
      'Dunzo',
      'BigBasket',
      'Blinkit',
      'Zepto',
      'Swiggy Instamart',
      'Amazon Fresh',
      'Flipkart Quick',
      'Uber Eats',
    ];
  }

  // Future method for when you integrate with real API
  Future<List<PaymentTransaction>> getFilteredTransactions({
    String? company,
    String? status,
    String? dateRange,
    DateTime? customFromDate,
    DateTime? customToDate,
  }) async {
    // This would be your actual API call with query parameters
    // For now, we'll use the local filtering in the cubit
    return getAllTransactions();
  }
}
