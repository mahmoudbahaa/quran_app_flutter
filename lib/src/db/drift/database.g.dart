// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VersesTable extends Verses with TableInfo<$VersesTable, Verse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 8),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  @override
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
      'juz', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hizbMeta = const VerificationMeta('hizb');
  @override
  late final GeneratedColumn<int> hizb = GeneratedColumn<int>(
      'hizb', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rubMeta = const VerificationMeta('rub');
  @override
  late final GeneratedColumn<int> rub = GeneratedColumn<int>(
      'rub', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, juz, hizb, rub];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verses';
  @override
  VerificationContext validateIntegrity(Insertable<Verse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('juz')) {
      context.handle(
          _juzMeta, juz.isAcceptableOrUnknown(data['juz']!, _juzMeta));
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    if (data.containsKey('hizb')) {
      context.handle(
          _hizbMeta, hizb.isAcceptableOrUnknown(data['hizb']!, _hizbMeta));
    } else if (isInserting) {
      context.missing(_hizbMeta);
    }
    if (data.containsKey('rub')) {
      context.handle(
          _rubMeta, rub.isAcceptableOrUnknown(data['rub']!, _rubMeta));
    } else if (isInserting) {
      context.missing(_rubMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Verse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Verse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      juz: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}juz'])!,
      hizb: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hizb'])!,
      rub: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rub'])!,
    );
  }

  @override
  $VersesTable createAlias(String alias) {
    return $VersesTable(attachedDatabase, alias);
  }
}

class Verse extends DataClass implements Insertable<Verse> {
  final String id;
  final int juz;
  final int hizb;
  final int rub;
  const Verse(
      {required this.id,
      required this.juz,
      required this.hizb,
      required this.rub});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['juz'] = Variable<int>(juz);
    map['hizb'] = Variable<int>(hizb);
    map['rub'] = Variable<int>(rub);
    return map;
  }

  VersesCompanion toCompanion(bool nullToAbsent) {
    return VersesCompanion(
      id: Value(id),
      juz: Value(juz),
      hizb: Value(hizb),
      rub: Value(rub),
    );
  }

  factory Verse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Verse(
      id: serializer.fromJson<String>(json['id']),
      juz: serializer.fromJson<int>(json['juz']),
      hizb: serializer.fromJson<int>(json['hizb']),
      rub: serializer.fromJson<int>(json['rub']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'juz': serializer.toJson<int>(juz),
      'hizb': serializer.toJson<int>(hizb),
      'rub': serializer.toJson<int>(rub),
    };
  }

  Verse copyWith({String? id, int? juz, int? hizb, int? rub}) => Verse(
        id: id ?? this.id,
        juz: juz ?? this.juz,
        hizb: hizb ?? this.hizb,
        rub: rub ?? this.rub,
      );
  Verse copyWithCompanion(VersesCompanion data) {
    return Verse(
      id: data.id.present ? data.id.value : this.id,
      juz: data.juz.present ? data.juz.value : this.juz,
      hizb: data.hizb.present ? data.hizb.value : this.hizb,
      rub: data.rub.present ? data.rub.value : this.rub,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Verse(')
          ..write('id: $id, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('rub: $rub')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, juz, hizb, rub);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Verse &&
          other.id == this.id &&
          other.juz == this.juz &&
          other.hizb == this.hizb &&
          other.rub == this.rub);
}

class VersesCompanion extends UpdateCompanion<Verse> {
  final Value<String> id;
  final Value<int> juz;
  final Value<int> hizb;
  final Value<int> rub;
  final Value<int> rowid;
  const VersesCompanion({
    this.id = const Value.absent(),
    this.juz = const Value.absent(),
    this.hizb = const Value.absent(),
    this.rub = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VersesCompanion.insert({
    required String id,
    required int juz,
    required int hizb,
    required int rub,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        juz = Value(juz),
        hizb = Value(hizb),
        rub = Value(rub);
  static Insertable<Verse> custom({
    Expression<String>? id,
    Expression<int>? juz,
    Expression<int>? hizb,
    Expression<int>? rub,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (juz != null) 'juz': juz,
      if (hizb != null) 'hizb': hizb,
      if (rub != null) 'rub': rub,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VersesCompanion copyWith(
      {Value<String>? id,
      Value<int>? juz,
      Value<int>? hizb,
      Value<int>? rub,
      Value<int>? rowid}) {
    return VersesCompanion(
      id: id ?? this.id,
      juz: juz ?? this.juz,
      hizb: hizb ?? this.hizb,
      rub: rub ?? this.rub,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (hizb.present) {
      map['hizb'] = Variable<int>(hizb.value);
    }
    if (rub.present) {
      map['rub'] = Variable<int>(rub.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersesCompanion(')
          ..write('id: $id, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('rub: $rub, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VerseInfosTable extends VerseInfos
    with TableInfo<$VerseInfosTable, VerseInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerseInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<String> verse = GeneratedColumn<String>(
      'verse', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES verses (id)'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<int> code = GeneratedColumn<int>(
      'code', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
      'page', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [verse, code, page];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verse_infos';
  @override
  VerificationContext validateIntegrity(Insertable<VerseInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('verse')) {
      context.handle(
          _verseMeta, verse.isAcceptableOrUnknown(data['verse']!, _verseMeta));
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
          _pageMeta, page.isAcceptableOrUnknown(data['page']!, _pageMeta));
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {verse, code};
  @override
  VerseInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseInfo(
      verse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verse'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}code'])!,
      page: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page'])!,
    );
  }

  @override
  $VerseInfosTable createAlias(String alias) {
    return $VerseInfosTable(attachedDatabase, alias);
  }
}

class VerseInfo extends DataClass implements Insertable<VerseInfo> {
  final String verse;
  final int code;
  final int page;
  const VerseInfo(
      {required this.verse, required this.code, required this.page});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['verse'] = Variable<String>(verse);
    map['code'] = Variable<int>(code);
    map['page'] = Variable<int>(page);
    return map;
  }

  VerseInfosCompanion toCompanion(bool nullToAbsent) {
    return VerseInfosCompanion(
      verse: Value(verse),
      code: Value(code),
      page: Value(page),
    );
  }

  factory VerseInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseInfo(
      verse: serializer.fromJson<String>(json['verse']),
      code: serializer.fromJson<int>(json['code']),
      page: serializer.fromJson<int>(json['page']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'verse': serializer.toJson<String>(verse),
      'code': serializer.toJson<int>(code),
      'page': serializer.toJson<int>(page),
    };
  }

  VerseInfo copyWith({String? verse, int? code, int? page}) => VerseInfo(
        verse: verse ?? this.verse,
        code: code ?? this.code,
        page: page ?? this.page,
      );
  VerseInfo copyWithCompanion(VerseInfosCompanion data) {
    return VerseInfo(
      verse: data.verse.present ? data.verse.value : this.verse,
      code: data.code.present ? data.code.value : this.code,
      page: data.page.present ? data.page.value : this.page,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseInfo(')
          ..write('verse: $verse, ')
          ..write('code: $code, ')
          ..write('page: $page')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(verse, code, page);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseInfo &&
          other.verse == this.verse &&
          other.code == this.code &&
          other.page == this.page);
}

class VerseInfosCompanion extends UpdateCompanion<VerseInfo> {
  final Value<String> verse;
  final Value<int> code;
  final Value<int> page;
  final Value<int> rowid;
  const VerseInfosCompanion({
    this.verse = const Value.absent(),
    this.code = const Value.absent(),
    this.page = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VerseInfosCompanion.insert({
    required String verse,
    required int code,
    required int page,
    this.rowid = const Value.absent(),
  })  : verse = Value(verse),
        code = Value(code),
        page = Value(page);
  static Insertable<VerseInfo> custom({
    Expression<String>? verse,
    Expression<int>? code,
    Expression<int>? page,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (verse != null) 'verse': verse,
      if (code != null) 'code': code,
      if (page != null) 'page': page,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VerseInfosCompanion copyWith(
      {Value<String>? verse,
      Value<int>? code,
      Value<int>? page,
      Value<int>? rowid}) {
    return VerseInfosCompanion(
      verse: verse ?? this.verse,
      code: code ?? this.code,
      page: page ?? this.page,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (verse.present) {
      map['verse'] = Variable<String>(verse.value);
    }
    if (code.present) {
      map['code'] = Variable<int>(code.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerseInfosCompanion(')
          ..write('verse: $verse, ')
          ..write('code: $code, ')
          ..write('page: $page, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<String> verse = GeneratedColumn<String>(
      'verse', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES verses (id)'));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _textUthmaniSimpleMeta =
      const VerificationMeta('textUthmaniSimple');
  @override
  late final GeneratedColumn<String> textUthmaniSimple =
      GeneratedColumn<String>('text_uthmani_simple', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textImlaeiMeta =
      const VerificationMeta('textImlaei');
  @override
  late final GeneratedColumn<String> textImlaei = GeneratedColumn<String>(
      'text_imlaei', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textImlaeiSimpleMeta =
      const VerificationMeta('textImlaeiSimple');
  @override
  late final GeneratedColumn<String> textImlaeiSimple = GeneratedColumn<String>(
      'text_imlaei_simple', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [verse, position, textUthmaniSimple, textImlaei, textImlaeiSimple];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(Insertable<Word> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('verse')) {
      context.handle(
          _verseMeta, verse.isAcceptableOrUnknown(data['verse']!, _verseMeta));
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('text_uthmani_simple')) {
      context.handle(
          _textUthmaniSimpleMeta,
          textUthmaniSimple.isAcceptableOrUnknown(
              data['text_uthmani_simple']!, _textUthmaniSimpleMeta));
    } else if (isInserting) {
      context.missing(_textUthmaniSimpleMeta);
    }
    if (data.containsKey('text_imlaei')) {
      context.handle(
          _textImlaeiMeta,
          textImlaei.isAcceptableOrUnknown(
              data['text_imlaei']!, _textImlaeiMeta));
    } else if (isInserting) {
      context.missing(_textImlaeiMeta);
    }
    if (data.containsKey('text_imlaei_simple')) {
      context.handle(
          _textImlaeiSimpleMeta,
          textImlaeiSimple.isAcceptableOrUnknown(
              data['text_imlaei_simple']!, _textImlaeiSimpleMeta));
    } else if (isInserting) {
      context.missing(_textImlaeiSimpleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {verse, position};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      verse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verse'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      textUthmaniSimple: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}text_uthmani_simple'])!,
      textImlaei: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_imlaei'])!,
      textImlaeiSimple: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}text_imlaei_simple'])!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final String verse;
  final int position;
  final String textUthmaniSimple;
  final String textImlaei;
  final String textImlaeiSimple;
  const Word(
      {required this.verse,
      required this.position,
      required this.textUthmaniSimple,
      required this.textImlaei,
      required this.textImlaeiSimple});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['verse'] = Variable<String>(verse);
    map['position'] = Variable<int>(position);
    map['text_uthmani_simple'] = Variable<String>(textUthmaniSimple);
    map['text_imlaei'] = Variable<String>(textImlaei);
    map['text_imlaei_simple'] = Variable<String>(textImlaeiSimple);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      verse: Value(verse),
      position: Value(position),
      textUthmaniSimple: Value(textUthmaniSimple),
      textImlaei: Value(textImlaei),
      textImlaeiSimple: Value(textImlaeiSimple),
    );
  }

  factory Word.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      verse: serializer.fromJson<String>(json['verse']),
      position: serializer.fromJson<int>(json['position']),
      textUthmaniSimple: serializer.fromJson<String>(json['textUthmaniSimple']),
      textImlaei: serializer.fromJson<String>(json['textImlaei']),
      textImlaeiSimple: serializer.fromJson<String>(json['textImlaeiSimple']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'verse': serializer.toJson<String>(verse),
      'position': serializer.toJson<int>(position),
      'textUthmaniSimple': serializer.toJson<String>(textUthmaniSimple),
      'textImlaei': serializer.toJson<String>(textImlaei),
      'textImlaeiSimple': serializer.toJson<String>(textImlaeiSimple),
    };
  }

  Word copyWith(
          {String? verse,
          int? position,
          String? textUthmaniSimple,
          String? textImlaei,
          String? textImlaeiSimple}) =>
      Word(
        verse: verse ?? this.verse,
        position: position ?? this.position,
        textUthmaniSimple: textUthmaniSimple ?? this.textUthmaniSimple,
        textImlaei: textImlaei ?? this.textImlaei,
        textImlaeiSimple: textImlaeiSimple ?? this.textImlaeiSimple,
      );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      verse: data.verse.present ? data.verse.value : this.verse,
      position: data.position.present ? data.position.value : this.position,
      textUthmaniSimple: data.textUthmaniSimple.present
          ? data.textUthmaniSimple.value
          : this.textUthmaniSimple,
      textImlaei:
          data.textImlaei.present ? data.textImlaei.value : this.textImlaei,
      textImlaeiSimple: data.textImlaeiSimple.present
          ? data.textImlaeiSimple.value
          : this.textImlaeiSimple,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('verse: $verse, ')
          ..write('position: $position, ')
          ..write('textUthmaniSimple: $textUthmaniSimple, ')
          ..write('textImlaei: $textImlaei, ')
          ..write('textImlaeiSimple: $textImlaeiSimple')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      verse, position, textUthmaniSimple, textImlaei, textImlaeiSimple);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.verse == this.verse &&
          other.position == this.position &&
          other.textUthmaniSimple == this.textUthmaniSimple &&
          other.textImlaei == this.textImlaei &&
          other.textImlaeiSimple == this.textImlaeiSimple);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<String> verse;
  final Value<int> position;
  final Value<String> textUthmaniSimple;
  final Value<String> textImlaei;
  final Value<String> textImlaeiSimple;
  final Value<int> rowid;
  const WordsCompanion({
    this.verse = const Value.absent(),
    this.position = const Value.absent(),
    this.textUthmaniSimple = const Value.absent(),
    this.textImlaei = const Value.absent(),
    this.textImlaeiSimple = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordsCompanion.insert({
    required String verse,
    required int position,
    required String textUthmaniSimple,
    required String textImlaei,
    required String textImlaeiSimple,
    this.rowid = const Value.absent(),
  })  : verse = Value(verse),
        position = Value(position),
        textUthmaniSimple = Value(textUthmaniSimple),
        textImlaei = Value(textImlaei),
        textImlaeiSimple = Value(textImlaeiSimple);
  static Insertable<Word> custom({
    Expression<String>? verse,
    Expression<int>? position,
    Expression<String>? textUthmaniSimple,
    Expression<String>? textImlaei,
    Expression<String>? textImlaeiSimple,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (verse != null) 'verse': verse,
      if (position != null) 'position': position,
      if (textUthmaniSimple != null) 'text_uthmani_simple': textUthmaniSimple,
      if (textImlaei != null) 'text_imlaei': textImlaei,
      if (textImlaeiSimple != null) 'text_imlaei_simple': textImlaeiSimple,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordsCompanion copyWith(
      {Value<String>? verse,
      Value<int>? position,
      Value<String>? textUthmaniSimple,
      Value<String>? textImlaei,
      Value<String>? textImlaeiSimple,
      Value<int>? rowid}) {
    return WordsCompanion(
      verse: verse ?? this.verse,
      position: position ?? this.position,
      textUthmaniSimple: textUthmaniSimple ?? this.textUthmaniSimple,
      textImlaei: textImlaei ?? this.textImlaei,
      textImlaeiSimple: textImlaeiSimple ?? this.textImlaeiSimple,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (verse.present) {
      map['verse'] = Variable<String>(verse.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (textUthmaniSimple.present) {
      map['text_uthmani_simple'] = Variable<String>(textUthmaniSimple.value);
    }
    if (textImlaei.present) {
      map['text_imlaei'] = Variable<String>(textImlaei.value);
    }
    if (textImlaeiSimple.present) {
      map['text_imlaei_simple'] = Variable<String>(textImlaeiSimple.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('verse: $verse, ')
          ..write('position: $position, ')
          ..write('textUthmaniSimple: $textUthmaniSimple, ')
          ..write('textImlaei: $textImlaei, ')
          ..write('textImlaeiSimple: $textImlaeiSimple, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordInfosTable extends WordInfos
    with TableInfo<$WordInfosTable, WordInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<String> verse = GeneratedColumn<String>(
      'verse', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _codeVersionMeta =
      const VerificationMeta('codeVersion');
  @override
  late final GeneratedColumn<int> codeVersion = GeneratedColumn<int>(
      'code_version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pageNumberMeta =
      const VerificationMeta('pageNumber');
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
      'page_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lineNumberMeta =
      const VerificationMeta('lineNumber');
  @override
  late final GeneratedColumn<int> lineNumber = GeneratedColumn<int>(
      'line_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [verse, position, codeVersion, code, pageNumber, lineNumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_infos';
  @override
  VerificationContext validateIntegrity(Insertable<WordInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('verse')) {
      context.handle(
          _verseMeta, verse.isAcceptableOrUnknown(data['verse']!, _verseMeta));
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('code_version')) {
      context.handle(
          _codeVersionMeta,
          codeVersion.isAcceptableOrUnknown(
              data['code_version']!, _codeVersionMeta));
    } else if (isInserting) {
      context.missing(_codeVersionMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
          _pageNumberMeta,
          pageNumber.isAcceptableOrUnknown(
              data['page_number']!, _pageNumberMeta));
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('line_number')) {
      context.handle(
          _lineNumberMeta,
          lineNumber.isAcceptableOrUnknown(
              data['line_number']!, _lineNumberMeta));
    } else if (isInserting) {
      context.missing(_lineNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {verse, position, codeVersion};
  @override
  WordInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordInfo(
      verse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verse'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      codeVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}code_version'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      pageNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_number'])!,
      lineNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_number'])!,
    );
  }

  @override
  $WordInfosTable createAlias(String alias) {
    return $WordInfosTable(attachedDatabase, alias);
  }
}

class WordInfo extends DataClass implements Insertable<WordInfo> {
  final String verse;
  final int position;
  final int codeVersion;
  final String code;
  final int pageNumber;
  final int lineNumber;
  const WordInfo(
      {required this.verse,
      required this.position,
      required this.codeVersion,
      required this.code,
      required this.pageNumber,
      required this.lineNumber});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['verse'] = Variable<String>(verse);
    map['position'] = Variable<int>(position);
    map['code_version'] = Variable<int>(codeVersion);
    map['code'] = Variable<String>(code);
    map['page_number'] = Variable<int>(pageNumber);
    map['line_number'] = Variable<int>(lineNumber);
    return map;
  }

  WordInfosCompanion toCompanion(bool nullToAbsent) {
    return WordInfosCompanion(
      verse: Value(verse),
      position: Value(position),
      codeVersion: Value(codeVersion),
      code: Value(code),
      pageNumber: Value(pageNumber),
      lineNumber: Value(lineNumber),
    );
  }

  factory WordInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordInfo(
      verse: serializer.fromJson<String>(json['verse']),
      position: serializer.fromJson<int>(json['position']),
      codeVersion: serializer.fromJson<int>(json['codeVersion']),
      code: serializer.fromJson<String>(json['code']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      lineNumber: serializer.fromJson<int>(json['lineNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'verse': serializer.toJson<String>(verse),
      'position': serializer.toJson<int>(position),
      'codeVersion': serializer.toJson<int>(codeVersion),
      'code': serializer.toJson<String>(code),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'lineNumber': serializer.toJson<int>(lineNumber),
    };
  }

  WordInfo copyWith(
          {String? verse,
          int? position,
          int? codeVersion,
          String? code,
          int? pageNumber,
          int? lineNumber}) =>
      WordInfo(
        verse: verse ?? this.verse,
        position: position ?? this.position,
        codeVersion: codeVersion ?? this.codeVersion,
        code: code ?? this.code,
        pageNumber: pageNumber ?? this.pageNumber,
        lineNumber: lineNumber ?? this.lineNumber,
      );
  WordInfo copyWithCompanion(WordInfosCompanion data) {
    return WordInfo(
      verse: data.verse.present ? data.verse.value : this.verse,
      position: data.position.present ? data.position.value : this.position,
      codeVersion:
          data.codeVersion.present ? data.codeVersion.value : this.codeVersion,
      code: data.code.present ? data.code.value : this.code,
      pageNumber:
          data.pageNumber.present ? data.pageNumber.value : this.pageNumber,
      lineNumber:
          data.lineNumber.present ? data.lineNumber.value : this.lineNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordInfo(')
          ..write('verse: $verse, ')
          ..write('position: $position, ')
          ..write('codeVersion: $codeVersion, ')
          ..write('code: $code, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('lineNumber: $lineNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(verse, position, codeVersion, code, pageNumber, lineNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordInfo &&
          other.verse == this.verse &&
          other.position == this.position &&
          other.codeVersion == this.codeVersion &&
          other.code == this.code &&
          other.pageNumber == this.pageNumber &&
          other.lineNumber == this.lineNumber);
}

class WordInfosCompanion extends UpdateCompanion<WordInfo> {
  final Value<String> verse;
  final Value<int> position;
  final Value<int> codeVersion;
  final Value<String> code;
  final Value<int> pageNumber;
  final Value<int> lineNumber;
  final Value<int> rowid;
  const WordInfosCompanion({
    this.verse = const Value.absent(),
    this.position = const Value.absent(),
    this.codeVersion = const Value.absent(),
    this.code = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.lineNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordInfosCompanion.insert({
    required String verse,
    required int position,
    required int codeVersion,
    required String code,
    required int pageNumber,
    required int lineNumber,
    this.rowid = const Value.absent(),
  })  : verse = Value(verse),
        position = Value(position),
        codeVersion = Value(codeVersion),
        code = Value(code),
        pageNumber = Value(pageNumber),
        lineNumber = Value(lineNumber);
  static Insertable<WordInfo> custom({
    Expression<String>? verse,
    Expression<int>? position,
    Expression<int>? codeVersion,
    Expression<String>? code,
    Expression<int>? pageNumber,
    Expression<int>? lineNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (verse != null) 'verse': verse,
      if (position != null) 'position': position,
      if (codeVersion != null) 'code_version': codeVersion,
      if (code != null) 'code': code,
      if (pageNumber != null) 'page_number': pageNumber,
      if (lineNumber != null) 'line_number': lineNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordInfosCompanion copyWith(
      {Value<String>? verse,
      Value<int>? position,
      Value<int>? codeVersion,
      Value<String>? code,
      Value<int>? pageNumber,
      Value<int>? lineNumber,
      Value<int>? rowid}) {
    return WordInfosCompanion(
      verse: verse ?? this.verse,
      position: position ?? this.position,
      codeVersion: codeVersion ?? this.codeVersion,
      code: code ?? this.code,
      pageNumber: pageNumber ?? this.pageNumber,
      lineNumber: lineNumber ?? this.lineNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (verse.present) {
      map['verse'] = Variable<String>(verse.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (codeVersion.present) {
      map['code_version'] = Variable<int>(codeVersion.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (lineNumber.present) {
      map['line_number'] = Variable<int>(lineNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordInfosCompanion(')
          ..write('verse: $verse, ')
          ..write('position: $position, ')
          ..write('codeVersion: $codeVersion, ')
          ..write('code: $code, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('lineNumber: $lineNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioFilesTable extends AudioFiles
    with TableInfo<$AudioFilesTable, AudioFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recitationMeta =
      const VerificationMeta('recitation');
  @override
  late final GeneratedColumn<int> recitation = GeneratedColumn<int>(
      'recitation', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _surahMeta = const VerificationMeta('surah');
  @override
  late final GeneratedColumn<int> surah = GeneratedColumn<int>(
      'surah', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<double> fileSize = GeneratedColumn<double>(
      'file_size', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<double> duration = GeneratedColumn<double>(
      'duration', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [recitation, surah, fileSize, duration, url];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_files';
  @override
  VerificationContext validateIntegrity(Insertable<AudioFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recitation')) {
      context.handle(
          _recitationMeta,
          recitation.isAcceptableOrUnknown(
              data['recitation']!, _recitationMeta));
    } else if (isInserting) {
      context.missing(_recitationMeta);
    }
    if (data.containsKey('surah')) {
      context.handle(
          _surahMeta, surah.isAcceptableOrUnknown(data['surah']!, _surahMeta));
    } else if (isInserting) {
      context.missing(_surahMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recitation, surah};
  @override
  AudioFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioFile(
      recitation: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recitation'])!,
      surah: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}file_size'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}duration'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
    );
  }

  @override
  $AudioFilesTable createAlias(String alias) {
    return $AudioFilesTable(attachedDatabase, alias);
  }
}

class AudioFile extends DataClass implements Insertable<AudioFile> {
  final int recitation;
  final int surah;
  final double fileSize;
  final double duration;
  final String url;
  const AudioFile(
      {required this.recitation,
      required this.surah,
      required this.fileSize,
      required this.duration,
      required this.url});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recitation'] = Variable<int>(recitation);
    map['surah'] = Variable<int>(surah);
    map['file_size'] = Variable<double>(fileSize);
    map['duration'] = Variable<double>(duration);
    map['url'] = Variable<String>(url);
    return map;
  }

  AudioFilesCompanion toCompanion(bool nullToAbsent) {
    return AudioFilesCompanion(
      recitation: Value(recitation),
      surah: Value(surah),
      fileSize: Value(fileSize),
      duration: Value(duration),
      url: Value(url),
    );
  }

  factory AudioFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioFile(
      recitation: serializer.fromJson<int>(json['recitation']),
      surah: serializer.fromJson<int>(json['surah']),
      fileSize: serializer.fromJson<double>(json['fileSize']),
      duration: serializer.fromJson<double>(json['duration']),
      url: serializer.fromJson<String>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recitation': serializer.toJson<int>(recitation),
      'surah': serializer.toJson<int>(surah),
      'fileSize': serializer.toJson<double>(fileSize),
      'duration': serializer.toJson<double>(duration),
      'url': serializer.toJson<String>(url),
    };
  }

  AudioFile copyWith(
          {int? recitation,
          int? surah,
          double? fileSize,
          double? duration,
          String? url}) =>
      AudioFile(
        recitation: recitation ?? this.recitation,
        surah: surah ?? this.surah,
        fileSize: fileSize ?? this.fileSize,
        duration: duration ?? this.duration,
        url: url ?? this.url,
      );
  AudioFile copyWithCompanion(AudioFilesCompanion data) {
    return AudioFile(
      recitation:
          data.recitation.present ? data.recitation.value : this.recitation,
      surah: data.surah.present ? data.surah.value : this.surah,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      duration: data.duration.present ? data.duration.value : this.duration,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioFile(')
          ..write('recitation: $recitation, ')
          ..write('surah: $surah, ')
          ..write('fileSize: $fileSize, ')
          ..write('duration: $duration, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(recitation, surah, fileSize, duration, url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioFile &&
          other.recitation == this.recitation &&
          other.surah == this.surah &&
          other.fileSize == this.fileSize &&
          other.duration == this.duration &&
          other.url == this.url);
}

class AudioFilesCompanion extends UpdateCompanion<AudioFile> {
  final Value<int> recitation;
  final Value<int> surah;
  final Value<double> fileSize;
  final Value<double> duration;
  final Value<String> url;
  final Value<int> rowid;
  const AudioFilesCompanion({
    this.recitation = const Value.absent(),
    this.surah = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.duration = const Value.absent(),
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioFilesCompanion.insert({
    required int recitation,
    required int surah,
    required double fileSize,
    required double duration,
    required String url,
    this.rowid = const Value.absent(),
  })  : recitation = Value(recitation),
        surah = Value(surah),
        fileSize = Value(fileSize),
        duration = Value(duration),
        url = Value(url);
  static Insertable<AudioFile> custom({
    Expression<int>? recitation,
    Expression<int>? surah,
    Expression<double>? fileSize,
    Expression<double>? duration,
    Expression<String>? url,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recitation != null) 'recitation': recitation,
      if (surah != null) 'surah': surah,
      if (fileSize != null) 'file_size': fileSize,
      if (duration != null) 'duration': duration,
      if (url != null) 'url': url,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioFilesCompanion copyWith(
      {Value<int>? recitation,
      Value<int>? surah,
      Value<double>? fileSize,
      Value<double>? duration,
      Value<String>? url,
      Value<int>? rowid}) {
    return AudioFilesCompanion(
      recitation: recitation ?? this.recitation,
      surah: surah ?? this.surah,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      url: url ?? this.url,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recitation.present) {
      map['recitation'] = Variable<int>(recitation.value);
    }
    if (surah.present) {
      map['surah'] = Variable<int>(surah.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<double>(fileSize.value);
    }
    if (duration.present) {
      map['duration'] = Variable<double>(duration.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioFilesCompanion(')
          ..write('recitation: $recitation, ')
          ..write('surah: $surah, ')
          ..write('fileSize: $fileSize, ')
          ..write('duration: $duration, ')
          ..write('url: $url, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VersesTimingsTable extends VersesTimings
    with TableInfo<$VersesTimingsTable, VerseTimings> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersesTimingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recitationMeta =
      const VerificationMeta('recitation');
  @override
  late final GeneratedColumn<int> recitation = GeneratedColumn<int>(
      'recitation', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _surahMeta = const VerificationMeta('surah');
  @override
  late final GeneratedColumn<int> surah = GeneratedColumn<int>(
      'surah', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<String> verse = GeneratedColumn<String>(
      'verse', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wordPositionMeta =
      const VerificationMeta('wordPosition');
  @override
  late final GeneratedColumn<int> wordPosition = GeneratedColumn<int>(
      'word_position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fromMeta = const VerificationMeta('from');
  @override
  late final GeneratedColumn<int> from = GeneratedColumn<int>(
      'from', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _toMeta = const VerificationMeta('to');
  @override
  late final GeneratedColumn<int> to = GeneratedColumn<int>(
      'to', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [recitation, surah, verse, wordPosition, from, to];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verses_timings';
  @override
  VerificationContext validateIntegrity(Insertable<VerseTimings> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recitation')) {
      context.handle(
          _recitationMeta,
          recitation.isAcceptableOrUnknown(
              data['recitation']!, _recitationMeta));
    } else if (isInserting) {
      context.missing(_recitationMeta);
    }
    if (data.containsKey('surah')) {
      context.handle(
          _surahMeta, surah.isAcceptableOrUnknown(data['surah']!, _surahMeta));
    } else if (isInserting) {
      context.missing(_surahMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
          _verseMeta, verse.isAcceptableOrUnknown(data['verse']!, _verseMeta));
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('word_position')) {
      context.handle(
          _wordPositionMeta,
          wordPosition.isAcceptableOrUnknown(
              data['word_position']!, _wordPositionMeta));
    } else if (isInserting) {
      context.missing(_wordPositionMeta);
    }
    if (data.containsKey('from')) {
      context.handle(
          _fromMeta, from.isAcceptableOrUnknown(data['from']!, _fromMeta));
    } else if (isInserting) {
      context.missing(_fromMeta);
    }
    if (data.containsKey('to')) {
      context.handle(_toMeta, to.isAcceptableOrUnknown(data['to']!, _toMeta));
    } else if (isInserting) {
      context.missing(_toMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  VerseTimings map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseTimings(
      recitation: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recitation'])!,
      surah: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah'])!,
      verse: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verse'])!,
      wordPosition: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_position'])!,
      from: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}from'])!,
      to: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}to'])!,
    );
  }

  @override
  $VersesTimingsTable createAlias(String alias) {
    return $VersesTimingsTable(attachedDatabase, alias);
  }
}

class VerseTimings extends DataClass implements Insertable<VerseTimings> {
  final int recitation;
  final int surah;
  final String verse;
  final int wordPosition;
  final int from;
  final int to;
  const VerseTimings(
      {required this.recitation,
      required this.surah,
      required this.verse,
      required this.wordPosition,
      required this.from,
      required this.to});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recitation'] = Variable<int>(recitation);
    map['surah'] = Variable<int>(surah);
    map['verse'] = Variable<String>(verse);
    map['word_position'] = Variable<int>(wordPosition);
    map['from'] = Variable<int>(from);
    map['to'] = Variable<int>(to);
    return map;
  }

  VersesTimingsCompanion toCompanion(bool nullToAbsent) {
    return VersesTimingsCompanion(
      recitation: Value(recitation),
      surah: Value(surah),
      verse: Value(verse),
      wordPosition: Value(wordPosition),
      from: Value(from),
      to: Value(to),
    );
  }

  factory VerseTimings.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseTimings(
      recitation: serializer.fromJson<int>(json['recitation']),
      surah: serializer.fromJson<int>(json['surah']),
      verse: serializer.fromJson<String>(json['verse']),
      wordPosition: serializer.fromJson<int>(json['wordPosition']),
      from: serializer.fromJson<int>(json['from']),
      to: serializer.fromJson<int>(json['to']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recitation': serializer.toJson<int>(recitation),
      'surah': serializer.toJson<int>(surah),
      'verse': serializer.toJson<String>(verse),
      'wordPosition': serializer.toJson<int>(wordPosition),
      'from': serializer.toJson<int>(from),
      'to': serializer.toJson<int>(to),
    };
  }

  VerseTimings copyWith(
          {int? recitation,
          int? surah,
          String? verse,
          int? wordPosition,
          int? from,
          int? to}) =>
      VerseTimings(
        recitation: recitation ?? this.recitation,
        surah: surah ?? this.surah,
        verse: verse ?? this.verse,
        wordPosition: wordPosition ?? this.wordPosition,
        from: from ?? this.from,
        to: to ?? this.to,
      );
  VerseTimings copyWithCompanion(VersesTimingsCompanion data) {
    return VerseTimings(
      recitation:
          data.recitation.present ? data.recitation.value : this.recitation,
      surah: data.surah.present ? data.surah.value : this.surah,
      verse: data.verse.present ? data.verse.value : this.verse,
      wordPosition: data.wordPosition.present
          ? data.wordPosition.value
          : this.wordPosition,
      from: data.from.present ? data.from.value : this.from,
      to: data.to.present ? data.to.value : this.to,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseTimings(')
          ..write('recitation: $recitation, ')
          ..write('surah: $surah, ')
          ..write('verse: $verse, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('from: $from, ')
          ..write('to: $to')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(recitation, surah, verse, wordPosition, from, to);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseTimings &&
          other.recitation == this.recitation &&
          other.surah == this.surah &&
          other.verse == this.verse &&
          other.wordPosition == this.wordPosition &&
          other.from == this.from &&
          other.to == this.to);
}

class VersesTimingsCompanion extends UpdateCompanion<VerseTimings> {
  final Value<int> recitation;
  final Value<int> surah;
  final Value<String> verse;
  final Value<int> wordPosition;
  final Value<int> from;
  final Value<int> to;
  final Value<int> rowid;
  const VersesTimingsCompanion({
    this.recitation = const Value.absent(),
    this.surah = const Value.absent(),
    this.verse = const Value.absent(),
    this.wordPosition = const Value.absent(),
    this.from = const Value.absent(),
    this.to = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VersesTimingsCompanion.insert({
    required int recitation,
    required int surah,
    required String verse,
    required int wordPosition,
    required int from,
    required int to,
    this.rowid = const Value.absent(),
  })  : recitation = Value(recitation),
        surah = Value(surah),
        verse = Value(verse),
        wordPosition = Value(wordPosition),
        from = Value(from),
        to = Value(to);
  static Insertable<VerseTimings> custom({
    Expression<int>? recitation,
    Expression<int>? surah,
    Expression<String>? verse,
    Expression<int>? wordPosition,
    Expression<int>? from,
    Expression<int>? to,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recitation != null) 'recitation': recitation,
      if (surah != null) 'surah': surah,
      if (verse != null) 'verse': verse,
      if (wordPosition != null) 'word_position': wordPosition,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VersesTimingsCompanion copyWith(
      {Value<int>? recitation,
      Value<int>? surah,
      Value<String>? verse,
      Value<int>? wordPosition,
      Value<int>? from,
      Value<int>? to,
      Value<int>? rowid}) {
    return VersesTimingsCompanion(
      recitation: recitation ?? this.recitation,
      surah: surah ?? this.surah,
      verse: verse ?? this.verse,
      wordPosition: wordPosition ?? this.wordPosition,
      from: from ?? this.from,
      to: to ?? this.to,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recitation.present) {
      map['recitation'] = Variable<int>(recitation.value);
    }
    if (surah.present) {
      map['surah'] = Variable<int>(surah.value);
    }
    if (verse.present) {
      map['verse'] = Variable<String>(verse.value);
    }
    if (wordPosition.present) {
      map['word_position'] = Variable<int>(wordPosition.value);
    }
    if (from.present) {
      map['from'] = Variable<int>(from.value);
    }
    if (to.present) {
      map['to'] = Variable<int>(to.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersesTimingsCompanion(')
          ..write('recitation: $recitation, ')
          ..write('surah: $surah, ')
          ..write('verse: $verse, ')
          ..write('wordPosition: $wordPosition, ')
          ..write('from: $from, ')
          ..write('to: $to, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FontFilesTable extends FontFiles
    with TableInfo<$FontFilesTable, FontFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FontFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<int> code = GeneratedColumn<int>(
      'code', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
      'page', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fontMeta = const VerificationMeta('font');
  @override
  late final GeneratedColumn<Uint8List> font = GeneratedColumn<Uint8List>(
      'font', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [code, page, font];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'font_files';
  @override
  VerificationContext validateIntegrity(Insertable<FontFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
          _pageMeta, page.isAcceptableOrUnknown(data['page']!, _pageMeta));
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('font')) {
      context.handle(
          _fontMeta, font.isAcceptableOrUnknown(data['font']!, _fontMeta));
    } else if (isInserting) {
      context.missing(_fontMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code, page};
  @override
  FontFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FontFile(
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}code'])!,
      page: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page'])!,
      font: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}font'])!,
    );
  }

  @override
  $FontFilesTable createAlias(String alias) {
    return $FontFilesTable(attachedDatabase, alias);
  }
}

class FontFile extends DataClass implements Insertable<FontFile> {
  final int code;
  final int page;
  final Uint8List font;
  const FontFile({required this.code, required this.page, required this.font});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<int>(code);
    map['page'] = Variable<int>(page);
    map['font'] = Variable<Uint8List>(font);
    return map;
  }

  FontFilesCompanion toCompanion(bool nullToAbsent) {
    return FontFilesCompanion(
      code: Value(code),
      page: Value(page),
      font: Value(font),
    );
  }

  factory FontFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FontFile(
      code: serializer.fromJson<int>(json['code']),
      page: serializer.fromJson<int>(json['page']),
      font: serializer.fromJson<Uint8List>(json['font']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<int>(code),
      'page': serializer.toJson<int>(page),
      'font': serializer.toJson<Uint8List>(font),
    };
  }

  FontFile copyWith({int? code, int? page, Uint8List? font}) => FontFile(
        code: code ?? this.code,
        page: page ?? this.page,
        font: font ?? this.font,
      );
  FontFile copyWithCompanion(FontFilesCompanion data) {
    return FontFile(
      code: data.code.present ? data.code.value : this.code,
      page: data.page.present ? data.page.value : this.page,
      font: data.font.present ? data.font.value : this.font,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FontFile(')
          ..write('code: $code, ')
          ..write('page: $page, ')
          ..write('font: $font')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, page, $driftBlobEquality.hash(font));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FontFile &&
          other.code == this.code &&
          other.page == this.page &&
          $driftBlobEquality.equals(other.font, this.font));
}

class FontFilesCompanion extends UpdateCompanion<FontFile> {
  final Value<int> code;
  final Value<int> page;
  final Value<Uint8List> font;
  final Value<int> rowid;
  const FontFilesCompanion({
    this.code = const Value.absent(),
    this.page = const Value.absent(),
    this.font = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FontFilesCompanion.insert({
    required int code,
    required int page,
    required Uint8List font,
    this.rowid = const Value.absent(),
  })  : code = Value(code),
        page = Value(page),
        font = Value(font);
  static Insertable<FontFile> custom({
    Expression<int>? code,
    Expression<int>? page,
    Expression<Uint8List>? font,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (page != null) 'page': page,
      if (font != null) 'font': font,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FontFilesCompanion copyWith(
      {Value<int>? code,
      Value<int>? page,
      Value<Uint8List>? font,
      Value<int>? rowid}) {
    return FontFilesCompanion(
      code: code ?? this.code,
      page: page ?? this.page,
      font: font ?? this.font,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<int>(code.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (font.present) {
      map['font'] = Variable<Uint8List>(font.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FontFilesCompanion(')
          ..write('code: $code, ')
          ..write('page: $page, ')
          ..write('font: $font, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VersesTable verses = $VersesTable(this);
  late final $VerseInfosTable verseInfos = $VerseInfosTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $WordInfosTable wordInfos = $WordInfosTable(this);
  late final $AudioFilesTable audioFiles = $AudioFilesTable(this);
  late final $VersesTimingsTable versesTimings = $VersesTimingsTable(this);
  late final $FontFilesTable fontFiles = $FontFilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        verses,
        verseInfos,
        words,
        wordInfos,
        audioFiles,
        versesTimings,
        fontFiles
      ];
}

typedef $$VersesTableCreateCompanionBuilder = VersesCompanion Function({
  required String id,
  required int juz,
  required int hizb,
  required int rub,
  Value<int> rowid,
});
typedef $$VersesTableUpdateCompanionBuilder = VersesCompanion Function({
  Value<String> id,
  Value<int> juz,
  Value<int> hizb,
  Value<int> rub,
  Value<int> rowid,
});

final class $$VersesTableReferences
    extends BaseReferences<_$AppDatabase, $VersesTable, Verse> {
  $$VersesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VerseInfosTable, List<VerseInfo>>
      _verseInfosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.verseInfos,
          aliasName: $_aliasNameGenerator(db.verses.id, db.verseInfos.verse));

  $$VerseInfosTableProcessedTableManager get verseInfosRefs {
    final manager = $$VerseInfosTableTableManager($_db, $_db.verseInfos)
        .filter((f) => f.verse.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_verseInfosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WordsTable, List<Word>> _wordsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.words,
          aliasName: $_aliasNameGenerator(db.verses.id, db.words.verse));

  $$WordsTableProcessedTableManager get wordsRefs {
    final manager = $$WordsTableTableManager($_db, $_db.words)
        .filter((f) => f.verse.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VersesTableFilterComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get juz => $composableBuilder(
      column: $table.juz, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hizb => $composableBuilder(
      column: $table.hizb, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rub => $composableBuilder(
      column: $table.rub, builder: (column) => ColumnFilters(column));

  Expression<bool> verseInfosRefs(
      Expression<bool> Function($$VerseInfosTableFilterComposer f) f) {
    final $$VerseInfosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.verseInfos,
        getReferencedColumn: (t) => t.verse,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VerseInfosTableFilterComposer(
              $db: $db,
              $table: $db.verseInfos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> wordsRefs(
      Expression<bool> Function($$WordsTableFilterComposer f) f) {
    final $$WordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.verse,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableFilterComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VersesTableOrderingComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get juz => $composableBuilder(
      column: $table.juz, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hizb => $composableBuilder(
      column: $table.hizb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rub => $composableBuilder(
      column: $table.rub, builder: (column) => ColumnOrderings(column));
}

class $$VersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<int> get hizb =>
      $composableBuilder(column: $table.hizb, builder: (column) => column);

  GeneratedColumn<int> get rub =>
      $composableBuilder(column: $table.rub, builder: (column) => column);

  Expression<T> verseInfosRefs<T extends Object>(
      Expression<T> Function($$VerseInfosTableAnnotationComposer a) f) {
    final $$VerseInfosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.verseInfos,
        getReferencedColumn: (t) => t.verse,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VerseInfosTableAnnotationComposer(
              $db: $db,
              $table: $db.verseInfos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> wordsRefs<T extends Object>(
      Expression<T> Function($$WordsTableAnnotationComposer a) f) {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.verse,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableAnnotationComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VersesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VersesTable,
    Verse,
    $$VersesTableFilterComposer,
    $$VersesTableOrderingComposer,
    $$VersesTableAnnotationComposer,
    $$VersesTableCreateCompanionBuilder,
    $$VersesTableUpdateCompanionBuilder,
    (Verse, $$VersesTableReferences),
    Verse,
    PrefetchHooks Function({bool verseInfosRefs, bool wordsRefs})> {
  $$VersesTableTableManager(_$AppDatabase db, $VersesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> juz = const Value.absent(),
            Value<int> hizb = const Value.absent(),
            Value<int> rub = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VersesCompanion(
            id: id,
            juz: juz,
            hizb: hizb,
            rub: rub,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int juz,
            required int hizb,
            required int rub,
            Value<int> rowid = const Value.absent(),
          }) =>
              VersesCompanion.insert(
            id: id,
            juz: juz,
            hizb: hizb,
            rub: rub,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VersesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({verseInfosRefs = false, wordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (verseInfosRefs) db.verseInfos,
                if (wordsRefs) db.words
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (verseInfosRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$VersesTableReferences._verseInfosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VersesTableReferences(db, table, p0)
                                .verseInfosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.verse == item.id),
                        typedResults: items),
                  if (wordsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$VersesTableReferences._wordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VersesTableReferences(db, table, p0).wordsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.verse == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VersesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VersesTable,
    Verse,
    $$VersesTableFilterComposer,
    $$VersesTableOrderingComposer,
    $$VersesTableAnnotationComposer,
    $$VersesTableCreateCompanionBuilder,
    $$VersesTableUpdateCompanionBuilder,
    (Verse, $$VersesTableReferences),
    Verse,
    PrefetchHooks Function({bool verseInfosRefs, bool wordsRefs})>;
typedef $$VerseInfosTableCreateCompanionBuilder = VerseInfosCompanion Function({
  required String verse,
  required int code,
  required int page,
  Value<int> rowid,
});
typedef $$VerseInfosTableUpdateCompanionBuilder = VerseInfosCompanion Function({
  Value<String> verse,
  Value<int> code,
  Value<int> page,
  Value<int> rowid,
});

final class $$VerseInfosTableReferences
    extends BaseReferences<_$AppDatabase, $VerseInfosTable, VerseInfo> {
  $$VerseInfosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VersesTable _verseTable(_$AppDatabase db) => db.verses
      .createAlias($_aliasNameGenerator(db.verseInfos.verse, db.verses.id));

  $$VersesTableProcessedTableManager get verse {
    final $_column = $_itemColumn<String>('verse')!;

    final manager = $$VersesTableTableManager($_db, $_db.verses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_verseTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VerseInfosTableFilterComposer
    extends Composer<_$AppDatabase, $VerseInfosTable> {
  $$VerseInfosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get page => $composableBuilder(
      column: $table.page, builder: (column) => ColumnFilters(column));

  $$VersesTableFilterComposer get verse {
    final $$VersesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.verse,
        referencedTable: $db.verses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VersesTableFilterComposer(
              $db: $db,
              $table: $db.verses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VerseInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $VerseInfosTable> {
  $$VerseInfosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get page => $composableBuilder(
      column: $table.page, builder: (column) => ColumnOrderings(column));

  $$VersesTableOrderingComposer get verse {
    final $$VersesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.verse,
        referencedTable: $db.verses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VersesTableOrderingComposer(
              $db: $db,
              $table: $db.verses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VerseInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VerseInfosTable> {
  $$VerseInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  $$VersesTableAnnotationComposer get verse {
    final $$VersesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.verse,
        referencedTable: $db.verses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VersesTableAnnotationComposer(
              $db: $db,
              $table: $db.verses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VerseInfosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VerseInfosTable,
    VerseInfo,
    $$VerseInfosTableFilterComposer,
    $$VerseInfosTableOrderingComposer,
    $$VerseInfosTableAnnotationComposer,
    $$VerseInfosTableCreateCompanionBuilder,
    $$VerseInfosTableUpdateCompanionBuilder,
    (VerseInfo, $$VerseInfosTableReferences),
    VerseInfo,
    PrefetchHooks Function({bool verse})> {
  $$VerseInfosTableTableManager(_$AppDatabase db, $VerseInfosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerseInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VerseInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerseInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> verse = const Value.absent(),
            Value<int> code = const Value.absent(),
            Value<int> page = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VerseInfosCompanion(
            verse: verse,
            code: code,
            page: page,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String verse,
            required int code,
            required int page,
            Value<int> rowid = const Value.absent(),
          }) =>
              VerseInfosCompanion.insert(
            verse: verse,
            code: code,
            page: page,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VerseInfosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({verse = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (verse) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.verse,
                    referencedTable:
                        $$VerseInfosTableReferences._verseTable(db),
                    referencedColumn:
                        $$VerseInfosTableReferences._verseTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VerseInfosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VerseInfosTable,
    VerseInfo,
    $$VerseInfosTableFilterComposer,
    $$VerseInfosTableOrderingComposer,
    $$VerseInfosTableAnnotationComposer,
    $$VerseInfosTableCreateCompanionBuilder,
    $$VerseInfosTableUpdateCompanionBuilder,
    (VerseInfo, $$VerseInfosTableReferences),
    VerseInfo,
    PrefetchHooks Function({bool verse})>;
typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  required String verse,
  required int position,
  required String textUthmaniSimple,
  required String textImlaei,
  required String textImlaeiSimple,
  Value<int> rowid,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<String> verse,
  Value<int> position,
  Value<String> textUthmaniSimple,
  Value<String> textImlaei,
  Value<String> textImlaeiSimple,
  Value<int> rowid,
});

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VersesTable _verseTable(_$AppDatabase db) =>
      db.verses.createAlias($_aliasNameGenerator(db.words.verse, db.verses.id));

  $$VersesTableProcessedTableManager get verse {
    final $_column = $_itemColumn<String>('verse')!;

    final manager = $$VersesTableTableManager($_db, $_db.verses)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_verseTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textUthmaniSimple => $composableBuilder(
      column: $table.textUthmaniSimple,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textImlaei => $composableBuilder(
      column: $table.textImlaei, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textImlaeiSimple => $composableBuilder(
      column: $table.textImlaeiSimple,
      builder: (column) => ColumnFilters(column));

  $$VersesTableFilterComposer get verse {
    final $$VersesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.verse,
        referencedTable: $db.verses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VersesTableFilterComposer(
              $db: $db,
              $table: $db.verses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textUthmaniSimple => $composableBuilder(
      column: $table.textUthmaniSimple,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textImlaei => $composableBuilder(
      column: $table.textImlaei, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textImlaeiSimple => $composableBuilder(
      column: $table.textImlaeiSimple,
      builder: (column) => ColumnOrderings(column));

  $$VersesTableOrderingComposer get verse {
    final $$VersesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.verse,
        referencedTable: $db.verses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VersesTableOrderingComposer(
              $db: $db,
              $table: $db.verses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get textUthmaniSimple => $composableBuilder(
      column: $table.textUthmaniSimple, builder: (column) => column);

  GeneratedColumn<String> get textImlaei => $composableBuilder(
      column: $table.textImlaei, builder: (column) => column);

  GeneratedColumn<String> get textImlaeiSimple => $composableBuilder(
      column: $table.textImlaeiSimple, builder: (column) => column);

  $$VersesTableAnnotationComposer get verse {
    final $$VersesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.verse,
        referencedTable: $db.verses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VersesTableAnnotationComposer(
              $db: $db,
              $table: $db.verses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordsTable,
    Word,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (Word, $$WordsTableReferences),
    Word,
    PrefetchHooks Function({bool verse})> {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> verse = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<String> textUthmaniSimple = const Value.absent(),
            Value<String> textImlaei = const Value.absent(),
            Value<String> textImlaeiSimple = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WordsCompanion(
            verse: verse,
            position: position,
            textUthmaniSimple: textUthmaniSimple,
            textImlaei: textImlaei,
            textImlaeiSimple: textImlaeiSimple,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String verse,
            required int position,
            required String textUthmaniSimple,
            required String textImlaei,
            required String textImlaeiSimple,
            Value<int> rowid = const Value.absent(),
          }) =>
              WordsCompanion.insert(
            verse: verse,
            position: position,
            textUthmaniSimple: textUthmaniSimple,
            textImlaei: textImlaei,
            textImlaeiSimple: textImlaeiSimple,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WordsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({verse = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (verse) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.verse,
                    referencedTable: $$WordsTableReferences._verseTable(db),
                    referencedColumn: $$WordsTableReferences._verseTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordsTable,
    Word,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (Word, $$WordsTableReferences),
    Word,
    PrefetchHooks Function({bool verse})>;
typedef $$WordInfosTableCreateCompanionBuilder = WordInfosCompanion Function({
  required String verse,
  required int position,
  required int codeVersion,
  required String code,
  required int pageNumber,
  required int lineNumber,
  Value<int> rowid,
});
typedef $$WordInfosTableUpdateCompanionBuilder = WordInfosCompanion Function({
  Value<String> verse,
  Value<int> position,
  Value<int> codeVersion,
  Value<String> code,
  Value<int> pageNumber,
  Value<int> lineNumber,
  Value<int> rowid,
});

class $$WordInfosTableFilterComposer
    extends Composer<_$AppDatabase, $WordInfosTable> {
  $$WordInfosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get verse => $composableBuilder(
      column: $table.verse, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get codeVersion => $composableBuilder(
      column: $table.codeVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineNumber => $composableBuilder(
      column: $table.lineNumber, builder: (column) => ColumnFilters(column));
}

class $$WordInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $WordInfosTable> {
  $$WordInfosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get verse => $composableBuilder(
      column: $table.verse, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get codeVersion => $composableBuilder(
      column: $table.codeVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineNumber => $composableBuilder(
      column: $table.lineNumber, builder: (column) => ColumnOrderings(column));
}

class $$WordInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordInfosTable> {
  $$WordInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get codeVersion => $composableBuilder(
      column: $table.codeVersion, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
      column: $table.pageNumber, builder: (column) => column);

  GeneratedColumn<int> get lineNumber => $composableBuilder(
      column: $table.lineNumber, builder: (column) => column);
}

class $$WordInfosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordInfosTable,
    WordInfo,
    $$WordInfosTableFilterComposer,
    $$WordInfosTableOrderingComposer,
    $$WordInfosTableAnnotationComposer,
    $$WordInfosTableCreateCompanionBuilder,
    $$WordInfosTableUpdateCompanionBuilder,
    (WordInfo, BaseReferences<_$AppDatabase, $WordInfosTable, WordInfo>),
    WordInfo,
    PrefetchHooks Function()> {
  $$WordInfosTableTableManager(_$AppDatabase db, $WordInfosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> verse = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> codeVersion = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<int> pageNumber = const Value.absent(),
            Value<int> lineNumber = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WordInfosCompanion(
            verse: verse,
            position: position,
            codeVersion: codeVersion,
            code: code,
            pageNumber: pageNumber,
            lineNumber: lineNumber,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String verse,
            required int position,
            required int codeVersion,
            required String code,
            required int pageNumber,
            required int lineNumber,
            Value<int> rowid = const Value.absent(),
          }) =>
              WordInfosCompanion.insert(
            verse: verse,
            position: position,
            codeVersion: codeVersion,
            code: code,
            pageNumber: pageNumber,
            lineNumber: lineNumber,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WordInfosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordInfosTable,
    WordInfo,
    $$WordInfosTableFilterComposer,
    $$WordInfosTableOrderingComposer,
    $$WordInfosTableAnnotationComposer,
    $$WordInfosTableCreateCompanionBuilder,
    $$WordInfosTableUpdateCompanionBuilder,
    (WordInfo, BaseReferences<_$AppDatabase, $WordInfosTable, WordInfo>),
    WordInfo,
    PrefetchHooks Function()>;
typedef $$AudioFilesTableCreateCompanionBuilder = AudioFilesCompanion Function({
  required int recitation,
  required int surah,
  required double fileSize,
  required double duration,
  required String url,
  Value<int> rowid,
});
typedef $$AudioFilesTableUpdateCompanionBuilder = AudioFilesCompanion Function({
  Value<int> recitation,
  Value<int> surah,
  Value<double> fileSize,
  Value<double> duration,
  Value<String> url,
  Value<int> rowid,
});

class $$AudioFilesTableFilterComposer
    extends Composer<_$AppDatabase, $AudioFilesTable> {
  $$AudioFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get recitation => $composableBuilder(
      column: $table.recitation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get surah => $composableBuilder(
      column: $table.surah, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));
}

class $$AudioFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioFilesTable> {
  $$AudioFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get recitation => $composableBuilder(
      column: $table.recitation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get surah => $composableBuilder(
      column: $table.surah, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));
}

class $$AudioFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioFilesTable> {
  $$AudioFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get recitation => $composableBuilder(
      column: $table.recitation, builder: (column) => column);

  GeneratedColumn<int> get surah =>
      $composableBuilder(column: $table.surah, builder: (column) => column);

  GeneratedColumn<double> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<double> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);
}

class $$AudioFilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AudioFilesTable,
    AudioFile,
    $$AudioFilesTableFilterComposer,
    $$AudioFilesTableOrderingComposer,
    $$AudioFilesTableAnnotationComposer,
    $$AudioFilesTableCreateCompanionBuilder,
    $$AudioFilesTableUpdateCompanionBuilder,
    (AudioFile, BaseReferences<_$AppDatabase, $AudioFilesTable, AudioFile>),
    AudioFile,
    PrefetchHooks Function()> {
  $$AudioFilesTableTableManager(_$AppDatabase db, $AudioFilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> recitation = const Value.absent(),
            Value<int> surah = const Value.absent(),
            Value<double> fileSize = const Value.absent(),
            Value<double> duration = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AudioFilesCompanion(
            recitation: recitation,
            surah: surah,
            fileSize: fileSize,
            duration: duration,
            url: url,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int recitation,
            required int surah,
            required double fileSize,
            required double duration,
            required String url,
            Value<int> rowid = const Value.absent(),
          }) =>
              AudioFilesCompanion.insert(
            recitation: recitation,
            surah: surah,
            fileSize: fileSize,
            duration: duration,
            url: url,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AudioFilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AudioFilesTable,
    AudioFile,
    $$AudioFilesTableFilterComposer,
    $$AudioFilesTableOrderingComposer,
    $$AudioFilesTableAnnotationComposer,
    $$AudioFilesTableCreateCompanionBuilder,
    $$AudioFilesTableUpdateCompanionBuilder,
    (AudioFile, BaseReferences<_$AppDatabase, $AudioFilesTable, AudioFile>),
    AudioFile,
    PrefetchHooks Function()>;
typedef $$VersesTimingsTableCreateCompanionBuilder = VersesTimingsCompanion
    Function({
  required int recitation,
  required int surah,
  required String verse,
  required int wordPosition,
  required int from,
  required int to,
  Value<int> rowid,
});
typedef $$VersesTimingsTableUpdateCompanionBuilder = VersesTimingsCompanion
    Function({
  Value<int> recitation,
  Value<int> surah,
  Value<String> verse,
  Value<int> wordPosition,
  Value<int> from,
  Value<int> to,
  Value<int> rowid,
});

class $$VersesTimingsTableFilterComposer
    extends Composer<_$AppDatabase, $VersesTimingsTable> {
  $$VersesTimingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get recitation => $composableBuilder(
      column: $table.recitation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get surah => $composableBuilder(
      column: $table.surah, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verse => $composableBuilder(
      column: $table.verse, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordPosition => $composableBuilder(
      column: $table.wordPosition, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get from => $composableBuilder(
      column: $table.from, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get to => $composableBuilder(
      column: $table.to, builder: (column) => ColumnFilters(column));
}

class $$VersesTimingsTableOrderingComposer
    extends Composer<_$AppDatabase, $VersesTimingsTable> {
  $$VersesTimingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get recitation => $composableBuilder(
      column: $table.recitation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get surah => $composableBuilder(
      column: $table.surah, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verse => $composableBuilder(
      column: $table.verse, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordPosition => $composableBuilder(
      column: $table.wordPosition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get from => $composableBuilder(
      column: $table.from, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get to => $composableBuilder(
      column: $table.to, builder: (column) => ColumnOrderings(column));
}

class $$VersesTimingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersesTimingsTable> {
  $$VersesTimingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get recitation => $composableBuilder(
      column: $table.recitation, builder: (column) => column);

  GeneratedColumn<int> get surah =>
      $composableBuilder(column: $table.surah, builder: (column) => column);

  GeneratedColumn<String> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<int> get wordPosition => $composableBuilder(
      column: $table.wordPosition, builder: (column) => column);

  GeneratedColumn<int> get from =>
      $composableBuilder(column: $table.from, builder: (column) => column);

  GeneratedColumn<int> get to =>
      $composableBuilder(column: $table.to, builder: (column) => column);
}

class $$VersesTimingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VersesTimingsTable,
    VerseTimings,
    $$VersesTimingsTableFilterComposer,
    $$VersesTimingsTableOrderingComposer,
    $$VersesTimingsTableAnnotationComposer,
    $$VersesTimingsTableCreateCompanionBuilder,
    $$VersesTimingsTableUpdateCompanionBuilder,
    (
      VerseTimings,
      BaseReferences<_$AppDatabase, $VersesTimingsTable, VerseTimings>
    ),
    VerseTimings,
    PrefetchHooks Function()> {
  $$VersesTimingsTableTableManager(_$AppDatabase db, $VersesTimingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersesTimingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersesTimingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersesTimingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> recitation = const Value.absent(),
            Value<int> surah = const Value.absent(),
            Value<String> verse = const Value.absent(),
            Value<int> wordPosition = const Value.absent(),
            Value<int> from = const Value.absent(),
            Value<int> to = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VersesTimingsCompanion(
            recitation: recitation,
            surah: surah,
            verse: verse,
            wordPosition: wordPosition,
            from: from,
            to: to,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int recitation,
            required int surah,
            required String verse,
            required int wordPosition,
            required int from,
            required int to,
            Value<int> rowid = const Value.absent(),
          }) =>
              VersesTimingsCompanion.insert(
            recitation: recitation,
            surah: surah,
            verse: verse,
            wordPosition: wordPosition,
            from: from,
            to: to,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VersesTimingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VersesTimingsTable,
    VerseTimings,
    $$VersesTimingsTableFilterComposer,
    $$VersesTimingsTableOrderingComposer,
    $$VersesTimingsTableAnnotationComposer,
    $$VersesTimingsTableCreateCompanionBuilder,
    $$VersesTimingsTableUpdateCompanionBuilder,
    (
      VerseTimings,
      BaseReferences<_$AppDatabase, $VersesTimingsTable, VerseTimings>
    ),
    VerseTimings,
    PrefetchHooks Function()>;
typedef $$FontFilesTableCreateCompanionBuilder = FontFilesCompanion Function({
  required int code,
  required int page,
  required Uint8List font,
  Value<int> rowid,
});
typedef $$FontFilesTableUpdateCompanionBuilder = FontFilesCompanion Function({
  Value<int> code,
  Value<int> page,
  Value<Uint8List> font,
  Value<int> rowid,
});

class $$FontFilesTableFilterComposer
    extends Composer<_$AppDatabase, $FontFilesTable> {
  $$FontFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get page => $composableBuilder(
      column: $table.page, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get font => $composableBuilder(
      column: $table.font, builder: (column) => ColumnFilters(column));
}

class $$FontFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $FontFilesTable> {
  $$FontFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get page => $composableBuilder(
      column: $table.page, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get font => $composableBuilder(
      column: $table.font, builder: (column) => ColumnOrderings(column));
}

class $$FontFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FontFilesTable> {
  $$FontFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<Uint8List> get font =>
      $composableBuilder(column: $table.font, builder: (column) => column);
}

class $$FontFilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FontFilesTable,
    FontFile,
    $$FontFilesTableFilterComposer,
    $$FontFilesTableOrderingComposer,
    $$FontFilesTableAnnotationComposer,
    $$FontFilesTableCreateCompanionBuilder,
    $$FontFilesTableUpdateCompanionBuilder,
    (FontFile, BaseReferences<_$AppDatabase, $FontFilesTable, FontFile>),
    FontFile,
    PrefetchHooks Function()> {
  $$FontFilesTableTableManager(_$AppDatabase db, $FontFilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FontFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FontFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FontFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> code = const Value.absent(),
            Value<int> page = const Value.absent(),
            Value<Uint8List> font = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FontFilesCompanion(
            code: code,
            page: page,
            font: font,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int code,
            required int page,
            required Uint8List font,
            Value<int> rowid = const Value.absent(),
          }) =>
              FontFilesCompanion.insert(
            code: code,
            page: page,
            font: font,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FontFilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FontFilesTable,
    FontFile,
    $$FontFilesTableFilterComposer,
    $$FontFilesTableOrderingComposer,
    $$FontFilesTableAnnotationComposer,
    $$FontFilesTableCreateCompanionBuilder,
    $$FontFilesTableUpdateCompanionBuilder,
    (FontFile, BaseReferences<_$AppDatabase, $FontFilesTable, FontFile>),
    FontFile,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db, _db.verses);
  $$VerseInfosTableTableManager get verseInfos =>
      $$VerseInfosTableTableManager(_db, _db.verseInfos);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$WordInfosTableTableManager get wordInfos =>
      $$WordInfosTableTableManager(_db, _db.wordInfos);
  $$AudioFilesTableTableManager get audioFiles =>
      $$AudioFilesTableTableManager(_db, _db.audioFiles);
  $$VersesTimingsTableTableManager get versesTimings =>
      $$VersesTimingsTableTableManager(_db, _db.versesTimings);
  $$FontFilesTableTableManager get fontFiles =>
      $$FontFilesTableTableManager(_db, _db.fontFiles);
}
