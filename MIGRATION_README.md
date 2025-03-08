# Firebase to MongoDB Migration Guide

This guide will help you migrate your Firebase Firestore database to MongoDB Atlas.

## Prerequisites

1. Node.js installed on your machine
2. Firebase service account key
3. MongoDB Atlas account and connection string

## Step 1: Get Firebase Service Account Key

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project (chatbot-bbf51)
3. Go to Project Settings > Service accounts
4. Click "Generate new private key"
5. Save the JSON file as `firebase-service-account.json` in this directory

## Step 2: Install Dependencies

Run the following command in this directory:

```bash
npm install
```

## Step 3: Run the Migration Script

```bash
npm run migrate
```

This will:
1. Export all data from your Firebase Firestore collections
2. Save a backup to `firestore-export.json`
3. Import the data into your MongoDB Atlas database

## Step 4: Update Your Flutter Application

After migrating the data, you'll need to update your Flutter application to use MongoDB instead of Firebase. See the `flutter-mongodb-integration.md` file for instructions on how to do this.

## Security Note

The migration script contains your MongoDB Atlas connection string with credentials. Make sure to:
1. Keep this script private
2. Change your MongoDB Atlas password after the migration is complete
