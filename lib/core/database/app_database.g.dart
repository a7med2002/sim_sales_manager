// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CompanyCatalogTableTable extends CompanyCatalogTable
    with TableInfo<$CompanyCatalogTableTable, CompanyCatalogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanyCatalogTableTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberUpdateUrlMeta = const VerificationMeta(
    'numberUpdateUrl',
  );
  @override
  late final GeneratedColumn<String> numberUpdateUrl = GeneratedColumn<String>(
    'number_update_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberUpdateProviderMeta =
      const VerificationMeta('numberUpdateProvider');
  @override
  late final GeneratedColumn<String> numberUpdateProvider =
      GeneratedColumn<String>(
        'number_update_provider',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    logoUrl,
    notes,
    numberUpdateUrl,
    numberUpdateProvider,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'company_catalog';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompanyCatalogTableData> instance, {
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
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('number_update_url')) {
      context.handle(
        _numberUpdateUrlMeta,
        numberUpdateUrl.isAcceptableOrUnknown(
          data['number_update_url']!,
          _numberUpdateUrlMeta,
        ),
      );
    }
    if (data.containsKey('number_update_provider')) {
      context.handle(
        _numberUpdateProviderMeta,
        numberUpdateProvider.isAcceptableOrUnknown(
          data['number_update_provider']!,
          _numberUpdateProviderMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompanyCatalogTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompanyCatalogTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      numberUpdateUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number_update_url'],
      ),
      numberUpdateProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number_update_provider'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CompanyCatalogTableTable createAlias(String alias) {
    return $CompanyCatalogTableTable(attachedDatabase, alias);
  }
}

class CompanyCatalogTableData extends DataClass
    implements Insertable<CompanyCatalogTableData> {
  final String id;
  final String name;
  final String? logoUrl;
  final String? notes;
  final String? numberUpdateUrl;
  final String? numberUpdateProvider;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CompanyCatalogTableData({
    required this.id,
    required this.name,
    this.logoUrl,
    this.notes,
    this.numberUpdateUrl,
    this.numberUpdateProvider,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || numberUpdateUrl != null) {
      map['number_update_url'] = Variable<String>(numberUpdateUrl);
    }
    if (!nullToAbsent || numberUpdateProvider != null) {
      map['number_update_provider'] = Variable<String>(numberUpdateProvider);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CompanyCatalogTableCompanion toCompanion(bool nullToAbsent) {
    return CompanyCatalogTableCompanion(
      id: Value(id),
      name: Value(name),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      numberUpdateUrl: numberUpdateUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(numberUpdateUrl),
      numberUpdateProvider: numberUpdateProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(numberUpdateProvider),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CompanyCatalogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompanyCatalogTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      notes: serializer.fromJson<String?>(json['notes']),
      numberUpdateUrl: serializer.fromJson<String?>(json['numberUpdateUrl']),
      numberUpdateProvider: serializer.fromJson<String?>(
        json['numberUpdateProvider'],
      ),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'notes': serializer.toJson<String?>(notes),
      'numberUpdateUrl': serializer.toJson<String?>(numberUpdateUrl),
      'numberUpdateProvider': serializer.toJson<String?>(numberUpdateProvider),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CompanyCatalogTableData copyWith({
    String? id,
    String? name,
    Value<String?> logoUrl = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> numberUpdateUrl = const Value.absent(),
    Value<String?> numberUpdateProvider = const Value.absent(),
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CompanyCatalogTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    notes: notes.present ? notes.value : this.notes,
    numberUpdateUrl: numberUpdateUrl.present
        ? numberUpdateUrl.value
        : this.numberUpdateUrl,
    numberUpdateProvider: numberUpdateProvider.present
        ? numberUpdateProvider.value
        : this.numberUpdateProvider,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CompanyCatalogTableData copyWithCompanion(CompanyCatalogTableCompanion data) {
    return CompanyCatalogTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      notes: data.notes.present ? data.notes.value : this.notes,
      numberUpdateUrl: data.numberUpdateUrl.present
          ? data.numberUpdateUrl.value
          : this.numberUpdateUrl,
      numberUpdateProvider: data.numberUpdateProvider.present
          ? data.numberUpdateProvider.value
          : this.numberUpdateProvider,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompanyCatalogTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('notes: $notes, ')
          ..write('numberUpdateUrl: $numberUpdateUrl, ')
          ..write('numberUpdateProvider: $numberUpdateProvider, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    logoUrl,
    notes,
    numberUpdateUrl,
    numberUpdateProvider,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompanyCatalogTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.logoUrl == this.logoUrl &&
          other.notes == this.notes &&
          other.numberUpdateUrl == this.numberUpdateUrl &&
          other.numberUpdateProvider == this.numberUpdateProvider &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CompanyCatalogTableCompanion
    extends UpdateCompanion<CompanyCatalogTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> logoUrl;
  final Value<String?> notes;
  final Value<String?> numberUpdateUrl;
  final Value<String?> numberUpdateProvider;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CompanyCatalogTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.numberUpdateUrl = const Value.absent(),
    this.numberUpdateProvider = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanyCatalogTableCompanion.insert({
    required String id,
    required String name,
    this.logoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.numberUpdateUrl = const Value.absent(),
    this.numberUpdateProvider = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CompanyCatalogTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? logoUrl,
    Expression<String>? notes,
    Expression<String>? numberUpdateUrl,
    Expression<String>? numberUpdateProvider,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (notes != null) 'notes': notes,
      if (numberUpdateUrl != null) 'number_update_url': numberUpdateUrl,
      if (numberUpdateProvider != null)
        'number_update_provider': numberUpdateProvider,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanyCatalogTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? logoUrl,
    Value<String?>? notes,
    Value<String?>? numberUpdateUrl,
    Value<String?>? numberUpdateProvider,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CompanyCatalogTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      notes: notes ?? this.notes,
      numberUpdateUrl: numberUpdateUrl ?? this.numberUpdateUrl,
      numberUpdateProvider: numberUpdateProvider ?? this.numberUpdateProvider,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (numberUpdateUrl.present) {
      map['number_update_url'] = Variable<String>(numberUpdateUrl.value);
    }
    if (numberUpdateProvider.present) {
      map['number_update_provider'] = Variable<String>(
        numberUpdateProvider.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanyCatalogTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('notes: $notes, ')
          ..write('numberUpdateUrl: $numberUpdateUrl, ')
          ..write('numberUpdateProvider: $numberUpdateProvider, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PackageCatalogTableTable extends PackageCatalogTable
    with TableInfo<$PackageCatalogTableTable, PackageCatalogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PackageCatalogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyCatalogIdMeta = const VerificationMeta(
    'companyCatalogId',
  );
  @override
  late final GeneratedColumn<String> companyCatalogId = GeneratedColumn<String>(
    'company_catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES company_catalog (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _simTypeMeta = const VerificationMeta(
    'simType',
  );
  @override
  late final GeneratedColumn<String> simType = GeneratedColumn<String>(
    'sim_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wholesaleCostMeta = const VerificationMeta(
    'wholesaleCost',
  );
  @override
  late final GeneratedColumn<double> wholesaleCost = GeneratedColumn<double>(
    'wholesale_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _suggestedRetailPriceMeta =
      const VerificationMeta('suggestedRetailPrice');
  @override
  late final GeneratedColumn<double> suggestedRetailPrice =
      GeneratedColumn<double>(
        'suggested_retail_price',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyCatalogId,
    name,
    simType,
    wholesaleCost,
    suggestedRetailPrice,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'package_catalog';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackageCatalogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_catalog_id')) {
      context.handle(
        _companyCatalogIdMeta,
        companyCatalogId.isAcceptableOrUnknown(
          data['company_catalog_id']!,
          _companyCatalogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyCatalogIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sim_type')) {
      context.handle(
        _simTypeMeta,
        simType.isAcceptableOrUnknown(data['sim_type']!, _simTypeMeta),
      );
    }
    if (data.containsKey('wholesale_cost')) {
      context.handle(
        _wholesaleCostMeta,
        wholesaleCost.isAcceptableOrUnknown(
          data['wholesale_cost']!,
          _wholesaleCostMeta,
        ),
      );
    }
    if (data.containsKey('suggested_retail_price')) {
      context.handle(
        _suggestedRetailPriceMeta,
        suggestedRetailPrice.isAcceptableOrUnknown(
          data['suggested_retail_price']!,
          _suggestedRetailPriceMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PackageCatalogTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackageCatalogTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyCatalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_catalog_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      simType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sim_type'],
      ),
      wholesaleCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wholesale_cost'],
      )!,
      suggestedRetailPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}suggested_retail_price'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PackageCatalogTableTable createAlias(String alias) {
    return $PackageCatalogTableTable(attachedDatabase, alias);
  }
}

class PackageCatalogTableData extends DataClass
    implements Insertable<PackageCatalogTableData> {
  final String id;
  final String companyCatalogId;
  final String name;
  final String? simType;
  final double wholesaleCost;
  final double suggestedRetailPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PackageCatalogTableData({
    required this.id,
    required this.companyCatalogId,
    required this.name,
    this.simType,
    required this.wholesaleCost,
    required this.suggestedRetailPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_catalog_id'] = Variable<String>(companyCatalogId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || simType != null) {
      map['sim_type'] = Variable<String>(simType);
    }
    map['wholesale_cost'] = Variable<double>(wholesaleCost);
    map['suggested_retail_price'] = Variable<double>(suggestedRetailPrice);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PackageCatalogTableCompanion toCompanion(bool nullToAbsent) {
    return PackageCatalogTableCompanion(
      id: Value(id),
      companyCatalogId: Value(companyCatalogId),
      name: Value(name),
      simType: simType == null && nullToAbsent
          ? const Value.absent()
          : Value(simType),
      wholesaleCost: Value(wholesaleCost),
      suggestedRetailPrice: Value(suggestedRetailPrice),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PackageCatalogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackageCatalogTableData(
      id: serializer.fromJson<String>(json['id']),
      companyCatalogId: serializer.fromJson<String>(json['companyCatalogId']),
      name: serializer.fromJson<String>(json['name']),
      simType: serializer.fromJson<String?>(json['simType']),
      wholesaleCost: serializer.fromJson<double>(json['wholesaleCost']),
      suggestedRetailPrice: serializer.fromJson<double>(
        json['suggestedRetailPrice'],
      ),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyCatalogId': serializer.toJson<String>(companyCatalogId),
      'name': serializer.toJson<String>(name),
      'simType': serializer.toJson<String?>(simType),
      'wholesaleCost': serializer.toJson<double>(wholesaleCost),
      'suggestedRetailPrice': serializer.toJson<double>(suggestedRetailPrice),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PackageCatalogTableData copyWith({
    String? id,
    String? companyCatalogId,
    String? name,
    Value<String?> simType = const Value.absent(),
    double? wholesaleCost,
    double? suggestedRetailPrice,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PackageCatalogTableData(
    id: id ?? this.id,
    companyCatalogId: companyCatalogId ?? this.companyCatalogId,
    name: name ?? this.name,
    simType: simType.present ? simType.value : this.simType,
    wholesaleCost: wholesaleCost ?? this.wholesaleCost,
    suggestedRetailPrice: suggestedRetailPrice ?? this.suggestedRetailPrice,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PackageCatalogTableData copyWithCompanion(PackageCatalogTableCompanion data) {
    return PackageCatalogTableData(
      id: data.id.present ? data.id.value : this.id,
      companyCatalogId: data.companyCatalogId.present
          ? data.companyCatalogId.value
          : this.companyCatalogId,
      name: data.name.present ? data.name.value : this.name,
      simType: data.simType.present ? data.simType.value : this.simType,
      wholesaleCost: data.wholesaleCost.present
          ? data.wholesaleCost.value
          : this.wholesaleCost,
      suggestedRetailPrice: data.suggestedRetailPrice.present
          ? data.suggestedRetailPrice.value
          : this.suggestedRetailPrice,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackageCatalogTableData(')
          ..write('id: $id, ')
          ..write('companyCatalogId: $companyCatalogId, ')
          ..write('name: $name, ')
          ..write('simType: $simType, ')
          ..write('wholesaleCost: $wholesaleCost, ')
          ..write('suggestedRetailPrice: $suggestedRetailPrice, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyCatalogId,
    name,
    simType,
    wholesaleCost,
    suggestedRetailPrice,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackageCatalogTableData &&
          other.id == this.id &&
          other.companyCatalogId == this.companyCatalogId &&
          other.name == this.name &&
          other.simType == this.simType &&
          other.wholesaleCost == this.wholesaleCost &&
          other.suggestedRetailPrice == this.suggestedRetailPrice &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PackageCatalogTableCompanion
    extends UpdateCompanion<PackageCatalogTableData> {
  final Value<String> id;
  final Value<String> companyCatalogId;
  final Value<String> name;
  final Value<String?> simType;
  final Value<double> wholesaleCost;
  final Value<double> suggestedRetailPrice;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PackageCatalogTableCompanion({
    this.id = const Value.absent(),
    this.companyCatalogId = const Value.absent(),
    this.name = const Value.absent(),
    this.simType = const Value.absent(),
    this.wholesaleCost = const Value.absent(),
    this.suggestedRetailPrice = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PackageCatalogTableCompanion.insert({
    required String id,
    required String companyCatalogId,
    required String name,
    this.simType = const Value.absent(),
    this.wholesaleCost = const Value.absent(),
    this.suggestedRetailPrice = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyCatalogId = Value(companyCatalogId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PackageCatalogTableData> custom({
    Expression<String>? id,
    Expression<String>? companyCatalogId,
    Expression<String>? name,
    Expression<String>? simType,
    Expression<double>? wholesaleCost,
    Expression<double>? suggestedRetailPrice,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyCatalogId != null) 'company_catalog_id': companyCatalogId,
      if (name != null) 'name': name,
      if (simType != null) 'sim_type': simType,
      if (wholesaleCost != null) 'wholesale_cost': wholesaleCost,
      if (suggestedRetailPrice != null)
        'suggested_retail_price': suggestedRetailPrice,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PackageCatalogTableCompanion copyWith({
    Value<String>? id,
    Value<String>? companyCatalogId,
    Value<String>? name,
    Value<String?>? simType,
    Value<double>? wholesaleCost,
    Value<double>? suggestedRetailPrice,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PackageCatalogTableCompanion(
      id: id ?? this.id,
      companyCatalogId: companyCatalogId ?? this.companyCatalogId,
      name: name ?? this.name,
      simType: simType ?? this.simType,
      wholesaleCost: wholesaleCost ?? this.wholesaleCost,
      suggestedRetailPrice: suggestedRetailPrice ?? this.suggestedRetailPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyCatalogId.present) {
      map['company_catalog_id'] = Variable<String>(companyCatalogId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (simType.present) {
      map['sim_type'] = Variable<String>(simType.value);
    }
    if (wholesaleCost.present) {
      map['wholesale_cost'] = Variable<double>(wholesaleCost.value);
    }
    if (suggestedRetailPrice.present) {
      map['suggested_retail_price'] = Variable<double>(
        suggestedRetailPrice.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PackageCatalogTableCompanion(')
          ..write('id: $id, ')
          ..write('companyCatalogId: $companyCatalogId, ')
          ..write('name: $name, ')
          ..write('simType: $simType, ')
          ..write('wholesaleCost: $wholesaleCost, ')
          ..write('suggestedRetailPrice: $suggestedRetailPrice, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompaniesTableTable extends CompaniesTable
    with TableInfo<$CompaniesTableTable, CompaniesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _catalogCompanyIdMeta = const VerificationMeta(
    'catalogCompanyId',
  );
  @override
  late final GeneratedColumn<String> catalogCompanyId = GeneratedColumn<String>(
    'catalog_company_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES company_catalog (id)',
    ),
  );
  static const VerificationMeta _numberUpdateProviderMeta =
      const VerificationMeta('numberUpdateProvider');
  @override
  late final GeneratedColumn<String> numberUpdateProvider =
      GeneratedColumn<String>(
        'number_update_provider',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _numberUpdateUrlMeta = const VerificationMeta(
    'numberUpdateUrl',
  );
  @override
  late final GeneratedColumn<String> numberUpdateUrl = GeneratedColumn<String>(
    'number_update_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allowNegativeBalanceMeta =
      const VerificationMeta('allowNegativeBalance');
  @override
  late final GeneratedColumn<bool> allowNegativeBalance = GeneratedColumn<bool>(
    'allow_negative_balance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_negative_balance" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    id,
    name,
    logoUrl,
    notes,
    status,
    pinned,
    catalogCompanyId,
    numberUpdateProvider,
    numberUpdateUrl,
    allowNegativeBalance,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompaniesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
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
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('catalog_company_id')) {
      context.handle(
        _catalogCompanyIdMeta,
        catalogCompanyId.isAcceptableOrUnknown(
          data['catalog_company_id']!,
          _catalogCompanyIdMeta,
        ),
      );
    }
    if (data.containsKey('number_update_provider')) {
      context.handle(
        _numberUpdateProviderMeta,
        numberUpdateProvider.isAcceptableOrUnknown(
          data['number_update_provider']!,
          _numberUpdateProviderMeta,
        ),
      );
    }
    if (data.containsKey('number_update_url')) {
      context.handle(
        _numberUpdateUrlMeta,
        numberUpdateUrl.isAcceptableOrUnknown(
          data['number_update_url']!,
          _numberUpdateUrlMeta,
        ),
      );
    }
    if (data.containsKey('allow_negative_balance')) {
      context.handle(
        _allowNegativeBalanceMeta,
        allowNegativeBalance.isAcceptableOrUnknown(
          data['allow_negative_balance']!,
          _allowNegativeBalanceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompaniesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompaniesTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      catalogCompanyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_company_id'],
      ),
      numberUpdateProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number_update_provider'],
      ),
      numberUpdateUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number_update_url'],
      ),
      allowNegativeBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_negative_balance'],
      )!,
    );
  }

  @override
  $CompaniesTableTable createAlias(String alias) {
    return $CompaniesTableTable(attachedDatabase, alias);
  }
}

class CompaniesTableData extends DataClass
    implements Insertable<CompaniesTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String id;
  final String name;
  final String? logoUrl;
  final String? notes;
  final String status;
  final bool pinned;
  final String? catalogCompanyId;
  final String? numberUpdateProvider;
  final String? numberUpdateUrl;
  final bool allowNegativeBalance;
  const CompaniesTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.id,
    required this.name,
    this.logoUrl,
    this.notes,
    required this.status,
    required this.pinned,
    this.catalogCompanyId,
    this.numberUpdateProvider,
    this.numberUpdateUrl,
    required this.allowNegativeBalance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    map['pinned'] = Variable<bool>(pinned);
    if (!nullToAbsent || catalogCompanyId != null) {
      map['catalog_company_id'] = Variable<String>(catalogCompanyId);
    }
    if (!nullToAbsent || numberUpdateProvider != null) {
      map['number_update_provider'] = Variable<String>(numberUpdateProvider);
    }
    if (!nullToAbsent || numberUpdateUrl != null) {
      map['number_update_url'] = Variable<String>(numberUpdateUrl);
    }
    map['allow_negative_balance'] = Variable<bool>(allowNegativeBalance);
    return map;
  }

  CompaniesTableCompanion toCompanion(bool nullToAbsent) {
    return CompaniesTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      pinned: Value(pinned),
      catalogCompanyId: catalogCompanyId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogCompanyId),
      numberUpdateProvider: numberUpdateProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(numberUpdateProvider),
      numberUpdateUrl: numberUpdateUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(numberUpdateUrl),
      allowNegativeBalance: Value(allowNegativeBalance),
    );
  }

  factory CompaniesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompaniesTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      catalogCompanyId: serializer.fromJson<String?>(json['catalogCompanyId']),
      numberUpdateProvider: serializer.fromJson<String?>(
        json['numberUpdateProvider'],
      ),
      numberUpdateUrl: serializer.fromJson<String?>(json['numberUpdateUrl']),
      allowNegativeBalance: serializer.fromJson<bool>(
        json['allowNegativeBalance'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'pinned': serializer.toJson<bool>(pinned),
      'catalogCompanyId': serializer.toJson<String?>(catalogCompanyId),
      'numberUpdateProvider': serializer.toJson<String?>(numberUpdateProvider),
      'numberUpdateUrl': serializer.toJson<String?>(numberUpdateUrl),
      'allowNegativeBalance': serializer.toJson<bool>(allowNegativeBalance),
    };
  }

  CompaniesTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? id,
    String? name,
    Value<String?> logoUrl = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? status,
    bool? pinned,
    Value<String?> catalogCompanyId = const Value.absent(),
    Value<String?> numberUpdateProvider = const Value.absent(),
    Value<String?> numberUpdateUrl = const Value.absent(),
    bool? allowNegativeBalance,
  }) => CompaniesTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    pinned: pinned ?? this.pinned,
    catalogCompanyId: catalogCompanyId.present
        ? catalogCompanyId.value
        : this.catalogCompanyId,
    numberUpdateProvider: numberUpdateProvider.present
        ? numberUpdateProvider.value
        : this.numberUpdateProvider,
    numberUpdateUrl: numberUpdateUrl.present
        ? numberUpdateUrl.value
        : this.numberUpdateUrl,
    allowNegativeBalance: allowNegativeBalance ?? this.allowNegativeBalance,
  );
  CompaniesTableData copyWithCompanion(CompaniesTableCompanion data) {
    return CompaniesTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      catalogCompanyId: data.catalogCompanyId.present
          ? data.catalogCompanyId.value
          : this.catalogCompanyId,
      numberUpdateProvider: data.numberUpdateProvider.present
          ? data.numberUpdateProvider.value
          : this.numberUpdateProvider,
      numberUpdateUrl: data.numberUpdateUrl.present
          ? data.numberUpdateUrl.value
          : this.numberUpdateUrl,
      allowNegativeBalance: data.allowNegativeBalance.present
          ? data.allowNegativeBalance.value
          : this.allowNegativeBalance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('pinned: $pinned, ')
          ..write('catalogCompanyId: $catalogCompanyId, ')
          ..write('numberUpdateProvider: $numberUpdateProvider, ')
          ..write('numberUpdateUrl: $numberUpdateUrl, ')
          ..write('allowNegativeBalance: $allowNegativeBalance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    id,
    name,
    logoUrl,
    notes,
    status,
    pinned,
    catalogCompanyId,
    numberUpdateProvider,
    numberUpdateUrl,
    allowNegativeBalance,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompaniesTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.logoUrl == this.logoUrl &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.pinned == this.pinned &&
          other.catalogCompanyId == this.catalogCompanyId &&
          other.numberUpdateProvider == this.numberUpdateProvider &&
          other.numberUpdateUrl == this.numberUpdateUrl &&
          other.allowNegativeBalance == this.allowNegativeBalance);
}

class CompaniesTableCompanion extends UpdateCompanion<CompaniesTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> logoUrl;
  final Value<String?> notes;
  final Value<String> status;
  final Value<bool> pinned;
  final Value<String?> catalogCompanyId;
  final Value<String?> numberUpdateProvider;
  final Value<String?> numberUpdateUrl;
  final Value<bool> allowNegativeBalance;
  final Value<int> rowid;
  const CompaniesTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.pinned = const Value.absent(),
    this.catalogCompanyId = const Value.absent(),
    this.numberUpdateProvider = const Value.absent(),
    this.numberUpdateUrl = const Value.absent(),
    this.allowNegativeBalance = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompaniesTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String id,
    required String name,
    this.logoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.pinned = const Value.absent(),
    this.catalogCompanyId = const Value.absent(),
    this.numberUpdateProvider = const Value.absent(),
    this.numberUpdateUrl = const Value.absent(),
    this.allowNegativeBalance = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name);
  static Insertable<CompaniesTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? logoUrl,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<bool>? pinned,
    Expression<String>? catalogCompanyId,
    Expression<String>? numberUpdateProvider,
    Expression<String>? numberUpdateUrl,
    Expression<bool>? allowNegativeBalance,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (pinned != null) 'pinned': pinned,
      if (catalogCompanyId != null) 'catalog_company_id': catalogCompanyId,
      if (numberUpdateProvider != null)
        'number_update_provider': numberUpdateProvider,
      if (numberUpdateUrl != null) 'number_update_url': numberUpdateUrl,
      if (allowNegativeBalance != null)
        'allow_negative_balance': allowNegativeBalance,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompaniesTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? logoUrl,
    Value<String?>? notes,
    Value<String>? status,
    Value<bool>? pinned,
    Value<String?>? catalogCompanyId,
    Value<String?>? numberUpdateProvider,
    Value<String?>? numberUpdateUrl,
    Value<bool>? allowNegativeBalance,
    Value<int>? rowid,
  }) {
    return CompaniesTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      pinned: pinned ?? this.pinned,
      catalogCompanyId: catalogCompanyId ?? this.catalogCompanyId,
      numberUpdateProvider: numberUpdateProvider ?? this.numberUpdateProvider,
      numberUpdateUrl: numberUpdateUrl ?? this.numberUpdateUrl,
      allowNegativeBalance: allowNegativeBalance ?? this.allowNegativeBalance,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (catalogCompanyId.present) {
      map['catalog_company_id'] = Variable<String>(catalogCompanyId.value);
    }
    if (numberUpdateProvider.present) {
      map['number_update_provider'] = Variable<String>(
        numberUpdateProvider.value,
      );
    }
    if (numberUpdateUrl.present) {
      map['number_update_url'] = Variable<String>(numberUpdateUrl.value);
    }
    if (allowNegativeBalance.present) {
      map['allow_negative_balance'] = Variable<bool>(
        allowNegativeBalance.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('pinned: $pinned, ')
          ..write('catalogCompanyId: $catalogCompanyId, ')
          ..write('numberUpdateProvider: $numberUpdateProvider, ')
          ..write('numberUpdateUrl: $numberUpdateUrl, ')
          ..write('allowNegativeBalance: $allowNegativeBalance, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PackagesTableTable extends PackagesTable
    with TableInfo<$PackagesTableTable, PackagesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PackagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _simTypeMeta = const VerificationMeta(
    'simType',
  );
  @override
  late final GeneratedColumn<String> simType = GeneratedColumn<String>(
    'sim_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wholesaleCostMeta = const VerificationMeta(
    'wholesaleCost',
  );
  @override
  late final GeneratedColumn<double> wholesaleCost = GeneratedColumn<double>(
    'wholesale_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _retailPriceMeta = const VerificationMeta(
    'retailPrice',
  );
  @override
  late final GeneratedColumn<double> retailPrice = GeneratedColumn<double>(
    'retail_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    id,
    companyId,
    name,
    simType,
    wholesaleCost,
    retailPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packages';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackagesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sim_type')) {
      context.handle(
        _simTypeMeta,
        simType.isAcceptableOrUnknown(data['sim_type']!, _simTypeMeta),
      );
    }
    if (data.containsKey('wholesale_cost')) {
      context.handle(
        _wholesaleCostMeta,
        wholesaleCost.isAcceptableOrUnknown(
          data['wholesale_cost']!,
          _wholesaleCostMeta,
        ),
      );
    }
    if (data.containsKey('retail_price')) {
      context.handle(
        _retailPriceMeta,
        retailPrice.isAcceptableOrUnknown(
          data['retail_price']!,
          _retailPriceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PackagesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackagesTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      simType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sim_type'],
      ),
      wholesaleCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wholesale_cost'],
      )!,
      retailPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}retail_price'],
      )!,
    );
  }

  @override
  $PackagesTableTable createAlias(String alias) {
    return $PackagesTableTable(attachedDatabase, alias);
  }
}

class PackagesTableData extends DataClass
    implements Insertable<PackagesTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String id;
  final String companyId;
  final String name;
  final String? simType;
  final double wholesaleCost;
  final double retailPrice;
  const PackagesTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.id,
    required this.companyId,
    required this.name,
    this.simType,
    required this.wholesaleCost,
    required this.retailPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || simType != null) {
      map['sim_type'] = Variable<String>(simType);
    }
    map['wholesale_cost'] = Variable<double>(wholesaleCost);
    map['retail_price'] = Variable<double>(retailPrice);
    return map;
  }

  PackagesTableCompanion toCompanion(bool nullToAbsent) {
    return PackagesTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      simType: simType == null && nullToAbsent
          ? const Value.absent()
          : Value(simType),
      wholesaleCost: Value(wholesaleCost),
      retailPrice: Value(retailPrice),
    );
  }

  factory PackagesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackagesTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      simType: serializer.fromJson<String?>(json['simType']),
      wholesaleCost: serializer.fromJson<double>(json['wholesaleCost']),
      retailPrice: serializer.fromJson<double>(json['retailPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'simType': serializer.toJson<String?>(simType),
      'wholesaleCost': serializer.toJson<double>(wholesaleCost),
      'retailPrice': serializer.toJson<double>(retailPrice),
    };
  }

  PackagesTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? id,
    String? companyId,
    String? name,
    Value<String?> simType = const Value.absent(),
    double? wholesaleCost,
    double? retailPrice,
  }) => PackagesTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    simType: simType.present ? simType.value : this.simType,
    wholesaleCost: wholesaleCost ?? this.wholesaleCost,
    retailPrice: retailPrice ?? this.retailPrice,
  );
  PackagesTableData copyWithCompanion(PackagesTableCompanion data) {
    return PackagesTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      simType: data.simType.present ? data.simType.value : this.simType,
      wholesaleCost: data.wholesaleCost.present
          ? data.wholesaleCost.value
          : this.wholesaleCost,
      retailPrice: data.retailPrice.present
          ? data.retailPrice.value
          : this.retailPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackagesTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('simType: $simType, ')
          ..write('wholesaleCost: $wholesaleCost, ')
          ..write('retailPrice: $retailPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    id,
    companyId,
    name,
    simType,
    wholesaleCost,
    retailPrice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackagesTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.simType == this.simType &&
          other.wholesaleCost == this.wholesaleCost &&
          other.retailPrice == this.retailPrice);
}

class PackagesTableCompanion extends UpdateCompanion<PackagesTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String?> simType;
  final Value<double> wholesaleCost;
  final Value<double> retailPrice;
  final Value<int> rowid;
  const PackagesTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.simType = const Value.absent(),
    this.wholesaleCost = const Value.absent(),
    this.retailPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PackagesTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String id,
    required String companyId,
    required String name,
    this.simType = const Value.absent(),
    this.wholesaleCost = const Value.absent(),
    this.retailPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       companyId = Value(companyId),
       name = Value(name);
  static Insertable<PackagesTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? simType,
    Expression<double>? wholesaleCost,
    Expression<double>? retailPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (simType != null) 'sim_type': simType,
      if (wholesaleCost != null) 'wholesale_cost': wholesaleCost,
      if (retailPrice != null) 'retail_price': retailPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PackagesTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String?>? simType,
    Value<double>? wholesaleCost,
    Value<double>? retailPrice,
    Value<int>? rowid,
  }) {
    return PackagesTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      simType: simType ?? this.simType,
      wholesaleCost: wholesaleCost ?? this.wholesaleCost,
      retailPrice: retailPrice ?? this.retailPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (simType.present) {
      map['sim_type'] = Variable<String>(simType.value);
    }
    if (wholesaleCost.present) {
      map['wholesale_cost'] = Variable<double>(wholesaleCost.value);
    }
    if (retailPrice.present) {
      map['retail_price'] = Variable<double>(retailPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PackagesTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('simType: $simType, ')
          ..write('wholesaleCost: $wholesaleCost, ')
          ..write('retailPrice: $retailPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTableTable extends CustomersTable
    with TableInfo<$CustomersTableTable, CustomersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNumberMeta = const VerificationMeta(
    'contactNumber',
  );
  @override
  late final GeneratedColumn<String> contactNumber = GeneratedColumn<String>(
    'contact_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('normal'),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    id,
    name,
    contactNumber,
    status,
    tags,
    pinned,
    notes,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
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
    if (data.containsKey('contact_number')) {
      context.handle(
        _contactNumberMeta,
        contactNumber.isAcceptableOrUnknown(
          data['contact_number']!,
          _contactNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomersTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $CustomersTableTable createAlias(String alias) {
    return $CustomersTableTable(attachedDatabase, alias);
  }
}

class CustomersTableData extends DataClass
    implements Insertable<CustomersTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String id;
  final String name;
  final String contactNumber;
  final String status;

  /// Comma-joined free-text tags — mirrors Postgres' `text[]`. A `,` in a
  /// tag itself isn't supported, consistent with tags being short labels
  /// picked from quick suggestions rather than free sentences.
  final String tags;
  final bool pinned;
  final String? notes;
  final bool deleted;
  const CustomersTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.status,
    required this.tags,
    required this.pinned,
    this.notes,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['contact_number'] = Variable<String>(contactNumber);
    map['status'] = Variable<String>(status);
    map['tags'] = Variable<String>(tags);
    map['pinned'] = Variable<bool>(pinned);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  CustomersTableCompanion toCompanion(bool nullToAbsent) {
    return CustomersTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      contactNumber: Value(contactNumber),
      status: Value(status),
      tags: Value(tags),
      pinned: Value(pinned),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      deleted: Value(deleted),
    );
  }

  factory CustomersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomersTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactNumber: serializer.fromJson<String>(json['contactNumber']),
      status: serializer.fromJson<String>(json['status']),
      tags: serializer.fromJson<String>(json['tags']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      notes: serializer.fromJson<String?>(json['notes']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'contactNumber': serializer.toJson<String>(contactNumber),
      'status': serializer.toJson<String>(status),
      'tags': serializer.toJson<String>(tags),
      'pinned': serializer.toJson<bool>(pinned),
      'notes': serializer.toJson<String?>(notes),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  CustomersTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? id,
    String? name,
    String? contactNumber,
    String? status,
    String? tags,
    bool? pinned,
    Value<String?> notes = const Value.absent(),
    bool? deleted,
  }) => CustomersTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    contactNumber: contactNumber ?? this.contactNumber,
    status: status ?? this.status,
    tags: tags ?? this.tags,
    pinned: pinned ?? this.pinned,
    notes: notes.present ? notes.value : this.notes,
    deleted: deleted ?? this.deleted,
  );
  CustomersTableData copyWithCompanion(CustomersTableCompanion data) {
    return CustomersTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactNumber: data.contactNumber.present
          ? data.contactNumber.value
          : this.contactNumber,
      status: data.status.present ? data.status.value : this.status,
      tags: data.tags.present ? data.tags.value : this.tags,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      notes: data.notes.present ? data.notes.value : this.notes,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('status: $status, ')
          ..write('tags: $tags, ')
          ..write('pinned: $pinned, ')
          ..write('notes: $notes, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    id,
    name,
    contactNumber,
    status,
    tags,
    pinned,
    notes,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomersTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactNumber == this.contactNumber &&
          other.status == this.status &&
          other.tags == this.tags &&
          other.pinned == this.pinned &&
          other.notes == this.notes &&
          other.deleted == this.deleted);
}

class CustomersTableCompanion extends UpdateCompanion<CustomersTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String> contactNumber;
  final Value<String> status;
  final Value<String> tags;
  final Value<bool> pinned;
  final Value<String?> notes;
  final Value<bool> deleted;
  final Value<int> rowid;
  const CustomersTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.tags = const Value.absent(),
    this.pinned = const Value.absent(),
    this.notes = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String id,
    required String name,
    required String contactNumber,
    this.status = const Value.absent(),
    this.tags = const Value.absent(),
    this.pinned = const Value.absent(),
    this.notes = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       name = Value(name),
       contactNumber = Value(contactNumber);
  static Insertable<CustomersTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? contactNumber,
    Expression<String>? status,
    Expression<String>? tags,
    Expression<bool>? pinned,
    Expression<String>? notes,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (status != null) 'status': status,
      if (tags != null) 'tags': tags,
      if (pinned != null) 'pinned': pinned,
      if (notes != null) 'notes': notes,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String>? contactNumber,
    Value<String>? status,
    Value<String>? tags,
    Value<bool>? pinned,
    Value<String?>? notes,
    Value<bool>? deleted,
    Value<int>? rowid,
  }) {
    return CustomersTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      pinned: pinned ?? this.pinned,
      notes: notes ?? this.notes,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactNumber.present) {
      map['contact_number'] = Variable<String>(contactNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('status: $status, ')
          ..write('tags: $tags, ')
          ..write('pinned: $pinned, ')
          ..write('notes: $notes, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShipmentsTableTable extends ShipmentsTable
    with TableInfo<$ShipmentsTableTable, ShipmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShipmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _amountRemainingMeta = const VerificationMeta(
    'amountRemaining',
  );
  @override
  late final GeneratedColumn<double> amountRemaining = GeneratedColumn<double>(
    'amount_remaining',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shipmentDateMeta = const VerificationMeta(
    'shipmentDate',
  );
  @override
  late final GeneratedColumn<DateTime> shipmentDate = GeneratedColumn<DateTime>(
    'shipment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    id,
    companyId,
    type,
    totalAmount,
    amountPaid,
    amountRemaining,
    paymentMethod,
    referenceNumber,
    shipmentDate,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shipments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShipmentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('amount_remaining')) {
      context.handle(
        _amountRemainingMeta,
        amountRemaining.isAcceptableOrUnknown(
          data['amount_remaining']!,
          _amountRemainingMeta,
        ),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('shipment_date')) {
      context.handle(
        _shipmentDateMeta,
        shipmentDate.isAcceptableOrUnknown(
          data['shipment_date']!,
          _shipmentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shipmentDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShipmentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShipmentsTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      amountRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_remaining'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      shipmentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}shipment_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ShipmentsTableTable createAlias(String alias) {
    return $ShipmentsTableTable(attachedDatabase, alias);
  }
}

class ShipmentsTableData extends DataClass
    implements Insertable<ShipmentsTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String id;
  final String companyId;
  final String type;
  final double totalAmount;
  final double amountPaid;
  final double amountRemaining;
  final String? paymentMethod;
  final String? referenceNumber;
  final DateTime shipmentDate;
  final String? notes;
  const ShipmentsTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.id,
    required this.companyId,
    required this.type,
    required this.totalAmount,
    required this.amountPaid,
    required this.amountRemaining,
    this.paymentMethod,
    this.referenceNumber,
    required this.shipmentDate,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['type'] = Variable<String>(type);
    map['total_amount'] = Variable<double>(totalAmount);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['amount_remaining'] = Variable<double>(amountRemaining);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    map['shipment_date'] = Variable<DateTime>(shipmentDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ShipmentsTableCompanion toCompanion(bool nullToAbsent) {
    return ShipmentsTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      id: Value(id),
      companyId: Value(companyId),
      type: Value(type),
      totalAmount: Value(totalAmount),
      amountPaid: Value(amountPaid),
      amountRemaining: Value(amountRemaining),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      shipmentDate: Value(shipmentDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ShipmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShipmentsTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      type: serializer.fromJson<String>(json['type']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      amountRemaining: serializer.fromJson<double>(json['amountRemaining']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      shipmentDate: serializer.fromJson<DateTime>(json['shipmentDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'type': serializer.toJson<String>(type),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'amountRemaining': serializer.toJson<double>(amountRemaining),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'shipmentDate': serializer.toJson<DateTime>(shipmentDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ShipmentsTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? id,
    String? companyId,
    String? type,
    double? totalAmount,
    double? amountPaid,
    double? amountRemaining,
    Value<String?> paymentMethod = const Value.absent(),
    Value<String?> referenceNumber = const Value.absent(),
    DateTime? shipmentDate,
    Value<String?> notes = const Value.absent(),
  }) => ShipmentsTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    type: type ?? this.type,
    totalAmount: totalAmount ?? this.totalAmount,
    amountPaid: amountPaid ?? this.amountPaid,
    amountRemaining: amountRemaining ?? this.amountRemaining,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    shipmentDate: shipmentDate ?? this.shipmentDate,
    notes: notes.present ? notes.value : this.notes,
  );
  ShipmentsTableData copyWithCompanion(ShipmentsTableCompanion data) {
    return ShipmentsTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      type: data.type.present ? data.type.value : this.type,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      amountRemaining: data.amountRemaining.present
          ? data.amountRemaining.value
          : this.amountRemaining,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      shipmentDate: data.shipmentDate.present
          ? data.shipmentDate.value
          : this.shipmentDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShipmentsTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('type: $type, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('amountRemaining: $amountRemaining, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('shipmentDate: $shipmentDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    id,
    companyId,
    type,
    totalAmount,
    amountPaid,
    amountRemaining,
    paymentMethod,
    referenceNumber,
    shipmentDate,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShipmentsTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.type == this.type &&
          other.totalAmount == this.totalAmount &&
          other.amountPaid == this.amountPaid &&
          other.amountRemaining == this.amountRemaining &&
          other.paymentMethod == this.paymentMethod &&
          other.referenceNumber == this.referenceNumber &&
          other.shipmentDate == this.shipmentDate &&
          other.notes == this.notes);
}

class ShipmentsTableCompanion extends UpdateCompanion<ShipmentsTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> type;
  final Value<double> totalAmount;
  final Value<double> amountPaid;
  final Value<double> amountRemaining;
  final Value<String?> paymentMethod;
  final Value<String?> referenceNumber;
  final Value<DateTime> shipmentDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const ShipmentsTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.type = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.amountRemaining = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.shipmentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShipmentsTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String id,
    required String companyId,
    required String type,
    this.totalAmount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.amountRemaining = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    required DateTime shipmentDate,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       companyId = Value(companyId),
       type = Value(type),
       shipmentDate = Value(shipmentDate);
  static Insertable<ShipmentsTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? type,
    Expression<double>? totalAmount,
    Expression<double>? amountPaid,
    Expression<double>? amountRemaining,
    Expression<String>? paymentMethod,
    Expression<String>? referenceNumber,
    Expression<DateTime>? shipmentDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (type != null) 'type': type,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (amountRemaining != null) 'amount_remaining': amountRemaining,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (shipmentDate != null) 'shipment_date': shipmentDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShipmentsTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? type,
    Value<double>? totalAmount,
    Value<double>? amountPaid,
    Value<double>? amountRemaining,
    Value<String?>? paymentMethod,
    Value<String?>? referenceNumber,
    Value<DateTime>? shipmentDate,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ShipmentsTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      amountRemaining: amountRemaining ?? this.amountRemaining,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      shipmentDate: shipmentDate ?? this.shipmentDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (amountRemaining.present) {
      map['amount_remaining'] = Variable<double>(amountRemaining.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (shipmentDate.present) {
      map['shipment_date'] = Variable<DateTime>(shipmentDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShipmentsTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('type: $type, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('amountRemaining: $amountRemaining, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('shipmentDate: $shipmentDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LinesTableTable extends LinesTable
    with TableInfo<$LinesTableTable, LinesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES packages (id)',
    ),
  );
  static const VerificationMeta _simNumberMeta = const VerificationMeta(
    'simNumber',
  );
  @override
  late final GeneratedColumn<String> simNumber = GeneratedColumn<String>(
    'sim_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyNameMeta = const VerificationMeta(
    'companyName',
  );
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
    'company_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyInitialsMeta = const VerificationMeta(
    'companyInitials',
  );
  @override
  late final GeneratedColumn<String> companyInitials = GeneratedColumn<String>(
    'company_initials',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packageSimTypeMeta = const VerificationMeta(
    'packageSimType',
  );
  @override
  late final GeneratedColumn<String> packageSimType = GeneratedColumn<String>(
    'package_sim_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wholesaleCostMeta = const VerificationMeta(
    'wholesaleCost',
  );
  @override
  late final GeneratedColumn<double> wholesaleCost = GeneratedColumn<double>(
    'wholesale_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _retailPriceMeta = const VerificationMeta(
    'retailPrice',
  );
  @override
  late final GeneratedColumn<double> retailPrice = GeneratedColumn<double>(
    'retail_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _profitMeta = const VerificationMeta('profit');
  @override
  late final GeneratedColumn<double> profit = GeneratedColumn<double>(
    'profit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unpaid'),
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _amountRemainingMeta = const VerificationMeta(
    'amountRemaining',
  );
  @override
  late final GeneratedColumn<double> amountRemaining = GeneratedColumn<double>(
    'amount_remaining',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    id,
    customerId,
    companyId,
    packageId,
    simNumber,
    companyName,
    companyInitials,
    packageName,
    packageSimType,
    purchaseDate,
    expiryDate,
    wholesaleCost,
    retailPrice,
    profit,
    paymentStatus,
    amountPaid,
    amountRemaining,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    }
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    }
    if (data.containsKey('sim_number')) {
      context.handle(
        _simNumberMeta,
        simNumber.isAcceptableOrUnknown(data['sim_number']!, _simNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_simNumberMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
        _companyNameMeta,
        companyName.isAcceptableOrUnknown(
          data['company_name']!,
          _companyNameMeta,
        ),
      );
    }
    if (data.containsKey('company_initials')) {
      context.handle(
        _companyInitialsMeta,
        companyInitials.isAcceptableOrUnknown(
          data['company_initials']!,
          _companyInitialsMeta,
        ),
      );
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    }
    if (data.containsKey('package_sim_type')) {
      context.handle(
        _packageSimTypeMeta,
        packageSimType.isAcceptableOrUnknown(
          data['package_sim_type']!,
          _packageSimTypeMeta,
        ),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('wholesale_cost')) {
      context.handle(
        _wholesaleCostMeta,
        wholesaleCost.isAcceptableOrUnknown(
          data['wholesale_cost']!,
          _wholesaleCostMeta,
        ),
      );
    }
    if (data.containsKey('retail_price')) {
      context.handle(
        _retailPriceMeta,
        retailPrice.isAcceptableOrUnknown(
          data['retail_price']!,
          _retailPriceMeta,
        ),
      );
    }
    if (data.containsKey('profit')) {
      context.handle(
        _profitMeta,
        profit.isAcceptableOrUnknown(data['profit']!, _profitMeta),
      );
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('amount_remaining')) {
      context.handle(
        _amountRemainingMeta,
        amountRemaining.isAcceptableOrUnknown(
          data['amount_remaining']!,
          _amountRemainingMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LinesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinesTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      ),
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      ),
      simNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sim_number'],
      )!,
      companyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name'],
      ),
      companyInitials: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_initials'],
      ),
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      ),
      packageSimType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_sim_type'],
      ),
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      wholesaleCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wholesale_cost'],
      )!,
      retailPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}retail_price'],
      )!,
      profit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}profit'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      amountRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_remaining'],
      )!,
    );
  }

  @override
  $LinesTableTable createAlias(String alias) {
    return $LinesTableTable(attachedDatabase, alias);
  }
}

class LinesTableData extends DataClass implements Insertable<LinesTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String id;
  final String customerId;
  final String? companyId;
  final String? packageId;
  final String simNumber;
  final String? companyName;
  final String? companyInitials;
  final String? packageName;
  final String? packageSimType;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double wholesaleCost;
  final double retailPrice;
  final double profit;
  final String paymentStatus;
  final double amountPaid;
  final double amountRemaining;
  const LinesTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.id,
    required this.customerId,
    this.companyId,
    this.packageId,
    required this.simNumber,
    this.companyName,
    this.companyInitials,
    this.packageName,
    this.packageSimType,
    required this.purchaseDate,
    required this.expiryDate,
    required this.wholesaleCost,
    required this.retailPrice,
    required this.profit,
    required this.paymentStatus,
    required this.amountPaid,
    required this.amountRemaining,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || companyId != null) {
      map['company_id'] = Variable<String>(companyId);
    }
    if (!nullToAbsent || packageId != null) {
      map['package_id'] = Variable<String>(packageId);
    }
    map['sim_number'] = Variable<String>(simNumber);
    if (!nullToAbsent || companyName != null) {
      map['company_name'] = Variable<String>(companyName);
    }
    if (!nullToAbsent || companyInitials != null) {
      map['company_initials'] = Variable<String>(companyInitials);
    }
    if (!nullToAbsent || packageName != null) {
      map['package_name'] = Variable<String>(packageName);
    }
    if (!nullToAbsent || packageSimType != null) {
      map['package_sim_type'] = Variable<String>(packageSimType);
    }
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    map['wholesale_cost'] = Variable<double>(wholesaleCost);
    map['retail_price'] = Variable<double>(retailPrice);
    map['profit'] = Variable<double>(profit);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['amount_remaining'] = Variable<double>(amountRemaining);
    return map;
  }

  LinesTableCompanion toCompanion(bool nullToAbsent) {
    return LinesTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      id: Value(id),
      customerId: Value(customerId),
      companyId: companyId == null && nullToAbsent
          ? const Value.absent()
          : Value(companyId),
      packageId: packageId == null && nullToAbsent
          ? const Value.absent()
          : Value(packageId),
      simNumber: Value(simNumber),
      companyName: companyName == null && nullToAbsent
          ? const Value.absent()
          : Value(companyName),
      companyInitials: companyInitials == null && nullToAbsent
          ? const Value.absent()
          : Value(companyInitials),
      packageName: packageName == null && nullToAbsent
          ? const Value.absent()
          : Value(packageName),
      packageSimType: packageSimType == null && nullToAbsent
          ? const Value.absent()
          : Value(packageSimType),
      purchaseDate: Value(purchaseDate),
      expiryDate: Value(expiryDate),
      wholesaleCost: Value(wholesaleCost),
      retailPrice: Value(retailPrice),
      profit: Value(profit),
      paymentStatus: Value(paymentStatus),
      amountPaid: Value(amountPaid),
      amountRemaining: Value(amountRemaining),
    );
  }

  factory LinesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinesTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      companyId: serializer.fromJson<String?>(json['companyId']),
      packageId: serializer.fromJson<String?>(json['packageId']),
      simNumber: serializer.fromJson<String>(json['simNumber']),
      companyName: serializer.fromJson<String?>(json['companyName']),
      companyInitials: serializer.fromJson<String?>(json['companyInitials']),
      packageName: serializer.fromJson<String?>(json['packageName']),
      packageSimType: serializer.fromJson<String?>(json['packageSimType']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      wholesaleCost: serializer.fromJson<double>(json['wholesaleCost']),
      retailPrice: serializer.fromJson<double>(json['retailPrice']),
      profit: serializer.fromJson<double>(json['profit']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      amountRemaining: serializer.fromJson<double>(json['amountRemaining']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'companyId': serializer.toJson<String?>(companyId),
      'packageId': serializer.toJson<String?>(packageId),
      'simNumber': serializer.toJson<String>(simNumber),
      'companyName': serializer.toJson<String?>(companyName),
      'companyInitials': serializer.toJson<String?>(companyInitials),
      'packageName': serializer.toJson<String?>(packageName),
      'packageSimType': serializer.toJson<String?>(packageSimType),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'wholesaleCost': serializer.toJson<double>(wholesaleCost),
      'retailPrice': serializer.toJson<double>(retailPrice),
      'profit': serializer.toJson<double>(profit),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'amountRemaining': serializer.toJson<double>(amountRemaining),
    };
  }

  LinesTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? id,
    String? customerId,
    Value<String?> companyId = const Value.absent(),
    Value<String?> packageId = const Value.absent(),
    String? simNumber,
    Value<String?> companyName = const Value.absent(),
    Value<String?> companyInitials = const Value.absent(),
    Value<String?> packageName = const Value.absent(),
    Value<String?> packageSimType = const Value.absent(),
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? wholesaleCost,
    double? retailPrice,
    double? profit,
    String? paymentStatus,
    double? amountPaid,
    double? amountRemaining,
  }) => LinesTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    companyId: companyId.present ? companyId.value : this.companyId,
    packageId: packageId.present ? packageId.value : this.packageId,
    simNumber: simNumber ?? this.simNumber,
    companyName: companyName.present ? companyName.value : this.companyName,
    companyInitials: companyInitials.present
        ? companyInitials.value
        : this.companyInitials,
    packageName: packageName.present ? packageName.value : this.packageName,
    packageSimType: packageSimType.present
        ? packageSimType.value
        : this.packageSimType,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    expiryDate: expiryDate ?? this.expiryDate,
    wholesaleCost: wholesaleCost ?? this.wholesaleCost,
    retailPrice: retailPrice ?? this.retailPrice,
    profit: profit ?? this.profit,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    amountPaid: amountPaid ?? this.amountPaid,
    amountRemaining: amountRemaining ?? this.amountRemaining,
  );
  LinesTableData copyWithCompanion(LinesTableCompanion data) {
    return LinesTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      simNumber: data.simNumber.present ? data.simNumber.value : this.simNumber,
      companyName: data.companyName.present
          ? data.companyName.value
          : this.companyName,
      companyInitials: data.companyInitials.present
          ? data.companyInitials.value
          : this.companyInitials,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      packageSimType: data.packageSimType.present
          ? data.packageSimType.value
          : this.packageSimType,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      wholesaleCost: data.wholesaleCost.present
          ? data.wholesaleCost.value
          : this.wholesaleCost,
      retailPrice: data.retailPrice.present
          ? data.retailPrice.value
          : this.retailPrice,
      profit: data.profit.present ? data.profit.value : this.profit,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      amountRemaining: data.amountRemaining.present
          ? data.amountRemaining.value
          : this.amountRemaining,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinesTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('companyId: $companyId, ')
          ..write('packageId: $packageId, ')
          ..write('simNumber: $simNumber, ')
          ..write('companyName: $companyName, ')
          ..write('companyInitials: $companyInitials, ')
          ..write('packageName: $packageName, ')
          ..write('packageSimType: $packageSimType, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('wholesaleCost: $wholesaleCost, ')
          ..write('retailPrice: $retailPrice, ')
          ..write('profit: $profit, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('amountRemaining: $amountRemaining')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    id,
    customerId,
    companyId,
    packageId,
    simNumber,
    companyName,
    companyInitials,
    packageName,
    packageSimType,
    purchaseDate,
    expiryDate,
    wholesaleCost,
    retailPrice,
    profit,
    paymentStatus,
    amountPaid,
    amountRemaining,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinesTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.companyId == this.companyId &&
          other.packageId == this.packageId &&
          other.simNumber == this.simNumber &&
          other.companyName == this.companyName &&
          other.companyInitials == this.companyInitials &&
          other.packageName == this.packageName &&
          other.packageSimType == this.packageSimType &&
          other.purchaseDate == this.purchaseDate &&
          other.expiryDate == this.expiryDate &&
          other.wholesaleCost == this.wholesaleCost &&
          other.retailPrice == this.retailPrice &&
          other.profit == this.profit &&
          other.paymentStatus == this.paymentStatus &&
          other.amountPaid == this.amountPaid &&
          other.amountRemaining == this.amountRemaining);
}

class LinesTableCompanion extends UpdateCompanion<LinesTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> customerId;
  final Value<String?> companyId;
  final Value<String?> packageId;
  final Value<String> simNumber;
  final Value<String?> companyName;
  final Value<String?> companyInitials;
  final Value<String?> packageName;
  final Value<String?> packageSimType;
  final Value<DateTime> purchaseDate;
  final Value<DateTime> expiryDate;
  final Value<double> wholesaleCost;
  final Value<double> retailPrice;
  final Value<double> profit;
  final Value<String> paymentStatus;
  final Value<double> amountPaid;
  final Value<double> amountRemaining;
  final Value<int> rowid;
  const LinesTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.packageId = const Value.absent(),
    this.simNumber = const Value.absent(),
    this.companyName = const Value.absent(),
    this.companyInitials = const Value.absent(),
    this.packageName = const Value.absent(),
    this.packageSimType = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.wholesaleCost = const Value.absent(),
    this.retailPrice = const Value.absent(),
    this.profit = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.amountRemaining = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LinesTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String id,
    required String customerId,
    this.companyId = const Value.absent(),
    this.packageId = const Value.absent(),
    required String simNumber,
    this.companyName = const Value.absent(),
    this.companyInitials = const Value.absent(),
    this.packageName = const Value.absent(),
    this.packageSimType = const Value.absent(),
    required DateTime purchaseDate,
    required DateTime expiryDate,
    this.wholesaleCost = const Value.absent(),
    this.retailPrice = const Value.absent(),
    this.profit = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.amountRemaining = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       customerId = Value(customerId),
       simNumber = Value(simNumber),
       purchaseDate = Value(purchaseDate),
       expiryDate = Value(expiryDate);
  static Insertable<LinesTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? companyId,
    Expression<String>? packageId,
    Expression<String>? simNumber,
    Expression<String>? companyName,
    Expression<String>? companyInitials,
    Expression<String>? packageName,
    Expression<String>? packageSimType,
    Expression<DateTime>? purchaseDate,
    Expression<DateTime>? expiryDate,
    Expression<double>? wholesaleCost,
    Expression<double>? retailPrice,
    Expression<double>? profit,
    Expression<String>? paymentStatus,
    Expression<double>? amountPaid,
    Expression<double>? amountRemaining,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (companyId != null) 'company_id': companyId,
      if (packageId != null) 'package_id': packageId,
      if (simNumber != null) 'sim_number': simNumber,
      if (companyName != null) 'company_name': companyName,
      if (companyInitials != null) 'company_initials': companyInitials,
      if (packageName != null) 'package_name': packageName,
      if (packageSimType != null) 'package_sim_type': packageSimType,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (wholesaleCost != null) 'wholesale_cost': wholesaleCost,
      if (retailPrice != null) 'retail_price': retailPrice,
      if (profit != null) 'profit': profit,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (amountRemaining != null) 'amount_remaining': amountRemaining,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LinesTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? customerId,
    Value<String?>? companyId,
    Value<String?>? packageId,
    Value<String>? simNumber,
    Value<String?>? companyName,
    Value<String?>? companyInitials,
    Value<String?>? packageName,
    Value<String?>? packageSimType,
    Value<DateTime>? purchaseDate,
    Value<DateTime>? expiryDate,
    Value<double>? wholesaleCost,
    Value<double>? retailPrice,
    Value<double>? profit,
    Value<String>? paymentStatus,
    Value<double>? amountPaid,
    Value<double>? amountRemaining,
    Value<int>? rowid,
  }) {
    return LinesTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      companyId: companyId ?? this.companyId,
      packageId: packageId ?? this.packageId,
      simNumber: simNumber ?? this.simNumber,
      companyName: companyName ?? this.companyName,
      companyInitials: companyInitials ?? this.companyInitials,
      packageName: packageName ?? this.packageName,
      packageSimType: packageSimType ?? this.packageSimType,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      wholesaleCost: wholesaleCost ?? this.wholesaleCost,
      retailPrice: retailPrice ?? this.retailPrice,
      profit: profit ?? this.profit,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      amountRemaining: amountRemaining ?? this.amountRemaining,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (simNumber.present) {
      map['sim_number'] = Variable<String>(simNumber.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (companyInitials.present) {
      map['company_initials'] = Variable<String>(companyInitials.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (packageSimType.present) {
      map['package_sim_type'] = Variable<String>(packageSimType.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (wholesaleCost.present) {
      map['wholesale_cost'] = Variable<double>(wholesaleCost.value);
    }
    if (retailPrice.present) {
      map['retail_price'] = Variable<double>(retailPrice.value);
    }
    if (profit.present) {
      map['profit'] = Variable<double>(profit.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (amountRemaining.present) {
      map['amount_remaining'] = Variable<double>(amountRemaining.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinesTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('companyId: $companyId, ')
          ..write('packageId: $packageId, ')
          ..write('simNumber: $simNumber, ')
          ..write('companyName: $companyName, ')
          ..write('companyInitials: $companyInitials, ')
          ..write('packageName: $packageName, ')
          ..write('packageSimType: $packageSimType, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('wholesaleCost: $wholesaleCost, ')
          ..write('retailPrice: $retailPrice, ')
          ..write('profit: $profit, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('amountRemaining: $amountRemaining, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperationsTableTable extends OperationsTable
    with TableInfo<$OperationsTableTable, OperationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<String> lineId = GeneratedColumn<String>(
    'line_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lines (id)',
    ),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
    'sale_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _profitMeta = const VerificationMeta('profit');
  @override
  late final GeneratedColumn<double> profit = GeneratedColumn<double>(
    'profit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unpaid'),
  );
  static const VerificationMeta _repNameMeta = const VerificationMeta(
    'repName',
  );
  @override
  late final GeneratedColumn<String> repName = GeneratedColumn<String>(
    'rep_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    id,
    customerId,
    lineId,
    companyId,
    occurredAt,
    salePrice,
    cost,
    profit,
    paymentStatus,
    repName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('line_id')) {
      context.handle(
        _lineIdMeta,
        lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta),
      );
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('profit')) {
      context.handle(
        _profitMeta,
        profit.isAcceptableOrUnknown(data['profit']!, _profitMeta),
      );
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    }
    if (data.containsKey('rep_name')) {
      context.handle(
        _repNameMeta,
        repName.isAcceptableOrUnknown(data['rep_name']!, _repNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OperationsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationsTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      lineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_id'],
      ),
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sale_price'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      profit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}profit'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      repName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rep_name'],
      ),
    );
  }

  @override
  $OperationsTableTable createAlias(String alias) {
    return $OperationsTableTable(attachedDatabase, alias);
  }
}

class OperationsTableData extends DataClass
    implements Insertable<OperationsTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String id;
  final String customerId;
  final String? lineId;
  final String companyId;
  final DateTime occurredAt;
  final double salePrice;
  final double cost;
  final double profit;
  final String paymentStatus;
  final String? repName;
  const OperationsTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.id,
    required this.customerId,
    this.lineId,
    required this.companyId,
    required this.occurredAt,
    required this.salePrice,
    required this.cost,
    required this.profit,
    required this.paymentStatus,
    this.repName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || lineId != null) {
      map['line_id'] = Variable<String>(lineId);
    }
    map['company_id'] = Variable<String>(companyId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['sale_price'] = Variable<double>(salePrice);
    map['cost'] = Variable<double>(cost);
    map['profit'] = Variable<double>(profit);
    map['payment_status'] = Variable<String>(paymentStatus);
    if (!nullToAbsent || repName != null) {
      map['rep_name'] = Variable<String>(repName);
    }
    return map;
  }

  OperationsTableCompanion toCompanion(bool nullToAbsent) {
    return OperationsTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      id: Value(id),
      customerId: Value(customerId),
      lineId: lineId == null && nullToAbsent
          ? const Value.absent()
          : Value(lineId),
      companyId: Value(companyId),
      occurredAt: Value(occurredAt),
      salePrice: Value(salePrice),
      cost: Value(cost),
      profit: Value(profit),
      paymentStatus: Value(paymentStatus),
      repName: repName == null && nullToAbsent
          ? const Value.absent()
          : Value(repName),
    );
  }

  factory OperationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationsTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      lineId: serializer.fromJson<String?>(json['lineId']),
      companyId: serializer.fromJson<String>(json['companyId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      salePrice: serializer.fromJson<double>(json['salePrice']),
      cost: serializer.fromJson<double>(json['cost']),
      profit: serializer.fromJson<double>(json['profit']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      repName: serializer.fromJson<String?>(json['repName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'lineId': serializer.toJson<String?>(lineId),
      'companyId': serializer.toJson<String>(companyId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'salePrice': serializer.toJson<double>(salePrice),
      'cost': serializer.toJson<double>(cost),
      'profit': serializer.toJson<double>(profit),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'repName': serializer.toJson<String?>(repName),
    };
  }

  OperationsTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? id,
    String? customerId,
    Value<String?> lineId = const Value.absent(),
    String? companyId,
    DateTime? occurredAt,
    double? salePrice,
    double? cost,
    double? profit,
    String? paymentStatus,
    Value<String?> repName = const Value.absent(),
  }) => OperationsTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    lineId: lineId.present ? lineId.value : this.lineId,
    companyId: companyId ?? this.companyId,
    occurredAt: occurredAt ?? this.occurredAt,
    salePrice: salePrice ?? this.salePrice,
    cost: cost ?? this.cost,
    profit: profit ?? this.profit,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    repName: repName.present ? repName.value : this.repName,
  );
  OperationsTableData copyWithCompanion(OperationsTableCompanion data) {
    return OperationsTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      cost: data.cost.present ? data.cost.value : this.cost,
      profit: data.profit.present ? data.profit.value : this.profit,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      repName: data.repName.present ? data.repName.value : this.repName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationsTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('lineId: $lineId, ')
          ..write('companyId: $companyId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('salePrice: $salePrice, ')
          ..write('cost: $cost, ')
          ..write('profit: $profit, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('repName: $repName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    id,
    customerId,
    lineId,
    companyId,
    occurredAt,
    salePrice,
    cost,
    profit,
    paymentStatus,
    repName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationsTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.lineId == this.lineId &&
          other.companyId == this.companyId &&
          other.occurredAt == this.occurredAt &&
          other.salePrice == this.salePrice &&
          other.cost == this.cost &&
          other.profit == this.profit &&
          other.paymentStatus == this.paymentStatus &&
          other.repName == this.repName);
}

class OperationsTableCompanion extends UpdateCompanion<OperationsTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> customerId;
  final Value<String?> lineId;
  final Value<String> companyId;
  final Value<DateTime> occurredAt;
  final Value<double> salePrice;
  final Value<double> cost;
  final Value<double> profit;
  final Value<String> paymentStatus;
  final Value<String?> repName;
  final Value<int> rowid;
  const OperationsTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.lineId = const Value.absent(),
    this.companyId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.cost = const Value.absent(),
    this.profit = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.repName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationsTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String id,
    required String customerId,
    this.lineId = const Value.absent(),
    required String companyId,
    required DateTime occurredAt,
    this.salePrice = const Value.absent(),
    this.cost = const Value.absent(),
    this.profit = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.repName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       customerId = Value(customerId),
       companyId = Value(companyId),
       occurredAt = Value(occurredAt);
  static Insertable<OperationsTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? lineId,
    Expression<String>? companyId,
    Expression<DateTime>? occurredAt,
    Expression<double>? salePrice,
    Expression<double>? cost,
    Expression<double>? profit,
    Expression<String>? paymentStatus,
    Expression<String>? repName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (lineId != null) 'line_id': lineId,
      if (companyId != null) 'company_id': companyId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (salePrice != null) 'sale_price': salePrice,
      if (cost != null) 'cost': cost,
      if (profit != null) 'profit': profit,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (repName != null) 'rep_name': repName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperationsTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? customerId,
    Value<String?>? lineId,
    Value<String>? companyId,
    Value<DateTime>? occurredAt,
    Value<double>? salePrice,
    Value<double>? cost,
    Value<double>? profit,
    Value<String>? paymentStatus,
    Value<String?>? repName,
    Value<int>? rowid,
  }) {
    return OperationsTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      lineId: lineId ?? this.lineId,
      companyId: companyId ?? this.companyId,
      occurredAt: occurredAt ?? this.occurredAt,
      salePrice: salePrice ?? this.salePrice,
      cost: cost ?? this.cost,
      profit: profit ?? this.profit,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      repName: repName ?? this.repName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (lineId.present) {
      map['line_id'] = Variable<String>(lineId.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (profit.present) {
      map['profit'] = Variable<double>(profit.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (repName.present) {
      map['rep_name'] = Variable<String>(repName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperationsTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('lineId: $lineId, ')
          ..write('companyId: $companyId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('salePrice: $salePrice, ')
          ..write('cost: $cost, ')
          ..write('profit: $profit, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('repName: $repName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogTableTable extends ActivityLogTable
    with TableInfo<$ActivityLogTableTable, ActivityLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    id,
    occurredAt,
    actionType,
    details,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityLogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLogTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
    );
  }

  @override
  $ActivityLogTableTable createAlias(String alias) {
    return $ActivityLogTableTable(attachedDatabase, alias);
  }
}

class ActivityLogTableData extends DataClass
    implements Insertable<ActivityLogTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String id;
  final DateTime occurredAt;
  final String actionType;
  final String? details;
  const ActivityLogTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.id,
    required this.occurredAt,
    required this.actionType,
    this.details,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['action_type'] = Variable<String>(actionType);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    return map;
  }

  ActivityLogTableCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      id: Value(id),
      occurredAt: Value(occurredAt),
      actionType: Value(actionType),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
    );
  }

  factory ActivityLogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLogTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      actionType: serializer.fromJson<String>(json['actionType']),
      details: serializer.fromJson<String?>(json['details']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'actionType': serializer.toJson<String>(actionType),
      'details': serializer.toJson<String?>(details),
    };
  }

  ActivityLogTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? id,
    DateTime? occurredAt,
    String? actionType,
    Value<String?> details = const Value.absent(),
  }) => ActivityLogTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    occurredAt: occurredAt ?? this.occurredAt,
    actionType: actionType ?? this.actionType,
    details: details.present ? details.value : this.details,
  );
  ActivityLogTableData copyWithCompanion(ActivityLogTableCompanion data) {
    return ActivityLogTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      details: data.details.present ? data.details.value : this.details,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('actionType: $actionType, ')
          ..write('details: $details')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    id,
    occurredAt,
    actionType,
    details,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLogTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.occurredAt == this.occurredAt &&
          other.actionType == this.actionType &&
          other.details == this.details);
}

class ActivityLogTableCompanion extends UpdateCompanion<ActivityLogTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<DateTime> occurredAt;
  final Value<String> actionType;
  final Value<String?> details;
  final Value<int> rowid;
  const ActivityLogTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.actionType = const Value.absent(),
    this.details = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityLogTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String id,
    required DateTime occurredAt,
    required String actionType,
    this.details = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       occurredAt = Value(occurredAt),
       actionType = Value(actionType);
  static Insertable<ActivityLogTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<DateTime>? occurredAt,
    Expression<String>? actionType,
    Expression<String>? details,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (actionType != null) 'action_type': actionType,
      if (details != null) 'details': details,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityLogTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<DateTime>? occurredAt,
    Value<String>? actionType,
    Value<String?>? details,
    Value<int>? rowid,
  }) {
    return ActivityLogTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      occurredAt: occurredAt ?? this.occurredAt,
      actionType: actionType ?? this.actionType,
      details: details ?? this.details,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('actionType: $actionType, ')
          ..write('details: $details, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupportRequestsTableTable extends SupportRequestsTable
    with TableInfo<$SupportRequestsTableTable, SupportRequestsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupportRequestsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attachmentUrlMeta = const VerificationMeta(
    'attachmentUrl',
  );
  @override
  late final GeneratedColumn<String> attachmentUrl = GeneratedColumn<String>(
    'attachment_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceNoteUrlMeta = const VerificationMeta(
    'voiceNoteUrl',
  );
  @override
  late final GeneratedColumn<String> voiceNoteUrl = GeneratedColumn<String>(
    'voice_note_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    id,
    type,
    body,
    attachmentUrl,
    voiceNoteUrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'support_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupportRequestsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('attachment_url')) {
      context.handle(
        _attachmentUrlMeta,
        attachmentUrl.isAcceptableOrUnknown(
          data['attachment_url']!,
          _attachmentUrlMeta,
        ),
      );
    }
    if (data.containsKey('voice_note_url')) {
      context.handle(
        _voiceNoteUrlMeta,
        voiceNoteUrl.isAcceptableOrUnknown(
          data['voice_note_url']!,
          _voiceNoteUrlMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupportRequestsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupportRequestsTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      attachmentUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_url'],
      ),
      voiceNoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_note_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SupportRequestsTableTable createAlias(String alias) {
    return $SupportRequestsTableTable(attachedDatabase, alias);
  }
}

class SupportRequestsTableData extends DataClass
    implements Insertable<SupportRequestsTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String id;
  final String type;
  final String body;
  final String? attachmentUrl;
  final String? voiceNoteUrl;
  final DateTime createdAt;
  const SupportRequestsTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.id,
    required this.type,
    required this.body,
    this.attachmentUrl,
    this.voiceNoteUrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || attachmentUrl != null) {
      map['attachment_url'] = Variable<String>(attachmentUrl);
    }
    if (!nullToAbsent || voiceNoteUrl != null) {
      map['voice_note_url'] = Variable<String>(voiceNoteUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SupportRequestsTableCompanion toCompanion(bool nullToAbsent) {
    return SupportRequestsTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      id: Value(id),
      type: Value(type),
      body: Value(body),
      attachmentUrl: attachmentUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentUrl),
      voiceNoteUrl: voiceNoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceNoteUrl),
      createdAt: Value(createdAt),
    );
  }

  factory SupportRequestsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupportRequestsTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      body: serializer.fromJson<String>(json['body']),
      attachmentUrl: serializer.fromJson<String?>(json['attachmentUrl']),
      voiceNoteUrl: serializer.fromJson<String?>(json['voiceNoteUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'body': serializer.toJson<String>(body),
      'attachmentUrl': serializer.toJson<String?>(attachmentUrl),
      'voiceNoteUrl': serializer.toJson<String?>(voiceNoteUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SupportRequestsTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? id,
    String? type,
    String? body,
    Value<String?> attachmentUrl = const Value.absent(),
    Value<String?> voiceNoteUrl = const Value.absent(),
    DateTime? createdAt,
  }) => SupportRequestsTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    type: type ?? this.type,
    body: body ?? this.body,
    attachmentUrl: attachmentUrl.present
        ? attachmentUrl.value
        : this.attachmentUrl,
    voiceNoteUrl: voiceNoteUrl.present ? voiceNoteUrl.value : this.voiceNoteUrl,
    createdAt: createdAt ?? this.createdAt,
  );
  SupportRequestsTableData copyWithCompanion(
    SupportRequestsTableCompanion data,
  ) {
    return SupportRequestsTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      body: data.body.present ? data.body.value : this.body,
      attachmentUrl: data.attachmentUrl.present
          ? data.attachmentUrl.value
          : this.attachmentUrl,
      voiceNoteUrl: data.voiceNoteUrl.present
          ? data.voiceNoteUrl.value
          : this.voiceNoteUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupportRequestsTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('attachmentUrl: $attachmentUrl, ')
          ..write('voiceNoteUrl: $voiceNoteUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    id,
    type,
    body,
    attachmentUrl,
    voiceNoteUrl,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupportRequestsTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.type == this.type &&
          other.body == this.body &&
          other.attachmentUrl == this.attachmentUrl &&
          other.voiceNoteUrl == this.voiceNoteUrl &&
          other.createdAt == this.createdAt);
}

class SupportRequestsTableCompanion
    extends UpdateCompanion<SupportRequestsTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> type;
  final Value<String> body;
  final Value<String?> attachmentUrl;
  final Value<String?> voiceNoteUrl;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SupportRequestsTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.body = const Value.absent(),
    this.attachmentUrl = const Value.absent(),
    this.voiceNoteUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupportRequestsTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String id,
    required String type,
    required String body,
    this.attachmentUrl = const Value.absent(),
    this.voiceNoteUrl = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       type = Value(type),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<SupportRequestsTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? body,
    Expression<String>? attachmentUrl,
    Expression<String>? voiceNoteUrl,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (body != null) 'body': body,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      if (voiceNoteUrl != null) 'voice_note_url': voiceNoteUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupportRequestsTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? type,
    Value<String>? body,
    Value<String?>? attachmentUrl,
    Value<String?>? voiceNoteUrl,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SupportRequestsTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      type: type ?? this.type,
      body: body ?? this.body,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (attachmentUrl.present) {
      map['attachment_url'] = Variable<String>(attachmentUrl.value);
    }
    if (voiceNoteUrl.present) {
      map['voice_note_url'] = Variable<String>(voiceNoteUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupportRequestsTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('body: $body, ')
          ..write('attachmentUrl: $attachmentUrl, ')
          ..write('voiceNoteUrl: $voiceNoteUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencySymbolMeta = const VerificationMeta(
    'currencySymbol',
  );
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
    'currency_symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('₪'),
  );
  static const VerificationMeta _themePreferenceMeta = const VerificationMeta(
    'themePreference',
  );
  @override
  late final GeneratedColumn<String> themePreference = GeneratedColumn<String>(
    'theme_preference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _cachedDisplayNameMeta = const VerificationMeta(
    'cachedDisplayName',
  );
  @override
  late final GeneratedColumn<String> cachedDisplayName =
      GeneratedColumn<String>(
        'cached_display_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _cachedRoleMeta = const VerificationMeta(
    'cachedRole',
  );
  @override
  late final GeneratedColumn<String> cachedRole = GeneratedColumn<String>(
    'cached_role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    currencySymbol,
    themePreference,
    cachedDisplayName,
    cachedRole,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
        _currencySymbolMeta,
        currencySymbol.isAcceptableOrUnknown(
          data['currency_symbol']!,
          _currencySymbolMeta,
        ),
      );
    }
    if (data.containsKey('theme_preference')) {
      context.handle(
        _themePreferenceMeta,
        themePreference.isAcceptableOrUnknown(
          data['theme_preference']!,
          _themePreferenceMeta,
        ),
      );
    }
    if (data.containsKey('cached_display_name')) {
      context.handle(
        _cachedDisplayNameMeta,
        cachedDisplayName.isAcceptableOrUnknown(
          data['cached_display_name']!,
          _cachedDisplayNameMeta,
        ),
      );
    }
    if (data.containsKey('cached_role')) {
      context.handle(
        _cachedRoleMeta,
        cachedRole.isAcceptableOrUnknown(data['cached_role']!, _cachedRoleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      currencySymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_symbol'],
      )!,
      themePreference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_preference'],
      )!,
      cachedDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cached_display_name'],
      ),
      cachedRole: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cached_role'],
      ),
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String currencySymbol;
  final String themePreference;
  final String? cachedDisplayName;
  final String? cachedRole;
  const SettingsTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.currencySymbol,
    required this.themePreference,
    this.cachedDisplayName,
    this.cachedRole,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['theme_preference'] = Variable<String>(themePreference);
    if (!nullToAbsent || cachedDisplayName != null) {
      map['cached_display_name'] = Variable<String>(cachedDisplayName);
    }
    if (!nullToAbsent || cachedRole != null) {
      map['cached_role'] = Variable<String>(cachedRole);
    }
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      currencySymbol: Value(currencySymbol),
      themePreference: Value(themePreference),
      cachedDisplayName: cachedDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(cachedDisplayName),
      cachedRole: cachedRole == null && nullToAbsent
          ? const Value.absent()
          : Value(cachedRole),
    );
  }

  factory SettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      themePreference: serializer.fromJson<String>(json['themePreference']),
      cachedDisplayName: serializer.fromJson<String?>(
        json['cachedDisplayName'],
      ),
      cachedRole: serializer.fromJson<String?>(json['cachedRole']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'themePreference': serializer.toJson<String>(themePreference),
      'cachedDisplayName': serializer.toJson<String?>(cachedDisplayName),
      'cachedRole': serializer.toJson<String?>(cachedRole),
    };
  }

  SettingsTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? currencySymbol,
    String? themePreference,
    Value<String?> cachedDisplayName = const Value.absent(),
    Value<String?> cachedRole = const Value.absent(),
  }) => SettingsTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    themePreference: themePreference ?? this.themePreference,
    cachedDisplayName: cachedDisplayName.present
        ? cachedDisplayName.value
        : this.cachedDisplayName,
    cachedRole: cachedRole.present ? cachedRole.value : this.cachedRole,
  );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      themePreference: data.themePreference.present
          ? data.themePreference.value
          : this.themePreference,
      cachedDisplayName: data.cachedDisplayName.present
          ? data.cachedDisplayName.value
          : this.cachedDisplayName,
      cachedRole: data.cachedRole.present
          ? data.cachedRole.value
          : this.cachedRole,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('themePreference: $themePreference, ')
          ..write('cachedDisplayName: $cachedDisplayName, ')
          ..write('cachedRole: $cachedRole')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    currencySymbol,
    themePreference,
    cachedDisplayName,
    cachedRole,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.currencySymbol == this.currencySymbol &&
          other.themePreference == this.themePreference &&
          other.cachedDisplayName == this.cachedDisplayName &&
          other.cachedRole == this.cachedRole);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> currencySymbol;
  final Value<String> themePreference;
  final Value<String?> cachedDisplayName;
  final Value<String?> cachedRole;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.themePreference = const Value.absent(),
    this.cachedDisplayName = const Value.absent(),
    this.cachedRole = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    this.currencySymbol = const Value.absent(),
    this.themePreference = const Value.absent(),
    this.cachedDisplayName = const Value.absent(),
    this.cachedRole = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt);
  static Insertable<SettingsTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? currencySymbol,
    Expression<String>? themePreference,
    Expression<String>? cachedDisplayName,
    Expression<String>? cachedRole,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (themePreference != null) 'theme_preference': themePreference,
      if (cachedDisplayName != null) 'cached_display_name': cachedDisplayName,
      if (cachedRole != null) 'cached_role': cachedRole,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? currencySymbol,
    Value<String>? themePreference,
    Value<String?>? cachedDisplayName,
    Value<String?>? cachedRole,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themePreference: themePreference ?? this.themePreference,
      cachedDisplayName: cachedDisplayName ?? this.cachedDisplayName,
      cachedRole: cachedRole ?? this.cachedRole,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (themePreference.present) {
      map['theme_preference'] = Variable<String>(themePreference.value);
    }
    if (cachedDisplayName.present) {
      map['cached_display_name'] = Variable<String>(cachedDisplayName.value);
    }
    if (cachedRole.present) {
      map['cached_role'] = Variable<String>(cachedRole.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('themePreference: $themePreference, ')
          ..write('cachedDisplayName: $cachedDisplayName, ')
          ..write('cachedRole: $cachedRole, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NumberUpdateLogTableTable extends NumberUpdateLogTable
    with TableInfo<$NumberUpdateLogTableTable, NumberUpdateLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NumberUpdateLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    id,
    phoneNumber,
    status,
    message,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'number_update_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<NumberUpdateLogTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NumberUpdateLogTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NumberUpdateLogTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NumberUpdateLogTableTable createAlias(String alias) {
    return $NumberUpdateLogTableTable(attachedDatabase, alias);
  }
}

class NumberUpdateLogTableData extends DataClass
    implements Insertable<NumberUpdateLogTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String id;
  final String phoneNumber;
  final String status;
  final String message;
  final DateTime createdAt;
  const NumberUpdateLogTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.id,
    required this.phoneNumber,
    required this.status,
    required this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<String>(id);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['status'] = Variable<String>(status);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NumberUpdateLogTableCompanion toCompanion(bool nullToAbsent) {
    return NumberUpdateLogTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      id: Value(id),
      phoneNumber: Value(phoneNumber),
      status: Value(status),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory NumberUpdateLogTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NumberUpdateLogTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      status: serializer.fromJson<String>(json['status']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<String>(id),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'status': serializer.toJson<String>(status),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NumberUpdateLogTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? id,
    String? phoneNumber,
    String? status,
    String? message,
    DateTime? createdAt,
  }) => NumberUpdateLogTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    status: status ?? this.status,
    message: message ?? this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  NumberUpdateLogTableData copyWithCompanion(
    NumberUpdateLogTableCompanion data,
  ) {
    return NumberUpdateLogTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      status: data.status.present ? data.status.value : this.status,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NumberUpdateLogTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ownerId,
    synced,
    updatedAt,
    id,
    phoneNumber,
    status,
    message,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NumberUpdateLogTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.phoneNumber == this.phoneNumber &&
          other.status == this.status &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class NumberUpdateLogTableCompanion
    extends UpdateCompanion<NumberUpdateLogTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> id;
  final Value<String> phoneNumber;
  final Value<String> status;
  final Value<String> message;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NumberUpdateLogTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NumberUpdateLogTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String id,
    required String phoneNumber,
    required String status,
    required String message,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       id = Value(id),
       phoneNumber = Value(phoneNumber),
       status = Value(status),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<NumberUpdateLogTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? id,
    Expression<String>? phoneNumber,
    Expression<String>? status,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NumberUpdateLogTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? id,
    Value<String>? phoneNumber,
    Value<String>? status,
    Value<String>? message,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NumberUpdateLogTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NumberUpdateLogTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NumberUpdateProviderCacheTableTable
    extends NumberUpdateProviderCacheTable
    with
        TableInfo<
          $NumberUpdateProviderCacheTableTable,
          NumberUpdateProviderCacheTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NumberUpdateProviderCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ownerId,
    synced,
    updatedAt,
    phoneNumber,
    provider,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'number_update_provider_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<NumberUpdateProviderCacheTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, phoneNumber};
  @override
  NumberUpdateProviderCacheTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NumberUpdateProviderCacheTableData(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
    );
  }

  @override
  $NumberUpdateProviderCacheTableTable createAlias(String alias) {
    return $NumberUpdateProviderCacheTableTable(attachedDatabase, alias);
  }
}

class NumberUpdateProviderCacheTableData extends DataClass
    implements Insertable<NumberUpdateProviderCacheTableData> {
  final String ownerId;
  final bool synced;
  final DateTime updatedAt;
  final String phoneNumber;
  final String provider;
  const NumberUpdateProviderCacheTableData({
    required this.ownerId,
    required this.synced,
    required this.updatedAt,
    required this.phoneNumber,
    required this.provider,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['synced'] = Variable<bool>(synced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['provider'] = Variable<String>(provider);
    return map;
  }

  NumberUpdateProviderCacheTableCompanion toCompanion(bool nullToAbsent) {
    return NumberUpdateProviderCacheTableCompanion(
      ownerId: Value(ownerId),
      synced: Value(synced),
      updatedAt: Value(updatedAt),
      phoneNumber: Value(phoneNumber),
      provider: Value(provider),
    );
  }

  factory NumberUpdateProviderCacheTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NumberUpdateProviderCacheTableData(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      synced: serializer.fromJson<bool>(json['synced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      provider: serializer.fromJson<String>(json['provider']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'synced': serializer.toJson<bool>(synced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'provider': serializer.toJson<String>(provider),
    };
  }

  NumberUpdateProviderCacheTableData copyWith({
    String? ownerId,
    bool? synced,
    DateTime? updatedAt,
    String? phoneNumber,
    String? provider,
  }) => NumberUpdateProviderCacheTableData(
    ownerId: ownerId ?? this.ownerId,
    synced: synced ?? this.synced,
    updatedAt: updatedAt ?? this.updatedAt,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    provider: provider ?? this.provider,
  );
  NumberUpdateProviderCacheTableData copyWithCompanion(
    NumberUpdateProviderCacheTableCompanion data,
  ) {
    return NumberUpdateProviderCacheTableData(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      synced: data.synced.present ? data.synced.value : this.synced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      provider: data.provider.present ? data.provider.value : this.provider,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NumberUpdateProviderCacheTableData(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('provider: $provider')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(ownerId, synced, updatedAt, phoneNumber, provider);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NumberUpdateProviderCacheTableData &&
          other.ownerId == this.ownerId &&
          other.synced == this.synced &&
          other.updatedAt == this.updatedAt &&
          other.phoneNumber == this.phoneNumber &&
          other.provider == this.provider);
}

class NumberUpdateProviderCacheTableCompanion
    extends UpdateCompanion<NumberUpdateProviderCacheTableData> {
  final Value<String> ownerId;
  final Value<bool> synced;
  final Value<DateTime> updatedAt;
  final Value<String> phoneNumber;
  final Value<String> provider;
  final Value<int> rowid;
  const NumberUpdateProviderCacheTableCompanion({
    this.ownerId = const Value.absent(),
    this.synced = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.provider = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NumberUpdateProviderCacheTableCompanion.insert({
    required String ownerId,
    this.synced = const Value.absent(),
    required DateTime updatedAt,
    required String phoneNumber,
    required String provider,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       updatedAt = Value(updatedAt),
       phoneNumber = Value(phoneNumber),
       provider = Value(provider);
  static Insertable<NumberUpdateProviderCacheTableData> custom({
    Expression<String>? ownerId,
    Expression<bool>? synced,
    Expression<DateTime>? updatedAt,
    Expression<String>? phoneNumber,
    Expression<String>? provider,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (synced != null) 'synced': synced,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (provider != null) 'provider': provider,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NumberUpdateProviderCacheTableCompanion copyWith({
    Value<String>? ownerId,
    Value<bool>? synced,
    Value<DateTime>? updatedAt,
    Value<String>? phoneNumber,
    Value<String>? provider,
    Value<int>? rowid,
  }) {
    return NumberUpdateProviderCacheTableCompanion(
      ownerId: ownerId ?? this.ownerId,
      synced: synced ?? this.synced,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      provider: provider ?? this.provider,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NumberUpdateProviderCacheTableCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('synced: $synced, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('provider: $provider, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingDeletesTableTable extends PendingDeletesTable
    with TableInfo<$PendingDeletesTableTable, PendingDeletesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingDeletesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entityTable, entityId, ownerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_deletes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingDeletesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityTable, entityId};
  @override
  PendingDeletesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingDeletesTableData(
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
    );
  }

  @override
  $PendingDeletesTableTable createAlias(String alias) {
    return $PendingDeletesTableTable(attachedDatabase, alias);
  }
}

class PendingDeletesTableData extends DataClass
    implements Insertable<PendingDeletesTableData> {
  final String entityTable;
  final String entityId;
  final String ownerId;
  const PendingDeletesTableData({
    required this.entityTable,
    required this.entityId,
    required this.ownerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_id'] = Variable<String>(entityId);
    map['owner_id'] = Variable<String>(ownerId);
    return map;
  }

  PendingDeletesTableCompanion toCompanion(bool nullToAbsent) {
    return PendingDeletesTableCompanion(
      entityTable: Value(entityTable),
      entityId: Value(entityId),
      ownerId: Value(ownerId),
    );
  }

  factory PendingDeletesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingDeletesTableData(
      entityTable: serializer.fromJson<String>(json['entityTable']),
      entityId: serializer.fromJson<String>(json['entityId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityTable': serializer.toJson<String>(entityTable),
      'entityId': serializer.toJson<String>(entityId),
      'ownerId': serializer.toJson<String>(ownerId),
    };
  }

  PendingDeletesTableData copyWith({
    String? entityTable,
    String? entityId,
    String? ownerId,
  }) => PendingDeletesTableData(
    entityTable: entityTable ?? this.entityTable,
    entityId: entityId ?? this.entityId,
    ownerId: ownerId ?? this.ownerId,
  );
  PendingDeletesTableData copyWithCompanion(PendingDeletesTableCompanion data) {
    return PendingDeletesTableData(
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingDeletesTableData(')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('ownerId: $ownerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityTable, entityId, ownerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingDeletesTableData &&
          other.entityTable == this.entityTable &&
          other.entityId == this.entityId &&
          other.ownerId == this.ownerId);
}

class PendingDeletesTableCompanion
    extends UpdateCompanion<PendingDeletesTableData> {
  final Value<String> entityTable;
  final Value<String> entityId;
  final Value<String> ownerId;
  final Value<int> rowid;
  const PendingDeletesTableCompanion({
    this.entityTable = const Value.absent(),
    this.entityId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingDeletesTableCompanion.insert({
    required String entityTable,
    required String entityId,
    required String ownerId,
    this.rowid = const Value.absent(),
  }) : entityTable = Value(entityTable),
       entityId = Value(entityId),
       ownerId = Value(ownerId);
  static Insertable<PendingDeletesTableData> custom({
    Expression<String>? entityTable,
    Expression<String>? entityId,
    Expression<String>? ownerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityTable != null) 'entity_table': entityTable,
      if (entityId != null) 'entity_id': entityId,
      if (ownerId != null) 'owner_id': ownerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingDeletesTableCompanion copyWith({
    Value<String>? entityTable,
    Value<String>? entityId,
    Value<String>? ownerId,
    Value<int>? rowid,
  }) {
    return PendingDeletesTableCompanion(
      entityTable: entityTable ?? this.entityTable,
      entityId: entityId ?? this.entityId,
      ownerId: ownerId ?? this.ownerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingDeletesTableCompanion(')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('ownerId: $ownerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CompanyCatalogTableTable companyCatalogTable =
      $CompanyCatalogTableTable(this);
  late final $PackageCatalogTableTable packageCatalogTable =
      $PackageCatalogTableTable(this);
  late final $CompaniesTableTable companiesTable = $CompaniesTableTable(this);
  late final $PackagesTableTable packagesTable = $PackagesTableTable(this);
  late final $CustomersTableTable customersTable = $CustomersTableTable(this);
  late final $ShipmentsTableTable shipmentsTable = $ShipmentsTableTable(this);
  late final $LinesTableTable linesTable = $LinesTableTable(this);
  late final $OperationsTableTable operationsTable = $OperationsTableTable(
    this,
  );
  late final $ActivityLogTableTable activityLogTable = $ActivityLogTableTable(
    this,
  );
  late final $SupportRequestsTableTable supportRequestsTable =
      $SupportRequestsTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $NumberUpdateLogTableTable numberUpdateLogTable =
      $NumberUpdateLogTableTable(this);
  late final $NumberUpdateProviderCacheTableTable
  numberUpdateProviderCacheTable = $NumberUpdateProviderCacheTableTable(this);
  late final $PendingDeletesTableTable pendingDeletesTable =
      $PendingDeletesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    companyCatalogTable,
    packageCatalogTable,
    companiesTable,
    packagesTable,
    customersTable,
    shipmentsTable,
    linesTable,
    operationsTable,
    activityLogTable,
    supportRequestsTable,
    settingsTable,
    numberUpdateLogTable,
    numberUpdateProviderCacheTable,
    pendingDeletesTable,
  ];
}

typedef $$CompanyCatalogTableTableCreateCompanionBuilder =
    CompanyCatalogTableCompanion Function({
      required String id,
      required String name,
      Value<String?> logoUrl,
      Value<String?> notes,
      Value<String?> numberUpdateUrl,
      Value<String?> numberUpdateProvider,
      Value<String> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CompanyCatalogTableTableUpdateCompanionBuilder =
    CompanyCatalogTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> logoUrl,
      Value<String?> notes,
      Value<String?> numberUpdateUrl,
      Value<String?> numberUpdateProvider,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CompanyCatalogTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CompanyCatalogTableTable,
          CompanyCatalogTableData
        > {
  $$CompanyCatalogTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PackageCatalogTableTable,
    List<PackageCatalogTableData>
  >
  _packageCatalogTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.packageCatalogTable,
        aliasName: 'company_catalog__id__package_catalog__company_catalog_id',
      );

  $$PackageCatalogTableTableProcessedTableManager get packageCatalogTableRefs {
    final manager =
        $$PackageCatalogTableTableTableManager(
          $_db,
          $_db.packageCatalogTable,
        ).filter(
          (f) => f.companyCatalogId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _packageCatalogTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CompaniesTableTable, List<CompaniesTableData>>
  _companiesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.companiesTable,
    aliasName: 'company_catalog__id__companies__catalog_company_id',
  );

  $$CompaniesTableTableProcessedTableManager get companiesTableRefs {
    final manager = $$CompaniesTableTableTableManager($_db, $_db.companiesTable)
        .filter(
          (f) => f.catalogCompanyId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_companiesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompanyCatalogTableTableFilterComposer
    extends Composer<_$AppDatabase, $CompanyCatalogTableTable> {
  $$CompanyCatalogTableTableFilterComposer({
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

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numberUpdateUrl => $composableBuilder(
    column: $table.numberUpdateUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numberUpdateProvider => $composableBuilder(
    column: $table.numberUpdateProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> packageCatalogTableRefs(
    Expression<bool> Function($$PackageCatalogTableTableFilterComposer f) f,
  ) {
    final $$PackageCatalogTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packageCatalogTable,
      getReferencedColumn: (t) => t.companyCatalogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackageCatalogTableTableFilterComposer(
            $db: $db,
            $table: $db.packageCatalogTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> companiesTableRefs(
    Expression<bool> Function($$CompaniesTableTableFilterComposer f) f,
  ) {
    final $$CompaniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.catalogCompanyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableFilterComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompanyCatalogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanyCatalogTableTable> {
  $$CompanyCatalogTableTableOrderingComposer({
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

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numberUpdateUrl => $composableBuilder(
    column: $table.numberUpdateUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numberUpdateProvider => $composableBuilder(
    column: $table.numberUpdateProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompanyCatalogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanyCatalogTableTable> {
  $$CompanyCatalogTableTableAnnotationComposer({
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

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get numberUpdateUrl => $composableBuilder(
    column: $table.numberUpdateUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get numberUpdateProvider => $composableBuilder(
    column: $table.numberUpdateProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> packageCatalogTableRefs<T extends Object>(
    Expression<T> Function($$PackageCatalogTableTableAnnotationComposer a) f,
  ) {
    final $$PackageCatalogTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.packageCatalogTable,
          getReferencedColumn: (t) => t.companyCatalogId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PackageCatalogTableTableAnnotationComposer(
                $db: $db,
                $table: $db.packageCatalogTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> companiesTableRefs<T extends Object>(
    Expression<T> Function($$CompaniesTableTableAnnotationComposer a) f,
  ) {
    final $$CompaniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.catalogCompanyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompanyCatalogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanyCatalogTableTable,
          CompanyCatalogTableData,
          $$CompanyCatalogTableTableFilterComposer,
          $$CompanyCatalogTableTableOrderingComposer,
          $$CompanyCatalogTableTableAnnotationComposer,
          $$CompanyCatalogTableTableCreateCompanionBuilder,
          $$CompanyCatalogTableTableUpdateCompanionBuilder,
          (CompanyCatalogTableData, $$CompanyCatalogTableTableReferences),
          CompanyCatalogTableData,
          PrefetchHooks Function({
            bool packageCatalogTableRefs,
            bool companiesTableRefs,
          })
        > {
  $$CompanyCatalogTableTableTableManager(
    _$AppDatabase db,
    $CompanyCatalogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanyCatalogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanyCatalogTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CompanyCatalogTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> numberUpdateUrl = const Value.absent(),
                Value<String?> numberUpdateProvider = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanyCatalogTableCompanion(
                id: id,
                name: name,
                logoUrl: logoUrl,
                notes: notes,
                numberUpdateUrl: numberUpdateUrl,
                numberUpdateProvider: numberUpdateProvider,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> numberUpdateUrl = const Value.absent(),
                Value<String?> numberUpdateProvider = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CompanyCatalogTableCompanion.insert(
                id: id,
                name: name,
                logoUrl: logoUrl,
                notes: notes,
                numberUpdateUrl: numberUpdateUrl,
                numberUpdateProvider: numberUpdateProvider,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompanyCatalogTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({packageCatalogTableRefs = false, companiesTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (packageCatalogTableRefs) db.packageCatalogTable,
                    if (companiesTableRefs) db.companiesTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (packageCatalogTableRefs)
                        await $_getPrefetchedData<
                          CompanyCatalogTableData,
                          $CompanyCatalogTableTable,
                          PackageCatalogTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CompanyCatalogTableTableReferences
                              ._packageCatalogTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompanyCatalogTableTableReferences(
                                db,
                                table,
                                p0,
                              ).packageCatalogTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyCatalogId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (companiesTableRefs)
                        await $_getPrefetchedData<
                          CompanyCatalogTableData,
                          $CompanyCatalogTableTable,
                          CompaniesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CompanyCatalogTableTableReferences
                              ._companiesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompanyCatalogTableTableReferences(
                                db,
                                table,
                                p0,
                              ).companiesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogCompanyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompanyCatalogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanyCatalogTableTable,
      CompanyCatalogTableData,
      $$CompanyCatalogTableTableFilterComposer,
      $$CompanyCatalogTableTableOrderingComposer,
      $$CompanyCatalogTableTableAnnotationComposer,
      $$CompanyCatalogTableTableCreateCompanionBuilder,
      $$CompanyCatalogTableTableUpdateCompanionBuilder,
      (CompanyCatalogTableData, $$CompanyCatalogTableTableReferences),
      CompanyCatalogTableData,
      PrefetchHooks Function({
        bool packageCatalogTableRefs,
        bool companiesTableRefs,
      })
    >;
typedef $$PackageCatalogTableTableCreateCompanionBuilder =
    PackageCatalogTableCompanion Function({
      required String id,
      required String companyCatalogId,
      required String name,
      Value<String?> simType,
      Value<double> wholesaleCost,
      Value<double> suggestedRetailPrice,
      Value<String> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PackageCatalogTableTableUpdateCompanionBuilder =
    PackageCatalogTableCompanion Function({
      Value<String> id,
      Value<String> companyCatalogId,
      Value<String> name,
      Value<String?> simType,
      Value<double> wholesaleCost,
      Value<double> suggestedRetailPrice,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PackageCatalogTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PackageCatalogTableTable,
          PackageCatalogTableData
        > {
  $$PackageCatalogTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompanyCatalogTableTable _companyCatalogIdTable(_$AppDatabase db) =>
      db.companyCatalogTable.createAlias(
        'package_catalog__company_catalog_id__company_catalog__id',
      );

  $$CompanyCatalogTableTableProcessedTableManager get companyCatalogId {
    final $_column = $_itemColumn<String>('company_catalog_id')!;

    final manager = $$CompanyCatalogTableTableTableManager(
      $_db,
      $_db.companyCatalogTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyCatalogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PackageCatalogTableTableFilterComposer
    extends Composer<_$AppDatabase, $PackageCatalogTableTable> {
  $$PackageCatalogTableTableFilterComposer({
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

  ColumnFilters<String> get simType => $composableBuilder(
    column: $table.simType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get wholesaleCost => $composableBuilder(
    column: $table.wholesaleCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get suggestedRetailPrice => $composableBuilder(
    column: $table.suggestedRetailPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompanyCatalogTableTableFilterComposer get companyCatalogId {
    final $$CompanyCatalogTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyCatalogId,
      referencedTable: $db.companyCatalogTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanyCatalogTableTableFilterComposer(
            $db: $db,
            $table: $db.companyCatalogTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PackageCatalogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PackageCatalogTableTable> {
  $$PackageCatalogTableTableOrderingComposer({
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

  ColumnOrderings<String> get simType => $composableBuilder(
    column: $table.simType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get wholesaleCost => $composableBuilder(
    column: $table.wholesaleCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get suggestedRetailPrice => $composableBuilder(
    column: $table.suggestedRetailPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompanyCatalogTableTableOrderingComposer get companyCatalogId {
    final $$CompanyCatalogTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.companyCatalogId,
          referencedTable: $db.companyCatalogTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompanyCatalogTableTableOrderingComposer(
                $db: $db,
                $table: $db.companyCatalogTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PackageCatalogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PackageCatalogTableTable> {
  $$PackageCatalogTableTableAnnotationComposer({
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

  GeneratedColumn<String> get simType =>
      $composableBuilder(column: $table.simType, builder: (column) => column);

  GeneratedColumn<double> get wholesaleCost => $composableBuilder(
    column: $table.wholesaleCost,
    builder: (column) => column,
  );

  GeneratedColumn<double> get suggestedRetailPrice => $composableBuilder(
    column: $table.suggestedRetailPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompanyCatalogTableTableAnnotationComposer get companyCatalogId {
    final $$CompanyCatalogTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.companyCatalogId,
          referencedTable: $db.companyCatalogTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompanyCatalogTableTableAnnotationComposer(
                $db: $db,
                $table: $db.companyCatalogTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PackageCatalogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PackageCatalogTableTable,
          PackageCatalogTableData,
          $$PackageCatalogTableTableFilterComposer,
          $$PackageCatalogTableTableOrderingComposer,
          $$PackageCatalogTableTableAnnotationComposer,
          $$PackageCatalogTableTableCreateCompanionBuilder,
          $$PackageCatalogTableTableUpdateCompanionBuilder,
          (PackageCatalogTableData, $$PackageCatalogTableTableReferences),
          PackageCatalogTableData,
          PrefetchHooks Function({bool companyCatalogId})
        > {
  $$PackageCatalogTableTableTableManager(
    _$AppDatabase db,
    $PackageCatalogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PackageCatalogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PackageCatalogTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PackageCatalogTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyCatalogId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> simType = const Value.absent(),
                Value<double> wholesaleCost = const Value.absent(),
                Value<double> suggestedRetailPrice = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackageCatalogTableCompanion(
                id: id,
                companyCatalogId: companyCatalogId,
                name: name,
                simType: simType,
                wholesaleCost: wholesaleCost,
                suggestedRetailPrice: suggestedRetailPrice,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyCatalogId,
                required String name,
                Value<String?> simType = const Value.absent(),
                Value<double> wholesaleCost = const Value.absent(),
                Value<double> suggestedRetailPrice = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PackageCatalogTableCompanion.insert(
                id: id,
                companyCatalogId: companyCatalogId,
                name: name,
                simType: simType,
                wholesaleCost: wholesaleCost,
                suggestedRetailPrice: suggestedRetailPrice,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PackageCatalogTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyCatalogId = false}) {
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
                    if (companyCatalogId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyCatalogId,
                                referencedTable:
                                    $$PackageCatalogTableTableReferences
                                        ._companyCatalogIdTable(db),
                                referencedColumn:
                                    $$PackageCatalogTableTableReferences
                                        ._companyCatalogIdTable(db)
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

typedef $$PackageCatalogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PackageCatalogTableTable,
      PackageCatalogTableData,
      $$PackageCatalogTableTableFilterComposer,
      $$PackageCatalogTableTableOrderingComposer,
      $$PackageCatalogTableTableAnnotationComposer,
      $$PackageCatalogTableTableCreateCompanionBuilder,
      $$PackageCatalogTableTableUpdateCompanionBuilder,
      (PackageCatalogTableData, $$PackageCatalogTableTableReferences),
      PackageCatalogTableData,
      PrefetchHooks Function({bool companyCatalogId})
    >;
typedef $$CompaniesTableTableCreateCompanionBuilder =
    CompaniesTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String id,
      required String name,
      Value<String?> logoUrl,
      Value<String?> notes,
      Value<String> status,
      Value<bool> pinned,
      Value<String?> catalogCompanyId,
      Value<String?> numberUpdateProvider,
      Value<String?> numberUpdateUrl,
      Value<bool> allowNegativeBalance,
      Value<int> rowid,
    });
typedef $$CompaniesTableTableUpdateCompanionBuilder =
    CompaniesTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> name,
      Value<String?> logoUrl,
      Value<String?> notes,
      Value<String> status,
      Value<bool> pinned,
      Value<String?> catalogCompanyId,
      Value<String?> numberUpdateProvider,
      Value<String?> numberUpdateUrl,
      Value<bool> allowNegativeBalance,
      Value<int> rowid,
    });

final class $$CompaniesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CompaniesTableTable,
          CompaniesTableData
        > {
  $$CompaniesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompanyCatalogTableTable _catalogCompanyIdTable(_$AppDatabase db) =>
      db.companyCatalogTable.createAlias(
        'companies__catalog_company_id__company_catalog__id',
      );

  $$CompanyCatalogTableTableProcessedTableManager? get catalogCompanyId {
    final $_column = $_itemColumn<String>('catalog_company_id');
    if ($_column == null) return null;
    final manager = $$CompanyCatalogTableTableTableManager(
      $_db,
      $_db.companyCatalogTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogCompanyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PackagesTableTable, List<PackagesTableData>>
  _packagesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.packagesTable,
    aliasName: 'companies__id__packages__company_id',
  );

  $$PackagesTableTableProcessedTableManager get packagesTableRefs {
    final manager = $$PackagesTableTableTableManager(
      $_db,
      $_db.packagesTable,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_packagesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShipmentsTableTable, List<ShipmentsTableData>>
  _shipmentsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shipmentsTable,
    aliasName: 'companies__id__shipments__company_id',
  );

  $$ShipmentsTableTableProcessedTableManager get shipmentsTableRefs {
    final manager = $$ShipmentsTableTableTableManager(
      $_db,
      $_db.shipmentsTable,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shipmentsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LinesTableTable, List<LinesTableData>>
  _linesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.linesTable,
    aliasName: 'companies__id__lines__company_id',
  );

  $$LinesTableTableProcessedTableManager get linesTableRefs {
    final manager = $$LinesTableTableTableManager(
      $_db,
      $_db.linesTable,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_linesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OperationsTableTable, List<OperationsTableData>>
  _operationsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operationsTable,
    aliasName: 'companies__id__operations__company_id',
  );

  $$OperationsTableTableProcessedTableManager get operationsTableRefs {
    final manager = $$OperationsTableTableTableManager(
      $_db,
      $_db.operationsTable,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _operationsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompaniesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTableTable> {
  $$CompaniesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numberUpdateProvider => $composableBuilder(
    column: $table.numberUpdateProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numberUpdateUrl => $composableBuilder(
    column: $table.numberUpdateUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowNegativeBalance => $composableBuilder(
    column: $table.allowNegativeBalance,
    builder: (column) => ColumnFilters(column),
  );

  $$CompanyCatalogTableTableFilterComposer get catalogCompanyId {
    final $$CompanyCatalogTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogCompanyId,
      referencedTable: $db.companyCatalogTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompanyCatalogTableTableFilterComposer(
            $db: $db,
            $table: $db.companyCatalogTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> packagesTableRefs(
    Expression<bool> Function($$PackagesTableTableFilterComposer f) f,
  ) {
    final $$PackagesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packagesTable,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackagesTableTableFilterComposer(
            $db: $db,
            $table: $db.packagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shipmentsTableRefs(
    Expression<bool> Function($$ShipmentsTableTableFilterComposer f) f,
  ) {
    final $$ShipmentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shipmentsTable,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShipmentsTableTableFilterComposer(
            $db: $db,
            $table: $db.shipmentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> linesTableRefs(
    Expression<bool> Function($$LinesTableTableFilterComposer f) f,
  ) {
    final $$LinesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.linesTable,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableTableFilterComposer(
            $db: $db,
            $table: $db.linesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> operationsTableRefs(
    Expression<bool> Function($$OperationsTableTableFilterComposer f) f,
  ) {
    final $$OperationsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableFilterComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTableTable> {
  $$CompaniesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numberUpdateProvider => $composableBuilder(
    column: $table.numberUpdateProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numberUpdateUrl => $composableBuilder(
    column: $table.numberUpdateUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowNegativeBalance => $composableBuilder(
    column: $table.allowNegativeBalance,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompanyCatalogTableTableOrderingComposer get catalogCompanyId {
    final $$CompanyCatalogTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogCompanyId,
          referencedTable: $db.companyCatalogTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompanyCatalogTableTableOrderingComposer(
                $db: $db,
                $table: $db.companyCatalogTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CompaniesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTableTable> {
  $$CompaniesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<String> get numberUpdateProvider => $composableBuilder(
    column: $table.numberUpdateProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get numberUpdateUrl => $composableBuilder(
    column: $table.numberUpdateUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowNegativeBalance => $composableBuilder(
    column: $table.allowNegativeBalance,
    builder: (column) => column,
  );

  $$CompanyCatalogTableTableAnnotationComposer get catalogCompanyId {
    final $$CompanyCatalogTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogCompanyId,
          referencedTable: $db.companyCatalogTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CompanyCatalogTableTableAnnotationComposer(
                $db: $db,
                $table: $db.companyCatalogTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> packagesTableRefs<T extends Object>(
    Expression<T> Function($$PackagesTableTableAnnotationComposer a) f,
  ) {
    final $$PackagesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packagesTable,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackagesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.packagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> shipmentsTableRefs<T extends Object>(
    Expression<T> Function($$ShipmentsTableTableAnnotationComposer a) f,
  ) {
    final $$ShipmentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shipmentsTable,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShipmentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.shipmentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> linesTableRefs<T extends Object>(
    Expression<T> Function($$LinesTableTableAnnotationComposer a) f,
  ) {
    final $$LinesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.linesTable,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.linesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> operationsTableRefs<T extends Object>(
    Expression<T> Function($$OperationsTableTableAnnotationComposer a) f,
  ) {
    final $$OperationsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTableTable,
          CompaniesTableData,
          $$CompaniesTableTableFilterComposer,
          $$CompaniesTableTableOrderingComposer,
          $$CompaniesTableTableAnnotationComposer,
          $$CompaniesTableTableCreateCompanionBuilder,
          $$CompaniesTableTableUpdateCompanionBuilder,
          (CompaniesTableData, $$CompaniesTableTableReferences),
          CompaniesTableData,
          PrefetchHooks Function({
            bool catalogCompanyId,
            bool packagesTableRefs,
            bool shipmentsTableRefs,
            bool linesTableRefs,
            bool operationsTableRefs,
          })
        > {
  $$CompaniesTableTableTableManager(
    _$AppDatabase db,
    $CompaniesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<String?> catalogCompanyId = const Value.absent(),
                Value<String?> numberUpdateProvider = const Value.absent(),
                Value<String?> numberUpdateUrl = const Value.absent(),
                Value<bool> allowNegativeBalance = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                name: name,
                logoUrl: logoUrl,
                notes: notes,
                status: status,
                pinned: pinned,
                catalogCompanyId: catalogCompanyId,
                numberUpdateProvider: numberUpdateProvider,
                numberUpdateUrl: numberUpdateUrl,
                allowNegativeBalance: allowNegativeBalance,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String id,
                required String name,
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<String?> catalogCompanyId = const Value.absent(),
                Value<String?> numberUpdateProvider = const Value.absent(),
                Value<String?> numberUpdateUrl = const Value.absent(),
                Value<bool> allowNegativeBalance = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                name: name,
                logoUrl: logoUrl,
                notes: notes,
                status: status,
                pinned: pinned,
                catalogCompanyId: catalogCompanyId,
                numberUpdateProvider: numberUpdateProvider,
                numberUpdateUrl: numberUpdateUrl,
                allowNegativeBalance: allowNegativeBalance,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompaniesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                catalogCompanyId = false,
                packagesTableRefs = false,
                shipmentsTableRefs = false,
                linesTableRefs = false,
                operationsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (packagesTableRefs) db.packagesTable,
                    if (shipmentsTableRefs) db.shipmentsTable,
                    if (linesTableRefs) db.linesTable,
                    if (operationsTableRefs) db.operationsTable,
                  ],
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
                        if (catalogCompanyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.catalogCompanyId,
                                    referencedTable:
                                        $$CompaniesTableTableReferences
                                            ._catalogCompanyIdTable(db),
                                    referencedColumn:
                                        $$CompaniesTableTableReferences
                                            ._catalogCompanyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (packagesTableRefs)
                        await $_getPrefetchedData<
                          CompaniesTableData,
                          $CompaniesTableTable,
                          PackagesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableTableReferences
                              ._packagesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).packagesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shipmentsTableRefs)
                        await $_getPrefetchedData<
                          CompaniesTableData,
                          $CompaniesTableTable,
                          ShipmentsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableTableReferences
                              ._shipmentsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).shipmentsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (linesTableRefs)
                        await $_getPrefetchedData<
                          CompaniesTableData,
                          $CompaniesTableTable,
                          LinesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableTableReferences
                              ._linesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).linesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (operationsTableRefs)
                        await $_getPrefetchedData<
                          CompaniesTableData,
                          $CompaniesTableTable,
                          OperationsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableTableReferences
                              ._operationsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).operationsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompaniesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTableTable,
      CompaniesTableData,
      $$CompaniesTableTableFilterComposer,
      $$CompaniesTableTableOrderingComposer,
      $$CompaniesTableTableAnnotationComposer,
      $$CompaniesTableTableCreateCompanionBuilder,
      $$CompaniesTableTableUpdateCompanionBuilder,
      (CompaniesTableData, $$CompaniesTableTableReferences),
      CompaniesTableData,
      PrefetchHooks Function({
        bool catalogCompanyId,
        bool packagesTableRefs,
        bool shipmentsTableRefs,
        bool linesTableRefs,
        bool operationsTableRefs,
      })
    >;
typedef $$PackagesTableTableCreateCompanionBuilder =
    PackagesTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String id,
      required String companyId,
      required String name,
      Value<String?> simType,
      Value<double> wholesaleCost,
      Value<double> retailPrice,
      Value<int> rowid,
    });
typedef $$PackagesTableTableUpdateCompanionBuilder =
    PackagesTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String?> simType,
      Value<double> wholesaleCost,
      Value<double> retailPrice,
      Value<int> rowid,
    });

final class $$PackagesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PackagesTableTable, PackagesTableData> {
  $$PackagesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTableTable _companyIdTable(_$AppDatabase db) =>
      db.companiesTable.createAlias('packages__company_id__companies__id');

  $$CompaniesTableTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableTableManager(
      $_db,
      $_db.companiesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LinesTableTable, List<LinesTableData>>
  _linesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.linesTable,
    aliasName: 'packages__id__lines__package_id',
  );

  $$LinesTableTableProcessedTableManager get linesTableRefs {
    final manager = $$LinesTableTableTableManager(
      $_db,
      $_db.linesTable,
    ).filter((f) => f.packageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_linesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PackagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PackagesTableTable> {
  $$PackagesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get simType => $composableBuilder(
    column: $table.simType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get wholesaleCost => $composableBuilder(
    column: $table.wholesaleCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get retailPrice => $composableBuilder(
    column: $table.retailPrice,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableTableFilterComposer get companyId {
    final $$CompaniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableFilterComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> linesTableRefs(
    Expression<bool> Function($$LinesTableTableFilterComposer f) f,
  ) {
    final $$LinesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.linesTable,
      getReferencedColumn: (t) => t.packageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableTableFilterComposer(
            $db: $db,
            $table: $db.linesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PackagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PackagesTableTable> {
  $$PackagesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get simType => $composableBuilder(
    column: $table.simType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get wholesaleCost => $composableBuilder(
    column: $table.wholesaleCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get retailPrice => $composableBuilder(
    column: $table.retailPrice,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableTableOrderingComposer get companyId {
    final $$CompaniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PackagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PackagesTableTable> {
  $$PackagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get simType =>
      $composableBuilder(column: $table.simType, builder: (column) => column);

  GeneratedColumn<double> get wholesaleCost => $composableBuilder(
    column: $table.wholesaleCost,
    builder: (column) => column,
  );

  GeneratedColumn<double> get retailPrice => $composableBuilder(
    column: $table.retailPrice,
    builder: (column) => column,
  );

  $$CompaniesTableTableAnnotationComposer get companyId {
    final $$CompaniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> linesTableRefs<T extends Object>(
    Expression<T> Function($$LinesTableTableAnnotationComposer a) f,
  ) {
    final $$LinesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.linesTable,
      getReferencedColumn: (t) => t.packageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.linesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PackagesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PackagesTableTable,
          PackagesTableData,
          $$PackagesTableTableFilterComposer,
          $$PackagesTableTableOrderingComposer,
          $$PackagesTableTableAnnotationComposer,
          $$PackagesTableTableCreateCompanionBuilder,
          $$PackagesTableTableUpdateCompanionBuilder,
          (PackagesTableData, $$PackagesTableTableReferences),
          PackagesTableData,
          PrefetchHooks Function({bool companyId, bool linesTableRefs})
        > {
  $$PackagesTableTableTableManager(_$AppDatabase db, $PackagesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PackagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PackagesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PackagesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> simType = const Value.absent(),
                Value<double> wholesaleCost = const Value.absent(),
                Value<double> retailPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackagesTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                companyId: companyId,
                name: name,
                simType: simType,
                wholesaleCost: wholesaleCost,
                retailPrice: retailPrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String id,
                required String companyId,
                required String name,
                Value<String?> simType = const Value.absent(),
                Value<double> wholesaleCost = const Value.absent(),
                Value<double> retailPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackagesTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                companyId: companyId,
                name: name,
                simType: simType,
                wholesaleCost: wholesaleCost,
                retailPrice: retailPrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PackagesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false, linesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (linesTableRefs) db.linesTable],
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
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$PackagesTableTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$PackagesTableTableReferences
                                    ._companyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (linesTableRefs)
                    await $_getPrefetchedData<
                      PackagesTableData,
                      $PackagesTableTable,
                      LinesTableData
                    >(
                      currentTable: table,
                      referencedTable: $$PackagesTableTableReferences
                          ._linesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PackagesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).linesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.packageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PackagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PackagesTableTable,
      PackagesTableData,
      $$PackagesTableTableFilterComposer,
      $$PackagesTableTableOrderingComposer,
      $$PackagesTableTableAnnotationComposer,
      $$PackagesTableTableCreateCompanionBuilder,
      $$PackagesTableTableUpdateCompanionBuilder,
      (PackagesTableData, $$PackagesTableTableReferences),
      PackagesTableData,
      PrefetchHooks Function({bool companyId, bool linesTableRefs})
    >;
typedef $$CustomersTableTableCreateCompanionBuilder =
    CustomersTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String id,
      required String name,
      required String contactNumber,
      Value<String> status,
      Value<String> tags,
      Value<bool> pinned,
      Value<String?> notes,
      Value<bool> deleted,
      Value<int> rowid,
    });
typedef $$CustomersTableTableUpdateCompanionBuilder =
    CustomersTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> name,
      Value<String> contactNumber,
      Value<String> status,
      Value<String> tags,
      Value<bool> pinned,
      Value<String?> notes,
      Value<bool> deleted,
      Value<int> rowid,
    });

final class $$CustomersTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomersTableTable,
          CustomersTableData
        > {
  $$CustomersTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LinesTableTable, List<LinesTableData>>
  _linesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.linesTable,
    aliasName: 'customers__id__lines__customer_id',
  );

  $$LinesTableTableProcessedTableManager get linesTableRefs {
    final manager = $$LinesTableTableTableManager(
      $_db,
      $_db.linesTable,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_linesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OperationsTableTable, List<OperationsTableData>>
  _operationsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operationsTable,
    aliasName: 'customers__id__operations__customer_id',
  );

  $$OperationsTableTableProcessedTableManager get operationsTableRefs {
    final manager = $$OperationsTableTableTableManager(
      $_db,
      $_db.operationsTable,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _operationsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> linesTableRefs(
    Expression<bool> Function($$LinesTableTableFilterComposer f) f,
  ) {
    final $$LinesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.linesTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableTableFilterComposer(
            $db: $db,
            $table: $db.linesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> operationsTableRefs(
    Expression<bool> Function($$OperationsTableTableFilterComposer f) f,
  ) {
    final $$OperationsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableFilterComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  Expression<T> linesTableRefs<T extends Object>(
    Expression<T> Function($$LinesTableTableAnnotationComposer a) f,
  ) {
    final $$LinesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.linesTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.linesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> operationsTableRefs<T extends Object>(
    Expression<T> Function($$OperationsTableTableAnnotationComposer a) f,
  ) {
    final $$OperationsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTableTable,
          CustomersTableData,
          $$CustomersTableTableFilterComposer,
          $$CustomersTableTableOrderingComposer,
          $$CustomersTableTableAnnotationComposer,
          $$CustomersTableTableCreateCompanionBuilder,
          $$CustomersTableTableUpdateCompanionBuilder,
          (CustomersTableData, $$CustomersTableTableReferences),
          CustomersTableData,
          PrefetchHooks Function({
            bool linesTableRefs,
            bool operationsTableRefs,
          })
        > {
  $$CustomersTableTableTableManager(
    _$AppDatabase db,
    $CustomersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> contactNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                name: name,
                contactNumber: contactNumber,
                status: status,
                tags: tags,
                pinned: pinned,
                notes: notes,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String id,
                required String name,
                required String contactNumber,
                Value<String> status = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                name: name,
                contactNumber: contactNumber,
                status: status,
                tags: tags,
                pinned: pinned,
                notes: notes,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({linesTableRefs = false, operationsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (linesTableRefs) db.linesTable,
                    if (operationsTableRefs) db.operationsTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (linesTableRefs)
                        await $_getPrefetchedData<
                          CustomersTableData,
                          $CustomersTableTable,
                          LinesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableTableReferences
                              ._linesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableTableReferences(
                                db,
                                table,
                                p0,
                              ).linesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (operationsTableRefs)
                        await $_getPrefetchedData<
                          CustomersTableData,
                          $CustomersTableTable,
                          OperationsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableTableReferences
                              ._operationsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableTableReferences(
                                db,
                                table,
                                p0,
                              ).operationsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTableTable,
      CustomersTableData,
      $$CustomersTableTableFilterComposer,
      $$CustomersTableTableOrderingComposer,
      $$CustomersTableTableAnnotationComposer,
      $$CustomersTableTableCreateCompanionBuilder,
      $$CustomersTableTableUpdateCompanionBuilder,
      (CustomersTableData, $$CustomersTableTableReferences),
      CustomersTableData,
      PrefetchHooks Function({bool linesTableRefs, bool operationsTableRefs})
    >;
typedef $$ShipmentsTableTableCreateCompanionBuilder =
    ShipmentsTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String id,
      required String companyId,
      required String type,
      Value<double> totalAmount,
      Value<double> amountPaid,
      Value<double> amountRemaining,
      Value<String?> paymentMethod,
      Value<String?> referenceNumber,
      required DateTime shipmentDate,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ShipmentsTableTableUpdateCompanionBuilder =
    ShipmentsTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> companyId,
      Value<String> type,
      Value<double> totalAmount,
      Value<double> amountPaid,
      Value<double> amountRemaining,
      Value<String?> paymentMethod,
      Value<String?> referenceNumber,
      Value<DateTime> shipmentDate,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$ShipmentsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ShipmentsTableTable,
          ShipmentsTableData
        > {
  $$ShipmentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTableTable _companyIdTable(_$AppDatabase db) =>
      db.companiesTable.createAlias('shipments__company_id__companies__id');

  $$CompaniesTableTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableTableManager(
      $_db,
      $_db.companiesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShipmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ShipmentsTableTable> {
  $$ShipmentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountRemaining => $composableBuilder(
    column: $table.amountRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get shipmentDate => $composableBuilder(
    column: $table.shipmentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableTableFilterComposer get companyId {
    final $$CompaniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableFilterComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShipmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ShipmentsTableTable> {
  $$ShipmentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountRemaining => $composableBuilder(
    column: $table.amountRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get shipmentDate => $composableBuilder(
    column: $table.shipmentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableTableOrderingComposer get companyId {
    final $$CompaniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShipmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShipmentsTableTable> {
  $$ShipmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountRemaining => $composableBuilder(
    column: $table.amountRemaining,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get shipmentDate => $composableBuilder(
    column: $table.shipmentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CompaniesTableTableAnnotationComposer get companyId {
    final $$CompaniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShipmentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShipmentsTableTable,
          ShipmentsTableData,
          $$ShipmentsTableTableFilterComposer,
          $$ShipmentsTableTableOrderingComposer,
          $$ShipmentsTableTableAnnotationComposer,
          $$ShipmentsTableTableCreateCompanionBuilder,
          $$ShipmentsTableTableUpdateCompanionBuilder,
          (ShipmentsTableData, $$ShipmentsTableTableReferences),
          ShipmentsTableData,
          PrefetchHooks Function({bool companyId})
        > {
  $$ShipmentsTableTableTableManager(
    _$AppDatabase db,
    $ShipmentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShipmentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShipmentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShipmentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> amountRemaining = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<DateTime> shipmentDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShipmentsTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                companyId: companyId,
                type: type,
                totalAmount: totalAmount,
                amountPaid: amountPaid,
                amountRemaining: amountRemaining,
                paymentMethod: paymentMethod,
                referenceNumber: referenceNumber,
                shipmentDate: shipmentDate,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String id,
                required String companyId,
                required String type,
                Value<double> totalAmount = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> amountRemaining = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                required DateTime shipmentDate,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShipmentsTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                companyId: companyId,
                type: type,
                totalAmount: totalAmount,
                amountPaid: amountPaid,
                amountRemaining: amountRemaining,
                paymentMethod: paymentMethod,
                referenceNumber: referenceNumber,
                shipmentDate: shipmentDate,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShipmentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
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
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$ShipmentsTableTableReferences
                                    ._companyIdTable(db),
                                referencedColumn:
                                    $$ShipmentsTableTableReferences
                                        ._companyIdTable(db)
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

typedef $$ShipmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShipmentsTableTable,
      ShipmentsTableData,
      $$ShipmentsTableTableFilterComposer,
      $$ShipmentsTableTableOrderingComposer,
      $$ShipmentsTableTableAnnotationComposer,
      $$ShipmentsTableTableCreateCompanionBuilder,
      $$ShipmentsTableTableUpdateCompanionBuilder,
      (ShipmentsTableData, $$ShipmentsTableTableReferences),
      ShipmentsTableData,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$LinesTableTableCreateCompanionBuilder =
    LinesTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String id,
      required String customerId,
      Value<String?> companyId,
      Value<String?> packageId,
      required String simNumber,
      Value<String?> companyName,
      Value<String?> companyInitials,
      Value<String?> packageName,
      Value<String?> packageSimType,
      required DateTime purchaseDate,
      required DateTime expiryDate,
      Value<double> wholesaleCost,
      Value<double> retailPrice,
      Value<double> profit,
      Value<String> paymentStatus,
      Value<double> amountPaid,
      Value<double> amountRemaining,
      Value<int> rowid,
    });
typedef $$LinesTableTableUpdateCompanionBuilder =
    LinesTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> customerId,
      Value<String?> companyId,
      Value<String?> packageId,
      Value<String> simNumber,
      Value<String?> companyName,
      Value<String?> companyInitials,
      Value<String?> packageName,
      Value<String?> packageSimType,
      Value<DateTime> purchaseDate,
      Value<DateTime> expiryDate,
      Value<double> wholesaleCost,
      Value<double> retailPrice,
      Value<double> profit,
      Value<String> paymentStatus,
      Value<double> amountPaid,
      Value<double> amountRemaining,
      Value<int> rowid,
    });

final class $$LinesTableTableReferences
    extends BaseReferences<_$AppDatabase, $LinesTableTable, LinesTableData> {
  $$LinesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTableTable _customerIdTable(_$AppDatabase db) =>
      db.customersTable.createAlias('lines__customer_id__customers__id');

  $$CustomersTableTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableTableManager(
      $_db,
      $_db.customersTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompaniesTableTable _companyIdTable(_$AppDatabase db) =>
      db.companiesTable.createAlias('lines__company_id__companies__id');

  $$CompaniesTableTableProcessedTableManager? get companyId {
    final $_column = $_itemColumn<String>('company_id');
    if ($_column == null) return null;
    final manager = $$CompaniesTableTableTableManager(
      $_db,
      $_db.companiesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PackagesTableTable _packageIdTable(_$AppDatabase db) =>
      db.packagesTable.createAlias('lines__package_id__packages__id');

  $$PackagesTableTableProcessedTableManager? get packageId {
    final $_column = $_itemColumn<String>('package_id');
    if ($_column == null) return null;
    final manager = $$PackagesTableTableTableManager(
      $_db,
      $_db.packagesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OperationsTableTable, List<OperationsTableData>>
  _operationsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operationsTable,
    aliasName: 'lines__id__operations__line_id',
  );

  $$OperationsTableTableProcessedTableManager get operationsTableRefs {
    final manager = $$OperationsTableTableTableManager(
      $_db,
      $_db.operationsTable,
    ).filter((f) => f.lineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _operationsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LinesTableTableFilterComposer
    extends Composer<_$AppDatabase, $LinesTableTable> {
  $$LinesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get simNumber => $composableBuilder(
    column: $table.simNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyInitials => $composableBuilder(
    column: $table.companyInitials,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageSimType => $composableBuilder(
    column: $table.packageSimType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get wholesaleCost => $composableBuilder(
    column: $table.wholesaleCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get retailPrice => $composableBuilder(
    column: $table.retailPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get profit => $composableBuilder(
    column: $table.profit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountRemaining => $composableBuilder(
    column: $table.amountRemaining,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableTableFilterComposer get customerId {
    final $$CustomersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableFilterComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableTableFilterComposer get companyId {
    final $$CompaniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableFilterComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PackagesTableTableFilterComposer get packageId {
    final $$PackagesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packageId,
      referencedTable: $db.packagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackagesTableTableFilterComposer(
            $db: $db,
            $table: $db.packagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> operationsTableRefs(
    Expression<bool> Function($$OperationsTableTableFilterComposer f) f,
  ) {
    final $$OperationsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.lineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableFilterComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LinesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LinesTableTable> {
  $$LinesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get simNumber => $composableBuilder(
    column: $table.simNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyInitials => $composableBuilder(
    column: $table.companyInitials,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageSimType => $composableBuilder(
    column: $table.packageSimType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get wholesaleCost => $composableBuilder(
    column: $table.wholesaleCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get retailPrice => $composableBuilder(
    column: $table.retailPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get profit => $composableBuilder(
    column: $table.profit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountRemaining => $composableBuilder(
    column: $table.amountRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableTableOrderingComposer get customerId {
    final $$CustomersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableOrderingComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableTableOrderingComposer get companyId {
    final $$CompaniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PackagesTableTableOrderingComposer get packageId {
    final $$PackagesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packageId,
      referencedTable: $db.packagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackagesTableTableOrderingComposer(
            $db: $db,
            $table: $db.packagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LinesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LinesTableTable> {
  $$LinesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get simNumber =>
      $composableBuilder(column: $table.simNumber, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get companyInitials => $composableBuilder(
    column: $table.companyInitials,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get packageSimType => $composableBuilder(
    column: $table.packageSimType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get wholesaleCost => $composableBuilder(
    column: $table.wholesaleCost,
    builder: (column) => column,
  );

  GeneratedColumn<double> get retailPrice => $composableBuilder(
    column: $table.retailPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get profit =>
      $composableBuilder(column: $table.profit, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountRemaining => $composableBuilder(
    column: $table.amountRemaining,
    builder: (column) => column,
  );

  $$CustomersTableTableAnnotationComposer get customerId {
    final $$CustomersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableTableAnnotationComposer get companyId {
    final $$CompaniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PackagesTableTableAnnotationComposer get packageId {
    final $$PackagesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packageId,
      referencedTable: $db.packagesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackagesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.packagesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> operationsTableRefs<T extends Object>(
    Expression<T> Function($$OperationsTableTableAnnotationComposer a) f,
  ) {
    final $$OperationsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationsTable,
      getReferencedColumn: (t) => t.lineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.operationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LinesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LinesTableTable,
          LinesTableData,
          $$LinesTableTableFilterComposer,
          $$LinesTableTableOrderingComposer,
          $$LinesTableTableAnnotationComposer,
          $$LinesTableTableCreateCompanionBuilder,
          $$LinesTableTableUpdateCompanionBuilder,
          (LinesTableData, $$LinesTableTableReferences),
          LinesTableData,
          PrefetchHooks Function({
            bool customerId,
            bool companyId,
            bool packageId,
            bool operationsTableRefs,
          })
        > {
  $$LinesTableTableTableManager(_$AppDatabase db, $LinesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> companyId = const Value.absent(),
                Value<String?> packageId = const Value.absent(),
                Value<String> simNumber = const Value.absent(),
                Value<String?> companyName = const Value.absent(),
                Value<String?> companyInitials = const Value.absent(),
                Value<String?> packageName = const Value.absent(),
                Value<String?> packageSimType = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<double> wholesaleCost = const Value.absent(),
                Value<double> retailPrice = const Value.absent(),
                Value<double> profit = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> amountRemaining = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinesTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                customerId: customerId,
                companyId: companyId,
                packageId: packageId,
                simNumber: simNumber,
                companyName: companyName,
                companyInitials: companyInitials,
                packageName: packageName,
                packageSimType: packageSimType,
                purchaseDate: purchaseDate,
                expiryDate: expiryDate,
                wholesaleCost: wholesaleCost,
                retailPrice: retailPrice,
                profit: profit,
                paymentStatus: paymentStatus,
                amountPaid: amountPaid,
                amountRemaining: amountRemaining,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String id,
                required String customerId,
                Value<String?> companyId = const Value.absent(),
                Value<String?> packageId = const Value.absent(),
                required String simNumber,
                Value<String?> companyName = const Value.absent(),
                Value<String?> companyInitials = const Value.absent(),
                Value<String?> packageName = const Value.absent(),
                Value<String?> packageSimType = const Value.absent(),
                required DateTime purchaseDate,
                required DateTime expiryDate,
                Value<double> wholesaleCost = const Value.absent(),
                Value<double> retailPrice = const Value.absent(),
                Value<double> profit = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> amountRemaining = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LinesTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                customerId: customerId,
                companyId: companyId,
                packageId: packageId,
                simNumber: simNumber,
                companyName: companyName,
                companyInitials: companyInitials,
                packageName: packageName,
                packageSimType: packageSimType,
                purchaseDate: purchaseDate,
                expiryDate: expiryDate,
                wholesaleCost: wholesaleCost,
                retailPrice: retailPrice,
                profit: profit,
                paymentStatus: paymentStatus,
                amountPaid: amountPaid,
                amountRemaining: amountRemaining,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LinesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerId = false,
                companyId = false,
                packageId = false,
                operationsTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (operationsTableRefs) db.operationsTable,
                  ],
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
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$LinesTableTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn:
                                        $$LinesTableTableReferences
                                            ._customerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$LinesTableTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn:
                                        $$LinesTableTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (packageId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.packageId,
                                    referencedTable: $$LinesTableTableReferences
                                        ._packageIdTable(db),
                                    referencedColumn:
                                        $$LinesTableTableReferences
                                            ._packageIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (operationsTableRefs)
                        await $_getPrefetchedData<
                          LinesTableData,
                          $LinesTableTable,
                          OperationsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$LinesTableTableReferences
                              ._operationsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LinesTableTableReferences(
                                db,
                                table,
                                p0,
                              ).operationsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lineId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LinesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LinesTableTable,
      LinesTableData,
      $$LinesTableTableFilterComposer,
      $$LinesTableTableOrderingComposer,
      $$LinesTableTableAnnotationComposer,
      $$LinesTableTableCreateCompanionBuilder,
      $$LinesTableTableUpdateCompanionBuilder,
      (LinesTableData, $$LinesTableTableReferences),
      LinesTableData,
      PrefetchHooks Function({
        bool customerId,
        bool companyId,
        bool packageId,
        bool operationsTableRefs,
      })
    >;
typedef $$OperationsTableTableCreateCompanionBuilder =
    OperationsTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String id,
      required String customerId,
      Value<String?> lineId,
      required String companyId,
      required DateTime occurredAt,
      Value<double> salePrice,
      Value<double> cost,
      Value<double> profit,
      Value<String> paymentStatus,
      Value<String?> repName,
      Value<int> rowid,
    });
typedef $$OperationsTableTableUpdateCompanionBuilder =
    OperationsTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> customerId,
      Value<String?> lineId,
      Value<String> companyId,
      Value<DateTime> occurredAt,
      Value<double> salePrice,
      Value<double> cost,
      Value<double> profit,
      Value<String> paymentStatus,
      Value<String?> repName,
      Value<int> rowid,
    });

final class $$OperationsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OperationsTableTable,
          OperationsTableData
        > {
  $$OperationsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTableTable _customerIdTable(_$AppDatabase db) =>
      db.customersTable.createAlias('operations__customer_id__customers__id');

  $$CustomersTableTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableTableManager(
      $_db,
      $_db.customersTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LinesTableTable _lineIdTable(_$AppDatabase db) =>
      db.linesTable.createAlias('operations__line_id__lines__id');

  $$LinesTableTableProcessedTableManager? get lineId {
    final $_column = $_itemColumn<String>('line_id');
    if ($_column == null) return null;
    final manager = $$LinesTableTableTableManager(
      $_db,
      $_db.linesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompaniesTableTable _companyIdTable(_$AppDatabase db) =>
      db.companiesTable.createAlias('operations__company_id__companies__id');

  $$CompaniesTableTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableTableManager(
      $_db,
      $_db.companiesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OperationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $OperationsTableTable> {
  $$OperationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get profit => $composableBuilder(
    column: $table.profit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repName => $composableBuilder(
    column: $table.repName,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableTableFilterComposer get customerId {
    final $$CustomersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableFilterComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LinesTableTableFilterComposer get lineId {
    final $$LinesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lineId,
      referencedTable: $db.linesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableTableFilterComposer(
            $db: $db,
            $table: $db.linesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableTableFilterComposer get companyId {
    final $$CompaniesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableFilterComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationsTableTable> {
  $$OperationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get profit => $composableBuilder(
    column: $table.profit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repName => $composableBuilder(
    column: $table.repName,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableTableOrderingComposer get customerId {
    final $$CustomersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableOrderingComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LinesTableTableOrderingComposer get lineId {
    final $$LinesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lineId,
      referencedTable: $db.linesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableTableOrderingComposer(
            $db: $db,
            $table: $db.linesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableTableOrderingComposer get companyId {
    final $$CompaniesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableOrderingComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationsTableTable> {
  $$OperationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<double> get profit =>
      $composableBuilder(column: $table.profit, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repName =>
      $composableBuilder(column: $table.repName, builder: (column) => column);

  $$CustomersTableTableAnnotationComposer get customerId {
    final $$CustomersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.customersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LinesTableTableAnnotationComposer get lineId {
    final $$LinesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lineId,
      referencedTable: $db.linesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LinesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.linesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompaniesTableTableAnnotationComposer get companyId {
    final $$CompaniesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companiesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.companiesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationsTableTable,
          OperationsTableData,
          $$OperationsTableTableFilterComposer,
          $$OperationsTableTableOrderingComposer,
          $$OperationsTableTableAnnotationComposer,
          $$OperationsTableTableCreateCompanionBuilder,
          $$OperationsTableTableUpdateCompanionBuilder,
          (OperationsTableData, $$OperationsTableTableReferences),
          OperationsTableData,
          PrefetchHooks Function({bool customerId, bool lineId, bool companyId})
        > {
  $$OperationsTableTableTableManager(
    _$AppDatabase db,
    $OperationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> lineId = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<double> salePrice = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<double> profit = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String?> repName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationsTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                customerId: customerId,
                lineId: lineId,
                companyId: companyId,
                occurredAt: occurredAt,
                salePrice: salePrice,
                cost: cost,
                profit: profit,
                paymentStatus: paymentStatus,
                repName: repName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String id,
                required String customerId,
                Value<String?> lineId = const Value.absent(),
                required String companyId,
                required DateTime occurredAt,
                Value<double> salePrice = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<double> profit = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String?> repName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationsTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                customerId: customerId,
                lineId: lineId,
                companyId: companyId,
                occurredAt: occurredAt,
                salePrice: salePrice,
                cost: cost,
                profit: profit,
                paymentStatus: paymentStatus,
                repName: repName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OperationsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({customerId = false, lineId = false, companyId = false}) {
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
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable:
                                        $$OperationsTableTableReferences
                                            ._customerIdTable(db),
                                    referencedColumn:
                                        $$OperationsTableTableReferences
                                            ._customerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (lineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.lineId,
                                    referencedTable:
                                        $$OperationsTableTableReferences
                                            ._lineIdTable(db),
                                    referencedColumn:
                                        $$OperationsTableTableReferences
                                            ._lineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$OperationsTableTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$OperationsTableTableReferences
                                            ._companyIdTable(db)
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

typedef $$OperationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationsTableTable,
      OperationsTableData,
      $$OperationsTableTableFilterComposer,
      $$OperationsTableTableOrderingComposer,
      $$OperationsTableTableAnnotationComposer,
      $$OperationsTableTableCreateCompanionBuilder,
      $$OperationsTableTableUpdateCompanionBuilder,
      (OperationsTableData, $$OperationsTableTableReferences),
      OperationsTableData,
      PrefetchHooks Function({bool customerId, bool lineId, bool companyId})
    >;
typedef $$ActivityLogTableTableCreateCompanionBuilder =
    ActivityLogTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String id,
      required DateTime occurredAt,
      required String actionType,
      Value<String?> details,
      Value<int> rowid,
    });
typedef $$ActivityLogTableTableUpdateCompanionBuilder =
    ActivityLogTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<DateTime> occurredAt,
      Value<String> actionType,
      Value<String?> details,
      Value<int> rowid,
    });

class $$ActivityLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLogTableTable> {
  $$ActivityLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLogTableTable> {
  $$ActivityLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLogTableTable> {
  $$ActivityLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);
}

class $$ActivityLogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityLogTableTable,
          ActivityLogTableData,
          $$ActivityLogTableTableFilterComposer,
          $$ActivityLogTableTableOrderingComposer,
          $$ActivityLogTableTableAnnotationComposer,
          $$ActivityLogTableTableCreateCompanionBuilder,
          $$ActivityLogTableTableUpdateCompanionBuilder,
          (
            ActivityLogTableData,
            BaseReferences<
              _$AppDatabase,
              $ActivityLogTableTable,
              ActivityLogTableData
            >,
          ),
          ActivityLogTableData,
          PrefetchHooks Function()
        > {
  $$ActivityLogTableTableTableManager(
    _$AppDatabase db,
    $ActivityLogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityLogTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                occurredAt: occurredAt,
                actionType: actionType,
                details: details,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String id,
                required DateTime occurredAt,
                required String actionType,
                Value<String?> details = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityLogTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                occurredAt: occurredAt,
                actionType: actionType,
                details: details,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityLogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityLogTableTable,
      ActivityLogTableData,
      $$ActivityLogTableTableFilterComposer,
      $$ActivityLogTableTableOrderingComposer,
      $$ActivityLogTableTableAnnotationComposer,
      $$ActivityLogTableTableCreateCompanionBuilder,
      $$ActivityLogTableTableUpdateCompanionBuilder,
      (
        ActivityLogTableData,
        BaseReferences<
          _$AppDatabase,
          $ActivityLogTableTable,
          ActivityLogTableData
        >,
      ),
      ActivityLogTableData,
      PrefetchHooks Function()
    >;
typedef $$SupportRequestsTableTableCreateCompanionBuilder =
    SupportRequestsTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String id,
      required String type,
      required String body,
      Value<String?> attachmentUrl,
      Value<String?> voiceNoteUrl,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SupportRequestsTableTableUpdateCompanionBuilder =
    SupportRequestsTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> type,
      Value<String> body,
      Value<String?> attachmentUrl,
      Value<String?> voiceNoteUrl,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SupportRequestsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SupportRequestsTableTable> {
  $$SupportRequestsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentUrl => $composableBuilder(
    column: $table.attachmentUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceNoteUrl => $composableBuilder(
    column: $table.voiceNoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupportRequestsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SupportRequestsTableTable> {
  $$SupportRequestsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentUrl => $composableBuilder(
    column: $table.attachmentUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceNoteUrl => $composableBuilder(
    column: $table.voiceNoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupportRequestsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupportRequestsTableTable> {
  $$SupportRequestsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get attachmentUrl => $composableBuilder(
    column: $table.attachmentUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voiceNoteUrl => $composableBuilder(
    column: $table.voiceNoteUrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SupportRequestsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupportRequestsTableTable,
          SupportRequestsTableData,
          $$SupportRequestsTableTableFilterComposer,
          $$SupportRequestsTableTableOrderingComposer,
          $$SupportRequestsTableTableAnnotationComposer,
          $$SupportRequestsTableTableCreateCompanionBuilder,
          $$SupportRequestsTableTableUpdateCompanionBuilder,
          (
            SupportRequestsTableData,
            BaseReferences<
              _$AppDatabase,
              $SupportRequestsTableTable,
              SupportRequestsTableData
            >,
          ),
          SupportRequestsTableData,
          PrefetchHooks Function()
        > {
  $$SupportRequestsTableTableTableManager(
    _$AppDatabase db,
    $SupportRequestsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupportRequestsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupportRequestsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupportRequestsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> attachmentUrl = const Value.absent(),
                Value<String?> voiceNoteUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupportRequestsTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                type: type,
                body: body,
                attachmentUrl: attachmentUrl,
                voiceNoteUrl: voiceNoteUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String id,
                required String type,
                required String body,
                Value<String?> attachmentUrl = const Value.absent(),
                Value<String?> voiceNoteUrl = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SupportRequestsTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                type: type,
                body: body,
                attachmentUrl: attachmentUrl,
                voiceNoteUrl: voiceNoteUrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupportRequestsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupportRequestsTableTable,
      SupportRequestsTableData,
      $$SupportRequestsTableTableFilterComposer,
      $$SupportRequestsTableTableOrderingComposer,
      $$SupportRequestsTableTableAnnotationComposer,
      $$SupportRequestsTableTableCreateCompanionBuilder,
      $$SupportRequestsTableTableUpdateCompanionBuilder,
      (
        SupportRequestsTableData,
        BaseReferences<
          _$AppDatabase,
          $SupportRequestsTableTable,
          SupportRequestsTableData
        >,
      ),
      SupportRequestsTableData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      Value<String> currencySymbol,
      Value<String> themePreference,
      Value<String?> cachedDisplayName,
      Value<String?> cachedRole,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> currencySymbol,
      Value<String> themePreference,
      Value<String?> cachedDisplayName,
      Value<String?> cachedRole,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachedDisplayName => $composableBuilder(
    column: $table.cachedDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachedRole => $composableBuilder(
    column: $table.cachedRole,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachedDisplayName => $composableBuilder(
    column: $table.cachedDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachedRole => $composableBuilder(
    column: $table.cachedRole,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cachedDisplayName => $composableBuilder(
    column: $table.cachedDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cachedRole => $composableBuilder(
    column: $table.cachedRole,
    builder: (column) => column,
  );
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsTableData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $SettingsTableTable,
              SettingsTableData
            >,
          ),
          SettingsTableData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<String> themePreference = const Value.absent(),
                Value<String?> cachedDisplayName = const Value.absent(),
                Value<String?> cachedRole = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                currencySymbol: currencySymbol,
                themePreference: themePreference,
                cachedDisplayName: cachedDisplayName,
                cachedRole: cachedRole,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                Value<String> currencySymbol = const Value.absent(),
                Value<String> themePreference = const Value.absent(),
                Value<String?> cachedDisplayName = const Value.absent(),
                Value<String?> cachedRole = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                currencySymbol: currencySymbol,
                themePreference: themePreference,
                cachedDisplayName: cachedDisplayName,
                cachedRole: cachedRole,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsTableData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsTableData,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>,
      ),
      SettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$NumberUpdateLogTableTableCreateCompanionBuilder =
    NumberUpdateLogTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String id,
      required String phoneNumber,
      required String status,
      required String message,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$NumberUpdateLogTableTableUpdateCompanionBuilder =
    NumberUpdateLogTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> id,
      Value<String> phoneNumber,
      Value<String> status,
      Value<String> message,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$NumberUpdateLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $NumberUpdateLogTableTable> {
  $$NumberUpdateLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NumberUpdateLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NumberUpdateLogTableTable> {
  $$NumberUpdateLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NumberUpdateLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NumberUpdateLogTableTable> {
  $$NumberUpdateLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NumberUpdateLogTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NumberUpdateLogTableTable,
          NumberUpdateLogTableData,
          $$NumberUpdateLogTableTableFilterComposer,
          $$NumberUpdateLogTableTableOrderingComposer,
          $$NumberUpdateLogTableTableAnnotationComposer,
          $$NumberUpdateLogTableTableCreateCompanionBuilder,
          $$NumberUpdateLogTableTableUpdateCompanionBuilder,
          (
            NumberUpdateLogTableData,
            BaseReferences<
              _$AppDatabase,
              $NumberUpdateLogTableTable,
              NumberUpdateLogTableData
            >,
          ),
          NumberUpdateLogTableData,
          PrefetchHooks Function()
        > {
  $$NumberUpdateLogTableTableTableManager(
    _$AppDatabase db,
    $NumberUpdateLogTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NumberUpdateLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NumberUpdateLogTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NumberUpdateLogTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NumberUpdateLogTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                phoneNumber: phoneNumber,
                status: status,
                message: message,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String id,
                required String phoneNumber,
                required String status,
                required String message,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => NumberUpdateLogTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                id: id,
                phoneNumber: phoneNumber,
                status: status,
                message: message,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NumberUpdateLogTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NumberUpdateLogTableTable,
      NumberUpdateLogTableData,
      $$NumberUpdateLogTableTableFilterComposer,
      $$NumberUpdateLogTableTableOrderingComposer,
      $$NumberUpdateLogTableTableAnnotationComposer,
      $$NumberUpdateLogTableTableCreateCompanionBuilder,
      $$NumberUpdateLogTableTableUpdateCompanionBuilder,
      (
        NumberUpdateLogTableData,
        BaseReferences<
          _$AppDatabase,
          $NumberUpdateLogTableTable,
          NumberUpdateLogTableData
        >,
      ),
      NumberUpdateLogTableData,
      PrefetchHooks Function()
    >;
typedef $$NumberUpdateProviderCacheTableTableCreateCompanionBuilder =
    NumberUpdateProviderCacheTableCompanion Function({
      required String ownerId,
      Value<bool> synced,
      required DateTime updatedAt,
      required String phoneNumber,
      required String provider,
      Value<int> rowid,
    });
typedef $$NumberUpdateProviderCacheTableTableUpdateCompanionBuilder =
    NumberUpdateProviderCacheTableCompanion Function({
      Value<String> ownerId,
      Value<bool> synced,
      Value<DateTime> updatedAt,
      Value<String> phoneNumber,
      Value<String> provider,
      Value<int> rowid,
    });

class $$NumberUpdateProviderCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $NumberUpdateProviderCacheTableTable> {
  $$NumberUpdateProviderCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NumberUpdateProviderCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NumberUpdateProviderCacheTableTable> {
  $$NumberUpdateProviderCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NumberUpdateProviderCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NumberUpdateProviderCacheTableTable> {
  $$NumberUpdateProviderCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);
}

class $$NumberUpdateProviderCacheTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NumberUpdateProviderCacheTableTable,
          NumberUpdateProviderCacheTableData,
          $$NumberUpdateProviderCacheTableTableFilterComposer,
          $$NumberUpdateProviderCacheTableTableOrderingComposer,
          $$NumberUpdateProviderCacheTableTableAnnotationComposer,
          $$NumberUpdateProviderCacheTableTableCreateCompanionBuilder,
          $$NumberUpdateProviderCacheTableTableUpdateCompanionBuilder,
          (
            NumberUpdateProviderCacheTableData,
            BaseReferences<
              _$AppDatabase,
              $NumberUpdateProviderCacheTableTable,
              NumberUpdateProviderCacheTableData
            >,
          ),
          NumberUpdateProviderCacheTableData,
          PrefetchHooks Function()
        > {
  $$NumberUpdateProviderCacheTableTableTableManager(
    _$AppDatabase db,
    $NumberUpdateProviderCacheTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NumberUpdateProviderCacheTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NumberUpdateProviderCacheTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NumberUpdateProviderCacheTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NumberUpdateProviderCacheTableCompanion(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                phoneNumber: phoneNumber,
                provider: provider,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                Value<bool> synced = const Value.absent(),
                required DateTime updatedAt,
                required String phoneNumber,
                required String provider,
                Value<int> rowid = const Value.absent(),
              }) => NumberUpdateProviderCacheTableCompanion.insert(
                ownerId: ownerId,
                synced: synced,
                updatedAt: updatedAt,
                phoneNumber: phoneNumber,
                provider: provider,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NumberUpdateProviderCacheTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NumberUpdateProviderCacheTableTable,
      NumberUpdateProviderCacheTableData,
      $$NumberUpdateProviderCacheTableTableFilterComposer,
      $$NumberUpdateProviderCacheTableTableOrderingComposer,
      $$NumberUpdateProviderCacheTableTableAnnotationComposer,
      $$NumberUpdateProviderCacheTableTableCreateCompanionBuilder,
      $$NumberUpdateProviderCacheTableTableUpdateCompanionBuilder,
      (
        NumberUpdateProviderCacheTableData,
        BaseReferences<
          _$AppDatabase,
          $NumberUpdateProviderCacheTableTable,
          NumberUpdateProviderCacheTableData
        >,
      ),
      NumberUpdateProviderCacheTableData,
      PrefetchHooks Function()
    >;
typedef $$PendingDeletesTableTableCreateCompanionBuilder =
    PendingDeletesTableCompanion Function({
      required String entityTable,
      required String entityId,
      required String ownerId,
      Value<int> rowid,
    });
typedef $$PendingDeletesTableTableUpdateCompanionBuilder =
    PendingDeletesTableCompanion Function({
      Value<String> entityTable,
      Value<String> entityId,
      Value<String> ownerId,
      Value<int> rowid,
    });

class $$PendingDeletesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingDeletesTableTable> {
  $$PendingDeletesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingDeletesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingDeletesTableTable> {
  $$PendingDeletesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingDeletesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingDeletesTableTable> {
  $$PendingDeletesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);
}

class $$PendingDeletesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingDeletesTableTable,
          PendingDeletesTableData,
          $$PendingDeletesTableTableFilterComposer,
          $$PendingDeletesTableTableOrderingComposer,
          $$PendingDeletesTableTableAnnotationComposer,
          $$PendingDeletesTableTableCreateCompanionBuilder,
          $$PendingDeletesTableTableUpdateCompanionBuilder,
          (
            PendingDeletesTableData,
            BaseReferences<
              _$AppDatabase,
              $PendingDeletesTableTable,
              PendingDeletesTableData
            >,
          ),
          PendingDeletesTableData,
          PrefetchHooks Function()
        > {
  $$PendingDeletesTableTableTableManager(
    _$AppDatabase db,
    $PendingDeletesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingDeletesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingDeletesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingDeletesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityTable = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingDeletesTableCompanion(
                entityTable: entityTable,
                entityId: entityId,
                ownerId: ownerId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityTable,
                required String entityId,
                required String ownerId,
                Value<int> rowid = const Value.absent(),
              }) => PendingDeletesTableCompanion.insert(
                entityTable: entityTable,
                entityId: entityId,
                ownerId: ownerId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingDeletesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingDeletesTableTable,
      PendingDeletesTableData,
      $$PendingDeletesTableTableFilterComposer,
      $$PendingDeletesTableTableOrderingComposer,
      $$PendingDeletesTableTableAnnotationComposer,
      $$PendingDeletesTableTableCreateCompanionBuilder,
      $$PendingDeletesTableTableUpdateCompanionBuilder,
      (
        PendingDeletesTableData,
        BaseReferences<
          _$AppDatabase,
          $PendingDeletesTableTable,
          PendingDeletesTableData
        >,
      ),
      PendingDeletesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CompanyCatalogTableTableTableManager get companyCatalogTable =>
      $$CompanyCatalogTableTableTableManager(_db, _db.companyCatalogTable);
  $$PackageCatalogTableTableTableManager get packageCatalogTable =>
      $$PackageCatalogTableTableTableManager(_db, _db.packageCatalogTable);
  $$CompaniesTableTableTableManager get companiesTable =>
      $$CompaniesTableTableTableManager(_db, _db.companiesTable);
  $$PackagesTableTableTableManager get packagesTable =>
      $$PackagesTableTableTableManager(_db, _db.packagesTable);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(_db, _db.customersTable);
  $$ShipmentsTableTableTableManager get shipmentsTable =>
      $$ShipmentsTableTableTableManager(_db, _db.shipmentsTable);
  $$LinesTableTableTableManager get linesTable =>
      $$LinesTableTableTableManager(_db, _db.linesTable);
  $$OperationsTableTableTableManager get operationsTable =>
      $$OperationsTableTableTableManager(_db, _db.operationsTable);
  $$ActivityLogTableTableTableManager get activityLogTable =>
      $$ActivityLogTableTableTableManager(_db, _db.activityLogTable);
  $$SupportRequestsTableTableTableManager get supportRequestsTable =>
      $$SupportRequestsTableTableTableManager(_db, _db.supportRequestsTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$NumberUpdateLogTableTableTableManager get numberUpdateLogTable =>
      $$NumberUpdateLogTableTableTableManager(_db, _db.numberUpdateLogTable);
  $$NumberUpdateProviderCacheTableTableTableManager
  get numberUpdateProviderCacheTable =>
      $$NumberUpdateProviderCacheTableTableTableManager(
        _db,
        _db.numberUpdateProviderCacheTable,
      );
  $$PendingDeletesTableTableTableManager get pendingDeletesTable =>
      $$PendingDeletesTableTableTableManager(_db, _db.pendingDeletesTable);
}
