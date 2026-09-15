// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hexColorMeta = const VerificationMeta(
    'hexColor',
  );
  @override
  late final GeneratedColumn<String> hexColor = GeneratedColumn<String>(
    'hex_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isBuiltinMeta = const VerificationMeta(
    'isBuiltin',
  );
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
    'is_builtin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_builtin" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategoryKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<CategoryKind>($CategoriesTable.$converterkind);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconKey,
    hexColor,
    isFavorite,
    sortOrder,
    isBuiltin,
    kind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('hex_color')) {
      context.handle(
        _hexColorMeta,
        hexColor.isAcceptableOrUnknown(data['hex_color']!, _hexColorMeta),
      );
    } else if (isInserting) {
      context.missing(_hexColorMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_builtin')) {
      context.handle(
        _isBuiltinMeta,
        isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      hexColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hex_color'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isBuiltin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_builtin'],
      )!,
      kind: $CategoriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoryKind, int, int> $converterkind =
      const EnumIndexConverter<CategoryKind>(CategoryKind.values);
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String iconKey;
  final String hexColor;
  final bool isFavorite;
  final int sortOrder;

  /// Seeded defaults; users can edit them but not delete.
  final bool isBuiltin;
  final CategoryKind kind;
  const Category({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.hexColor,
    required this.isFavorite,
    required this.sortOrder,
    required this.isBuiltin,
    required this.kind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    map['hex_color'] = Variable<String>(hexColor);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_builtin'] = Variable<bool>(isBuiltin);
    {
      map['kind'] = Variable<int>($CategoriesTable.$converterkind.toSql(kind));
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconKey: Value(iconKey),
      hexColor: Value(hexColor),
      isFavorite: Value(isFavorite),
      sortOrder: Value(sortOrder),
      isBuiltin: Value(isBuiltin),
      kind: Value(kind),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      hexColor: serializer.fromJson<String>(json['hexColor']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      kind: $CategoriesTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'hexColor': serializer.toJson<String>(hexColor),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'kind': serializer.toJson<int>(
        $CategoriesTable.$converterkind.toJson(kind),
      ),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? iconKey,
    String? hexColor,
    bool? isFavorite,
    int? sortOrder,
    bool? isBuiltin,
    CategoryKind? kind,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    hexColor: hexColor ?? this.hexColor,
    isFavorite: isFavorite ?? this.isFavorite,
    sortOrder: sortOrder ?? this.sortOrder,
    isBuiltin: isBuiltin ?? this.isBuiltin,
    kind: kind ?? this.kind,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      hexColor: data.hexColor.present ? data.hexColor.value : this.hexColor,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('hexColor: $hexColor, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconKey,
    hexColor,
    isFavorite,
    sortOrder,
    isBuiltin,
    kind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.hexColor == this.hexColor &&
          other.isFavorite == this.isFavorite &&
          other.sortOrder == this.sortOrder &&
          other.isBuiltin == this.isBuiltin &&
          other.kind == this.kind);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<String> hexColor;
  final Value<bool> isFavorite;
  final Value<int> sortOrder;
  final Value<bool> isBuiltin;
  final Value<CategoryKind> kind;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.hexColor = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String iconKey,
    required String hexColor,
    this.isFavorite = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.kind = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       iconKey = Value(iconKey),
       hexColor = Value(hexColor);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<String>? hexColor,
    Expression<bool>? isFavorite,
    Expression<int>? sortOrder,
    Expression<bool>? isBuiltin,
    Expression<int>? kind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (hexColor != null) 'hex_color': hexColor,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (kind != null) 'kind': kind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconKey,
    Value<String>? hexColor,
    Value<bool>? isFavorite,
    Value<int>? sortOrder,
    Value<bool>? isBuiltin,
    Value<CategoryKind>? kind,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      hexColor: hexColor ?? this.hexColor,
      isFavorite: isFavorite ?? this.isFavorite,
      sortOrder: sortOrder ?? this.sortOrder,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      kind: kind ?? this.kind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (hexColor.present) {
      map['hex_color'] = Variable<String>(hexColor.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
        $CategoriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('hexColor: $hexColor, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('kind: $kind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TxnType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TxnType>($TransactionsTable.$convertertype);
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    amount,
    type,
    merchant,
    note,
    timestamp,
    receiptPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      type: $TransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TxnType, int, int> $convertertype =
      const EnumIndexConverter<TxnType>(TxnType.values);
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String categoryId;
  final double amount;
  final TxnType type;
  final String merchant;
  final String? note;
  final DateTime timestamp;
  final String? receiptPath;
  const Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.merchant,
    this.note,
    required this.timestamp,
    this.receiptPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['amount'] = Variable<double>(amount);
    {
      map['type'] = Variable<int>(
        $TransactionsTable.$convertertype.toSql(type),
      );
    }
    map['merchant'] = Variable<String>(merchant);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      amount: Value(amount),
      type: Value(type),
      merchant: Value(merchant),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      timestamp: Value(timestamp),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      type: $TransactionsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      merchant: serializer.fromJson<String>(json['merchant']),
      note: serializer.fromJson<String?>(json['note']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<int>(
        $TransactionsTable.$convertertype.toJson(type),
      ),
      'merchant': serializer.toJson<String>(merchant),
      'note': serializer.toJson<String?>(note),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'receiptPath': serializer.toJson<String?>(receiptPath),
    };
  }

  Transaction copyWith({
    String? id,
    String? categoryId,
    double? amount,
    TxnType? type,
    String? merchant,
    Value<String?> note = const Value.absent(),
    DateTime? timestamp,
    Value<String?> receiptPath = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    merchant: merchant ?? this.merchant,
    note: note.present ? note.value : this.note,
    timestamp: timestamp ?? this.timestamp,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      note: data.note.present ? data.note.value : this.note,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('timestamp: $timestamp, ')
          ..write('receiptPath: $receiptPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    amount,
    type,
    merchant,
    note,
    timestamp,
    receiptPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.merchant == this.merchant &&
          other.note == this.note &&
          other.timestamp == this.timestamp &&
          other.receiptPath == this.receiptPath);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<double> amount;
  final Value<TxnType> type;
  final Value<String> merchant;
  final Value<String?> note;
  final Value<DateTime> timestamp;
  final Value<String?> receiptPath;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String categoryId,
    required double amount,
    required TxnType type,
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime timestamp,
    this.receiptPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       amount = Value(amount),
       type = Value(type),
       timestamp = Value(timestamp);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<double>? amount,
    Expression<int>? type,
    Expression<String>? merchant,
    Expression<String>? note,
    Expression<DateTime>? timestamp,
    Expression<String>? receiptPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (merchant != null) 'merchant': merchant,
      if (note != null) 'note': note,
      if (timestamp != null) 'timestamp': timestamp,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<double>? amount,
    Value<TxnType>? type,
    Value<String>? merchant,
    Value<String?>? note,
    Value<DateTime>? timestamp,
    Value<String?>? receiptPath,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      receiptPath: receiptPath ?? this.receiptPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $TransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('timestamp: $timestamp, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetSettingsTable extends BudgetSettings
    with TableInfo<$BudgetSettingsTable, BudgetSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyCapMeta = const VerificationMeta(
    'monthlyCap',
  );
  @override
  late final GeneratedColumn<double> monthlyCap = GeneratedColumn<double>(
    'monthly_cap',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _monthlyIncomeMeta = const VerificationMeta(
    'monthlyIncome',
  );
  @override
  late final GeneratedColumn<double> monthlyIncome = GeneratedColumn<double>(
    'monthly_income',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, monthlyCap, monthlyIncome];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('monthly_cap')) {
      context.handle(
        _monthlyCapMeta,
        monthlyCap.isAcceptableOrUnknown(data['monthly_cap']!, _monthlyCapMeta),
      );
    }
    if (data.containsKey('monthly_income')) {
      context.handle(
        _monthlyIncomeMeta,
        monthlyIncome.isAcceptableOrUnknown(
          data['monthly_income']!,
          _monthlyIncomeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      monthlyCap: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_cap'],
      )!,
      monthlyIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_income'],
      )!,
    );
  }

  @override
  $BudgetSettingsTable createAlias(String alias) {
    return $BudgetSettingsTable(attachedDatabase, alias);
  }
}

class BudgetSetting extends DataClass implements Insertable<BudgetSetting> {
  final int id;
  final double monthlyCap;
  final double monthlyIncome;
  const BudgetSetting({
    required this.id,
    required this.monthlyCap,
    required this.monthlyIncome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['monthly_cap'] = Variable<double>(monthlyCap);
    map['monthly_income'] = Variable<double>(monthlyIncome);
    return map;
  }

  BudgetSettingsCompanion toCompanion(bool nullToAbsent) {
    return BudgetSettingsCompanion(
      id: Value(id),
      monthlyCap: Value(monthlyCap),
      monthlyIncome: Value(monthlyIncome),
    );
  }

  factory BudgetSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetSetting(
      id: serializer.fromJson<int>(json['id']),
      monthlyCap: serializer.fromJson<double>(json['monthlyCap']),
      monthlyIncome: serializer.fromJson<double>(json['monthlyIncome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthlyCap': serializer.toJson<double>(monthlyCap),
      'monthlyIncome': serializer.toJson<double>(monthlyIncome),
    };
  }

  BudgetSetting copyWith({
    int? id,
    double? monthlyCap,
    double? monthlyIncome,
  }) => BudgetSetting(
    id: id ?? this.id,
    monthlyCap: monthlyCap ?? this.monthlyCap,
    monthlyIncome: monthlyIncome ?? this.monthlyIncome,
  );
  BudgetSetting copyWithCompanion(BudgetSettingsCompanion data) {
    return BudgetSetting(
      id: data.id.present ? data.id.value : this.id,
      monthlyCap: data.monthlyCap.present
          ? data.monthlyCap.value
          : this.monthlyCap,
      monthlyIncome: data.monthlyIncome.present
          ? data.monthlyIncome.value
          : this.monthlyIncome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetSetting(')
          ..write('id: $id, ')
          ..write('monthlyCap: $monthlyCap, ')
          ..write('monthlyIncome: $monthlyIncome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, monthlyCap, monthlyIncome);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetSetting &&
          other.id == this.id &&
          other.monthlyCap == this.monthlyCap &&
          other.monthlyIncome == this.monthlyIncome);
}

class BudgetSettingsCompanion extends UpdateCompanion<BudgetSetting> {
  final Value<int> id;
  final Value<double> monthlyCap;
  final Value<double> monthlyIncome;
  const BudgetSettingsCompanion({
    this.id = const Value.absent(),
    this.monthlyCap = const Value.absent(),
    this.monthlyIncome = const Value.absent(),
  });
  BudgetSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.monthlyCap = const Value.absent(),
    this.monthlyIncome = const Value.absent(),
  });
  static Insertable<BudgetSetting> custom({
    Expression<int>? id,
    Expression<double>? monthlyCap,
    Expression<double>? monthlyIncome,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthlyCap != null) 'monthly_cap': monthlyCap,
      if (monthlyIncome != null) 'monthly_income': monthlyIncome,
    });
  }

  BudgetSettingsCompanion copyWith({
    Value<int>? id,
    Value<double>? monthlyCap,
    Value<double>? monthlyIncome,
  }) {
    return BudgetSettingsCompanion(
      id: id ?? this.id,
      monthlyCap: monthlyCap ?? this.monthlyCap,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthlyCap.present) {
      map['monthly_cap'] = Variable<double>(monthlyCap.value);
    }
    if (monthlyIncome.present) {
      map['monthly_income'] = Variable<double>(monthlyIncome.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetSettingsCompanion(')
          ..write('id: $id, ')
          ..write('monthlyCap: $monthlyCap, ')
          ..write('monthlyIncome: $monthlyIncome')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appLockEnabledMeta = const VerificationMeta(
    'appLockEnabled',
  );
  @override
  late final GeneratedColumn<bool> appLockEnabled = GeneratedColumn<bool>(
    'app_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("app_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bioUnlockEnabledMeta = const VerificationMeta(
    'bioUnlockEnabled',
  );
  @override
  late final GeneratedColumn<bool> bioUnlockEnabled = GeneratedColumn<bool>(
    'bio_unlock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bio_unlock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hideBalancesOnSwitchMeta =
      const VerificationMeta('hideBalancesOnSwitch');
  @override
  late final GeneratedColumn<bool> hideBalancesOnSwitch = GeneratedColumn<bool>(
    'hide_balances_on_switch',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hide_balances_on_switch" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _encryptionActiveMeta = const VerificationMeta(
    'encryptionActive',
  );
  @override
  late final GeneratedColumn<bool> encryptionActive = GeneratedColumn<bool>(
    'encryption_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("encryption_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lockTimeoutSecondsMeta =
      const VerificationMeta('lockTimeoutSeconds');
  @override
  late final GeneratedColumn<int> lockTimeoutSeconds = GeneratedColumn<int>(
    'lock_timeout_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dailyExpenseReminderEnabledMeta =
      const VerificationMeta('dailyExpenseReminderEnabled');
  @override
  late final GeneratedColumn<bool> dailyExpenseReminderEnabled =
      GeneratedColumn<bool>(
        'daily_expense_reminder_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("daily_expense_reminder_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    appLockEnabled,
    bioUnlockEnabled,
    hideBalancesOnSwitch,
    encryptionActive,
    lockTimeoutSeconds,
    dailyExpenseReminderEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('app_lock_enabled')) {
      context.handle(
        _appLockEnabledMeta,
        appLockEnabled.isAcceptableOrUnknown(
          data['app_lock_enabled']!,
          _appLockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('bio_unlock_enabled')) {
      context.handle(
        _bioUnlockEnabledMeta,
        bioUnlockEnabled.isAcceptableOrUnknown(
          data['bio_unlock_enabled']!,
          _bioUnlockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('hide_balances_on_switch')) {
      context.handle(
        _hideBalancesOnSwitchMeta,
        hideBalancesOnSwitch.isAcceptableOrUnknown(
          data['hide_balances_on_switch']!,
          _hideBalancesOnSwitchMeta,
        ),
      );
    }
    if (data.containsKey('encryption_active')) {
      context.handle(
        _encryptionActiveMeta,
        encryptionActive.isAcceptableOrUnknown(
          data['encryption_active']!,
          _encryptionActiveMeta,
        ),
      );
    }
    if (data.containsKey('lock_timeout_seconds')) {
      context.handle(
        _lockTimeoutSecondsMeta,
        lockTimeoutSeconds.isAcceptableOrUnknown(
          data['lock_timeout_seconds']!,
          _lockTimeoutSecondsMeta,
        ),
      );
    }
    if (data.containsKey('daily_expense_reminder_enabled')) {
      context.handle(
        _dailyExpenseReminderEnabledMeta,
        dailyExpenseReminderEnabled.isAcceptableOrUnknown(
          data['daily_expense_reminder_enabled']!,
          _dailyExpenseReminderEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      appLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}app_lock_enabled'],
      )!,
      bioUnlockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bio_unlock_enabled'],
      )!,
      hideBalancesOnSwitch: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_balances_on_switch'],
      )!,
      encryptionActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}encryption_active'],
      )!,
      lockTimeoutSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lock_timeout_seconds'],
      )!,
      dailyExpenseReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_expense_reminder_enabled'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final bool appLockEnabled;
  final bool bioUnlockEnabled;

  /// Always on in product; kept for backups / older rows.
  final bool hideBalancesOnSwitch;
  final bool encryptionActive;

  /// Seconds of no interaction while Kash is open before locking.
  /// `0` = off (leaving the app still locks immediately when lock is on).
  final int lockTimeoutSeconds;

  /// Daily local notification at 8:30 PM to log expenses.
  final bool dailyExpenseReminderEnabled;
  const AppSetting({
    required this.id,
    required this.appLockEnabled,
    required this.bioUnlockEnabled,
    required this.hideBalancesOnSwitch,
    required this.encryptionActive,
    required this.lockTimeoutSeconds,
    required this.dailyExpenseReminderEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['app_lock_enabled'] = Variable<bool>(appLockEnabled);
    map['bio_unlock_enabled'] = Variable<bool>(bioUnlockEnabled);
    map['hide_balances_on_switch'] = Variable<bool>(hideBalancesOnSwitch);
    map['encryption_active'] = Variable<bool>(encryptionActive);
    map['lock_timeout_seconds'] = Variable<int>(lockTimeoutSeconds);
    map['daily_expense_reminder_enabled'] = Variable<bool>(
      dailyExpenseReminderEnabled,
    );
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      appLockEnabled: Value(appLockEnabled),
      bioUnlockEnabled: Value(bioUnlockEnabled),
      hideBalancesOnSwitch: Value(hideBalancesOnSwitch),
      encryptionActive: Value(encryptionActive),
      lockTimeoutSeconds: Value(lockTimeoutSeconds),
      dailyExpenseReminderEnabled: Value(dailyExpenseReminderEnabled),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      appLockEnabled: serializer.fromJson<bool>(json['appLockEnabled']),
      bioUnlockEnabled: serializer.fromJson<bool>(json['bioUnlockEnabled']),
      hideBalancesOnSwitch: serializer.fromJson<bool>(
        json['hideBalancesOnSwitch'],
      ),
      encryptionActive: serializer.fromJson<bool>(json['encryptionActive']),
      lockTimeoutSeconds: serializer.fromJson<int>(json['lockTimeoutSeconds']),
      dailyExpenseReminderEnabled: serializer.fromJson<bool>(
        json['dailyExpenseReminderEnabled'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'appLockEnabled': serializer.toJson<bool>(appLockEnabled),
      'bioUnlockEnabled': serializer.toJson<bool>(bioUnlockEnabled),
      'hideBalancesOnSwitch': serializer.toJson<bool>(hideBalancesOnSwitch),
      'encryptionActive': serializer.toJson<bool>(encryptionActive),
      'lockTimeoutSeconds': serializer.toJson<int>(lockTimeoutSeconds),
      'dailyExpenseReminderEnabled': serializer.toJson<bool>(
        dailyExpenseReminderEnabled,
      ),
    };
  }

  AppSetting copyWith({
    int? id,
    bool? appLockEnabled,
    bool? bioUnlockEnabled,
    bool? hideBalancesOnSwitch,
    bool? encryptionActive,
    int? lockTimeoutSeconds,
    bool? dailyExpenseReminderEnabled,
  }) => AppSetting(
    id: id ?? this.id,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    bioUnlockEnabled: bioUnlockEnabled ?? this.bioUnlockEnabled,
    hideBalancesOnSwitch: hideBalancesOnSwitch ?? this.hideBalancesOnSwitch,
    encryptionActive: encryptionActive ?? this.encryptionActive,
    lockTimeoutSeconds: lockTimeoutSeconds ?? this.lockTimeoutSeconds,
    dailyExpenseReminderEnabled:
        dailyExpenseReminderEnabled ?? this.dailyExpenseReminderEnabled,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      appLockEnabled: data.appLockEnabled.present
          ? data.appLockEnabled.value
          : this.appLockEnabled,
      bioUnlockEnabled: data.bioUnlockEnabled.present
          ? data.bioUnlockEnabled.value
          : this.bioUnlockEnabled,
      hideBalancesOnSwitch: data.hideBalancesOnSwitch.present
          ? data.hideBalancesOnSwitch.value
          : this.hideBalancesOnSwitch,
      encryptionActive: data.encryptionActive.present
          ? data.encryptionActive.value
          : this.encryptionActive,
      lockTimeoutSeconds: data.lockTimeoutSeconds.present
          ? data.lockTimeoutSeconds.value
          : this.lockTimeoutSeconds,
      dailyExpenseReminderEnabled: data.dailyExpenseReminderEnabled.present
          ? data.dailyExpenseReminderEnabled.value
          : this.dailyExpenseReminderEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('bioUnlockEnabled: $bioUnlockEnabled, ')
          ..write('hideBalancesOnSwitch: $hideBalancesOnSwitch, ')
          ..write('encryptionActive: $encryptionActive, ')
          ..write('lockTimeoutSeconds: $lockTimeoutSeconds, ')
          ..write('dailyExpenseReminderEnabled: $dailyExpenseReminderEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    appLockEnabled,
    bioUnlockEnabled,
    hideBalancesOnSwitch,
    encryptionActive,
    lockTimeoutSeconds,
    dailyExpenseReminderEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.appLockEnabled == this.appLockEnabled &&
          other.bioUnlockEnabled == this.bioUnlockEnabled &&
          other.hideBalancesOnSwitch == this.hideBalancesOnSwitch &&
          other.encryptionActive == this.encryptionActive &&
          other.lockTimeoutSeconds == this.lockTimeoutSeconds &&
          other.dailyExpenseReminderEnabled ==
              this.dailyExpenseReminderEnabled);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<bool> appLockEnabled;
  final Value<bool> bioUnlockEnabled;
  final Value<bool> hideBalancesOnSwitch;
  final Value<bool> encryptionActive;
  final Value<int> lockTimeoutSeconds;
  final Value<bool> dailyExpenseReminderEnabled;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.bioUnlockEnabled = const Value.absent(),
    this.hideBalancesOnSwitch = const Value.absent(),
    this.encryptionActive = const Value.absent(),
    this.lockTimeoutSeconds = const Value.absent(),
    this.dailyExpenseReminderEnabled = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.bioUnlockEnabled = const Value.absent(),
    this.hideBalancesOnSwitch = const Value.absent(),
    this.encryptionActive = const Value.absent(),
    this.lockTimeoutSeconds = const Value.absent(),
    this.dailyExpenseReminderEnabled = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<bool>? appLockEnabled,
    Expression<bool>? bioUnlockEnabled,
    Expression<bool>? hideBalancesOnSwitch,
    Expression<bool>? encryptionActive,
    Expression<int>? lockTimeoutSeconds,
    Expression<bool>? dailyExpenseReminderEnabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appLockEnabled != null) 'app_lock_enabled': appLockEnabled,
      if (bioUnlockEnabled != null) 'bio_unlock_enabled': bioUnlockEnabled,
      if (hideBalancesOnSwitch != null)
        'hide_balances_on_switch': hideBalancesOnSwitch,
      if (encryptionActive != null) 'encryption_active': encryptionActive,
      if (lockTimeoutSeconds != null)
        'lock_timeout_seconds': lockTimeoutSeconds,
      if (dailyExpenseReminderEnabled != null)
        'daily_expense_reminder_enabled': dailyExpenseReminderEnabled,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? appLockEnabled,
    Value<bool>? bioUnlockEnabled,
    Value<bool>? hideBalancesOnSwitch,
    Value<bool>? encryptionActive,
    Value<int>? lockTimeoutSeconds,
    Value<bool>? dailyExpenseReminderEnabled,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      bioUnlockEnabled: bioUnlockEnabled ?? this.bioUnlockEnabled,
      hideBalancesOnSwitch: hideBalancesOnSwitch ?? this.hideBalancesOnSwitch,
      encryptionActive: encryptionActive ?? this.encryptionActive,
      lockTimeoutSeconds: lockTimeoutSeconds ?? this.lockTimeoutSeconds,
      dailyExpenseReminderEnabled:
          dailyExpenseReminderEnabled ?? this.dailyExpenseReminderEnabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (appLockEnabled.present) {
      map['app_lock_enabled'] = Variable<bool>(appLockEnabled.value);
    }
    if (bioUnlockEnabled.present) {
      map['bio_unlock_enabled'] = Variable<bool>(bioUnlockEnabled.value);
    }
    if (hideBalancesOnSwitch.present) {
      map['hide_balances_on_switch'] = Variable<bool>(
        hideBalancesOnSwitch.value,
      );
    }
    if (encryptionActive.present) {
      map['encryption_active'] = Variable<bool>(encryptionActive.value);
    }
    if (lockTimeoutSeconds.present) {
      map['lock_timeout_seconds'] = Variable<int>(lockTimeoutSeconds.value);
    }
    if (dailyExpenseReminderEnabled.present) {
      map['daily_expense_reminder_enabled'] = Variable<bool>(
        dailyExpenseReminderEnabled.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('bioUnlockEnabled: $bioUnlockEnabled, ')
          ..write('hideBalancesOnSwitch: $hideBalancesOnSwitch, ')
          ..write('encryptionActive: $encryptionActive, ')
          ..write('lockTimeoutSeconds: $lockTimeoutSeconds, ')
          ..write('dailyExpenseReminderEnabled: $dailyExpenseReminderEnabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetSettingsTable budgetSettings = $BudgetSettingsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    transactions,
    budgetSettings,
    appSettings,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String iconKey,
      required String hexColor,
      Value<bool> isFavorite,
      Value<int> sortOrder,
      Value<bool> isBuiltin,
      Value<CategoryKind> kind,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconKey,
      Value<String> hexColor,
      Value<bool> isFavorite,
      Value<int> sortOrder,
      Value<bool> isBuiltin,
      Value<CategoryKind> kind,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.transactions.categoryId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CategoryKind, CategoryKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hexColor => $composableBuilder(
    column: $table.hexColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
    column: $table.isBuiltin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get hexColor =>
      $composableBuilder(column: $table.hexColor, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoryKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool transactionsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> hexColor = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<CategoryKind> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                iconKey: iconKey,
                hexColor: hexColor,
                isFavorite: isFavorite,
                sortOrder: sortOrder,
                isBuiltin: isBuiltin,
                kind: kind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String iconKey,
                required String hexColor,
                Value<bool> isFavorite = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isBuiltin = const Value.absent(),
                Value<CategoryKind> kind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                iconKey: iconKey,
                hexColor: hexColor,
                isFavorite: isFavorite,
                sortOrder: sortOrder,
                isBuiltin: isBuiltin,
                kind: kind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Transaction
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._transactionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).transactionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String categoryId,
      required double amount,
      required TxnType type,
      Value<String> merchant,
      Value<String?> note,
      required DateTime timestamp,
      Value<String?> receiptPath,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<double> amount,
      Value<TxnType> type,
      Value<String> merchant,
      Value<String?> note,
      Value<DateTime> timestamp,
      Value<String?> receiptPath,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.transactions.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TxnType, TxnType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TxnType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool categoryId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<TxnType> type = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                categoryId: categoryId,
                amount: amount,
                type: type,
                merchant: merchant,
                note: note,
                timestamp: timestamp,
                receiptPath: receiptPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required double amount,
                required TxnType type,
                Value<String> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime timestamp,
                Value<String?> receiptPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                categoryId: categoryId,
                amount: amount,
                type: type,
                merchant: merchant,
                note: note,
                timestamp: timestamp,
                receiptPath: receiptPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$TransactionsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$BudgetSettingsTableCreateCompanionBuilder =
    BudgetSettingsCompanion Function({
      Value<int> id,
      Value<double> monthlyCap,
      Value<double> monthlyIncome,
    });
typedef $$BudgetSettingsTableUpdateCompanionBuilder =
    BudgetSettingsCompanion Function({
      Value<int> id,
      Value<double> monthlyCap,
      Value<double> monthlyIncome,
    });

class $$BudgetSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetSettingsTable> {
  $$BudgetSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyCap => $composableBuilder(
    column: $table.monthlyCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetSettingsTable> {
  $$BudgetSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyCap => $composableBuilder(
    column: $table.monthlyCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetSettingsTable> {
  $$BudgetSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get monthlyCap => $composableBuilder(
    column: $table.monthlyCap,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => column,
  );
}

class $$BudgetSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetSettingsTable,
          BudgetSetting,
          $$BudgetSettingsTableFilterComposer,
          $$BudgetSettingsTableOrderingComposer,
          $$BudgetSettingsTableAnnotationComposer,
          $$BudgetSettingsTableCreateCompanionBuilder,
          $$BudgetSettingsTableUpdateCompanionBuilder,
          (
            BudgetSetting,
            BaseReferences<_$AppDatabase, $BudgetSettingsTable, BudgetSetting>,
          ),
          BudgetSetting,
          PrefetchHooks Function()
        > {
  $$BudgetSettingsTableTableManager(
    _$AppDatabase db,
    $BudgetSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> monthlyCap = const Value.absent(),
                Value<double> monthlyIncome = const Value.absent(),
              }) => BudgetSettingsCompanion(
                id: id,
                monthlyCap: monthlyCap,
                monthlyIncome: monthlyIncome,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> monthlyCap = const Value.absent(),
                Value<double> monthlyIncome = const Value.absent(),
              }) => BudgetSettingsCompanion.insert(
                id: id,
                monthlyCap: monthlyCap,
                monthlyIncome: monthlyIncome,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetSettingsTable,
      BudgetSetting,
      $$BudgetSettingsTableFilterComposer,
      $$BudgetSettingsTableOrderingComposer,
      $$BudgetSettingsTableAnnotationComposer,
      $$BudgetSettingsTableCreateCompanionBuilder,
      $$BudgetSettingsTableUpdateCompanionBuilder,
      (
        BudgetSetting,
        BaseReferences<_$AppDatabase, $BudgetSettingsTable, BudgetSetting>,
      ),
      BudgetSetting,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> appLockEnabled,
      Value<bool> bioUnlockEnabled,
      Value<bool> hideBalancesOnSwitch,
      Value<bool> encryptionActive,
      Value<int> lockTimeoutSeconds,
      Value<bool> dailyExpenseReminderEnabled,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> appLockEnabled,
      Value<bool> bioUnlockEnabled,
      Value<bool> hideBalancesOnSwitch,
      Value<bool> encryptionActive,
      Value<int> lockTimeoutSeconds,
      Value<bool> dailyExpenseReminderEnabled,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bioUnlockEnabled => $composableBuilder(
    column: $table.bioUnlockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hideBalancesOnSwitch => $composableBuilder(
    column: $table.hideBalancesOnSwitch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get encryptionActive => $composableBuilder(
    column: $table.encryptionActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lockTimeoutSeconds => $composableBuilder(
    column: $table.lockTimeoutSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dailyExpenseReminderEnabled => $composableBuilder(
    column: $table.dailyExpenseReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bioUnlockEnabled => $composableBuilder(
    column: $table.bioUnlockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hideBalancesOnSwitch => $composableBuilder(
    column: $table.hideBalancesOnSwitch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get encryptionActive => $composableBuilder(
    column: $table.encryptionActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lockTimeoutSeconds => $composableBuilder(
    column: $table.lockTimeoutSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dailyExpenseReminderEnabled => $composableBuilder(
    column: $table.dailyExpenseReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bioUnlockEnabled => $composableBuilder(
    column: $table.bioUnlockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hideBalancesOnSwitch => $composableBuilder(
    column: $table.hideBalancesOnSwitch,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get encryptionActive => $composableBuilder(
    column: $table.encryptionActive,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lockTimeoutSeconds => $composableBuilder(
    column: $table.lockTimeoutSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get dailyExpenseReminderEnabled => $composableBuilder(
    column: $table.dailyExpenseReminderEnabled,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<bool> bioUnlockEnabled = const Value.absent(),
                Value<bool> hideBalancesOnSwitch = const Value.absent(),
                Value<bool> encryptionActive = const Value.absent(),
                Value<int> lockTimeoutSeconds = const Value.absent(),
                Value<bool> dailyExpenseReminderEnabled = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                appLockEnabled: appLockEnabled,
                bioUnlockEnabled: bioUnlockEnabled,
                hideBalancesOnSwitch: hideBalancesOnSwitch,
                encryptionActive: encryptionActive,
                lockTimeoutSeconds: lockTimeoutSeconds,
                dailyExpenseReminderEnabled: dailyExpenseReminderEnabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<bool> bioUnlockEnabled = const Value.absent(),
                Value<bool> hideBalancesOnSwitch = const Value.absent(),
                Value<bool> encryptionActive = const Value.absent(),
                Value<int> lockTimeoutSeconds = const Value.absent(),
                Value<bool> dailyExpenseReminderEnabled = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                appLockEnabled: appLockEnabled,
                bioUnlockEnabled: bioUnlockEnabled,
                hideBalancesOnSwitch: hideBalancesOnSwitch,
                encryptionActive: encryptionActive,
                lockTimeoutSeconds: lockTimeoutSeconds,
                dailyExpenseReminderEnabled: dailyExpenseReminderEnabled,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetSettingsTableTableManager get budgetSettings =>
      $$BudgetSettingsTableTableManager(_db, _db.budgetSettings);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
