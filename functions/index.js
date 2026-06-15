const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

// 1. Queue Management: Triggered when a driver goes online
exports.onDriverOnline = functions.firestore
    .document('drivers/{driverId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();

        // If driver just went online
        if (newData.isOnline && !oldData.isOnline) {
            // Logic to assign to next available station or update queue
            console.log(`Driver ${context.params.driverId} is now online.`);
        }
    });

// 2. Trip Completion: Calculate earnings and update stats securely
exports.completeTrip = functions.https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Login required');

    const { tripId, passengerCount } = data;
    const tripRef = db.collection('trips').doc(tripId);
    
    return db.runTransaction(async (transaction) => {
        const tripSnap = await transaction.get(tripRef);
        const tripData = tripSnap.data();

        if (tripData.driverId !== context.auth.uid) {
            throw new functions.https.HttpsError('permission-denied', 'Not your trip');
        }

        const earnings = passengerCount * 50; // Secure calculation on server
        
        transaction.update(tripRef, { status: 'finished', endedAt: admin.firestore.FieldValue.serverTimestamp() });
        transaction.update(db.collection('drivers').doc(context.auth.uid), {
            totalEarnings: admin.firestore.FieldValue.increment(earnings),
            completedTrips: admin.firestore.FieldValue.increment(1)
        });

        return { success: true, earnings };
    });
});
