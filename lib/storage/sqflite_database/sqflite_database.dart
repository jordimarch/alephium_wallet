import 'dart:async';

import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/models/contact_store.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:sqflite/sqflite.dart';

import '../models/address_store.dart';
import '../models/wallet_store.dart';

final String _walletTable = "wallets";
final String _transactionTable = "transactions";
final String _addressesTable = "addresses";
final String _balancesTable = "balances";
final String _contactsTable = "contacts";

class SQLiteDBHelper extends BaseDBHelper {
  @override
  Map<String, Map<String, List<TransactionStore>>> transactions = {
    ...Network.values.asMap().map((key, value) =>
        MapEntry(value.name, <String, List<TransactionStore>>{}))
  };

  SQLiteDBHelper() : super();

  late Completer<Database> _database;

  _dropTables(Database _db) async {
    final batch = _db.batch();
    // batch.execute('DROP TABLE IF EXISTS $_addressesTable');
    // batch.execute('DROP TABLE IF EXISTS $_transactionTable');
    // batch.execute('DROP TABLE IF EXISTS $_walletTable');
    // batch.execute('DROP TABLE IF EXISTS $_balancesTable');
    await batch.commit();
  }

  Future<void> _onConfigure(Database _db) async {
    await _dropTables(_db);
    await _db.execute("PRAGMA foreign_keys = ON");
    final batch = _db.batch();
    batch.execute("""
      CREATE TABLE IF NOT EXISTS $_walletTable (
          id TEXT PRIMARY KEY NOT NULL,
          title VARCHAR(20),
          passphrase VARCHAR(20),
          blockchain TEXT NOT NULL,
          mnemonic TEXT,
          seed TEXT,
          mainAddress TEXT NOT NULL
      )""");
    batch.execute("""
      CREATE TABLE IF NOT EXISTS $_transactionTable (
          id TEXT PRIMARY KEY NOT NULL,
          hash TEXT NOT NULL,
          txId VARCHAR(255),
          txAddress TEXT NOT NULL,
          walletId TEXT NOT NULL,
          blockHash TEXT,
          timeStamp INTEGER NOT NULL,
          gasAmount INTEGER,
          gasPrice TEXT,
          status VARCHAR(10) NOT NULL,
          network VARCHAR(10) NOT NULL,
          refsIn BLOB,
          refsOut BLOB,
          FOREIGN KEY(walletId) REFERENCES $_walletTable(id) ON DELETE CASCADE
      )""");
    batch.execute("""
      CREATE TABLE IF NOT EXISTS $_addressesTable (
          address TEXT PRIMARY KEY NOT NULL,
          addressTitle VARCHAR(20),
          addressColor VARCHAR(20),
          publicKey TEXT,
          privateKey TEXT,
          addressIndex INTEGER,
          addressGroup INTEGER,
          warning TEXT,
          walletId TEXT NOT NULL,
          FOREIGN KEY(walletId) REFERENCES $_walletTable(id) ON DELETE CASCADE
      )
      """);
    batch.execute("""
      CREATE TABLE IF NOT EXISTS $_balancesTable (
          balanceId TEXT PRIMARY KEY NOT NULL,
          balanceAddress TEXT NOT NULL,
          balance TEXT,
          balanceHint TEXT,
          balanceLocked TEXT,
          balanceLockedHint TEXT,
          network TEXT NOT NULL,
          tokens BLOB,
          FOREIGN KEY(balanceAddress) REFERENCES $_addressesTable(address) ON DELETE CASCADE
      )
      """);
    // batch.execute("""
    //   CREATE TABLE IF NOT EXISTS $_contactsTable (
    //       id TEXT PRIMARY KEY NOT NULL,
    //       firstName TEXT,
    //       lastName TEXT,
    //       addresses TEXT
    //   )
    //   """);
    await batch.commit();
  }

  Future<void> _onCreate(Database _db, int version) async {}

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute("""
          ALTER TABLE $_transactionTable
          ADD txID VARCHAR(255)
          """);
  }

  @override
  init() async {
    _database = Completer<Database>();
    var _db = await openDatabase(
      "db.db",
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade,
      version: 1,
    );
    _database.complete(_db);
  }

  @override
  Future<List<ContactStore>> getContacts() async {
    var _db = await _database.future;
    var data = await _db.query(_contactsTable);
    return data.map((contact) => ContactStore.fromDb(contact)).toList();
  }

  @override
  insertContact(ContactStore contactStore) async {
    var _db = await _database.future;
    await _db.insert(_contactsTable, contactStore.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  deleteContact(String id) async {
    var _db = await _database.future;
    await _db.delete(_contactsTable, where: "id = ?", whereArgs: [id]);
  }

  @override
  insertWallet(WalletStore wallet, AddressStore addressStore) async {
    var _db = await _database.future;
    var value = await _db.query(_addressesTable,
        where: "address = ?", whereArgs: [addressStore.address]);
    if (value.isNotEmpty) {
      throw Exception("address Already Exists");
    }
    var batch = _db.batch();
    batch.insert(_walletTable, wallet.toDb());
    batch.insert(_addressesTable, addressStore.toDb());
    await batch.commit();
  }

  @override
  Future<List<WalletStore>> getWallets({required Network network}) async {
    var _db = await _database.future;
    var data = await _db.rawQuery("""
        SELECT * FROM ${_walletTable} wallets
        LEFT JOIN ${_addressesTable} addresses
        ON wallets.id = addresses.walletId 
        LEFT JOIN ${_balancesTable} balances
        ON balances.balanceAddress = addresses.address
        AND balances.network = '${network.name}';
      """);
    return List<Map<String, dynamic>>.from(data)
        .combine()
        .map((e) => WalletStore.fromDb(e))
        .toList();
  }

  @override
  updateWalletName(
    String id,
    String title,
  ) async {
    var _db = await _database.future;
    await _db.update(
      _walletTable,
      {"title": title},
      where: "id = ?",
      whereArgs: [
        id,
      ],
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  updateWalletMainAddress(
    String id,
    String mainAddress,
  ) async {
    var _db = await _database.future;
    await _db.update(
      _walletTable,
      {"mainAddress": mainAddress},
      where: "id = ?",
      whereArgs: [
        id,
      ],
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  deleteWallet(String id) async {
    var _db = await _database.future;
    await _db.delete(
      _walletTable,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  @override
  insertAddress(List<AddressStore> addresses) async {
    var _db = await _database.future;
    var batch = _db.batch();
    for (var address in addresses)
      batch.insert(_addressesTable, address.toDb());
    await batch.commit();
  }

  @override
  updateAddressBalance(List<AddressStore> addresses) async {
    var _db = await _database.future;
    var batch = await _db.batch();
    for (var address in addresses)
      if (address.balance != null)
        batch.insert(
          _balancesTable,
          address.balance!.toDb(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
    batch.commit();
  }

  @override
  Future<void> insertTransactions(
    String walletId,
    List<TransactionStore> transactionStores,
  ) async {
    if (transactionStores.isEmpty) return;
    var _db = await _database.future;
    var batch = _db.batch();
    transactionStores.forEach((element) {
      batch.insert(
        _transactionTable,
        element.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  @override
  Future<List<TransactionStore>> getTransactions(
      String walletID, Network network) async {
    var _db = await _database.future;
    var data = await _db.rawQuery(
      '''SELECT * FROM $_transactionTable t 
           WHERE t.walletId = "${walletID}" AND t.network = "${network.name}"
           ORDER BY timeStamp DESC
        ''',
    );
    var transactions = data
        .combine("id", "refs")
        .map((e) => TransactionStore.fromDb(e))
        .toList();
    return transactions;
  }
}

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inPlace = true]) {
    final ids = Set();
    var list = inPlace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

extension Combine on List<Map<String, dynamic>> {
  List<Map<String, dynamic>> combine(
      [String compare = 'id', String whereReturns = 'addresses']) {
    List<Map<String, dynamic>> updated = [];
    for (var element in this) {
      if (updated.isEmpty || element[compare] != updated.last[compare]) {
        updated.add({...element});
        updated.last[whereReturns] = <Map<String, dynamic>>[];
      }
      updated.last[whereReturns].add(element);
    }
    return updated;
  }
}
