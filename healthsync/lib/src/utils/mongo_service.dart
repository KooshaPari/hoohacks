import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static const String MONGO_PASSWORD = 'testpw032925';
  static const String MONGO_URL = 'mongodb+srv://test_user:$MONGO_PASSWORD@health-data.mongodb.net/health-sync';
  static const String COLLECTION_NAME = 'user_data';

  late Db _db;
  late DbCollection _collection;

  MongoService();

  Future<void> connect() async {
    _db = await Db.create(MONGO_URL);
    await _db.open();
    _collection = _db.collection(COLLECTION_NAME);
    print("Connected to MongoDB");
  }

  Future<void> insertEntry(Map<String, dynamic> entryData) async {
    await _collection.insertOne(entryData);
    print("Entry saved to MongoDB");
  }

  Future<List<Map<String, dynamic>>> fetchEntries() async {
    return await _collection.find().toList();
  }

  Future<void> close() async {
    await _db.close();
    print("MongoDB connection closed");
  }
}