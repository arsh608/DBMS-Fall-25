// ============================================
// TASK 1: Create database and collection, insert three documents
// ============================================

use inventoryDB;

db.furniture.insertMany([
    {
        "name": "Chair",
        "color": "Brown",
        "material": "Wood",
        "price": 4999,
        "dimensions": [40, 40, 90],
        "inStock": true,
        "manufacturer": "FurnitureCo"
    },
    {
        "name": "Table",
        "color": "White",
        "material": "Glass",
        "price": 12999,
        "dimensions": [120, 60, 75],
        "inStock": true,
        "manufacturer": "ModernFurnish"
    },
    {
        "name": "Bookshelf",
        "color": "Brown",
        "material": "Wood",
        "price": 8999,
        "dimensions": [80, 30, 180],
        "inStock": false,
        "manufacturer": "WoodCraft"
    }
]);

print("Inserted 3 documents into furniture collection:");
db.furniture.find().pretty();

// ============================================
// TASK 2: Insert a single document using insertOne()
// ============================================

db.furniture.insertOne({
    "name": "Desk",
    "color": "Brown",
    "material": "Wood",
    "price": 15999,
    "dimensions": [50, 100, 75],
    "inStock": true,
    "manufacturer": "OfficePro"
});

print("Inserted Desk document. All documents:");
db.furniture.find().pretty();

// ============================================
// TASK 3: Find items where dimensions[0] > 30
// ============================================

db.furniture.insertOne({
    "name": "Side Table",
    "color": "Black",
    "dimensions": [25, 25, 45]
});

print("Furniture items with first dimension > 30:");
db.furniture.find(
    { "dimensions.0": { $gt: 30 } },
    { name: 1, dimensions: 1, _id: 0 }
).pretty();

// ============================================
// TASK 4: Retrieve documents with color="Brown" AND name is "Table" or "Chair"
// ============================================

db.furniture.insertOne({
    "name": "Table",
    "color": "Brown",
    "dimensions": [150, 80, 75]
});

print("Brown Table or Chair documents:");
db.furniture.find({
    $and: [
        { color: "Brown" },
        { name: { $in: ["Table", "Chair"] } }
    ]
}).pretty();

// ============================================
// TASK 5: Update color of ONE document where name="Table" to "Ivory"
// ============================================

print("Before update - Tables:");
db.furniture.find({ name: "Table" }, { name: 1, color: 1, _id: 0 }).pretty();

db.furniture.updateOne(
    { name: "Table" },
    { $set: { color: "Ivory" } }
);

print("After update - Tables:");
db.furniture.find({ name: "Table" }, { name: 1, color: 1, _id: 0 }).pretty();

// ============================================
// TASK 6: Update ALL furniture items where color="Brown" to "Dark Brown"
// ============================================

print("Before update - Brown items:");
db.furniture.find({ color: "Brown" }, { name: 1, color: 1, _id: 0 }).pretty();

db.furniture.updateMany(
    { color: "Brown" },
    { $set: { color: "Dark Brown" } }
);

print("After update - Formerly Brown items (now Dark Brown):");
db.furniture.find({ color: "Dark Brown" }, { name: 1, color: 1, _id: 0 }).pretty();

// ============================================
// TASK 7: Delete ONE document where name="Chair"
// ============================================

print("Before deletion - All Chairs:");
db.furniture.find({ name: "Chair" }, { name: 1, color: 1, _id: 0 }).pretty();

db.furniture.deleteOne({ name: "Chair" });

print("After deletion - Remaining Chairs:");
db.furniture.find({ name: "Chair" }, { name: 1, color: 1, _id: 0 }).pretty();

// ============================================
// TASK 8: Delete ALL items where dimensions exactly match [12, 18]
// ============================================

db.furniture.insertMany([
    {
        "name": "Small Shelf",
        "color": "White",
        "dimensions": [12, 18, 10]
    },
    {
        "name": "Mini Table",
        "color": "Black",
        "dimensions": [12, 18]
    }
]);

print("Before deletion - All documents:");
db.furniture.find({}, { name: 1, dimensions: 1, _id: 0 }).pretty();

db.furniture.deleteMany({ dimensions: [12, 18] });

print("After deletion - All documents:");
db.furniture.find({}, { name: 1, dimensions: 1, _id: 0 }).pretty();

// ============================================
// TASK 9: Group by color using aggregation pipeline
// ============================================

print("Furniture count by color:");
db.furniture.aggregate([
    {
        $group: {
            _id: "$color",
            count: { $sum: 1 },
            items: { $push: "$name" }
        }
    },
    {
        $sort: { count: -1 }
    }
]).pretty();

// ============================================
// TASK 10: Create text index and search for "table"
// ============================================

db.furniture.createIndex({ name: "text" });

db.furniture.insertMany([
    {
        "name": "Coffee Table",
        "color": "Black",
        "dimensions": [100, 50, 45]
    },
    {
        "name": "Dining Table",
        "color": "Mahogany",
        "dimensions": [200, 100, 75]
    },
    {
        "name": "Table Lamp",
        "color": "White",
        "dimensions": [15, 15, 40]
    }
]);

print("Searching for 'table' in name field:");
db.furniture.find(
    { $text: { $search: "table" } },
    { name: 1, color: 1, score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } }).pretty();


print("\n=== FINAL STATE OF FURNITURE COLLECTION ===");
print("Total documents in furniture collection: " + db.furniture.countDocuments());
print("\nAll furniture items:");
db.furniture.find({}, { name: 1, color: 1, dimensions: 1, _id: 0 }).sort({ name: 1 }).pretty();

print("\n=== COLLECTION STATISTICS ===");
print("Indexes on furniture collection:");
db.furniture.getIndexes();
