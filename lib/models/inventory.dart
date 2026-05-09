import 'item.dart';

/// Một slot trong balo: một loại vật phẩm + số lượng.
class InventoryEntry {
  final Item item;
  int quantity;

  InventoryEntry({required this.item, this.quantity = 1});
}

/// Balo của nhân vật – quản lý toàn bộ vật phẩm mang theo.
class Inventory {
  final List<InventoryEntry> _entries = [];

  List<InventoryEntry> get entries => List.unmodifiable(_entries);

  /// Vật phẩm tiêu hao (tất cả nhóm trừ [ItemGroup.core] chứa material
  /// và trừ các item có flag [ItemFlag.passive] không có hiệu ứng active).
  List<InventoryEntry> get consumables => _entries
      .where((e) => _isConsumable(e.item))
      .toList();

  /// Trang bị và vật liệu đặc biệt (core, passive, material).
  List<InventoryEntry> get equipment => _entries
      .where((e) => !_isConsumable(e.item))
      .toList();

  static bool _isConsumable(Item item) {
    if (item.hasFlag(ItemFlag.material)) return false;
    if (item.hasFlag(ItemFlag.passive)) return false;
    // Vũ khí và áo giáp luôn thuộc mục trang bị, không phải tiêu hao
    if (item.group == ItemGroup.weapon) return false;
    if (item.group == ItemGroup.armor) return false;
    return true;
  }

  /// Thêm [count] đơn vị của [item].
  /// Nếu đã có trong balo thì cộng thêm số lượng.
  void add(Item item, {int count = 1}) {
    final existing = _findEntry(item.id);
    if (existing != null) {
      existing.quantity += count;
    } else {
      _entries.add(InventoryEntry(item: item, quantity: count));
    }
  }

  /// Bỏ [count] đơn vị của [itemId].
  /// Nếu số lượng về 0 thì xóa khỏi balo.
  /// Trả về [true] nếu thành công.
  bool remove(String itemId, {int count = 1}) {
    final entry = _findEntry(itemId);
    if (entry == null || entry.quantity < count) return false;
    // Vật phẩm độc nhất không bao giờ bị xóa khỏi balo
    if (entry.item.isUnique && entry.quantity - count <= 0) return false;
    entry.quantity -= count;
    if (entry.quantity == 0) {
      _entries.removeWhere((e) => e.item.id == itemId);
    }
    return true;
  }

  /// Kiểm tra có ít nhất [count] đơn vị của [itemId] không.
  bool has(String itemId, {int count = 1}) {
    final entry = _findEntry(itemId);
    return entry != null && entry.quantity >= count;
  }

  InventoryEntry? _findEntry(String itemId) {
    for (final e in _entries) {
      if (e.item.id == itemId) return e;
    }
    return null;
  }
}
