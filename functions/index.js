const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Send notification when a new swap offer is created
exports.onSwapOfferCreated = functions.firestore
    .document('swapOffers/{offerId}')
    .onCreate(async (snapshot, context) => {
        const offer = snapshot.data();
        
        // Don't send notification if it's not pending
        if (offer.status !== 'pending') {
            return;
        }
        
        try {
            // Get the recipient's FCM token
            const userDoc = await admin.firestore()
                .collection('users')
                .doc(offer.toUserId)
                .get();
            
            const userData = userDoc.data();
            const fcmToken = userData?.fcmToken;
            
            if (!fcmToken) {
                console.log('No FCM token for user:', offer.toUserId);
                return;
            }
            
            const message = {
                notification: {
                    title: '📚 New Swap Offer!',
                    body: `You have a new offer for "${offer.bookTitle}"`,
                },
                data: {
                    type: 'new_offer',
                    offerId: context.params.offerId,
                    bookId: offer.bookId,
                    fromUserId: offer.fromUserId,
                },
                token: fcmToken,
            };
            
            await admin.messaging().send(message);
            console.log('Swap offer notification sent successfully');
        } catch (error) {
            console.error('Error sending swap offer notification:', error);
        }
    });

// Send notification when a new chat message is sent
exports.onNewChatMessage = functions.firestore
    .document('chatRooms/{chatRoomId}/messages/{messageId}')
    .onCreate(async (snapshot, context) => {
        const message = snapshot.data();
        
        // Don't send notifications for system messages
        if (message.senderId === 'system') {
            return;
        }
        
        try {
            // Get chat room details
            const chatRoomDoc = await admin.firestore()
                .collection('chatRooms')
                .doc(context.params.chatRoomId)
                .get();
            
            const chatRoom = chatRoomDoc.data();
            if (!chatRoom) return;
            
            // Find the recipient (the other participant)
            const participantIds = chatRoom.participantIds;
            const recipientId = participantIds.find(id => id !== message.senderId);
            
            if (!recipientId) return;
            
            // Get recipient's FCM token
            const userDoc = await admin.firestore()
                .collection('users')
                .doc(recipientId)
                .get();
            
            const userData = userDoc.data();
            const fcmToken = userData?.fcmToken;
            
            if (!fcmToken) {
                console.log('No FCM token for user:', recipientId);
                return;
            }
            
            // Truncate long messages
            const messageBody = message.message.length > 50 
                ? message.message.substring(0, 50) + '...' 
                : message.message;
            
            const notificationMessage = {
                notification: {
                    title: `💬 ${message.senderEmail}`,
                    body: messageBody,
                },
                data: {
                    type: 'new_message',
                    chatRoomId: context.params.chatRoomId,
                    senderId: message.senderId,
                    senderEmail: message.senderEmail,
                },
                token: fcmToken,
            };
            
            await admin.messaging().send(notificationMessage);
            console.log('Chat notification sent successfully');
        } catch (error) {
            console.error('Error sending chat notification:', error);
        }
    });

// Send notification when swap offer status changes
exports.onOfferStatusChanged = functions.firestore
    .document('swapOffers/{offerId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();
        
        // Only notify if status changed to accepted or rejected
        if (before.status === after.status) return;
        
        if (after.status === 'accepted' || after.status === 'rejected') {
            try {
                // Notify the offer sender
                const userDoc = await admin.firestore()
                    .collection('users')
                    .doc(after.fromUserId)
                    .get();
                
                const userData = userDoc.data();
                const fcmToken = userData?.fcmToken;
                
                if (!fcmToken) return;
                
                const statusText = after.status === 'accepted' ? 'accepted' : 'declined';
                const message = {
                    notification: {
                        title: 'Offer Update',
                        body: `Your offer for "${after.bookTitle}" has been ${statusText}`,
                    },
                    data: {
                        type: 'offer_update',
                        offerId: context.params.offerId,
                        status: after.status,
                    },
                    token: fcmToken,
                };
                
                await admin.messaging().send(message);
                console.log('Offer status notification sent');
            } catch (error) {
                console.error('Error sending offer status notification:', error);
            }
        }
    });