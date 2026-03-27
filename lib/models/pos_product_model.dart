import 'package:flutter/material.dart';

class PosProduct {
  final String id;
  final String name;
  final String? unit;
  final double price;
  final double? purchasePrice;
  final int stock;
  String? categoryName;
  String? subCategoryName;
  String? departmentId;
  String? departmentName;
  final String? imageUrl;
  final double vatRate;
  final int criticalStockPoint;
  final bool allowDecimalQty;

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
    this.criticalStockPoint = 0,
    this.allowDecimalQty = false,
  });

  factory PosProduct.fromJson(Map<String, dynamic> json) {
    final product = PosProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      unit: json['unit'],
      price: double.tryParse(json['salePrice']?.toString() ?? json['sellingPrice']?.toString() ?? '0.0') ?? 0.0,
      purchasePrice: double.tryParse(json['purchasePrice']?.toString() ?? '0.0'),
      stock: int.tryParse(json['qtyOnHand']?.toString() ?? json['openingQty']?.toString() ?? '0') ?? 0,
      categoryName: json['categoryName'],
      subCategoryName: json['subCategoryName'],
      departmentId: json['departmentId']?.toString(),
      departmentName: json['departmentName'],
      imageUrl: json['imageUrl'],
      criticalStockPoint: int.tryParse(json['criticalStockPoint']?.toString() ?? '0') ?? 0,
      allowDecimalQty: json['allowDecimalQty'] == true || json['allowDecimalQty'] == 'true',
    );
    product.isServiceType = json['type'] == 'service';
    return product;
  }

  // To keep compatibility with existing code that uses .category
  String get category => categoryName ?? 'Uncategorized';
  
  // To keep compatibility with existing code that uses .subtitle
  String get subtitle => unit ?? '';

  double get priceInclVat => price * (1 + vatRate);

  bool isServiceType = false;

  // Stock Helper (Matches old UI logic)
  bool get isService => isServiceType;

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
    final prods = (json['products'] as List?)?.map((p) => PosProduct.fromJson(p)).toList() ?? [];
    final servs = (json['services'] as List?)?.map((s) {
       final p = PosProduct.fromJson(s);
       p.isServiceType = true;
       return p;
    }).toList() ?? [];
    
    return ProductSubCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      products: [...prods, ...servs],
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
    final prods = ((json['productsWithoutSub'] ?? json['products']) as List?)?.map((p) => PosProduct.fromJson(p)).toList() ?? [];
    final servs = ((json['servicesWithoutSub'] ?? json['services']) as List?)?.map((s) {
       final p = PosProduct.fromJson(s);
       p.isServiceType = true;
       return p;
    }).toList() ?? [];

    return ProductCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      subCategories: (json['subCategories'] as List?)
              ?.map((s) => ProductSubCategory.fromJson(s))
              .toList() ??
          [],
      productsWithoutSub: [...prods, ...servs],
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
    final List<ProductCategory> allCategories = [];
    final List<PosProduct> allUncategorized = [];

    if (json.containsKey('departments') && json['departments'] != null) {
      final departments = json['departments'] as List;
      for (var deptJson in departments) {
        final deptId = deptJson['id']?.toString() ?? '';
        final deptName = deptJson['name']?.toString() ?? '';

        final cats = (deptJson['categories'] as List?)?.map((c) {
          final cat = ProductCategory.fromJson(c);
          for (var sub in cat.subCategories) {
            for (var p in sub.products) {
              p.categoryName = cat.name;
              p.subCategoryName = sub.name;
              p.departmentId = deptId;
              p.departmentName = deptName;
            }
          }
          for (var p in cat.productsWithoutSub) {
            p.categoryName = cat.name;
            p.departmentId = deptId;
            p.departmentName = deptName;
          }
          return cat;
        }).toList() ?? [];
        allCategories.addAll(cats);
        
        final uncatProd = (deptJson['uncategorizedProducts'] as List?)?.map((p) {
          final product = PosProduct.fromJson(p);
          product.departmentId = deptId;
          product.departmentName = deptName;
          return product;
        }).toList() ?? [];
        allUncategorized.addAll(uncatProd);
        
        final uncatServ = (deptJson['uncategorizedServices'] as List?)?.map((s) {
           final p = PosProduct.fromJson(s);
           p.isServiceType = true;
           p.departmentId = deptId;
           p.departmentName = deptName;
           return p;
        }).toList() ?? [];
        allUncategorized.addAll(uncatServ);
      }
    } else {
      final cats = (json['categories'] as List?)?.map((c) {
        final cat = ProductCategory.fromJson(c);
        for (var sub in cat.subCategories) {
          for (var p in sub.products) {
            p.categoryName = cat.name;
            p.subCategoryName = sub.name;
          }
        }
        for (var p in cat.productsWithoutSub) {
          p.categoryName = cat.name;
        }
        return cat;
      }).toList() ?? [];
      allCategories.addAll(cats);
      allUncategorized.addAll((json['uncategorizedProducts'] as List?)?.map((p) => PosProduct.fromJson(p)).toList() ?? []);
    }

    return ProductsResponse(
      success: json['success'] ?? false,
      workshopId: json['workshopId']?.toString() ?? json['branch']?['id']?.toString(),
      categories: allCategories,
      uncategorizedProducts: allUncategorized,
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
