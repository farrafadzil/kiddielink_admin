/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const nodemailer = require('nodemailer');

// Set up SMTP credentials (use environment variables for security)
const transporter = nodemailer.createTransport({
  service: 'gmail', // e.g., 'gmail', 'yahoo', etc.
  auth: {
    user: 'mykiddielink@gmail.com', // Use a real email address
    pass: 'gbsv fvje oled qncg', // Use an app password, not your regular email password
  },
});

exports.sendEmail = functions.https.onRequest((req, res) => {
  const { recipientEmail, fullName, uniqueCode } = req.body;

  const mailOptions = {
    from: 'mykiddielink@gmail.com',
    to: recipientEmail,
    subject: 'Your Child\'s Unique Code',
    html: `<h1>Your Child's Unique Code</h1><p>Hello,</p><p>Here is the unique code for your child, <b>${fullName}</b>: <b>${uniqueCode}</b></p><p>Best regards,<br>Your School</p>`,
  };

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      return res.status(500).send(error.toString());
    }
    return res.status(200).send('Email sent: ' + info.response);
  });
});
