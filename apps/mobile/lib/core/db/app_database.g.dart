// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MachinesTable extends Machines with TableInfo<$MachinesTable, Machine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MachinesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeCodeMeta = const VerificationMeta(
    'typeCode',
  );
  @override
  late final GeneratedColumn<String> typeCode = GeneratedColumn<String>(
    'type_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kCodeMeta = const VerificationMeta('kCode');
  @override
  late final GeneratedColumn<String> kCode = GeneratedColumn<String>(
    'k_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _marketMeta = const VerificationMeta('market');
  @override
  late final GeneratedColumn<String> market = GeneratedColumn<String>(
    'market',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _engineSeriesMeta = const VerificationMeta(
    'engineSeries',
  );
  @override
  late final GeneratedColumn<String> engineSeries = GeneratedColumn<String>(
    'engine_series',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frameSeriesMeta = const VerificationMeta(
    'frameSeries',
  );
  @override
  late final GeneratedColumn<String> frameSeries = GeneratedColumn<String>(
    'frame_series',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearFromMeta = const VerificationMeta(
    'yearFrom',
  );
  @override
  late final GeneratedColumn<int> yearFrom = GeneratedColumn<int>(
    'year_from',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearToMeta = const VerificationMeta('yearTo');
  @override
  late final GeneratedColumn<int> yearTo = GeneratedColumn<int>(
    'year_to',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogEditionMeta = const VerificationMeta(
    'catalogEdition',
  );
  @override
  late final GeneratedColumn<String> catalogEdition = GeneratedColumn<String>(
    'catalog_edition',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _catalogDateMeta = const VerificationMeta(
    'catalogDate',
  );
  @override
  late final GeneratedColumn<String> catalogDate = GeneratedColumn<String>(
    'catalog_date',
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
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    brand,
    model,
    typeCode,
    kCode,
    market,
    engineSeries,
    frameSeries,
    yearFrom,
    yearTo,
    catalogEdition,
    catalogDate,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'machines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Machine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('type_code')) {
      context.handle(
        _typeCodeMeta,
        typeCode.isAcceptableOrUnknown(data['type_code']!, _typeCodeMeta),
      );
    }
    if (data.containsKey('k_code')) {
      context.handle(
        _kCodeMeta,
        kCode.isAcceptableOrUnknown(data['k_code']!, _kCodeMeta),
      );
    }
    if (data.containsKey('market')) {
      context.handle(
        _marketMeta,
        market.isAcceptableOrUnknown(data['market']!, _marketMeta),
      );
    }
    if (data.containsKey('engine_series')) {
      context.handle(
        _engineSeriesMeta,
        engineSeries.isAcceptableOrUnknown(
          data['engine_series']!,
          _engineSeriesMeta,
        ),
      );
    }
    if (data.containsKey('frame_series')) {
      context.handle(
        _frameSeriesMeta,
        frameSeries.isAcceptableOrUnknown(
          data['frame_series']!,
          _frameSeriesMeta,
        ),
      );
    }
    if (data.containsKey('year_from')) {
      context.handle(
        _yearFromMeta,
        yearFrom.isAcceptableOrUnknown(data['year_from']!, _yearFromMeta),
      );
    }
    if (data.containsKey('year_to')) {
      context.handle(
        _yearToMeta,
        yearTo.isAcceptableOrUnknown(data['year_to']!, _yearToMeta),
      );
    }
    if (data.containsKey('catalog_edition')) {
      context.handle(
        _catalogEditionMeta,
        catalogEdition.isAcceptableOrUnknown(
          data['catalog_edition']!,
          _catalogEditionMeta,
        ),
      );
    }
    if (data.containsKey('catalog_date')) {
      context.handle(
        _catalogDateMeta,
        catalogDate.isAcceptableOrUnknown(
          data['catalog_date']!,
          _catalogDateMeta,
        ),
      );
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
  Machine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Machine(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      typeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_code'],
      ),
      kCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}k_code'],
      ),
      market: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market'],
      ),
      engineSeries: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_series'],
      ),
      frameSeries: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frame_series'],
      ),
      yearFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_from'],
      ),
      yearTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_to'],
      ),
      catalogEdition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_edition'],
      ),
      catalogDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $MachinesTable createAlias(String alias) {
    return $MachinesTable(attachedDatabase, alias);
  }
}

class Machine extends DataClass implements Insertable<Machine> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String brand;
  final String model;
  final String? typeCode;
  final String? kCode;
  final String? market;
  final String? engineSeries;
  final String? frameSeries;
  final int? yearFrom;
  final int? yearTo;
  final String? catalogEdition;
  final String? catalogDate;
  final String? notes;
  const Machine({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.brand,
    required this.model,
    this.typeCode,
    this.kCode,
    this.market,
    this.engineSeries,
    this.frameSeries,
    this.yearFrom,
    this.yearTo,
    this.catalogEdition,
    this.catalogDate,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || typeCode != null) {
      map['type_code'] = Variable<String>(typeCode);
    }
    if (!nullToAbsent || kCode != null) {
      map['k_code'] = Variable<String>(kCode);
    }
    if (!nullToAbsent || market != null) {
      map['market'] = Variable<String>(market);
    }
    if (!nullToAbsent || engineSeries != null) {
      map['engine_series'] = Variable<String>(engineSeries);
    }
    if (!nullToAbsent || frameSeries != null) {
      map['frame_series'] = Variable<String>(frameSeries);
    }
    if (!nullToAbsent || yearFrom != null) {
      map['year_from'] = Variable<int>(yearFrom);
    }
    if (!nullToAbsent || yearTo != null) {
      map['year_to'] = Variable<int>(yearTo);
    }
    if (!nullToAbsent || catalogEdition != null) {
      map['catalog_edition'] = Variable<String>(catalogEdition);
    }
    if (!nullToAbsent || catalogDate != null) {
      map['catalog_date'] = Variable<String>(catalogDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  MachinesCompanion toCompanion(bool nullToAbsent) {
    return MachinesCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      brand: Value(brand),
      model: Value(model),
      typeCode: typeCode == null && nullToAbsent
          ? const Value.absent()
          : Value(typeCode),
      kCode: kCode == null && nullToAbsent
          ? const Value.absent()
          : Value(kCode),
      market: market == null && nullToAbsent
          ? const Value.absent()
          : Value(market),
      engineSeries: engineSeries == null && nullToAbsent
          ? const Value.absent()
          : Value(engineSeries),
      frameSeries: frameSeries == null && nullToAbsent
          ? const Value.absent()
          : Value(frameSeries),
      yearFrom: yearFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(yearFrom),
      yearTo: yearTo == null && nullToAbsent
          ? const Value.absent()
          : Value(yearTo),
      catalogEdition: catalogEdition == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogEdition),
      catalogDate: catalogDate == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Machine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Machine(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      typeCode: serializer.fromJson<String?>(json['typeCode']),
      kCode: serializer.fromJson<String?>(json['kCode']),
      market: serializer.fromJson<String?>(json['market']),
      engineSeries: serializer.fromJson<String?>(json['engineSeries']),
      frameSeries: serializer.fromJson<String?>(json['frameSeries']),
      yearFrom: serializer.fromJson<int?>(json['yearFrom']),
      yearTo: serializer.fromJson<int?>(json['yearTo']),
      catalogEdition: serializer.fromJson<String?>(json['catalogEdition']),
      catalogDate: serializer.fromJson<String?>(json['catalogDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'typeCode': serializer.toJson<String?>(typeCode),
      'kCode': serializer.toJson<String?>(kCode),
      'market': serializer.toJson<String?>(market),
      'engineSeries': serializer.toJson<String?>(engineSeries),
      'frameSeries': serializer.toJson<String?>(frameSeries),
      'yearFrom': serializer.toJson<int?>(yearFrom),
      'yearTo': serializer.toJson<int?>(yearTo),
      'catalogEdition': serializer.toJson<String?>(catalogEdition),
      'catalogDate': serializer.toJson<String?>(catalogDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Machine copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? brand,
    String? model,
    Value<String?> typeCode = const Value.absent(),
    Value<String?> kCode = const Value.absent(),
    Value<String?> market = const Value.absent(),
    Value<String?> engineSeries = const Value.absent(),
    Value<String?> frameSeries = const Value.absent(),
    Value<int?> yearFrom = const Value.absent(),
    Value<int?> yearTo = const Value.absent(),
    Value<String?> catalogEdition = const Value.absent(),
    Value<String?> catalogDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Machine(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    typeCode: typeCode.present ? typeCode.value : this.typeCode,
    kCode: kCode.present ? kCode.value : this.kCode,
    market: market.present ? market.value : this.market,
    engineSeries: engineSeries.present ? engineSeries.value : this.engineSeries,
    frameSeries: frameSeries.present ? frameSeries.value : this.frameSeries,
    yearFrom: yearFrom.present ? yearFrom.value : this.yearFrom,
    yearTo: yearTo.present ? yearTo.value : this.yearTo,
    catalogEdition: catalogEdition.present
        ? catalogEdition.value
        : this.catalogEdition,
    catalogDate: catalogDate.present ? catalogDate.value : this.catalogDate,
    notes: notes.present ? notes.value : this.notes,
  );
  Machine copyWithCompanion(MachinesCompanion data) {
    return Machine(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      typeCode: data.typeCode.present ? data.typeCode.value : this.typeCode,
      kCode: data.kCode.present ? data.kCode.value : this.kCode,
      market: data.market.present ? data.market.value : this.market,
      engineSeries: data.engineSeries.present
          ? data.engineSeries.value
          : this.engineSeries,
      frameSeries: data.frameSeries.present
          ? data.frameSeries.value
          : this.frameSeries,
      yearFrom: data.yearFrom.present ? data.yearFrom.value : this.yearFrom,
      yearTo: data.yearTo.present ? data.yearTo.value : this.yearTo,
      catalogEdition: data.catalogEdition.present
          ? data.catalogEdition.value
          : this.catalogEdition,
      catalogDate: data.catalogDate.present
          ? data.catalogDate.value
          : this.catalogDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Machine(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('typeCode: $typeCode, ')
          ..write('kCode: $kCode, ')
          ..write('market: $market, ')
          ..write('engineSeries: $engineSeries, ')
          ..write('frameSeries: $frameSeries, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('yearTo: $yearTo, ')
          ..write('catalogEdition: $catalogEdition, ')
          ..write('catalogDate: $catalogDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    deletedAt,
    id,
    brand,
    model,
    typeCode,
    kCode,
    market,
    engineSeries,
    frameSeries,
    yearFrom,
    yearTo,
    catalogEdition,
    catalogDate,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Machine &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.typeCode == this.typeCode &&
          other.kCode == this.kCode &&
          other.market == this.market &&
          other.engineSeries == this.engineSeries &&
          other.frameSeries == this.frameSeries &&
          other.yearFrom == this.yearFrom &&
          other.yearTo == this.yearTo &&
          other.catalogEdition == this.catalogEdition &&
          other.catalogDate == this.catalogDate &&
          other.notes == this.notes);
}

class MachinesCompanion extends UpdateCompanion<Machine> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> brand;
  final Value<String> model;
  final Value<String?> typeCode;
  final Value<String?> kCode;
  final Value<String?> market;
  final Value<String?> engineSeries;
  final Value<String?> frameSeries;
  final Value<int?> yearFrom;
  final Value<int?> yearTo;
  final Value<String?> catalogEdition;
  final Value<String?> catalogDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const MachinesCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.typeCode = const Value.absent(),
    this.kCode = const Value.absent(),
    this.market = const Value.absent(),
    this.engineSeries = const Value.absent(),
    this.frameSeries = const Value.absent(),
    this.yearFrom = const Value.absent(),
    this.yearTo = const Value.absent(),
    this.catalogEdition = const Value.absent(),
    this.catalogDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MachinesCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String brand,
    required String model,
    this.typeCode = const Value.absent(),
    this.kCode = const Value.absent(),
    this.market = const Value.absent(),
    this.engineSeries = const Value.absent(),
    this.frameSeries = const Value.absent(),
    this.yearFrom = const Value.absent(),
    this.yearTo = const Value.absent(),
    this.catalogEdition = const Value.absent(),
    this.catalogDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       brand = Value(brand),
       model = Value(model);
  static Insertable<Machine> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? typeCode,
    Expression<String>? kCode,
    Expression<String>? market,
    Expression<String>? engineSeries,
    Expression<String>? frameSeries,
    Expression<int>? yearFrom,
    Expression<int>? yearTo,
    Expression<String>? catalogEdition,
    Expression<String>? catalogDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (typeCode != null) 'type_code': typeCode,
      if (kCode != null) 'k_code': kCode,
      if (market != null) 'market': market,
      if (engineSeries != null) 'engine_series': engineSeries,
      if (frameSeries != null) 'frame_series': frameSeries,
      if (yearFrom != null) 'year_from': yearFrom,
      if (yearTo != null) 'year_to': yearTo,
      if (catalogEdition != null) 'catalog_edition': catalogEdition,
      if (catalogDate != null) 'catalog_date': catalogDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MachinesCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? brand,
    Value<String>? model,
    Value<String?>? typeCode,
    Value<String?>? kCode,
    Value<String?>? market,
    Value<String?>? engineSeries,
    Value<String?>? frameSeries,
    Value<int?>? yearFrom,
    Value<int?>? yearTo,
    Value<String?>? catalogEdition,
    Value<String?>? catalogDate,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return MachinesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      typeCode: typeCode ?? this.typeCode,
      kCode: kCode ?? this.kCode,
      market: market ?? this.market,
      engineSeries: engineSeries ?? this.engineSeries,
      frameSeries: frameSeries ?? this.frameSeries,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      catalogEdition: catalogEdition ?? this.catalogEdition,
      catalogDate: catalogDate ?? this.catalogDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (typeCode.present) {
      map['type_code'] = Variable<String>(typeCode.value);
    }
    if (kCode.present) {
      map['k_code'] = Variable<String>(kCode.value);
    }
    if (market.present) {
      map['market'] = Variable<String>(market.value);
    }
    if (engineSeries.present) {
      map['engine_series'] = Variable<String>(engineSeries.value);
    }
    if (frameSeries.present) {
      map['frame_series'] = Variable<String>(frameSeries.value);
    }
    if (yearFrom.present) {
      map['year_from'] = Variable<int>(yearFrom.value);
    }
    if (yearTo.present) {
      map['year_to'] = Variable<int>(yearTo.value);
    }
    if (catalogEdition.present) {
      map['catalog_edition'] = Variable<String>(catalogEdition.value);
    }
    if (catalogDate.present) {
      map['catalog_date'] = Variable<String>(catalogDate.value);
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
    return (StringBuffer('MachinesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('typeCode: $typeCode, ')
          ..write('kCode: $kCode, ')
          ..write('market: $market, ')
          ..write('engineSeries: $engineSeries, ')
          ..write('frameSeries: $frameSeries, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('yearTo: $yearTo, ')
          ..write('catalogEdition: $catalogEdition, ')
          ..write('catalogDate: $catalogDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MachineVariantsTable extends MachineVariants
    with TableInfo<$MachineVariantsTable, MachineVariant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MachineVariantsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _machineIdMeta = const VerificationMeta(
    'machineId',
  );
  @override
  late final GeneratedColumn<String> machineId = GeneratedColumn<String>(
    'machine_id',
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
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    machineId,
    name,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'machine_variants';
  @override
  VerificationContext validateIntegrity(
    Insertable<MachineVariant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('machine_id')) {
      context.handle(
        _machineIdMeta,
        machineId.isAcceptableOrUnknown(data['machine_id']!, _machineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_machineIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MachineVariant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MachineVariant(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      machineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}machine_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $MachineVariantsTable createAlias(String alias) {
    return $MachineVariantsTable(attachedDatabase, alias);
  }
}

class MachineVariant extends DataClass implements Insertable<MachineVariant> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String machineId;
  final String name;
  final String? note;
  const MachineVariant({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.machineId,
    required this.name,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['machine_id'] = Variable<String>(machineId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  MachineVariantsCompanion toCompanion(bool nullToAbsent) {
    return MachineVariantsCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      machineId: Value(machineId),
      name: Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory MachineVariant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MachineVariant(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      machineId: serializer.fromJson<String>(json['machineId']),
      name: serializer.fromJson<String>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'machineId': serializer.toJson<String>(machineId),
      'name': serializer.toJson<String>(name),
      'note': serializer.toJson<String?>(note),
    };
  }

  MachineVariant copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? machineId,
    String? name,
    Value<String?> note = const Value.absent(),
  }) => MachineVariant(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    machineId: machineId ?? this.machineId,
    name: name ?? this.name,
    note: note.present ? note.value : this.note,
  );
  MachineVariant copyWithCompanion(MachineVariantsCompanion data) {
    return MachineVariant(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      machineId: data.machineId.present ? data.machineId.value : this.machineId,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MachineVariant(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('machineId: $machineId, ')
          ..write('name: $name, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(updatedAt, deletedAt, id, machineId, name, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MachineVariant &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.machineId == this.machineId &&
          other.name == this.name &&
          other.note == this.note);
}

class MachineVariantsCompanion extends UpdateCompanion<MachineVariant> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> machineId;
  final Value<String> name;
  final Value<String?> note;
  final Value<int> rowid;
  const MachineVariantsCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.machineId = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MachineVariantsCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String machineId,
    required String name,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       machineId = Value(machineId),
       name = Value(name);
  static Insertable<MachineVariant> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? machineId,
    Expression<String>? name,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (machineId != null) 'machine_id': machineId,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MachineVariantsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? machineId,
    Value<String>? name,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return MachineVariantsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      name: name ?? this.name,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (machineId.present) {
      map['machine_id'] = Variable<String>(machineId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MachineVariantsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('machineId: $machineId, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColorsTable extends Colors with TableInfo<$ColorsTable, Color> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColorsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _machineIdMeta = const VerificationMeta(
    'machineId',
  );
  @override
  late final GeneratedColumn<String> machineId = GeneratedColumn<String>(
    'machine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    machineId,
    code,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'colors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Color> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('machine_id')) {
      context.handle(
        _machineIdMeta,
        machineId.isAcceptableOrUnknown(data['machine_id']!, _machineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_machineIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Color map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Color(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      machineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}machine_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ColorsTable createAlias(String alias) {
    return $ColorsTable(attachedDatabase, alias);
  }
}

class Color extends DataClass implements Insertable<Color> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String machineId;
  final String code;
  final String name;
  const Color({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.machineId,
    required this.code,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['machine_id'] = Variable<String>(machineId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    return map;
  }

  ColorsCompanion toCompanion(bool nullToAbsent) {
    return ColorsCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      machineId: Value(machineId),
      code: Value(code),
      name: Value(name),
    );
  }

  factory Color.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Color(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      machineId: serializer.fromJson<String>(json['machineId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'machineId': serializer.toJson<String>(machineId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
    };
  }

  Color copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? machineId,
    String? code,
    String? name,
  }) => Color(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    machineId: machineId ?? this.machineId,
    code: code ?? this.code,
    name: name ?? this.name,
  );
  Color copyWithCompanion(ColorsCompanion data) {
    return Color(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      machineId: data.machineId.present ? data.machineId.value : this.machineId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Color(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('machineId: $machineId, ')
          ..write('code: $code, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(updatedAt, deletedAt, id, machineId, code, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Color &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.machineId == this.machineId &&
          other.code == this.code &&
          other.name == this.name);
}

class ColorsCompanion extends UpdateCompanion<Color> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> machineId;
  final Value<String> code;
  final Value<String> name;
  final Value<int> rowid;
  const ColorsCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.machineId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColorsCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String machineId,
    required String code,
    required String name,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       machineId = Value(machineId),
       code = Value(code),
       name = Value(name);
  static Insertable<Color> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? machineId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (machineId != null) 'machine_id': machineId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ColorsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? machineId,
    Value<String>? code,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return ColorsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      code: code ?? this.code,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (machineId.present) {
      map['machine_id'] = Variable<String>(machineId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColorsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('machineId: $machineId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssembliesTable extends Assemblies
    with TableInfo<$AssembliesTable, Assembly> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssembliesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _machineIdMeta = const VerificationMeta(
    'machineId',
  );
  @override
  late final GeneratedColumn<String> machineId = GeneratedColumn<String>(
    'machine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupTypeMeta = const VerificationMeta(
    'groupType',
  );
  @override
  late final GeneratedColumn<String> groupType = GeneratedColumn<String>(
    'group_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  static const VerificationMeta _imageRefMeta = const VerificationMeta(
    'imageRef',
  );
  @override
  late final GeneratedColumn<String> imageRef = GeneratedColumn<String>(
    'image_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageCodeMeta = const VerificationMeta(
    'imageCode',
  );
  @override
  late final GeneratedColumn<String> imageCode = GeneratedColumn<String>(
    'image_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageNoMeta = const VerificationMeta('pageNo');
  @override
  late final GeneratedColumn<int> pageNo = GeneratedColumn<int>(
    'page_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    machineId,
    groupType,
    code,
    name,
    imageRef,
    imageCode,
    width,
    height,
    pageNo,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assemblies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Assembly> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('machine_id')) {
      context.handle(
        _machineIdMeta,
        machineId.isAcceptableOrUnknown(data['machine_id']!, _machineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_machineIdMeta);
    }
    if (data.containsKey('group_type')) {
      context.handle(
        _groupTypeMeta,
        groupType.isAcceptableOrUnknown(data['group_type']!, _groupTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_groupTypeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_ref')) {
      context.handle(
        _imageRefMeta,
        imageRef.isAcceptableOrUnknown(data['image_ref']!, _imageRefMeta),
      );
    }
    if (data.containsKey('image_code')) {
      context.handle(
        _imageCodeMeta,
        imageCode.isAcceptableOrUnknown(data['image_code']!, _imageCodeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('page_no')) {
      context.handle(
        _pageNoMeta,
        pageNo.isAcceptableOrUnknown(data['page_no']!, _pageNoMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assembly map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assembly(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      machineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}machine_id'],
      )!,
      groupType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_type'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_ref'],
      ),
      imageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_code'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      pageNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_no'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  $AssembliesTable createAlias(String alias) {
    return $AssembliesTable(attachedDatabase, alias);
  }
}

class Assembly extends DataClass implements Insertable<Assembly> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String machineId;
  final String groupType;
  final String code;
  final String name;
  final String? imageRef;
  final String? imageCode;
  final int? width;
  final int? height;
  final int? pageNo;
  final int? sortOrder;
  const Assembly({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.machineId,
    required this.groupType,
    required this.code,
    required this.name,
    this.imageRef,
    this.imageCode,
    this.width,
    this.height,
    this.pageNo,
    this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['machine_id'] = Variable<String>(machineId);
    map['group_type'] = Variable<String>(groupType);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageRef != null) {
      map['image_ref'] = Variable<String>(imageRef);
    }
    if (!nullToAbsent || imageCode != null) {
      map['image_code'] = Variable<String>(imageCode);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || pageNo != null) {
      map['page_no'] = Variable<int>(pageNo);
    }
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  AssembliesCompanion toCompanion(bool nullToAbsent) {
    return AssembliesCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      machineId: Value(machineId),
      groupType: Value(groupType),
      code: Value(code),
      name: Value(name),
      imageRef: imageRef == null && nullToAbsent
          ? const Value.absent()
          : Value(imageRef),
      imageCode: imageCode == null && nullToAbsent
          ? const Value.absent()
          : Value(imageCode),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      pageNo: pageNo == null && nullToAbsent
          ? const Value.absent()
          : Value(pageNo),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory Assembly.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assembly(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      machineId: serializer.fromJson<String>(json['machineId']),
      groupType: serializer.fromJson<String>(json['groupType']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      imageRef: serializer.fromJson<String?>(json['imageRef']),
      imageCode: serializer.fromJson<String?>(json['imageCode']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      pageNo: serializer.fromJson<int?>(json['pageNo']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'machineId': serializer.toJson<String>(machineId),
      'groupType': serializer.toJson<String>(groupType),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'imageRef': serializer.toJson<String?>(imageRef),
      'imageCode': serializer.toJson<String?>(imageCode),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'pageNo': serializer.toJson<int?>(pageNo),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  Assembly copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? machineId,
    String? groupType,
    String? code,
    String? name,
    Value<String?> imageRef = const Value.absent(),
    Value<String?> imageCode = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> pageNo = const Value.absent(),
    Value<int?> sortOrder = const Value.absent(),
  }) => Assembly(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    machineId: machineId ?? this.machineId,
    groupType: groupType ?? this.groupType,
    code: code ?? this.code,
    name: name ?? this.name,
    imageRef: imageRef.present ? imageRef.value : this.imageRef,
    imageCode: imageCode.present ? imageCode.value : this.imageCode,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    pageNo: pageNo.present ? pageNo.value : this.pageNo,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  Assembly copyWithCompanion(AssembliesCompanion data) {
    return Assembly(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      machineId: data.machineId.present ? data.machineId.value : this.machineId,
      groupType: data.groupType.present ? data.groupType.value : this.groupType,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      imageRef: data.imageRef.present ? data.imageRef.value : this.imageRef,
      imageCode: data.imageCode.present ? data.imageCode.value : this.imageCode,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      pageNo: data.pageNo.present ? data.pageNo.value : this.pageNo,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assembly(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('machineId: $machineId, ')
          ..write('groupType: $groupType, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('imageRef: $imageRef, ')
          ..write('imageCode: $imageCode, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('pageNo: $pageNo, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    deletedAt,
    id,
    machineId,
    groupType,
    code,
    name,
    imageRef,
    imageCode,
    width,
    height,
    pageNo,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assembly &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.machineId == this.machineId &&
          other.groupType == this.groupType &&
          other.code == this.code &&
          other.name == this.name &&
          other.imageRef == this.imageRef &&
          other.imageCode == this.imageCode &&
          other.width == this.width &&
          other.height == this.height &&
          other.pageNo == this.pageNo &&
          other.sortOrder == this.sortOrder);
}

class AssembliesCompanion extends UpdateCompanion<Assembly> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> machineId;
  final Value<String> groupType;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> imageRef;
  final Value<String?> imageCode;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> pageNo;
  final Value<int?> sortOrder;
  final Value<int> rowid;
  const AssembliesCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.machineId = const Value.absent(),
    this.groupType = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.imageRef = const Value.absent(),
    this.imageCode = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.pageNo = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssembliesCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String machineId,
    required String groupType,
    required String code,
    required String name,
    this.imageRef = const Value.absent(),
    this.imageCode = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.pageNo = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       machineId = Value(machineId),
       groupType = Value(groupType),
       code = Value(code),
       name = Value(name);
  static Insertable<Assembly> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? machineId,
    Expression<String>? groupType,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? imageRef,
    Expression<String>? imageCode,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? pageNo,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (machineId != null) 'machine_id': machineId,
      if (groupType != null) 'group_type': groupType,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (imageRef != null) 'image_ref': imageRef,
      if (imageCode != null) 'image_code': imageCode,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (pageNo != null) 'page_no': pageNo,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssembliesCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? machineId,
    Value<String>? groupType,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? imageRef,
    Value<String?>? imageCode,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? pageNo,
    Value<int?>? sortOrder,
    Value<int>? rowid,
  }) {
    return AssembliesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      groupType: groupType ?? this.groupType,
      code: code ?? this.code,
      name: name ?? this.name,
      imageRef: imageRef ?? this.imageRef,
      imageCode: imageCode ?? this.imageCode,
      width: width ?? this.width,
      height: height ?? this.height,
      pageNo: pageNo ?? this.pageNo,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (machineId.present) {
      map['machine_id'] = Variable<String>(machineId.value);
    }
    if (groupType.present) {
      map['group_type'] = Variable<String>(groupType.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageRef.present) {
      map['image_ref'] = Variable<String>(imageRef.value);
    }
    if (imageCode.present) {
      map['image_code'] = Variable<String>(imageCode.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (pageNo.present) {
      map['page_no'] = Variable<int>(pageNo.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssembliesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('machineId: $machineId, ')
          ..write('groupType: $groupType, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('imageRef: $imageRef, ')
          ..write('imageCode: $imageCode, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('pageNo: $pageNo, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssemblyItemsTable extends AssemblyItems
    with TableInfo<$AssemblyItemsTable, AssemblyItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssemblyItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _assemblyIdMeta = const VerificationMeta(
    'assemblyId',
  );
  @override
  late final GeneratedColumn<String> assemblyId = GeneratedColumn<String>(
    'assembly_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refNoMeta = const VerificationMeta('refNo');
  @override
  late final GeneratedColumn<String> refNo = GeneratedColumn<String>(
    'ref_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basePartIdMeta = const VerificationMeta(
    'basePartId',
  );
  @override
  late final GeneratedColumn<String> basePartId = GeneratedColumn<String>(
    'base_part_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    assemblyId,
    refNo,
    basePartId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assembly_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssemblyItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assembly_id')) {
      context.handle(
        _assemblyIdMeta,
        assemblyId.isAcceptableOrUnknown(data['assembly_id']!, _assemblyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assemblyIdMeta);
    }
    if (data.containsKey('ref_no')) {
      context.handle(
        _refNoMeta,
        refNo.isAcceptableOrUnknown(data['ref_no']!, _refNoMeta),
      );
    } else if (isInserting) {
      context.missing(_refNoMeta);
    }
    if (data.containsKey('base_part_id')) {
      context.handle(
        _basePartIdMeta,
        basePartId.isAcceptableOrUnknown(
          data['base_part_id']!,
          _basePartIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssemblyItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssemblyItem(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assemblyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assembly_id'],
      )!,
      refNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_no'],
      )!,
      basePartId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_part_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $AssemblyItemsTable createAlias(String alias) {
    return $AssemblyItemsTable(attachedDatabase, alias);
  }
}

class AssemblyItem extends DataClass implements Insertable<AssemblyItem> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String assemblyId;
  final String refNo;
  final String? basePartId;
  final String? note;
  const AssemblyItem({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.assemblyId,
    required this.refNo,
    this.basePartId,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['assembly_id'] = Variable<String>(assemblyId);
    map['ref_no'] = Variable<String>(refNo);
    if (!nullToAbsent || basePartId != null) {
      map['base_part_id'] = Variable<String>(basePartId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  AssemblyItemsCompanion toCompanion(bool nullToAbsent) {
    return AssemblyItemsCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      assemblyId: Value(assemblyId),
      refNo: Value(refNo),
      basePartId: basePartId == null && nullToAbsent
          ? const Value.absent()
          : Value(basePartId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory AssemblyItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssemblyItem(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      assemblyId: serializer.fromJson<String>(json['assemblyId']),
      refNo: serializer.fromJson<String>(json['refNo']),
      basePartId: serializer.fromJson<String?>(json['basePartId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'assemblyId': serializer.toJson<String>(assemblyId),
      'refNo': serializer.toJson<String>(refNo),
      'basePartId': serializer.toJson<String?>(basePartId),
      'note': serializer.toJson<String?>(note),
    };
  }

  AssemblyItem copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? assemblyId,
    String? refNo,
    Value<String?> basePartId = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => AssemblyItem(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    assemblyId: assemblyId ?? this.assemblyId,
    refNo: refNo ?? this.refNo,
    basePartId: basePartId.present ? basePartId.value : this.basePartId,
    note: note.present ? note.value : this.note,
  );
  AssemblyItem copyWithCompanion(AssemblyItemsCompanion data) {
    return AssemblyItem(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      assemblyId: data.assemblyId.present
          ? data.assemblyId.value
          : this.assemblyId,
      refNo: data.refNo.present ? data.refNo.value : this.refNo,
      basePartId: data.basePartId.present
          ? data.basePartId.value
          : this.basePartId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssemblyItem(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('assemblyId: $assemblyId, ')
          ..write('refNo: $refNo, ')
          ..write('basePartId: $basePartId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    deletedAt,
    id,
    assemblyId,
    refNo,
    basePartId,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssemblyItem &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.assemblyId == this.assemblyId &&
          other.refNo == this.refNo &&
          other.basePartId == this.basePartId &&
          other.note == this.note);
}

class AssemblyItemsCompanion extends UpdateCompanion<AssemblyItem> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> assemblyId;
  final Value<String> refNo;
  final Value<String?> basePartId;
  final Value<String?> note;
  final Value<int> rowid;
  const AssemblyItemsCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.assemblyId = const Value.absent(),
    this.refNo = const Value.absent(),
    this.basePartId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssemblyItemsCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String assemblyId,
    required String refNo,
    this.basePartId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       assemblyId = Value(assemblyId),
       refNo = Value(refNo);
  static Insertable<AssemblyItem> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? assemblyId,
    Expression<String>? refNo,
    Expression<String>? basePartId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (assemblyId != null) 'assembly_id': assemblyId,
      if (refNo != null) 'ref_no': refNo,
      if (basePartId != null) 'base_part_id': basePartId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssemblyItemsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? assemblyId,
    Value<String>? refNo,
    Value<String?>? basePartId,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return AssemblyItemsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      assemblyId: assemblyId ?? this.assemblyId,
      refNo: refNo ?? this.refNo,
      basePartId: basePartId ?? this.basePartId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assemblyId.present) {
      map['assembly_id'] = Variable<String>(assemblyId.value);
    }
    if (refNo.present) {
      map['ref_no'] = Variable<String>(refNo.value);
    }
    if (basePartId.present) {
      map['base_part_id'] = Variable<String>(basePartId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssemblyItemsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('assemblyId: $assemblyId, ')
          ..write('refNo: $refNo, ')
          ..write('basePartId: $basePartId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemResolutionsTable extends ItemResolutions
    with TableInfo<$ItemResolutionsTable, ItemResolution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemResolutionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _assemblyItemIdMeta = const VerificationMeta(
    'assemblyItemId',
  );
  @override
  late final GeneratedColumn<String> assemblyItemId = GeneratedColumn<String>(
    'assembly_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partNumberIdMeta = const VerificationMeta(
    'partNumberId',
  );
  @override
  late final GeneratedColumn<String> partNumberId = GeneratedColumn<String>(
    'part_number_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _variantIdMeta = const VerificationMeta(
    'variantId',
  );
  @override
  late final GeneratedColumn<String> variantId = GeneratedColumn<String>(
    'variant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialFromMeta = const VerificationMeta(
    'serialFrom',
  );
  @override
  late final GeneratedColumn<String> serialFrom = GeneratedColumn<String>(
    'serial_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialToMeta = const VerificationMeta(
    'serialTo',
  );
  @override
  late final GeneratedColumn<String> serialTo = GeneratedColumn<String>(
    'serial_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    assemblyItemId,
    partNumberId,
    qty,
    variantId,
    serialFrom,
    serialTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_resolutions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemResolution> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assembly_item_id')) {
      context.handle(
        _assemblyItemIdMeta,
        assemblyItemId.isAcceptableOrUnknown(
          data['assembly_item_id']!,
          _assemblyItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assemblyItemIdMeta);
    }
    if (data.containsKey('part_number_id')) {
      context.handle(
        _partNumberIdMeta,
        partNumberId.isAcceptableOrUnknown(
          data['part_number_id']!,
          _partNumberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partNumberIdMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    }
    if (data.containsKey('variant_id')) {
      context.handle(
        _variantIdMeta,
        variantId.isAcceptableOrUnknown(data['variant_id']!, _variantIdMeta),
      );
    }
    if (data.containsKey('serial_from')) {
      context.handle(
        _serialFromMeta,
        serialFrom.isAcceptableOrUnknown(data['serial_from']!, _serialFromMeta),
      );
    }
    if (data.containsKey('serial_to')) {
      context.handle(
        _serialToMeta,
        serialTo.isAcceptableOrUnknown(data['serial_to']!, _serialToMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemResolution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemResolution(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assemblyItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assembly_item_id'],
      )!,
      partNumberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_number_id'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      variantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant_id'],
      ),
      serialFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_from'],
      ),
      serialTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial_to'],
      ),
    );
  }

  @override
  $ItemResolutionsTable createAlias(String alias) {
    return $ItemResolutionsTable(attachedDatabase, alias);
  }
}

class ItemResolution extends DataClass implements Insertable<ItemResolution> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String assemblyItemId;
  final String partNumberId;
  final int qty;
  final String? variantId;
  final String? serialFrom;
  final String? serialTo;
  const ItemResolution({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.assemblyItemId,
    required this.partNumberId,
    required this.qty,
    this.variantId,
    this.serialFrom,
    this.serialTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['assembly_item_id'] = Variable<String>(assemblyItemId);
    map['part_number_id'] = Variable<String>(partNumberId);
    map['qty'] = Variable<int>(qty);
    if (!nullToAbsent || variantId != null) {
      map['variant_id'] = Variable<String>(variantId);
    }
    if (!nullToAbsent || serialFrom != null) {
      map['serial_from'] = Variable<String>(serialFrom);
    }
    if (!nullToAbsent || serialTo != null) {
      map['serial_to'] = Variable<String>(serialTo);
    }
    return map;
  }

  ItemResolutionsCompanion toCompanion(bool nullToAbsent) {
    return ItemResolutionsCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      assemblyItemId: Value(assemblyItemId),
      partNumberId: Value(partNumberId),
      qty: Value(qty),
      variantId: variantId == null && nullToAbsent
          ? const Value.absent()
          : Value(variantId),
      serialFrom: serialFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(serialFrom),
      serialTo: serialTo == null && nullToAbsent
          ? const Value.absent()
          : Value(serialTo),
    );
  }

  factory ItemResolution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemResolution(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      assemblyItemId: serializer.fromJson<String>(json['assemblyItemId']),
      partNumberId: serializer.fromJson<String>(json['partNumberId']),
      qty: serializer.fromJson<int>(json['qty']),
      variantId: serializer.fromJson<String?>(json['variantId']),
      serialFrom: serializer.fromJson<String?>(json['serialFrom']),
      serialTo: serializer.fromJson<String?>(json['serialTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'assemblyItemId': serializer.toJson<String>(assemblyItemId),
      'partNumberId': serializer.toJson<String>(partNumberId),
      'qty': serializer.toJson<int>(qty),
      'variantId': serializer.toJson<String?>(variantId),
      'serialFrom': serializer.toJson<String?>(serialFrom),
      'serialTo': serializer.toJson<String?>(serialTo),
    };
  }

  ItemResolution copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? assemblyItemId,
    String? partNumberId,
    int? qty,
    Value<String?> variantId = const Value.absent(),
    Value<String?> serialFrom = const Value.absent(),
    Value<String?> serialTo = const Value.absent(),
  }) => ItemResolution(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    assemblyItemId: assemblyItemId ?? this.assemblyItemId,
    partNumberId: partNumberId ?? this.partNumberId,
    qty: qty ?? this.qty,
    variantId: variantId.present ? variantId.value : this.variantId,
    serialFrom: serialFrom.present ? serialFrom.value : this.serialFrom,
    serialTo: serialTo.present ? serialTo.value : this.serialTo,
  );
  ItemResolution copyWithCompanion(ItemResolutionsCompanion data) {
    return ItemResolution(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      assemblyItemId: data.assemblyItemId.present
          ? data.assemblyItemId.value
          : this.assemblyItemId,
      partNumberId: data.partNumberId.present
          ? data.partNumberId.value
          : this.partNumberId,
      qty: data.qty.present ? data.qty.value : this.qty,
      variantId: data.variantId.present ? data.variantId.value : this.variantId,
      serialFrom: data.serialFrom.present
          ? data.serialFrom.value
          : this.serialFrom,
      serialTo: data.serialTo.present ? data.serialTo.value : this.serialTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemResolution(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('assemblyItemId: $assemblyItemId, ')
          ..write('partNumberId: $partNumberId, ')
          ..write('qty: $qty, ')
          ..write('variantId: $variantId, ')
          ..write('serialFrom: $serialFrom, ')
          ..write('serialTo: $serialTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    deletedAt,
    id,
    assemblyItemId,
    partNumberId,
    qty,
    variantId,
    serialFrom,
    serialTo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemResolution &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.assemblyItemId == this.assemblyItemId &&
          other.partNumberId == this.partNumberId &&
          other.qty == this.qty &&
          other.variantId == this.variantId &&
          other.serialFrom == this.serialFrom &&
          other.serialTo == this.serialTo);
}

class ItemResolutionsCompanion extends UpdateCompanion<ItemResolution> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> assemblyItemId;
  final Value<String> partNumberId;
  final Value<int> qty;
  final Value<String?> variantId;
  final Value<String?> serialFrom;
  final Value<String?> serialTo;
  final Value<int> rowid;
  const ItemResolutionsCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.assemblyItemId = const Value.absent(),
    this.partNumberId = const Value.absent(),
    this.qty = const Value.absent(),
    this.variantId = const Value.absent(),
    this.serialFrom = const Value.absent(),
    this.serialTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemResolutionsCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String assemblyItemId,
    required String partNumberId,
    this.qty = const Value.absent(),
    this.variantId = const Value.absent(),
    this.serialFrom = const Value.absent(),
    this.serialTo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       assemblyItemId = Value(assemblyItemId),
       partNumberId = Value(partNumberId);
  static Insertable<ItemResolution> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? assemblyItemId,
    Expression<String>? partNumberId,
    Expression<int>? qty,
    Expression<String>? variantId,
    Expression<String>? serialFrom,
    Expression<String>? serialTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (assemblyItemId != null) 'assembly_item_id': assemblyItemId,
      if (partNumberId != null) 'part_number_id': partNumberId,
      if (qty != null) 'qty': qty,
      if (variantId != null) 'variant_id': variantId,
      if (serialFrom != null) 'serial_from': serialFrom,
      if (serialTo != null) 'serial_to': serialTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemResolutionsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? assemblyItemId,
    Value<String>? partNumberId,
    Value<int>? qty,
    Value<String?>? variantId,
    Value<String?>? serialFrom,
    Value<String?>? serialTo,
    Value<int>? rowid,
  }) {
    return ItemResolutionsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      assemblyItemId: assemblyItemId ?? this.assemblyItemId,
      partNumberId: partNumberId ?? this.partNumberId,
      qty: qty ?? this.qty,
      variantId: variantId ?? this.variantId,
      serialFrom: serialFrom ?? this.serialFrom,
      serialTo: serialTo ?? this.serialTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assemblyItemId.present) {
      map['assembly_item_id'] = Variable<String>(assemblyItemId.value);
    }
    if (partNumberId.present) {
      map['part_number_id'] = Variable<String>(partNumberId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (variantId.present) {
      map['variant_id'] = Variable<String>(variantId.value);
    }
    if (serialFrom.present) {
      map['serial_from'] = Variable<String>(serialFrom.value);
    }
    if (serialTo.present) {
      map['serial_to'] = Variable<String>(serialTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemResolutionsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('assemblyItemId: $assemblyItemId, ')
          ..write('partNumberId: $partNumberId, ')
          ..write('qty: $qty, ')
          ..write('variantId: $variantId, ')
          ..write('serialFrom: $serialFrom, ')
          ..write('serialTo: $serialTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DotsTable extends Dots with TableInfo<$DotsTable, Dot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DotsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _assemblyItemIdMeta = const VerificationMeta(
    'assemblyItemId',
  );
  @override
  late final GeneratedColumn<String> assemblyItemId = GeneratedColumn<String>(
    'assembly_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    assemblyItemId,
    x,
    y,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dots';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assembly_item_id')) {
      context.handle(
        _assemblyItemIdMeta,
        assemblyItemId.isAcceptableOrUnknown(
          data['assembly_item_id']!,
          _assemblyItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assemblyItemIdMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dot(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assemblyItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assembly_item_id'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
    );
  }

  @override
  $DotsTable createAlias(String alias) {
    return $DotsTable(attachedDatabase, alias);
  }
}

class Dot extends DataClass implements Insertable<Dot> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String assemblyItemId;
  final double x;
  final double y;
  const Dot({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.assemblyItemId,
    required this.x,
    required this.y,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['assembly_item_id'] = Variable<String>(assemblyItemId);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    return map;
  }

  DotsCompanion toCompanion(bool nullToAbsent) {
    return DotsCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      assemblyItemId: Value(assemblyItemId),
      x: Value(x),
      y: Value(y),
    );
  }

  factory Dot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dot(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      assemblyItemId: serializer.fromJson<String>(json['assemblyItemId']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'assemblyItemId': serializer.toJson<String>(assemblyItemId),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
    };
  }

  Dot copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? assemblyItemId,
    double? x,
    double? y,
  }) => Dot(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    assemblyItemId: assemblyItemId ?? this.assemblyItemId,
    x: x ?? this.x,
    y: y ?? this.y,
  );
  Dot copyWithCompanion(DotsCompanion data) {
    return Dot(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      assemblyItemId: data.assemblyItemId.present
          ? data.assemblyItemId.value
          : this.assemblyItemId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dot(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('assemblyItemId: $assemblyItemId, ')
          ..write('x: $x, ')
          ..write('y: $y')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(updatedAt, deletedAt, id, assemblyItemId, x, y);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dot &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.assemblyItemId == this.assemblyItemId &&
          other.x == this.x &&
          other.y == this.y);
}

class DotsCompanion extends UpdateCompanion<Dot> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> assemblyItemId;
  final Value<double> x;
  final Value<double> y;
  final Value<int> rowid;
  const DotsCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.assemblyItemId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DotsCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String assemblyItemId,
    required double x,
    required double y,
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       assemblyItemId = Value(assemblyItemId),
       x = Value(x),
       y = Value(y);
  static Insertable<Dot> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? assemblyItemId,
    Expression<double>? x,
    Expression<double>? y,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (assemblyItemId != null) 'assembly_item_id': assemblyItemId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DotsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? assemblyItemId,
    Value<double>? x,
    Value<double>? y,
    Value<int>? rowid,
  }) {
    return DotsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      assemblyItemId: assemblyItemId ?? this.assemblyItemId,
      x: x ?? this.x,
      y: y ?? this.y,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assemblyItemId.present) {
      map['assembly_item_id'] = Variable<String>(assemblyItemId.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DotsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('assemblyItemId: $assemblyItemId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssemblyLinksTable extends AssemblyLinks
    with TableInfo<$AssemblyLinksTable, AssemblyLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssemblyLinksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _fromAssemblyIdMeta = const VerificationMeta(
    'fromAssemblyId',
  );
  @override
  late final GeneratedColumn<String> fromAssemblyId = GeneratedColumn<String>(
    'from_assembly_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toCodeMeta = const VerificationMeta('toCode');
  @override
  late final GeneratedColumn<String> toCode = GeneratedColumn<String>(
    'to_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toAssemblyIdMeta = const VerificationMeta(
    'toAssemblyId',
  );
  @override
  late final GeneratedColumn<String> toAssemblyId = GeneratedColumn<String>(
    'to_assembly_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    fromAssemblyId,
    toCode,
    toAssemblyId,
    x,
    y,
    label,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assembly_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssemblyLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_assembly_id')) {
      context.handle(
        _fromAssemblyIdMeta,
        fromAssemblyId.isAcceptableOrUnknown(
          data['from_assembly_id']!,
          _fromAssemblyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromAssemblyIdMeta);
    }
    if (data.containsKey('to_code')) {
      context.handle(
        _toCodeMeta,
        toCode.isAcceptableOrUnknown(data['to_code']!, _toCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_toCodeMeta);
    }
    if (data.containsKey('to_assembly_id')) {
      context.handle(
        _toAssemblyIdMeta,
        toAssemblyId.isAcceptableOrUnknown(
          data['to_assembly_id']!,
          _toAssemblyIdMeta,
        ),
      );
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssemblyLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssemblyLink(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromAssemblyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_assembly_id'],
      )!,
      toCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_code'],
      )!,
      toAssemblyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_assembly_id'],
      ),
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      ),
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
    );
  }

  @override
  $AssemblyLinksTable createAlias(String alias) {
    return $AssemblyLinksTable(attachedDatabase, alias);
  }
}

class AssemblyLink extends DataClass implements Insertable<AssemblyLink> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String fromAssemblyId;
  final String toCode;
  final String? toAssemblyId;
  final double? x;
  final double? y;
  final String? label;
  const AssemblyLink({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.fromAssemblyId,
    required this.toCode,
    this.toAssemblyId,
    this.x,
    this.y,
    this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['from_assembly_id'] = Variable<String>(fromAssemblyId);
    map['to_code'] = Variable<String>(toCode);
    if (!nullToAbsent || toAssemblyId != null) {
      map['to_assembly_id'] = Variable<String>(toAssemblyId);
    }
    if (!nullToAbsent || x != null) {
      map['x'] = Variable<double>(x);
    }
    if (!nullToAbsent || y != null) {
      map['y'] = Variable<double>(y);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  AssemblyLinksCompanion toCompanion(bool nullToAbsent) {
    return AssemblyLinksCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      fromAssemblyId: Value(fromAssemblyId),
      toCode: Value(toCode),
      toAssemblyId: toAssemblyId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAssemblyId),
      x: x == null && nullToAbsent ? const Value.absent() : Value(x),
      y: y == null && nullToAbsent ? const Value.absent() : Value(y),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
    );
  }

  factory AssemblyLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssemblyLink(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      fromAssemblyId: serializer.fromJson<String>(json['fromAssemblyId']),
      toCode: serializer.fromJson<String>(json['toCode']),
      toAssemblyId: serializer.fromJson<String?>(json['toAssemblyId']),
      x: serializer.fromJson<double?>(json['x']),
      y: serializer.fromJson<double?>(json['y']),
      label: serializer.fromJson<String?>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'fromAssemblyId': serializer.toJson<String>(fromAssemblyId),
      'toCode': serializer.toJson<String>(toCode),
      'toAssemblyId': serializer.toJson<String?>(toAssemblyId),
      'x': serializer.toJson<double?>(x),
      'y': serializer.toJson<double?>(y),
      'label': serializer.toJson<String?>(label),
    };
  }

  AssemblyLink copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? fromAssemblyId,
    String? toCode,
    Value<String?> toAssemblyId = const Value.absent(),
    Value<double?> x = const Value.absent(),
    Value<double?> y = const Value.absent(),
    Value<String?> label = const Value.absent(),
  }) => AssemblyLink(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    fromAssemblyId: fromAssemblyId ?? this.fromAssemblyId,
    toCode: toCode ?? this.toCode,
    toAssemblyId: toAssemblyId.present ? toAssemblyId.value : this.toAssemblyId,
    x: x.present ? x.value : this.x,
    y: y.present ? y.value : this.y,
    label: label.present ? label.value : this.label,
  );
  AssemblyLink copyWithCompanion(AssemblyLinksCompanion data) {
    return AssemblyLink(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      fromAssemblyId: data.fromAssemblyId.present
          ? data.fromAssemblyId.value
          : this.fromAssemblyId,
      toCode: data.toCode.present ? data.toCode.value : this.toCode,
      toAssemblyId: data.toAssemblyId.present
          ? data.toAssemblyId.value
          : this.toAssemblyId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssemblyLink(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('fromAssemblyId: $fromAssemblyId, ')
          ..write('toCode: $toCode, ')
          ..write('toAssemblyId: $toAssemblyId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    deletedAt,
    id,
    fromAssemblyId,
    toCode,
    toAssemblyId,
    x,
    y,
    label,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssemblyLink &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.fromAssemblyId == this.fromAssemblyId &&
          other.toCode == this.toCode &&
          other.toAssemblyId == this.toAssemblyId &&
          other.x == this.x &&
          other.y == this.y &&
          other.label == this.label);
}

class AssemblyLinksCompanion extends UpdateCompanion<AssemblyLink> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> fromAssemblyId;
  final Value<String> toCode;
  final Value<String?> toAssemblyId;
  final Value<double?> x;
  final Value<double?> y;
  final Value<String?> label;
  final Value<int> rowid;
  const AssemblyLinksCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.fromAssemblyId = const Value.absent(),
    this.toCode = const Value.absent(),
    this.toAssemblyId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssemblyLinksCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String fromAssemblyId,
    required String toCode,
    this.toAssemblyId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       fromAssemblyId = Value(fromAssemblyId),
       toCode = Value(toCode);
  static Insertable<AssemblyLink> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? fromAssemblyId,
    Expression<String>? toCode,
    Expression<String>? toAssemblyId,
    Expression<double>? x,
    Expression<double>? y,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (fromAssemblyId != null) 'from_assembly_id': fromAssemblyId,
      if (toCode != null) 'to_code': toCode,
      if (toAssemblyId != null) 'to_assembly_id': toAssemblyId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssemblyLinksCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? fromAssemblyId,
    Value<String>? toCode,
    Value<String?>? toAssemblyId,
    Value<double?>? x,
    Value<double?>? y,
    Value<String?>? label,
    Value<int>? rowid,
  }) {
    return AssemblyLinksCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      fromAssemblyId: fromAssemblyId ?? this.fromAssemblyId,
      toCode: toCode ?? this.toCode,
      toAssemblyId: toAssemblyId ?? this.toAssemblyId,
      x: x ?? this.x,
      y: y ?? this.y,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromAssemblyId.present) {
      map['from_assembly_id'] = Variable<String>(fromAssemblyId.value);
    }
    if (toCode.present) {
      map['to_code'] = Variable<String>(toCode.value);
    }
    if (toAssemblyId.present) {
      map['to_assembly_id'] = Variable<String>(toAssemblyId.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssemblyLinksCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('fromAssemblyId: $fromAssemblyId, ')
          ..write('toCode: $toCode, ')
          ..write('toAssemblyId: $toAssemblyId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartsTable extends Parts with TableInfo<$PartsTable, Part> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _nameRawMeta = const VerificationMeta(
    'nameRaw',
  );
  @override
  late final GeneratedColumn<String> nameRaw = GeneratedColumn<String>(
    'name_raw',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameNormalizedMeta = const VerificationMeta(
    'nameNormalized',
  );
  @override
  late final GeneratedColumn<String> nameNormalized = GeneratedColumn<String>(
    'name_normalized',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specsMeta = const VerificationMeta('specs');
  @override
  late final GeneratedColumn<String> specs = GeneratedColumn<String>(
    'specs',
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
  static const VerificationMeta _isCurrentReplacementMeta =
      const VerificationMeta('isCurrentReplacement');
  @override
  late final GeneratedColumn<bool> isCurrentReplacement = GeneratedColumn<bool>(
    'is_current_replacement',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current_replacement" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    nameRaw,
    nameNormalized,
    category,
    specs,
    notes,
    isCurrentReplacement,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Part> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_raw')) {
      context.handle(
        _nameRawMeta,
        nameRaw.isAcceptableOrUnknown(data['name_raw']!, _nameRawMeta),
      );
    } else if (isInserting) {
      context.missing(_nameRawMeta);
    }
    if (data.containsKey('name_normalized')) {
      context.handle(
        _nameNormalizedMeta,
        nameNormalized.isAcceptableOrUnknown(
          data['name_normalized']!,
          _nameNormalizedMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('specs')) {
      context.handle(
        _specsMeta,
        specs.isAcceptableOrUnknown(data['specs']!, _specsMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_current_replacement')) {
      context.handle(
        _isCurrentReplacementMeta,
        isCurrentReplacement.isAcceptableOrUnknown(
          data['is_current_replacement']!,
          _isCurrentReplacementMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Part map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Part(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_raw'],
      )!,
      nameNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_normalized'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      specs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specs'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isCurrentReplacement: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current_replacement'],
      )!,
    );
  }

  @override
  $PartsTable createAlias(String alias) {
    return $PartsTable(attachedDatabase, alias);
  }
}

class Part extends DataClass implements Insertable<Part> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String nameRaw;
  final String? nameNormalized;
  final String? category;
  final String? specs;
  final String? notes;
  final bool isCurrentReplacement;
  const Part({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.nameRaw,
    this.nameNormalized,
    this.category,
    this.specs,
    this.notes,
    required this.isCurrentReplacement,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['name_raw'] = Variable<String>(nameRaw);
    if (!nullToAbsent || nameNormalized != null) {
      map['name_normalized'] = Variable<String>(nameNormalized);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || specs != null) {
      map['specs'] = Variable<String>(specs);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_current_replacement'] = Variable<bool>(isCurrentReplacement);
    return map;
  }

  PartsCompanion toCompanion(bool nullToAbsent) {
    return PartsCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      nameRaw: Value(nameRaw),
      nameNormalized: nameNormalized == null && nullToAbsent
          ? const Value.absent()
          : Value(nameNormalized),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      specs: specs == null && nullToAbsent
          ? const Value.absent()
          : Value(specs),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isCurrentReplacement: Value(isCurrentReplacement),
    );
  }

  factory Part.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Part(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      nameRaw: serializer.fromJson<String>(json['nameRaw']),
      nameNormalized: serializer.fromJson<String?>(json['nameNormalized']),
      category: serializer.fromJson<String?>(json['category']),
      specs: serializer.fromJson<String?>(json['specs']),
      notes: serializer.fromJson<String?>(json['notes']),
      isCurrentReplacement: serializer.fromJson<bool>(
        json['isCurrentReplacement'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'nameRaw': serializer.toJson<String>(nameRaw),
      'nameNormalized': serializer.toJson<String?>(nameNormalized),
      'category': serializer.toJson<String?>(category),
      'specs': serializer.toJson<String?>(specs),
      'notes': serializer.toJson<String?>(notes),
      'isCurrentReplacement': serializer.toJson<bool>(isCurrentReplacement),
    };
  }

  Part copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? nameRaw,
    Value<String?> nameNormalized = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> specs = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isCurrentReplacement,
  }) => Part(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    nameRaw: nameRaw ?? this.nameRaw,
    nameNormalized: nameNormalized.present
        ? nameNormalized.value
        : this.nameNormalized,
    category: category.present ? category.value : this.category,
    specs: specs.present ? specs.value : this.specs,
    notes: notes.present ? notes.value : this.notes,
    isCurrentReplacement: isCurrentReplacement ?? this.isCurrentReplacement,
  );
  Part copyWithCompanion(PartsCompanion data) {
    return Part(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      nameRaw: data.nameRaw.present ? data.nameRaw.value : this.nameRaw,
      nameNormalized: data.nameNormalized.present
          ? data.nameNormalized.value
          : this.nameNormalized,
      category: data.category.present ? data.category.value : this.category,
      specs: data.specs.present ? data.specs.value : this.specs,
      notes: data.notes.present ? data.notes.value : this.notes,
      isCurrentReplacement: data.isCurrentReplacement.present
          ? data.isCurrentReplacement.value
          : this.isCurrentReplacement,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Part(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nameRaw: $nameRaw, ')
          ..write('nameNormalized: $nameNormalized, ')
          ..write('category: $category, ')
          ..write('specs: $specs, ')
          ..write('notes: $notes, ')
          ..write('isCurrentReplacement: $isCurrentReplacement')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    deletedAt,
    id,
    nameRaw,
    nameNormalized,
    category,
    specs,
    notes,
    isCurrentReplacement,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Part &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.nameRaw == this.nameRaw &&
          other.nameNormalized == this.nameNormalized &&
          other.category == this.category &&
          other.specs == this.specs &&
          other.notes == this.notes &&
          other.isCurrentReplacement == this.isCurrentReplacement);
}

class PartsCompanion extends UpdateCompanion<Part> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> nameRaw;
  final Value<String?> nameNormalized;
  final Value<String?> category;
  final Value<String?> specs;
  final Value<String?> notes;
  final Value<bool> isCurrentReplacement;
  final Value<int> rowid;
  const PartsCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.nameRaw = const Value.absent(),
    this.nameNormalized = const Value.absent(),
    this.category = const Value.absent(),
    this.specs = const Value.absent(),
    this.notes = const Value.absent(),
    this.isCurrentReplacement = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartsCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String nameRaw,
    this.nameNormalized = const Value.absent(),
    this.category = const Value.absent(),
    this.specs = const Value.absent(),
    this.notes = const Value.absent(),
    this.isCurrentReplacement = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       nameRaw = Value(nameRaw);
  static Insertable<Part> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? nameRaw,
    Expression<String>? nameNormalized,
    Expression<String>? category,
    Expression<String>? specs,
    Expression<String>? notes,
    Expression<bool>? isCurrentReplacement,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (nameRaw != null) 'name_raw': nameRaw,
      if (nameNormalized != null) 'name_normalized': nameNormalized,
      if (category != null) 'category': category,
      if (specs != null) 'specs': specs,
      if (notes != null) 'notes': notes,
      if (isCurrentReplacement != null)
        'is_current_replacement': isCurrentReplacement,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? nameRaw,
    Value<String?>? nameNormalized,
    Value<String?>? category,
    Value<String?>? specs,
    Value<String?>? notes,
    Value<bool>? isCurrentReplacement,
    Value<int>? rowid,
  }) {
    return PartsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      nameRaw: nameRaw ?? this.nameRaw,
      nameNormalized: nameNormalized ?? this.nameNormalized,
      category: category ?? this.category,
      specs: specs ?? this.specs,
      notes: notes ?? this.notes,
      isCurrentReplacement: isCurrentReplacement ?? this.isCurrentReplacement,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameRaw.present) {
      map['name_raw'] = Variable<String>(nameRaw.value);
    }
    if (nameNormalized.present) {
      map['name_normalized'] = Variable<String>(nameNormalized.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (specs.present) {
      map['specs'] = Variable<String>(specs.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isCurrentReplacement.present) {
      map['is_current_replacement'] = Variable<bool>(
        isCurrentReplacement.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('nameRaw: $nameRaw, ')
          ..write('nameNormalized: $nameNormalized, ')
          ..write('category: $category, ')
          ..write('specs: $specs, ')
          ..write('notes: $notes, ')
          ..write('isCurrentReplacement: $isCurrentReplacement, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartNumbersTable extends PartNumbers
    with TableInfo<$PartNumbersTable, PartNumber> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartNumbersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<String> partId = GeneratedColumn<String>(
    'part_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('oem'),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    partId,
    value,
    kind,
    brand,
    note,
    isPrimary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'part_numbers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartNumber> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('part_id')) {
      context.handle(
        _partIdMeta,
        partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartNumber map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartNumber(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      partId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $PartNumbersTable createAlias(String alias) {
    return $PartNumbersTable(attachedDatabase, alias);
  }
}

class PartNumber extends DataClass implements Insertable<PartNumber> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String partId;
  final String value;
  final String kind;
  final String? brand;
  final String? note;
  final bool isPrimary;
  const PartNumber({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.partId,
    required this.value,
    required this.kind,
    this.brand,
    this.note,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['part_id'] = Variable<String>(partId);
    map['value'] = Variable<String>(value);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  PartNumbersCompanion toCompanion(bool nullToAbsent) {
    return PartNumbersCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      partId: Value(partId),
      value: Value(value),
      kind: Value(kind),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isPrimary: Value(isPrimary),
    );
  }

  factory PartNumber.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartNumber(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      partId: serializer.fromJson<String>(json['partId']),
      value: serializer.fromJson<String>(json['value']),
      kind: serializer.fromJson<String>(json['kind']),
      brand: serializer.fromJson<String?>(json['brand']),
      note: serializer.fromJson<String?>(json['note']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'partId': serializer.toJson<String>(partId),
      'value': serializer.toJson<String>(value),
      'kind': serializer.toJson<String>(kind),
      'brand': serializer.toJson<String?>(brand),
      'note': serializer.toJson<String?>(note),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  PartNumber copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? partId,
    String? value,
    String? kind,
    Value<String?> brand = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? isPrimary,
  }) => PartNumber(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    partId: partId ?? this.partId,
    value: value ?? this.value,
    kind: kind ?? this.kind,
    brand: brand.present ? brand.value : this.brand,
    note: note.present ? note.value : this.note,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  PartNumber copyWithCompanion(PartNumbersCompanion data) {
    return PartNumber(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      partId: data.partId.present ? data.partId.value : this.partId,
      value: data.value.present ? data.value.value : this.value,
      kind: data.kind.present ? data.kind.value : this.kind,
      brand: data.brand.present ? data.brand.value : this.brand,
      note: data.note.present ? data.note.value : this.note,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartNumber(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('value: $value, ')
          ..write('kind: $kind, ')
          ..write('brand: $brand, ')
          ..write('note: $note, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    deletedAt,
    id,
    partId,
    value,
    kind,
    brand,
    note,
    isPrimary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartNumber &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.partId == this.partId &&
          other.value == this.value &&
          other.kind == this.kind &&
          other.brand == this.brand &&
          other.note == this.note &&
          other.isPrimary == this.isPrimary);
}

class PartNumbersCompanion extends UpdateCompanion<PartNumber> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> partId;
  final Value<String> value;
  final Value<String> kind;
  final Value<String?> brand;
  final Value<String?> note;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const PartNumbersCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.partId = const Value.absent(),
    this.value = const Value.absent(),
    this.kind = const Value.absent(),
    this.brand = const Value.absent(),
    this.note = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartNumbersCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String partId,
    required String value,
    this.kind = const Value.absent(),
    this.brand = const Value.absent(),
    this.note = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       partId = Value(partId),
       value = Value(value);
  static Insertable<PartNumber> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? partId,
    Expression<String>? value,
    Expression<String>? kind,
    Expression<String>? brand,
    Expression<String>? note,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (partId != null) 'part_id': partId,
      if (value != null) 'value': value,
      if (kind != null) 'kind': kind,
      if (brand != null) 'brand': brand,
      if (note != null) 'note': note,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartNumbersCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? partId,
    Value<String>? value,
    Value<String>? kind,
    Value<String?>? brand,
    Value<String?>? note,
    Value<bool>? isPrimary,
    Value<int>? rowid,
  }) {
    return PartNumbersCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      partId: partId ?? this.partId,
      value: value ?? this.value,
      kind: kind ?? this.kind,
      brand: brand ?? this.brand,
      note: note ?? this.note,
      isPrimary: isPrimary ?? this.isPrimary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<String>(partId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartNumbersCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('value: $value, ')
          ..write('kind: $kind, ')
          ..write('brand: $brand, ')
          ..write('note: $note, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartColorVariantsTable extends PartColorVariants
    with TableInfo<$PartColorVariantsTable, PartColorVariant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartColorVariantsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<String> partId = GeneratedColumn<String>(
    'part_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorIdMeta = const VerificationMeta(
    'colorId',
  );
  @override
  late final GeneratedColumn<String> colorId = GeneratedColumn<String>(
    'color_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suffixCodeMeta = const VerificationMeta(
    'suffixCode',
  );
  @override
  late final GeneratedColumn<String> suffixCode = GeneratedColumn<String>(
    'suffix_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullNumberMeta = const VerificationMeta(
    'fullNumber',
  );
  @override
  late final GeneratedColumn<String> fullNumber = GeneratedColumn<String>(
    'full_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    partId,
    colorId,
    suffixCode,
    fullNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'part_color_variants';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartColorVariant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('part_id')) {
      context.handle(
        _partIdMeta,
        partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('color_id')) {
      context.handle(
        _colorIdMeta,
        colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_colorIdMeta);
    }
    if (data.containsKey('suffix_code')) {
      context.handle(
        _suffixCodeMeta,
        suffixCode.isAcceptableOrUnknown(data['suffix_code']!, _suffixCodeMeta),
      );
    }
    if (data.containsKey('full_number')) {
      context.handle(
        _fullNumberMeta,
        fullNumber.isAcceptableOrUnknown(data['full_number']!, _fullNumberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartColorVariant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartColorVariant(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      partId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_id'],
      )!,
      colorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_id'],
      )!,
      suffixCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suffix_code'],
      ),
      fullNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_number'],
      ),
    );
  }

  @override
  $PartColorVariantsTable createAlias(String alias) {
    return $PartColorVariantsTable(attachedDatabase, alias);
  }
}

class PartColorVariant extends DataClass
    implements Insertable<PartColorVariant> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String partId;
  final String colorId;
  final String? suffixCode;
  final String? fullNumber;
  const PartColorVariant({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.partId,
    required this.colorId,
    this.suffixCode,
    this.fullNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['part_id'] = Variable<String>(partId);
    map['color_id'] = Variable<String>(colorId);
    if (!nullToAbsent || suffixCode != null) {
      map['suffix_code'] = Variable<String>(suffixCode);
    }
    if (!nullToAbsent || fullNumber != null) {
      map['full_number'] = Variable<String>(fullNumber);
    }
    return map;
  }

  PartColorVariantsCompanion toCompanion(bool nullToAbsent) {
    return PartColorVariantsCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      partId: Value(partId),
      colorId: Value(colorId),
      suffixCode: suffixCode == null && nullToAbsent
          ? const Value.absent()
          : Value(suffixCode),
      fullNumber: fullNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(fullNumber),
    );
  }

  factory PartColorVariant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartColorVariant(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      partId: serializer.fromJson<String>(json['partId']),
      colorId: serializer.fromJson<String>(json['colorId']),
      suffixCode: serializer.fromJson<String?>(json['suffixCode']),
      fullNumber: serializer.fromJson<String?>(json['fullNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'partId': serializer.toJson<String>(partId),
      'colorId': serializer.toJson<String>(colorId),
      'suffixCode': serializer.toJson<String?>(suffixCode),
      'fullNumber': serializer.toJson<String?>(fullNumber),
    };
  }

  PartColorVariant copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? partId,
    String? colorId,
    Value<String?> suffixCode = const Value.absent(),
    Value<String?> fullNumber = const Value.absent(),
  }) => PartColorVariant(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    partId: partId ?? this.partId,
    colorId: colorId ?? this.colorId,
    suffixCode: suffixCode.present ? suffixCode.value : this.suffixCode,
    fullNumber: fullNumber.present ? fullNumber.value : this.fullNumber,
  );
  PartColorVariant copyWithCompanion(PartColorVariantsCompanion data) {
    return PartColorVariant(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      partId: data.partId.present ? data.partId.value : this.partId,
      colorId: data.colorId.present ? data.colorId.value : this.colorId,
      suffixCode: data.suffixCode.present
          ? data.suffixCode.value
          : this.suffixCode,
      fullNumber: data.fullNumber.present
          ? data.fullNumber.value
          : this.fullNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartColorVariant(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('colorId: $colorId, ')
          ..write('suffixCode: $suffixCode, ')
          ..write('fullNumber: $fullNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    deletedAt,
    id,
    partId,
    colorId,
    suffixCode,
    fullNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartColorVariant &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.partId == this.partId &&
          other.colorId == this.colorId &&
          other.suffixCode == this.suffixCode &&
          other.fullNumber == this.fullNumber);
}

class PartColorVariantsCompanion extends UpdateCompanion<PartColorVariant> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> partId;
  final Value<String> colorId;
  final Value<String?> suffixCode;
  final Value<String?> fullNumber;
  final Value<int> rowid;
  const PartColorVariantsCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.partId = const Value.absent(),
    this.colorId = const Value.absent(),
    this.suffixCode = const Value.absent(),
    this.fullNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartColorVariantsCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String partId,
    required String colorId,
    this.suffixCode = const Value.absent(),
    this.fullNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       partId = Value(partId),
       colorId = Value(colorId);
  static Insertable<PartColorVariant> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? partId,
    Expression<String>? colorId,
    Expression<String>? suffixCode,
    Expression<String>? fullNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (partId != null) 'part_id': partId,
      if (colorId != null) 'color_id': colorId,
      if (suffixCode != null) 'suffix_code': suffixCode,
      if (fullNumber != null) 'full_number': fullNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartColorVariantsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? partId,
    Value<String>? colorId,
    Value<String?>? suffixCode,
    Value<String?>? fullNumber,
    Value<int>? rowid,
  }) {
    return PartColorVariantsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      partId: partId ?? this.partId,
      colorId: colorId ?? this.colorId,
      suffixCode: suffixCode ?? this.suffixCode,
      fullNumber: fullNumber ?? this.fullNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<String>(partId.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<String>(colorId.value);
    }
    if (suffixCode.present) {
      map['suffix_code'] = Variable<String>(suffixCode.value);
    }
    if (fullNumber.present) {
      map['full_number'] = Variable<String>(fullNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartColorVariantsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('colorId: $colorId, ')
          ..write('suffixCode: $suffixCode, ')
          ..write('fullNumber: $fullNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AliasesTable extends Aliases with TableInfo<$AliasesTable, Aliase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AliasesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<String> partId = GeneratedColumn<String>(
    'part_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    partId,
    term,
    lang,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<Aliase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('part_id')) {
      context.handle(
        _partIdMeta,
        partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('lang')) {
      context.handle(
        _langMeta,
        lang.isAcceptableOrUnknown(data['lang']!, _langMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Aliase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Aliase(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      partId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term'],
      )!,
      lang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lang'],
      ),
    );
  }

  @override
  $AliasesTable createAlias(String alias) {
    return $AliasesTable(attachedDatabase, alias);
  }
}

class Aliase extends DataClass implements Insertable<Aliase> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String partId;
  final String term;
  final String? lang;
  const Aliase({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.partId,
    required this.term,
    this.lang,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['part_id'] = Variable<String>(partId);
    map['term'] = Variable<String>(term);
    if (!nullToAbsent || lang != null) {
      map['lang'] = Variable<String>(lang);
    }
    return map;
  }

  AliasesCompanion toCompanion(bool nullToAbsent) {
    return AliasesCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      partId: Value(partId),
      term: Value(term),
      lang: lang == null && nullToAbsent ? const Value.absent() : Value(lang),
    );
  }

  factory Aliase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Aliase(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      partId: serializer.fromJson<String>(json['partId']),
      term: serializer.fromJson<String>(json['term']),
      lang: serializer.fromJson<String?>(json['lang']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'partId': serializer.toJson<String>(partId),
      'term': serializer.toJson<String>(term),
      'lang': serializer.toJson<String?>(lang),
    };
  }

  Aliase copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? partId,
    String? term,
    Value<String?> lang = const Value.absent(),
  }) => Aliase(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    partId: partId ?? this.partId,
    term: term ?? this.term,
    lang: lang.present ? lang.value : this.lang,
  );
  Aliase copyWithCompanion(AliasesCompanion data) {
    return Aliase(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      partId: data.partId.present ? data.partId.value : this.partId,
      term: data.term.present ? data.term.value : this.term,
      lang: data.lang.present ? data.lang.value : this.lang,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Aliase(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('term: $term, ')
          ..write('lang: $lang')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(updatedAt, deletedAt, id, partId, term, lang);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Aliase &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.partId == this.partId &&
          other.term == this.term &&
          other.lang == this.lang);
}

class AliasesCompanion extends UpdateCompanion<Aliase> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> partId;
  final Value<String> term;
  final Value<String?> lang;
  final Value<int> rowid;
  const AliasesCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.partId = const Value.absent(),
    this.term = const Value.absent(),
    this.lang = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AliasesCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String partId,
    required String term,
    this.lang = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       partId = Value(partId),
       term = Value(term);
  static Insertable<Aliase> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? partId,
    Expression<String>? term,
    Expression<String>? lang,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (partId != null) 'part_id': partId,
      if (term != null) 'term': term,
      if (lang != null) 'lang': lang,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AliasesCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? partId,
    Value<String>? term,
    Value<String?>? lang,
    Value<int>? rowid,
  }) {
    return AliasesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      partId: partId ?? this.partId,
      term: term ?? this.term,
      lang: lang ?? this.lang,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<String>(partId.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AliasesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('term: $term, ')
          ..write('lang: $lang, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceItemsTable extends ServiceItems
    with TableInfo<$ServiceItemsTable, ServiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _assemblyIdMeta = const VerificationMeta(
    'assemblyId',
  );
  @override
  late final GeneratedColumn<String> assemblyId = GeneratedColumn<String>(
    'assembly_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refNoMeta = const VerificationMeta('refNo');
  @override
  late final GeneratedColumn<String> refNo = GeneratedColumn<String>(
    'ref_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _frtHoursMeta = const VerificationMeta(
    'frtHours',
  );
  @override
  late final GeneratedColumn<double> frtHours = GeneratedColumn<double>(
    'frt_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    assemblyId,
    refNo,
    name,
    frtHours,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assembly_id')) {
      context.handle(
        _assemblyIdMeta,
        assemblyId.isAcceptableOrUnknown(data['assembly_id']!, _assemblyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assemblyIdMeta);
    }
    if (data.containsKey('ref_no')) {
      context.handle(
        _refNoMeta,
        refNo.isAcceptableOrUnknown(data['ref_no']!, _refNoMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('frt_hours')) {
      context.handle(
        _frtHoursMeta,
        frtHours.isAcceptableOrUnknown(data['frt_hours']!, _frtHoursMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceItem(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assemblyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assembly_id'],
      )!,
      refNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_no'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      frtHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}frt_hours'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ServiceItemsTable createAlias(String alias) {
    return $ServiceItemsTable(attachedDatabase, alias);
  }
}

class ServiceItem extends DataClass implements Insertable<ServiceItem> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String assemblyId;
  final String? refNo;
  final String name;
  final double? frtHours;
  final String? note;
  const ServiceItem({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.assemblyId,
    this.refNo,
    required this.name,
    this.frtHours,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['assembly_id'] = Variable<String>(assemblyId);
    if (!nullToAbsent || refNo != null) {
      map['ref_no'] = Variable<String>(refNo);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || frtHours != null) {
      map['frt_hours'] = Variable<double>(frtHours);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ServiceItemsCompanion toCompanion(bool nullToAbsent) {
    return ServiceItemsCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      assemblyId: Value(assemblyId),
      refNo: refNo == null && nullToAbsent
          ? const Value.absent()
          : Value(refNo),
      name: Value(name),
      frtHours: frtHours == null && nullToAbsent
          ? const Value.absent()
          : Value(frtHours),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ServiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceItem(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      assemblyId: serializer.fromJson<String>(json['assemblyId']),
      refNo: serializer.fromJson<String?>(json['refNo']),
      name: serializer.fromJson<String>(json['name']),
      frtHours: serializer.fromJson<double?>(json['frtHours']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'assemblyId': serializer.toJson<String>(assemblyId),
      'refNo': serializer.toJson<String?>(refNo),
      'name': serializer.toJson<String>(name),
      'frtHours': serializer.toJson<double?>(frtHours),
      'note': serializer.toJson<String?>(note),
    };
  }

  ServiceItem copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? assemblyId,
    Value<String?> refNo = const Value.absent(),
    String? name,
    Value<double?> frtHours = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => ServiceItem(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    assemblyId: assemblyId ?? this.assemblyId,
    refNo: refNo.present ? refNo.value : this.refNo,
    name: name ?? this.name,
    frtHours: frtHours.present ? frtHours.value : this.frtHours,
    note: note.present ? note.value : this.note,
  );
  ServiceItem copyWithCompanion(ServiceItemsCompanion data) {
    return ServiceItem(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      assemblyId: data.assemblyId.present
          ? data.assemblyId.value
          : this.assemblyId,
      refNo: data.refNo.present ? data.refNo.value : this.refNo,
      name: data.name.present ? data.name.value : this.name,
      frtHours: data.frtHours.present ? data.frtHours.value : this.frtHours,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceItem(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('assemblyId: $assemblyId, ')
          ..write('refNo: $refNo, ')
          ..write('name: $name, ')
          ..write('frtHours: $frtHours, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    deletedAt,
    id,
    assemblyId,
    refNo,
    name,
    frtHours,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceItem &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.assemblyId == this.assemblyId &&
          other.refNo == this.refNo &&
          other.name == this.name &&
          other.frtHours == this.frtHours &&
          other.note == this.note);
}

class ServiceItemsCompanion extends UpdateCompanion<ServiceItem> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> assemblyId;
  final Value<String?> refNo;
  final Value<String> name;
  final Value<double?> frtHours;
  final Value<String?> note;
  final Value<int> rowid;
  const ServiceItemsCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.assemblyId = const Value.absent(),
    this.refNo = const Value.absent(),
    this.name = const Value.absent(),
    this.frtHours = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceItemsCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String assemblyId,
    this.refNo = const Value.absent(),
    required String name,
    this.frtHours = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       assemblyId = Value(assemblyId),
       name = Value(name);
  static Insertable<ServiceItem> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? assemblyId,
    Expression<String>? refNo,
    Expression<String>? name,
    Expression<double>? frtHours,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (assemblyId != null) 'assembly_id': assemblyId,
      if (refNo != null) 'ref_no': refNo,
      if (name != null) 'name': name,
      if (frtHours != null) 'frt_hours': frtHours,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceItemsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? assemblyId,
    Value<String?>? refNo,
    Value<String>? name,
    Value<double?>? frtHours,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return ServiceItemsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      assemblyId: assemblyId ?? this.assemblyId,
      refNo: refNo ?? this.refNo,
      name: name ?? this.name,
      frtHours: frtHours ?? this.frtHours,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (assemblyId.present) {
      map['assembly_id'] = Variable<String>(assemblyId.value);
    }
    if (refNo.present) {
      map['ref_no'] = Variable<String>(refNo.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (frtHours.present) {
      map['frt_hours'] = Variable<double>(frtHours.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceItemsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('assemblyId: $assemblyId, ')
          ..write('refNo: $refNo, ')
          ..write('name: $name, ')
          ..write('frtHours: $frtHours, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartSubstitutesTable extends PartSubstitutes
    with TableInfo<$PartSubstitutesTable, PartSubstitute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartSubstitutesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<String> partId = GeneratedColumn<String>(
    'part_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _substitutePartIdMeta = const VerificationMeta(
    'substitutePartId',
  );
  @override
  late final GeneratedColumn<String> substitutePartId = GeneratedColumn<String>(
    'substitute_part_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    deletedAt,
    id,
    partId,
    substitutePartId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'part_substitutes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartSubstitute> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('part_id')) {
      context.handle(
        _partIdMeta,
        partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('substitute_part_id')) {
      context.handle(
        _substitutePartIdMeta,
        substitutePartId.isAcceptableOrUnknown(
          data['substitute_part_id']!,
          _substitutePartIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_substitutePartIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartSubstitute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartSubstitute(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      partId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_id'],
      )!,
      substitutePartId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}substitute_part_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PartSubstitutesTable createAlias(String alias) {
    return $PartSubstitutesTable(attachedDatabase, alias);
  }
}

class PartSubstitute extends DataClass implements Insertable<PartSubstitute> {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String partId;
  final String substitutePartId;
  final String? note;
  const PartSubstitute({
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.partId,
    required this.substitutePartId,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['part_id'] = Variable<String>(partId);
    map['substitute_part_id'] = Variable<String>(substitutePartId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PartSubstitutesCompanion toCompanion(bool nullToAbsent) {
    return PartSubstitutesCompanion(
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      partId: Value(partId),
      substitutePartId: Value(substitutePartId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory PartSubstitute.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartSubstitute(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      partId: serializer.fromJson<String>(json['partId']),
      substitutePartId: serializer.fromJson<String>(json['substitutePartId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'partId': serializer.toJson<String>(partId),
      'substitutePartId': serializer.toJson<String>(substitutePartId),
      'note': serializer.toJson<String?>(note),
    };
  }

  PartSubstitute copyWith({
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? partId,
    String? substitutePartId,
    Value<String?> note = const Value.absent(),
  }) => PartSubstitute(
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    partId: partId ?? this.partId,
    substitutePartId: substitutePartId ?? this.substitutePartId,
    note: note.present ? note.value : this.note,
  );
  PartSubstitute copyWithCompanion(PartSubstitutesCompanion data) {
    return PartSubstitute(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      partId: data.partId.present ? data.partId.value : this.partId,
      substitutePartId: data.substitutePartId.present
          ? data.substitutePartId.value
          : this.substitutePartId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartSubstitute(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('substitutePartId: $substitutePartId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(updatedAt, deletedAt, id, partId, substitutePartId, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartSubstitute &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.partId == this.partId &&
          other.substitutePartId == this.substitutePartId &&
          other.note == this.note);
}

class PartSubstitutesCompanion extends UpdateCompanion<PartSubstitute> {
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> partId;
  final Value<String> substitutePartId;
  final Value<String?> note;
  final Value<int> rowid;
  const PartSubstitutesCompanion({
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.partId = const Value.absent(),
    this.substitutePartId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartSubstitutesCompanion.insert({
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String id,
    required String partId,
    required String substitutePartId,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : updatedAt = Value(updatedAt),
       id = Value(id),
       partId = Value(partId),
       substitutePartId = Value(substitutePartId);
  static Insertable<PartSubstitute> custom({
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? partId,
    Expression<String>? substitutePartId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (partId != null) 'part_id': partId,
      if (substitutePartId != null) 'substitute_part_id': substitutePartId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartSubstitutesCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? partId,
    Value<String>? substitutePartId,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PartSubstitutesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      partId: partId ?? this.partId,
      substitutePartId: substitutePartId ?? this.substitutePartId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<String>(partId.value);
    }
    if (substitutePartId.present) {
      map['substitute_part_id'] = Variable<String>(substitutePartId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartSubstitutesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('partId: $partId, ')
          ..write('substitutePartId: $substitutePartId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cursor, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final int id;
  final String cursor;
  final DateTime? lastSyncedAt;
  const SyncState({required this.id, required this.cursor, this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cursor'] = Variable<String>(cursor);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      id: Value(id),
      cursor: Value(cursor),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      id: serializer.fromJson<int>(json['id']),
      cursor: serializer.fromJson<String>(json['cursor']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursor': serializer.toJson<String>(cursor),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SyncState copyWith({
    int? id,
    String? cursor,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => SyncState(
    id: id ?? this.id,
    cursor: cursor ?? this.cursor,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      id: data.id.present ? data.id.value : this.id,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('id: $id, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cursor, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.id == this.id &&
          other.cursor == this.cursor &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<int> id;
  final Value<String> cursor;
  final Value<DateTime?> lastSyncedAt;
  const SyncStatesCompanion({
    this.id = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    this.id = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  static Insertable<SyncState> custom({
    Expression<int>? id,
    Expression<String>? cursor,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursor != null) 'cursor': cursor,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  SyncStatesCompanion copyWith({
    Value<int>? id,
    Value<String>? cursor,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return SyncStatesCompanion(
      id: id ?? this.id,
      cursor: cursor ?? this.cursor,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('id: $id, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MachinesTable machines = $MachinesTable(this);
  late final $MachineVariantsTable machineVariants = $MachineVariantsTable(
    this,
  );
  late final $ColorsTable colors = $ColorsTable(this);
  late final $AssembliesTable assemblies = $AssembliesTable(this);
  late final $AssemblyItemsTable assemblyItems = $AssemblyItemsTable(this);
  late final $ItemResolutionsTable itemResolutions = $ItemResolutionsTable(
    this,
  );
  late final $DotsTable dots = $DotsTable(this);
  late final $AssemblyLinksTable assemblyLinks = $AssemblyLinksTable(this);
  late final $PartsTable parts = $PartsTable(this);
  late final $PartNumbersTable partNumbers = $PartNumbersTable(this);
  late final $PartColorVariantsTable partColorVariants =
      $PartColorVariantsTable(this);
  late final $AliasesTable aliases = $AliasesTable(this);
  late final $ServiceItemsTable serviceItems = $ServiceItemsTable(this);
  late final $PartSubstitutesTable partSubstitutes = $PartSubstitutesTable(
    this,
  );
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final Index assembliesMachine = Index(
    'assemblies_machine',
    'CREATE INDEX assemblies_machine ON assemblies (machine_id)',
  );
  late final Index assemblyItemsAssembly = Index(
    'assembly_items_assembly',
    'CREATE INDEX assembly_items_assembly ON assembly_items (assembly_id)',
  );
  late final Index itemResolutionsItem = Index(
    'item_resolutions_item',
    'CREATE INDEX item_resolutions_item ON item_resolutions (assembly_item_id)',
  );
  late final Index dotsItem = Index(
    'dots_item',
    'CREATE INDEX dots_item ON dots (assembly_item_id)',
  );
  late final Index partsNameNormalized = Index(
    'parts_name_normalized',
    'CREATE INDEX parts_name_normalized ON parts (name_normalized)',
  );
  late final Index partNumbersValue = Index(
    'part_numbers_value',
    'CREATE INDEX part_numbers_value ON part_numbers (value)',
  );
  late final Index partNumbersPart = Index(
    'part_numbers_part',
    'CREATE INDEX part_numbers_part ON part_numbers (part_id)',
  );
  late final Index partColorVariantsPart = Index(
    'part_color_variants_part',
    'CREATE INDEX part_color_variants_part ON part_color_variants (part_id)',
  );
  late final Index aliasesTerm = Index(
    'aliases_term',
    'CREATE INDEX aliases_term ON aliases (term)',
  );
  late final Index partSubstitutesPart = Index(
    'part_substitutes_part',
    'CREATE INDEX part_substitutes_part ON part_substitutes (part_id)',
  );
  late final Index partSubstitutesSub = Index(
    'part_substitutes_sub',
    'CREATE INDEX part_substitutes_sub ON part_substitutes (substitute_part_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    machines,
    machineVariants,
    colors,
    assemblies,
    assemblyItems,
    itemResolutions,
    dots,
    assemblyLinks,
    parts,
    partNumbers,
    partColorVariants,
    aliases,
    serviceItems,
    partSubstitutes,
    syncStates,
    assembliesMachine,
    assemblyItemsAssembly,
    itemResolutionsItem,
    dotsItem,
    partsNameNormalized,
    partNumbersValue,
    partNumbersPart,
    partColorVariantsPart,
    aliasesTerm,
    partSubstitutesPart,
    partSubstitutesSub,
  ];
}

typedef $$MachinesTableCreateCompanionBuilder =
    MachinesCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String brand,
      required String model,
      Value<String?> typeCode,
      Value<String?> kCode,
      Value<String?> market,
      Value<String?> engineSeries,
      Value<String?> frameSeries,
      Value<int?> yearFrom,
      Value<int?> yearTo,
      Value<String?> catalogEdition,
      Value<String?> catalogDate,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$MachinesTableUpdateCompanionBuilder =
    MachinesCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> brand,
      Value<String> model,
      Value<String?> typeCode,
      Value<String?> kCode,
      Value<String?> market,
      Value<String?> engineSeries,
      Value<String?> frameSeries,
      Value<int?> yearFrom,
      Value<int?> yearTo,
      Value<String?> catalogEdition,
      Value<String?> catalogDate,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$MachinesTableFilterComposer
    extends Composer<_$AppDatabase, $MachinesTable> {
  $$MachinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeCode => $composableBuilder(
    column: $table.typeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kCode => $composableBuilder(
    column: $table.kCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineSeries => $composableBuilder(
    column: $table.engineSeries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frameSeries => $composableBuilder(
    column: $table.frameSeries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearTo => $composableBuilder(
    column: $table.yearTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogEdition => $composableBuilder(
    column: $table.catalogEdition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogDate => $composableBuilder(
    column: $table.catalogDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MachinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MachinesTable> {
  $$MachinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeCode => $composableBuilder(
    column: $table.typeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kCode => $composableBuilder(
    column: $table.kCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get market => $composableBuilder(
    column: $table.market,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineSeries => $composableBuilder(
    column: $table.engineSeries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frameSeries => $composableBuilder(
    column: $table.frameSeries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearTo => $composableBuilder(
    column: $table.yearTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogEdition => $composableBuilder(
    column: $table.catalogEdition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogDate => $composableBuilder(
    column: $table.catalogDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MachinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MachinesTable> {
  $$MachinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get typeCode =>
      $composableBuilder(column: $table.typeCode, builder: (column) => column);

  GeneratedColumn<String> get kCode =>
      $composableBuilder(column: $table.kCode, builder: (column) => column);

  GeneratedColumn<String> get market =>
      $composableBuilder(column: $table.market, builder: (column) => column);

  GeneratedColumn<String> get engineSeries => $composableBuilder(
    column: $table.engineSeries,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frameSeries => $composableBuilder(
    column: $table.frameSeries,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yearFrom =>
      $composableBuilder(column: $table.yearFrom, builder: (column) => column);

  GeneratedColumn<int> get yearTo =>
      $composableBuilder(column: $table.yearTo, builder: (column) => column);

  GeneratedColumn<String> get catalogEdition => $composableBuilder(
    column: $table.catalogEdition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogDate => $composableBuilder(
    column: $table.catalogDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$MachinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MachinesTable,
          Machine,
          $$MachinesTableFilterComposer,
          $$MachinesTableOrderingComposer,
          $$MachinesTableAnnotationComposer,
          $$MachinesTableCreateCompanionBuilder,
          $$MachinesTableUpdateCompanionBuilder,
          (Machine, BaseReferences<_$AppDatabase, $MachinesTable, Machine>),
          Machine,
          PrefetchHooks Function()
        > {
  $$MachinesTableTableManager(_$AppDatabase db, $MachinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MachinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MachinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MachinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String?> typeCode = const Value.absent(),
                Value<String?> kCode = const Value.absent(),
                Value<String?> market = const Value.absent(),
                Value<String?> engineSeries = const Value.absent(),
                Value<String?> frameSeries = const Value.absent(),
                Value<int?> yearFrom = const Value.absent(),
                Value<int?> yearTo = const Value.absent(),
                Value<String?> catalogEdition = const Value.absent(),
                Value<String?> catalogDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MachinesCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                brand: brand,
                model: model,
                typeCode: typeCode,
                kCode: kCode,
                market: market,
                engineSeries: engineSeries,
                frameSeries: frameSeries,
                yearFrom: yearFrom,
                yearTo: yearTo,
                catalogEdition: catalogEdition,
                catalogDate: catalogDate,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String brand,
                required String model,
                Value<String?> typeCode = const Value.absent(),
                Value<String?> kCode = const Value.absent(),
                Value<String?> market = const Value.absent(),
                Value<String?> engineSeries = const Value.absent(),
                Value<String?> frameSeries = const Value.absent(),
                Value<int?> yearFrom = const Value.absent(),
                Value<int?> yearTo = const Value.absent(),
                Value<String?> catalogEdition = const Value.absent(),
                Value<String?> catalogDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MachinesCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                brand: brand,
                model: model,
                typeCode: typeCode,
                kCode: kCode,
                market: market,
                engineSeries: engineSeries,
                frameSeries: frameSeries,
                yearFrom: yearFrom,
                yearTo: yearTo,
                catalogEdition: catalogEdition,
                catalogDate: catalogDate,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MachinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MachinesTable,
      Machine,
      $$MachinesTableFilterComposer,
      $$MachinesTableOrderingComposer,
      $$MachinesTableAnnotationComposer,
      $$MachinesTableCreateCompanionBuilder,
      $$MachinesTableUpdateCompanionBuilder,
      (Machine, BaseReferences<_$AppDatabase, $MachinesTable, Machine>),
      Machine,
      PrefetchHooks Function()
    >;
typedef $$MachineVariantsTableCreateCompanionBuilder =
    MachineVariantsCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String machineId,
      required String name,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$MachineVariantsTableUpdateCompanionBuilder =
    MachineVariantsCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> machineId,
      Value<String> name,
      Value<String?> note,
      Value<int> rowid,
    });

class $$MachineVariantsTableFilterComposer
    extends Composer<_$AppDatabase, $MachineVariantsTable> {
  $$MachineVariantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get machineId => $composableBuilder(
    column: $table.machineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MachineVariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $MachineVariantsTable> {
  $$MachineVariantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get machineId => $composableBuilder(
    column: $table.machineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MachineVariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MachineVariantsTable> {
  $$MachineVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get machineId =>
      $composableBuilder(column: $table.machineId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$MachineVariantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MachineVariantsTable,
          MachineVariant,
          $$MachineVariantsTableFilterComposer,
          $$MachineVariantsTableOrderingComposer,
          $$MachineVariantsTableAnnotationComposer,
          $$MachineVariantsTableCreateCompanionBuilder,
          $$MachineVariantsTableUpdateCompanionBuilder,
          (
            MachineVariant,
            BaseReferences<
              _$AppDatabase,
              $MachineVariantsTable,
              MachineVariant
            >,
          ),
          MachineVariant,
          PrefetchHooks Function()
        > {
  $$MachineVariantsTableTableManager(
    _$AppDatabase db,
    $MachineVariantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MachineVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MachineVariantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MachineVariantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> machineId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MachineVariantsCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                machineId: machineId,
                name: name,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String machineId,
                required String name,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MachineVariantsCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                machineId: machineId,
                name: name,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MachineVariantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MachineVariantsTable,
      MachineVariant,
      $$MachineVariantsTableFilterComposer,
      $$MachineVariantsTableOrderingComposer,
      $$MachineVariantsTableAnnotationComposer,
      $$MachineVariantsTableCreateCompanionBuilder,
      $$MachineVariantsTableUpdateCompanionBuilder,
      (
        MachineVariant,
        BaseReferences<_$AppDatabase, $MachineVariantsTable, MachineVariant>,
      ),
      MachineVariant,
      PrefetchHooks Function()
    >;
typedef $$ColorsTableCreateCompanionBuilder =
    ColorsCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String machineId,
      required String code,
      required String name,
      Value<int> rowid,
    });
typedef $$ColorsTableUpdateCompanionBuilder =
    ColorsCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> machineId,
      Value<String> code,
      Value<String> name,
      Value<int> rowid,
    });

class $$ColorsTableFilterComposer
    extends Composer<_$AppDatabase, $ColorsTable> {
  $$ColorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get machineId => $composableBuilder(
    column: $table.machineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ColorsTableOrderingComposer
    extends Composer<_$AppDatabase, $ColorsTable> {
  $$ColorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get machineId => $composableBuilder(
    column: $table.machineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ColorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColorsTable> {
  $$ColorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get machineId =>
      $composableBuilder(column: $table.machineId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$ColorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ColorsTable,
          Color,
          $$ColorsTableFilterComposer,
          $$ColorsTableOrderingComposer,
          $$ColorsTableAnnotationComposer,
          $$ColorsTableCreateCompanionBuilder,
          $$ColorsTableUpdateCompanionBuilder,
          (Color, BaseReferences<_$AppDatabase, $ColorsTable, Color>),
          Color,
          PrefetchHooks Function()
        > {
  $$ColorsTableTableManager(_$AppDatabase db, $ColorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> machineId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColorsCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                machineId: machineId,
                code: code,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String machineId,
                required String code,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => ColorsCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                machineId: machineId,
                code: code,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ColorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ColorsTable,
      Color,
      $$ColorsTableFilterComposer,
      $$ColorsTableOrderingComposer,
      $$ColorsTableAnnotationComposer,
      $$ColorsTableCreateCompanionBuilder,
      $$ColorsTableUpdateCompanionBuilder,
      (Color, BaseReferences<_$AppDatabase, $ColorsTable, Color>),
      Color,
      PrefetchHooks Function()
    >;
typedef $$AssembliesTableCreateCompanionBuilder =
    AssembliesCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String machineId,
      required String groupType,
      required String code,
      required String name,
      Value<String?> imageRef,
      Value<String?> imageCode,
      Value<int?> width,
      Value<int?> height,
      Value<int?> pageNo,
      Value<int?> sortOrder,
      Value<int> rowid,
    });
typedef $$AssembliesTableUpdateCompanionBuilder =
    AssembliesCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> machineId,
      Value<String> groupType,
      Value<String> code,
      Value<String> name,
      Value<String?> imageRef,
      Value<String?> imageCode,
      Value<int?> width,
      Value<int?> height,
      Value<int?> pageNo,
      Value<int?> sortOrder,
      Value<int> rowid,
    });

class $$AssembliesTableFilterComposer
    extends Composer<_$AppDatabase, $AssembliesTable> {
  $$AssembliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get machineId => $composableBuilder(
    column: $table.machineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupType => $composableBuilder(
    column: $table.groupType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageRef => $composableBuilder(
    column: $table.imageRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageCode => $composableBuilder(
    column: $table.imageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNo => $composableBuilder(
    column: $table.pageNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssembliesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssembliesTable> {
  $$AssembliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get machineId => $composableBuilder(
    column: $table.machineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupType => $composableBuilder(
    column: $table.groupType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageRef => $composableBuilder(
    column: $table.imageRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageCode => $composableBuilder(
    column: $table.imageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNo => $composableBuilder(
    column: $table.pageNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssembliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssembliesTable> {
  $$AssembliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get machineId =>
      $composableBuilder(column: $table.machineId, builder: (column) => column);

  GeneratedColumn<String> get groupType =>
      $composableBuilder(column: $table.groupType, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageRef =>
      $composableBuilder(column: $table.imageRef, builder: (column) => column);

  GeneratedColumn<String> get imageCode =>
      $composableBuilder(column: $table.imageCode, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get pageNo =>
      $composableBuilder(column: $table.pageNo, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$AssembliesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssembliesTable,
          Assembly,
          $$AssembliesTableFilterComposer,
          $$AssembliesTableOrderingComposer,
          $$AssembliesTableAnnotationComposer,
          $$AssembliesTableCreateCompanionBuilder,
          $$AssembliesTableUpdateCompanionBuilder,
          (Assembly, BaseReferences<_$AppDatabase, $AssembliesTable, Assembly>),
          Assembly,
          PrefetchHooks Function()
        > {
  $$AssembliesTableTableManager(_$AppDatabase db, $AssembliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssembliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssembliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssembliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> machineId = const Value.absent(),
                Value<String> groupType = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageRef = const Value.absent(),
                Value<String?> imageCode = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> pageNo = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssembliesCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                machineId: machineId,
                groupType: groupType,
                code: code,
                name: name,
                imageRef: imageRef,
                imageCode: imageCode,
                width: width,
                height: height,
                pageNo: pageNo,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String machineId,
                required String groupType,
                required String code,
                required String name,
                Value<String?> imageRef = const Value.absent(),
                Value<String?> imageCode = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> pageNo = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssembliesCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                machineId: machineId,
                groupType: groupType,
                code: code,
                name: name,
                imageRef: imageRef,
                imageCode: imageCode,
                width: width,
                height: height,
                pageNo: pageNo,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssembliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssembliesTable,
      Assembly,
      $$AssembliesTableFilterComposer,
      $$AssembliesTableOrderingComposer,
      $$AssembliesTableAnnotationComposer,
      $$AssembliesTableCreateCompanionBuilder,
      $$AssembliesTableUpdateCompanionBuilder,
      (Assembly, BaseReferences<_$AppDatabase, $AssembliesTable, Assembly>),
      Assembly,
      PrefetchHooks Function()
    >;
typedef $$AssemblyItemsTableCreateCompanionBuilder =
    AssemblyItemsCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String assemblyId,
      required String refNo,
      Value<String?> basePartId,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$AssemblyItemsTableUpdateCompanionBuilder =
    AssemblyItemsCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> assemblyId,
      Value<String> refNo,
      Value<String?> basePartId,
      Value<String?> note,
      Value<int> rowid,
    });

class $$AssemblyItemsTableFilterComposer
    extends Composer<_$AppDatabase, $AssemblyItemsTable> {
  $$AssemblyItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assemblyId => $composableBuilder(
    column: $table.assemblyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refNo => $composableBuilder(
    column: $table.refNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basePartId => $composableBuilder(
    column: $table.basePartId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssemblyItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssemblyItemsTable> {
  $$AssemblyItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assemblyId => $composableBuilder(
    column: $table.assemblyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refNo => $composableBuilder(
    column: $table.refNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basePartId => $composableBuilder(
    column: $table.basePartId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssemblyItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssemblyItemsTable> {
  $$AssemblyItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assemblyId => $composableBuilder(
    column: $table.assemblyId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refNo =>
      $composableBuilder(column: $table.refNo, builder: (column) => column);

  GeneratedColumn<String> get basePartId => $composableBuilder(
    column: $table.basePartId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$AssemblyItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssemblyItemsTable,
          AssemblyItem,
          $$AssemblyItemsTableFilterComposer,
          $$AssemblyItemsTableOrderingComposer,
          $$AssemblyItemsTableAnnotationComposer,
          $$AssemblyItemsTableCreateCompanionBuilder,
          $$AssemblyItemsTableUpdateCompanionBuilder,
          (
            AssemblyItem,
            BaseReferences<_$AppDatabase, $AssemblyItemsTable, AssemblyItem>,
          ),
          AssemblyItem,
          PrefetchHooks Function()
        > {
  $$AssemblyItemsTableTableManager(_$AppDatabase db, $AssemblyItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssemblyItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssemblyItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssemblyItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> assemblyId = const Value.absent(),
                Value<String> refNo = const Value.absent(),
                Value<String?> basePartId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssemblyItemsCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                assemblyId: assemblyId,
                refNo: refNo,
                basePartId: basePartId,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String assemblyId,
                required String refNo,
                Value<String?> basePartId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssemblyItemsCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                assemblyId: assemblyId,
                refNo: refNo,
                basePartId: basePartId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssemblyItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssemblyItemsTable,
      AssemblyItem,
      $$AssemblyItemsTableFilterComposer,
      $$AssemblyItemsTableOrderingComposer,
      $$AssemblyItemsTableAnnotationComposer,
      $$AssemblyItemsTableCreateCompanionBuilder,
      $$AssemblyItemsTableUpdateCompanionBuilder,
      (
        AssemblyItem,
        BaseReferences<_$AppDatabase, $AssemblyItemsTable, AssemblyItem>,
      ),
      AssemblyItem,
      PrefetchHooks Function()
    >;
typedef $$ItemResolutionsTableCreateCompanionBuilder =
    ItemResolutionsCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String assemblyItemId,
      required String partNumberId,
      Value<int> qty,
      Value<String?> variantId,
      Value<String?> serialFrom,
      Value<String?> serialTo,
      Value<int> rowid,
    });
typedef $$ItemResolutionsTableUpdateCompanionBuilder =
    ItemResolutionsCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> assemblyItemId,
      Value<String> partNumberId,
      Value<int> qty,
      Value<String?> variantId,
      Value<String?> serialFrom,
      Value<String?> serialTo,
      Value<int> rowid,
    });

class $$ItemResolutionsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemResolutionsTable> {
  $$ItemResolutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assemblyItemId => $composableBuilder(
    column: $table.assemblyItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partNumberId => $composableBuilder(
    column: $table.partNumberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialFrom => $composableBuilder(
    column: $table.serialFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serialTo => $composableBuilder(
    column: $table.serialTo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemResolutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemResolutionsTable> {
  $$ItemResolutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assemblyItemId => $composableBuilder(
    column: $table.assemblyItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partNumberId => $composableBuilder(
    column: $table.partNumberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variantId => $composableBuilder(
    column: $table.variantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialFrom => $composableBuilder(
    column: $table.serialFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serialTo => $composableBuilder(
    column: $table.serialTo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemResolutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemResolutionsTable> {
  $$ItemResolutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assemblyItemId => $composableBuilder(
    column: $table.assemblyItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partNumberId => $composableBuilder(
    column: $table.partNumberId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get variantId =>
      $composableBuilder(column: $table.variantId, builder: (column) => column);

  GeneratedColumn<String> get serialFrom => $composableBuilder(
    column: $table.serialFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serialTo =>
      $composableBuilder(column: $table.serialTo, builder: (column) => column);
}

class $$ItemResolutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemResolutionsTable,
          ItemResolution,
          $$ItemResolutionsTableFilterComposer,
          $$ItemResolutionsTableOrderingComposer,
          $$ItemResolutionsTableAnnotationComposer,
          $$ItemResolutionsTableCreateCompanionBuilder,
          $$ItemResolutionsTableUpdateCompanionBuilder,
          (
            ItemResolution,
            BaseReferences<
              _$AppDatabase,
              $ItemResolutionsTable,
              ItemResolution
            >,
          ),
          ItemResolution,
          PrefetchHooks Function()
        > {
  $$ItemResolutionsTableTableManager(
    _$AppDatabase db,
    $ItemResolutionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemResolutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemResolutionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemResolutionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> assemblyItemId = const Value.absent(),
                Value<String> partNumberId = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<String?> variantId = const Value.absent(),
                Value<String?> serialFrom = const Value.absent(),
                Value<String?> serialTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemResolutionsCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                assemblyItemId: assemblyItemId,
                partNumberId: partNumberId,
                qty: qty,
                variantId: variantId,
                serialFrom: serialFrom,
                serialTo: serialTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String assemblyItemId,
                required String partNumberId,
                Value<int> qty = const Value.absent(),
                Value<String?> variantId = const Value.absent(),
                Value<String?> serialFrom = const Value.absent(),
                Value<String?> serialTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemResolutionsCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                assemblyItemId: assemblyItemId,
                partNumberId: partNumberId,
                qty: qty,
                variantId: variantId,
                serialFrom: serialFrom,
                serialTo: serialTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemResolutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemResolutionsTable,
      ItemResolution,
      $$ItemResolutionsTableFilterComposer,
      $$ItemResolutionsTableOrderingComposer,
      $$ItemResolutionsTableAnnotationComposer,
      $$ItemResolutionsTableCreateCompanionBuilder,
      $$ItemResolutionsTableUpdateCompanionBuilder,
      (
        ItemResolution,
        BaseReferences<_$AppDatabase, $ItemResolutionsTable, ItemResolution>,
      ),
      ItemResolution,
      PrefetchHooks Function()
    >;
typedef $$DotsTableCreateCompanionBuilder =
    DotsCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String assemblyItemId,
      required double x,
      required double y,
      Value<int> rowid,
    });
typedef $$DotsTableUpdateCompanionBuilder =
    DotsCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> assemblyItemId,
      Value<double> x,
      Value<double> y,
      Value<int> rowid,
    });

class $$DotsTableFilterComposer extends Composer<_$AppDatabase, $DotsTable> {
  $$DotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assemblyItemId => $composableBuilder(
    column: $table.assemblyItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DotsTableOrderingComposer extends Composer<_$AppDatabase, $DotsTable> {
  $$DotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assemblyItemId => $composableBuilder(
    column: $table.assemblyItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DotsTable> {
  $$DotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assemblyItemId => $composableBuilder(
    column: $table.assemblyItemId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);
}

class $$DotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DotsTable,
          Dot,
          $$DotsTableFilterComposer,
          $$DotsTableOrderingComposer,
          $$DotsTableAnnotationComposer,
          $$DotsTableCreateCompanionBuilder,
          $$DotsTableUpdateCompanionBuilder,
          (Dot, BaseReferences<_$AppDatabase, $DotsTable, Dot>),
          Dot,
          PrefetchHooks Function()
        > {
  $$DotsTableTableManager(_$AppDatabase db, $DotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> assemblyItemId = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DotsCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                assemblyItemId: assemblyItemId,
                x: x,
                y: y,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String assemblyItemId,
                required double x,
                required double y,
                Value<int> rowid = const Value.absent(),
              }) => DotsCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                assemblyItemId: assemblyItemId,
                x: x,
                y: y,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DotsTable,
      Dot,
      $$DotsTableFilterComposer,
      $$DotsTableOrderingComposer,
      $$DotsTableAnnotationComposer,
      $$DotsTableCreateCompanionBuilder,
      $$DotsTableUpdateCompanionBuilder,
      (Dot, BaseReferences<_$AppDatabase, $DotsTable, Dot>),
      Dot,
      PrefetchHooks Function()
    >;
typedef $$AssemblyLinksTableCreateCompanionBuilder =
    AssemblyLinksCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String fromAssemblyId,
      required String toCode,
      Value<String?> toAssemblyId,
      Value<double?> x,
      Value<double?> y,
      Value<String?> label,
      Value<int> rowid,
    });
typedef $$AssemblyLinksTableUpdateCompanionBuilder =
    AssemblyLinksCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> fromAssemblyId,
      Value<String> toCode,
      Value<String?> toAssemblyId,
      Value<double?> x,
      Value<double?> y,
      Value<String?> label,
      Value<int> rowid,
    });

class $$AssemblyLinksTableFilterComposer
    extends Composer<_$AppDatabase, $AssemblyLinksTable> {
  $$AssemblyLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromAssemblyId => $composableBuilder(
    column: $table.fromAssemblyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toCode => $composableBuilder(
    column: $table.toCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toAssemblyId => $composableBuilder(
    column: $table.toAssemblyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssemblyLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $AssemblyLinksTable> {
  $$AssemblyLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromAssemblyId => $composableBuilder(
    column: $table.fromAssemblyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toCode => $composableBuilder(
    column: $table.toCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toAssemblyId => $composableBuilder(
    column: $table.toAssemblyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssemblyLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssemblyLinksTable> {
  $$AssemblyLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromAssemblyId => $composableBuilder(
    column: $table.fromAssemblyId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toCode =>
      $composableBuilder(column: $table.toCode, builder: (column) => column);

  GeneratedColumn<String> get toAssemblyId => $composableBuilder(
    column: $table.toAssemblyId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);
}

class $$AssemblyLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssemblyLinksTable,
          AssemblyLink,
          $$AssemblyLinksTableFilterComposer,
          $$AssemblyLinksTableOrderingComposer,
          $$AssemblyLinksTableAnnotationComposer,
          $$AssemblyLinksTableCreateCompanionBuilder,
          $$AssemblyLinksTableUpdateCompanionBuilder,
          (
            AssemblyLink,
            BaseReferences<_$AppDatabase, $AssemblyLinksTable, AssemblyLink>,
          ),
          AssemblyLink,
          PrefetchHooks Function()
        > {
  $$AssemblyLinksTableTableManager(_$AppDatabase db, $AssemblyLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssemblyLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssemblyLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssemblyLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> fromAssemblyId = const Value.absent(),
                Value<String> toCode = const Value.absent(),
                Value<String?> toAssemblyId = const Value.absent(),
                Value<double?> x = const Value.absent(),
                Value<double?> y = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssemblyLinksCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                fromAssemblyId: fromAssemblyId,
                toCode: toCode,
                toAssemblyId: toAssemblyId,
                x: x,
                y: y,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String fromAssemblyId,
                required String toCode,
                Value<String?> toAssemblyId = const Value.absent(),
                Value<double?> x = const Value.absent(),
                Value<double?> y = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssemblyLinksCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                fromAssemblyId: fromAssemblyId,
                toCode: toCode,
                toAssemblyId: toAssemblyId,
                x: x,
                y: y,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssemblyLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssemblyLinksTable,
      AssemblyLink,
      $$AssemblyLinksTableFilterComposer,
      $$AssemblyLinksTableOrderingComposer,
      $$AssemblyLinksTableAnnotationComposer,
      $$AssemblyLinksTableCreateCompanionBuilder,
      $$AssemblyLinksTableUpdateCompanionBuilder,
      (
        AssemblyLink,
        BaseReferences<_$AppDatabase, $AssemblyLinksTable, AssemblyLink>,
      ),
      AssemblyLink,
      PrefetchHooks Function()
    >;
typedef $$PartsTableCreateCompanionBuilder =
    PartsCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String nameRaw,
      Value<String?> nameNormalized,
      Value<String?> category,
      Value<String?> specs,
      Value<String?> notes,
      Value<bool> isCurrentReplacement,
      Value<int> rowid,
    });
typedef $$PartsTableUpdateCompanionBuilder =
    PartsCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> nameRaw,
      Value<String?> nameNormalized,
      Value<String?> category,
      Value<String?> specs,
      Value<String?> notes,
      Value<bool> isCurrentReplacement,
      Value<int> rowid,
    });

class $$PartsTableFilterComposer extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameRaw => $composableBuilder(
    column: $table.nameRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNormalized => $composableBuilder(
    column: $table.nameNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specs => $composableBuilder(
    column: $table.specs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrentReplacement => $composableBuilder(
    column: $table.isCurrentReplacement,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameRaw => $composableBuilder(
    column: $table.nameRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNormalized => $composableBuilder(
    column: $table.nameNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specs => $composableBuilder(
    column: $table.specs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrentReplacement => $composableBuilder(
    column: $table.isCurrentReplacement,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameRaw =>
      $composableBuilder(column: $table.nameRaw, builder: (column) => column);

  GeneratedColumn<String> get nameNormalized => $composableBuilder(
    column: $table.nameNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get specs =>
      $composableBuilder(column: $table.specs, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isCurrentReplacement => $composableBuilder(
    column: $table.isCurrentReplacement,
    builder: (column) => column,
  );
}

class $$PartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartsTable,
          Part,
          $$PartsTableFilterComposer,
          $$PartsTableOrderingComposer,
          $$PartsTableAnnotationComposer,
          $$PartsTableCreateCompanionBuilder,
          $$PartsTableUpdateCompanionBuilder,
          (Part, BaseReferences<_$AppDatabase, $PartsTable, Part>),
          Part,
          PrefetchHooks Function()
        > {
  $$PartsTableTableManager(_$AppDatabase db, $PartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> nameRaw = const Value.absent(),
                Value<String?> nameNormalized = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> specs = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isCurrentReplacement = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartsCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                nameRaw: nameRaw,
                nameNormalized: nameNormalized,
                category: category,
                specs: specs,
                notes: notes,
                isCurrentReplacement: isCurrentReplacement,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String nameRaw,
                Value<String?> nameNormalized = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> specs = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isCurrentReplacement = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartsCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                nameRaw: nameRaw,
                nameNormalized: nameNormalized,
                category: category,
                specs: specs,
                notes: notes,
                isCurrentReplacement: isCurrentReplacement,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartsTable,
      Part,
      $$PartsTableFilterComposer,
      $$PartsTableOrderingComposer,
      $$PartsTableAnnotationComposer,
      $$PartsTableCreateCompanionBuilder,
      $$PartsTableUpdateCompanionBuilder,
      (Part, BaseReferences<_$AppDatabase, $PartsTable, Part>),
      Part,
      PrefetchHooks Function()
    >;
typedef $$PartNumbersTableCreateCompanionBuilder =
    PartNumbersCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String partId,
      required String value,
      Value<String> kind,
      Value<String?> brand,
      Value<String?> note,
      Value<bool> isPrimary,
      Value<int> rowid,
    });
typedef $$PartNumbersTableUpdateCompanionBuilder =
    PartNumbersCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> partId,
      Value<String> value,
      Value<String> kind,
      Value<String?> brand,
      Value<String?> note,
      Value<bool> isPrimary,
      Value<int> rowid,
    });

class $$PartNumbersTableFilterComposer
    extends Composer<_$AppDatabase, $PartNumbersTable> {
  $$PartNumbersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartNumbersTableOrderingComposer
    extends Composer<_$AppDatabase, $PartNumbersTable> {
  $$PartNumbersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartNumbersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartNumbersTable> {
  $$PartNumbersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partId =>
      $composableBuilder(column: $table.partId, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);
}

class $$PartNumbersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartNumbersTable,
          PartNumber,
          $$PartNumbersTableFilterComposer,
          $$PartNumbersTableOrderingComposer,
          $$PartNumbersTableAnnotationComposer,
          $$PartNumbersTableCreateCompanionBuilder,
          $$PartNumbersTableUpdateCompanionBuilder,
          (
            PartNumber,
            BaseReferences<_$AppDatabase, $PartNumbersTable, PartNumber>,
          ),
          PartNumber,
          PrefetchHooks Function()
        > {
  $$PartNumbersTableTableManager(_$AppDatabase db, $PartNumbersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartNumbersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartNumbersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartNumbersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> partId = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartNumbersCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                partId: partId,
                value: value,
                kind: kind,
                brand: brand,
                note: note,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String partId,
                required String value,
                Value<String> kind = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartNumbersCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                partId: partId,
                value: value,
                kind: kind,
                brand: brand,
                note: note,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartNumbersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartNumbersTable,
      PartNumber,
      $$PartNumbersTableFilterComposer,
      $$PartNumbersTableOrderingComposer,
      $$PartNumbersTableAnnotationComposer,
      $$PartNumbersTableCreateCompanionBuilder,
      $$PartNumbersTableUpdateCompanionBuilder,
      (
        PartNumber,
        BaseReferences<_$AppDatabase, $PartNumbersTable, PartNumber>,
      ),
      PartNumber,
      PrefetchHooks Function()
    >;
typedef $$PartColorVariantsTableCreateCompanionBuilder =
    PartColorVariantsCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String partId,
      required String colorId,
      Value<String?> suffixCode,
      Value<String?> fullNumber,
      Value<int> rowid,
    });
typedef $$PartColorVariantsTableUpdateCompanionBuilder =
    PartColorVariantsCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> partId,
      Value<String> colorId,
      Value<String?> suffixCode,
      Value<String?> fullNumber,
      Value<int> rowid,
    });

class $$PartColorVariantsTableFilterComposer
    extends Composer<_$AppDatabase, $PartColorVariantsTable> {
  $$PartColorVariantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suffixCode => $composableBuilder(
    column: $table.suffixCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullNumber => $composableBuilder(
    column: $table.fullNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartColorVariantsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartColorVariantsTable> {
  $$PartColorVariantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suffixCode => $composableBuilder(
    column: $table.suffixCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullNumber => $composableBuilder(
    column: $table.fullNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartColorVariantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartColorVariantsTable> {
  $$PartColorVariantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partId =>
      $composableBuilder(column: $table.partId, builder: (column) => column);

  GeneratedColumn<String> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumn<String> get suffixCode => $composableBuilder(
    column: $table.suffixCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullNumber => $composableBuilder(
    column: $table.fullNumber,
    builder: (column) => column,
  );
}

class $$PartColorVariantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartColorVariantsTable,
          PartColorVariant,
          $$PartColorVariantsTableFilterComposer,
          $$PartColorVariantsTableOrderingComposer,
          $$PartColorVariantsTableAnnotationComposer,
          $$PartColorVariantsTableCreateCompanionBuilder,
          $$PartColorVariantsTableUpdateCompanionBuilder,
          (
            PartColorVariant,
            BaseReferences<
              _$AppDatabase,
              $PartColorVariantsTable,
              PartColorVariant
            >,
          ),
          PartColorVariant,
          PrefetchHooks Function()
        > {
  $$PartColorVariantsTableTableManager(
    _$AppDatabase db,
    $PartColorVariantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartColorVariantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartColorVariantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartColorVariantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> partId = const Value.absent(),
                Value<String> colorId = const Value.absent(),
                Value<String?> suffixCode = const Value.absent(),
                Value<String?> fullNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartColorVariantsCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                partId: partId,
                colorId: colorId,
                suffixCode: suffixCode,
                fullNumber: fullNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String partId,
                required String colorId,
                Value<String?> suffixCode = const Value.absent(),
                Value<String?> fullNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartColorVariantsCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                partId: partId,
                colorId: colorId,
                suffixCode: suffixCode,
                fullNumber: fullNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartColorVariantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartColorVariantsTable,
      PartColorVariant,
      $$PartColorVariantsTableFilterComposer,
      $$PartColorVariantsTableOrderingComposer,
      $$PartColorVariantsTableAnnotationComposer,
      $$PartColorVariantsTableCreateCompanionBuilder,
      $$PartColorVariantsTableUpdateCompanionBuilder,
      (
        PartColorVariant,
        BaseReferences<
          _$AppDatabase,
          $PartColorVariantsTable,
          PartColorVariant
        >,
      ),
      PartColorVariant,
      PrefetchHooks Function()
    >;
typedef $$AliasesTableCreateCompanionBuilder =
    AliasesCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String partId,
      required String term,
      Value<String?> lang,
      Value<int> rowid,
    });
typedef $$AliasesTableUpdateCompanionBuilder =
    AliasesCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> partId,
      Value<String> term,
      Value<String?> lang,
      Value<int> rowid,
    });

class $$AliasesTableFilterComposer
    extends Composer<_$AppDatabase, $AliasesTable> {
  $$AliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AliasesTableOrderingComposer
    extends Composer<_$AppDatabase, $AliasesTable> {
  $$AliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lang => $composableBuilder(
    column: $table.lang,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AliasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AliasesTable> {
  $$AliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partId =>
      $composableBuilder(column: $table.partId, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);
}

class $$AliasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AliasesTable,
          Aliase,
          $$AliasesTableFilterComposer,
          $$AliasesTableOrderingComposer,
          $$AliasesTableAnnotationComposer,
          $$AliasesTableCreateCompanionBuilder,
          $$AliasesTableUpdateCompanionBuilder,
          (Aliase, BaseReferences<_$AppDatabase, $AliasesTable, Aliase>),
          Aliase,
          PrefetchHooks Function()
        > {
  $$AliasesTableTableManager(_$AppDatabase db, $AliasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> partId = const Value.absent(),
                Value<String> term = const Value.absent(),
                Value<String?> lang = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AliasesCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                partId: partId,
                term: term,
                lang: lang,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String partId,
                required String term,
                Value<String?> lang = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AliasesCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                partId: partId,
                term: term,
                lang: lang,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AliasesTable,
      Aliase,
      $$AliasesTableFilterComposer,
      $$AliasesTableOrderingComposer,
      $$AliasesTableAnnotationComposer,
      $$AliasesTableCreateCompanionBuilder,
      $$AliasesTableUpdateCompanionBuilder,
      (Aliase, BaseReferences<_$AppDatabase, $AliasesTable, Aliase>),
      Aliase,
      PrefetchHooks Function()
    >;
typedef $$ServiceItemsTableCreateCompanionBuilder =
    ServiceItemsCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String assemblyId,
      Value<String?> refNo,
      required String name,
      Value<double?> frtHours,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$ServiceItemsTableUpdateCompanionBuilder =
    ServiceItemsCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> assemblyId,
      Value<String?> refNo,
      Value<String> name,
      Value<double?> frtHours,
      Value<String?> note,
      Value<int> rowid,
    });

class $$ServiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assemblyId => $composableBuilder(
    column: $table.assemblyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refNo => $composableBuilder(
    column: $table.refNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get frtHours => $composableBuilder(
    column: $table.frtHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assemblyId => $composableBuilder(
    column: $table.assemblyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refNo => $composableBuilder(
    column: $table.refNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get frtHours => $composableBuilder(
    column: $table.frtHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceItemsTable> {
  $$ServiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assemblyId => $composableBuilder(
    column: $table.assemblyId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refNo =>
      $composableBuilder(column: $table.refNo, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get frtHours =>
      $composableBuilder(column: $table.frtHours, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$ServiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceItemsTable,
          ServiceItem,
          $$ServiceItemsTableFilterComposer,
          $$ServiceItemsTableOrderingComposer,
          $$ServiceItemsTableAnnotationComposer,
          $$ServiceItemsTableCreateCompanionBuilder,
          $$ServiceItemsTableUpdateCompanionBuilder,
          (
            ServiceItem,
            BaseReferences<_$AppDatabase, $ServiceItemsTable, ServiceItem>,
          ),
          ServiceItem,
          PrefetchHooks Function()
        > {
  $$ServiceItemsTableTableManager(_$AppDatabase db, $ServiceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> assemblyId = const Value.absent(),
                Value<String?> refNo = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> frtHours = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceItemsCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                assemblyId: assemblyId,
                refNo: refNo,
                name: name,
                frtHours: frtHours,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String assemblyId,
                Value<String?> refNo = const Value.absent(),
                required String name,
                Value<double?> frtHours = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceItemsCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                assemblyId: assemblyId,
                refNo: refNo,
                name: name,
                frtHours: frtHours,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceItemsTable,
      ServiceItem,
      $$ServiceItemsTableFilterComposer,
      $$ServiceItemsTableOrderingComposer,
      $$ServiceItemsTableAnnotationComposer,
      $$ServiceItemsTableCreateCompanionBuilder,
      $$ServiceItemsTableUpdateCompanionBuilder,
      (
        ServiceItem,
        BaseReferences<_$AppDatabase, $ServiceItemsTable, ServiceItem>,
      ),
      ServiceItem,
      PrefetchHooks Function()
    >;
typedef $$PartSubstitutesTableCreateCompanionBuilder =
    PartSubstitutesCompanion Function({
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String partId,
      required String substitutePartId,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$PartSubstitutesTableUpdateCompanionBuilder =
    PartSubstitutesCompanion Function({
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> partId,
      Value<String> substitutePartId,
      Value<String?> note,
      Value<int> rowid,
    });

class $$PartSubstitutesTableFilterComposer
    extends Composer<_$AppDatabase, $PartSubstitutesTable> {
  $$PartSubstitutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get substitutePartId => $composableBuilder(
    column: $table.substitutePartId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartSubstitutesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartSubstitutesTable> {
  $$PartSubstitutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partId => $composableBuilder(
    column: $table.partId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get substitutePartId => $composableBuilder(
    column: $table.substitutePartId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartSubstitutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartSubstitutesTable> {
  $$PartSubstitutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partId =>
      $composableBuilder(column: $table.partId, builder: (column) => column);

  GeneratedColumn<String> get substitutePartId => $composableBuilder(
    column: $table.substitutePartId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$PartSubstitutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartSubstitutesTable,
          PartSubstitute,
          $$PartSubstitutesTableFilterComposer,
          $$PartSubstitutesTableOrderingComposer,
          $$PartSubstitutesTableAnnotationComposer,
          $$PartSubstitutesTableCreateCompanionBuilder,
          $$PartSubstitutesTableUpdateCompanionBuilder,
          (
            PartSubstitute,
            BaseReferences<
              _$AppDatabase,
              $PartSubstitutesTable,
              PartSubstitute
            >,
          ),
          PartSubstitute,
          PrefetchHooks Function()
        > {
  $$PartSubstitutesTableTableManager(
    _$AppDatabase db,
    $PartSubstitutesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartSubstitutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartSubstitutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartSubstitutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> partId = const Value.absent(),
                Value<String> substitutePartId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartSubstitutesCompanion(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                partId: partId,
                substitutePartId: substitutePartId,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String partId,
                required String substitutePartId,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartSubstitutesCompanion.insert(
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                partId: partId,
                substitutePartId: substitutePartId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartSubstitutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartSubstitutesTable,
      PartSubstitute,
      $$PartSubstitutesTableFilterComposer,
      $$PartSubstitutesTableOrderingComposer,
      $$PartSubstitutesTableAnnotationComposer,
      $$PartSubstitutesTableCreateCompanionBuilder,
      $$PartSubstitutesTableUpdateCompanionBuilder,
      (
        PartSubstitute,
        BaseReferences<_$AppDatabase, $PartSubstitutesTable, PartSubstitute>,
      ),
      PartSubstitute,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<int> id,
      Value<String> cursor,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$SyncStatesTableUpdateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<int> id,
      Value<String> cursor,
      Value<DateTime?> lastSyncedAt,
    });

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
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

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
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

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncState,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>,
          ),
          SyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => SyncStatesCompanion(
                id: id,
                cursor: cursor,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cursor = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                id: id,
                cursor: cursor,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
      SyncState,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MachinesTableTableManager get machines =>
      $$MachinesTableTableManager(_db, _db.machines);
  $$MachineVariantsTableTableManager get machineVariants =>
      $$MachineVariantsTableTableManager(_db, _db.machineVariants);
  $$ColorsTableTableManager get colors =>
      $$ColorsTableTableManager(_db, _db.colors);
  $$AssembliesTableTableManager get assemblies =>
      $$AssembliesTableTableManager(_db, _db.assemblies);
  $$AssemblyItemsTableTableManager get assemblyItems =>
      $$AssemblyItemsTableTableManager(_db, _db.assemblyItems);
  $$ItemResolutionsTableTableManager get itemResolutions =>
      $$ItemResolutionsTableTableManager(_db, _db.itemResolutions);
  $$DotsTableTableManager get dots => $$DotsTableTableManager(_db, _db.dots);
  $$AssemblyLinksTableTableManager get assemblyLinks =>
      $$AssemblyLinksTableTableManager(_db, _db.assemblyLinks);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db, _db.parts);
  $$PartNumbersTableTableManager get partNumbers =>
      $$PartNumbersTableTableManager(_db, _db.partNumbers);
  $$PartColorVariantsTableTableManager get partColorVariants =>
      $$PartColorVariantsTableTableManager(_db, _db.partColorVariants);
  $$AliasesTableTableManager get aliases =>
      $$AliasesTableTableManager(_db, _db.aliases);
  $$ServiceItemsTableTableManager get serviceItems =>
      $$ServiceItemsTableTableManager(_db, _db.serviceItems);
  $$PartSubstitutesTableTableManager get partSubstitutes =>
      $$PartSubstitutesTableTableManager(_db, _db.partSubstitutes);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
