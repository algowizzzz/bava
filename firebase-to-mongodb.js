const admin = require('firebase-admin');
const { MongoClient } = require('mongodb');
const fs = require('fs');

// Initialize Firebase Admin SDK with your service account
// You'll need to download the service account key from Firebase console
const serviceAccount = require('./firebase-service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// MongoDB Atlas connection string
const mongoUri = 'mongodb+srv://sahme29:Gzt2AZw6NJqj95Dn@cluster0.k1x8c.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
const dbName = 'tassist'; // Name for your new MongoDB database

// Collections to migrate from Firestore
const collections = ['Teacher', 'students', 'classes', 'topics', 'chats', 'history'];

async function exportFirestoreData() {
  const db = admin.firestore();
  const exportData = {};
  
  console.log('Starting Firestore export...');
  
  for (const collection of collections) {
    console.log(`Exporting collection: ${collection}`);
    const snapshot = await db.collection(collection).get();
    
    exportData[collection] = [];
    
    snapshot.forEach(doc => {
      const data = doc.data();
      // Add document ID as a field
      data._id = doc.id;
      exportData[collection].push(data);
    });
    
    console.log(`Exported ${exportData[collection].length} documents from ${collection}`);
  }
  
  // Save the exported data to a JSON file
  fs.writeFileSync('./firestore-export.json', JSON.stringify(exportData, null, 2));
  console.log('Export completed and saved to firestore-export.json');
  
  return exportData;
}

async function importToMongoDB(data) {
  console.log('Starting MongoDB import...');
  
  const client = new MongoClient(mongoUri);
  
  try {
    await client.connect();
    console.log('Connected to MongoDB Atlas');
    
    const db = client.db(dbName);
    
    for (const collection of collections) {
      if (data[collection] && data[collection].length > 0) {
        console.log(`Importing collection: ${collection}`);
        
        // Drop existing collection if it exists
        try {
          await db.collection(collection).drop();
          console.log(`Dropped existing collection: ${collection}`);
        } catch (err) {
          // Collection might not exist, which is fine
        }
        
        // Insert the documents
        const result = await db.collection(collection).insertMany(data[collection]);
        console.log(`Imported ${result.insertedCount} documents into ${collection}`);
      }
    }
    
    console.log('Import to MongoDB Atlas completed successfully');
  } catch (err) {
    console.error('Error importing to MongoDB:', err);
  } finally {
    await client.close();
  }
}

async function migrateData() {
  try {
    const data = await exportFirestoreData();
    await importToMongoDB(data);
    console.log('Migration completed successfully');
  } catch (err) {
    console.error('Migration failed:', err);
  }
}

migrateData();
