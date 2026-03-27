class ExpenseCategory {
  final String id;
  final String name;

  ExpenseCategory({required this.id, required this.name});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ExpenseCategoriesResponse {
  final bool success;
  final List<ExpenseCategory> categories;

  ExpenseCategoriesResponse({
    required this.success,
    required this.categories,
  });

  factory ExpenseCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, ExpenseCategory> uniqueCategories = {};
    
    // The API returns a map where keys are indices "0", "1", etc.
    // We iterate through the values that are maps and have 'id' and 'name'.
    json.forEach((key, value) {
      if (value is Map<String, dynamic> && value.containsKey('id') && value.containsKey('name')) {
        final cat = ExpenseCategory.fromJson(value);
        uniqueCategories[cat.id] = cat;
      }
    });
    
    final List<ExpenseCategory> loadedCategories = uniqueCategories.values.toList();

    // Check for "true" string or boolean true
    bool isSuccess = false;
    if (json['success'] is bool) {
      isSuccess = json['success'];
    } else if (json['success'] is String) {
      isSuccess = json['success'].toString().toLowerCase() == 'true';
    }

    return ExpenseCategoriesResponse(
      success: isSuccess,
      categories: loadedCategories,
    );
  }
}
