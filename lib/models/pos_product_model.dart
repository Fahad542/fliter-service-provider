import 'package:flutter/material.dart';

class PosProduct {
  final String id;
  final String name;
  final String? unit;
  final double price;
  final double? purchasePrice;
  final int stock;
  final String? categoryName;
  final String? subCategoryName;
  final String? departmentId;
  final String? departmentName;
  final String? imageUrl;
  final double vatRate;

  PosProduct({
    required this.id,
    required this.name,
    this.unit,
    required this.price,
    this.purchasePrice,
    required this.stock,
    this.categoryName,
    this.subCategoryName,
    this.departmentId,
    this.departmentName,
    this.imageUrl,
    this.vatRate = 0.15,
  });

  factory PosProduct.fromJson(Map<String, dynamic> json) {
    return PosProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      unit: json['unit'],
      price: double.tryParse(json['salePrice']?.toString() ?? '0.0') ?? 0.0,
      purchasePrice: double.tryParse(json['purchasePrice']?.toString() ?? '0.0'),
      stock: int.tryParse(json['openingQty']?.toString() ?? '0') ?? 0,
      categoryName: json['categoryName'],
      subCategoryName: json['subCategoryName'],
      departmentId: json['departmentId']?.toString(),
      departmentName: json['departmentName'],
      imageUrl: json['imageUrl'],
    );
  }

  // To keep compatibility with existing code that uses .category
  String get category => categoryName ?? 'Uncategorized';
  
  // To keep compatibility with existing code that uses .subtitle
  String get subtitle => unit ?? '';

  double get priceInclVat => price * (1 + vatRate);

  // Stock Helper (Matches old UI logic)
  bool get isService => false; // Adjust if API provides type

  Color get stockColor {
    if (isService) return const Color(0xFF4CAF50);
    if (stock > 5) return const Color(0xFF4CAF50);
    if (stock > 0) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String get stockLabel {
    if (isService) return 'Service';
    if (stock > 5) return 'In Stock ($stock)';
    if (stock > 0) return 'Low ($stock)';
    return 'Out of Stock';
  }
}

class ProductSubCategory {
  final String id;
  final String name;
  final List<PosProduct> products;

  ProductSubCategory({
    required this.id,
    required this.name,
    required this.products,
  });

  factory ProductSubCategory.fromJson(Map<String, dynamic> json) {
    return ProductSubCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      products: (json['products'] as List?)
              ?.map((p) => PosProduct.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class ProductCategory {
  final String id;
  final String name;
  final String type;
  final List<ProductSubCategory> subCategories;
  final List<PosProduct> productsWithoutSub;

  ProductCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.subCategories,
    required this.productsWithoutSub,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      subCategories: (json['subCategories'] as List?)
              ?.map((s) => ProductSubCategory.fromJson(s))
              .toList() ??
          [],
      productsWithoutSub: (json['productsWithoutSub'] as List?)
              ?.map((p) => PosProduct.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class ProductsResponse {
  final bool success;
  final String? workshopId;
  final List<ProductCategory> categories;
  final List<PosProduct> uncategorizedProducts;

  ProductsResponse({
    required this.success,
    this.workshopId,
    required this.categories,
    required this.uncategorizedProducts,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      success: json['success'] ?? false,
      workshopId: json['workshopId']?.toString(),
      categories: (json['categories'] as List?)
              ?.map((c) => ProductCategory.fromJson(c))
              .toList() ??
          [],
      uncategorizedProducts: (json['uncategorizedProducts'] as List?)
              ?.map((p) => PosProduct.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class CartItem {
  final PosProduct product;
  double quantity;
  double discount;
  bool isDiscountPercent;

  CartItem({
    required this.product,
    this.quantity = 1.0,
    this.discount = 0.0,
    this.isDiscountPercent = false,
  });

  double get actualDiscountAmount {
    if (isDiscountPercent) {
      return (product.price * quantity) * (discount / 100);
    }
    return discount;
  }

  double get totalPrice => (product.price * quantity) - actualDiscountAmount;
}
