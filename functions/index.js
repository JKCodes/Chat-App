const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.sendMessage = functions.database.ref('/user-messages/{fromId}/{toId}/{messageId}')
	.onWrite(event => {
		const fromId = event.params.fromId;
		const toId = event.params.toId;
		const messageId = event.params.messageId;
		const tokenAddress = '/users/' + toId + '/notificationTokens';
		const messageAddress = '/messages/' + messageId;
		const userAddress = '/users/' + toId;

		const getDeviceToken = admin.database().ref(tokenAddress).once('value');
		const fromIdProfile = admin.auth().getUser(fromId);
		const userData = admin.database().ref(userAddress).once('value');
		const messageData = admin.database().ref(messageAddress).once('value');

		return Promise.all([getDeviceToken, fromIdProfile, userData, messageData]).then(results => {
			const tokensSnapshot = results[0];
			const fromProfile = results[1];
			const userSnapshot = results[2];
			const messageSnapshot = results[3];

			const user = userSnapshot.val();
			const message = messageSnapshot.val();
			const title = user.firstName + ' ' + user.lastName + '(@' + user.username + ') sent you a message!'

			const payload = {
				notification: {
					title: title,
					body: message.text,
					sound: "default"
				},
			};

			const tokens = Object.keys(tokensSnapshot.val());
			
			return admin.messaging().sendToDevice(tokens, payload).then(response => {
		      // For each message check if there was an error.
		      const tokensToRemove = [];
		      response.results.forEach((result, index) => {
		        const error = result.error;
		        if (error) {
		          console.error('Failure sending notification to', tokens[index], error);
		          // Cleanup the tokens who are not registered anymore.
		          if (error.code === 'messaging/invalid-registration-token' ||
		              error.code === 'messaging/registration-token-not-registered') {
		            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
		          }
		        }
		      });
		      return Promise.all(tokensToRemove);
		    });
		});
	});