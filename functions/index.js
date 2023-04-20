const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const cors = require("cors")({ origin: true });

admin.initializeApp();

/**
 * Here we're using Gmail to send
 */
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "cgraceyoon@gmail.com",
    pass: "candyland",
  },
});

exports.sendMail = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    // getting dest email by query string
    const dest = req.query.dest;

    const mailOptions = {
      from: "Your Account Name <cgraceyoon@gmail.com>",
      // Something like: Jane Doe <janedoe@gmail.com>
      to: dest,
      subject: "Test Email", // email subject
      html: `<p style="font-size: 16px;">Test!!</p>
            `, // email content in HTML
    };

    // returning result
    return transporter.sendMail(mailOptions, (erro, info) => {
      if (erro) {
        return res.send(erro.toString());
      }
      return res.send("Sent");
    });
  });
});
