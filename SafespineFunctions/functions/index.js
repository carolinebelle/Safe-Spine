const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const fs = require("fs-extra");
const gcs = require("@google-cloud/storage")();

const path = require("path");
const os = require("os");

const json2csv = require("json2csv");

exports.createCSV = functions.firestore
  .document("reports=/{reportId}")
  .onCreate((event) => {
    // Step 1. Set main variables

    const reportId = event.params.reportId;
    const fileName = `reports/${reportId}.csv`;
    const tempFilePath = path.join(os.tmpdir(), fileName);

    // Reference report in Firestore
    const db = admin.firestore();
    const reportRef = db.collection("reports").doc(reportId);

    // Reference Storage Bucket
    const storage = gcs.bucket("gs://safespine-6f2ce.appspot.com"); // or set to env variable

    // Step 2. Query collection
    return db
      .collection("forms")
      .get()
      .then((querySnapshot) => {
        /// Step 3. Creates CSV file from with orders collection
        const forms = [];

        // create array of order data
        querySnapshot.forEach((doc) => {
          forms.push(doc.data());
        });

        return json2csv({ data: forms });
      })
      .then((csv) => {
        // Step 4. Write the file to cloud function tmp storage
        return fs.outputFile(tempFilePath, csv);
      })
      .then(() => {
        // Step 5. Upload the file to Firebase cloud storage
        return storage.upload(tempFilePath, { destination: fileName });
      })
      .then((file) => {
        // Step 6. Update status to complete in Firestore

        return reportRef.update({ status: "complete" });
      })
      .catch((err) => console.log(err));
  });
