const express = require('express');
const router = express.Router();
var helper = require('sendgrid').mail;
var sg = require('sendgrid')(process.env.SENDGRID_API_KEY || "");

router.get('/', function(req, res, next) {
  res.render('pages/index');
});

router.post('/contact', function(req, res) {
  let status = sendMail(req, function(status){
    if(status==202){
        res.send({sucess:1});
    }else{
        res.send({success:0});
    }
  });
  
});



function sendMail(req, callback){
    let [replyTo,subject,mailtext] = [req.body.replyTo, req.body.subject, req.body.mailtext];
    let request = sg.emptyRequest({
        method: 'POST',
        path: '/v3/mail/send',
        body: {
          personalizations: [
            {
              to: [
                {
                  email: 'cphamlet@protonmail.com',
                },
              ],
              subject: subject,
            },
          ],
          reply_to:{
              email: replyTo
          },
          from: {
            email: 'no-reply@queep-bot.herokuapp.com',
          },
          content: [
            {
              type: 'text/plain',
              value: mailtext,
            },
          ],
        },
      });
    
    sg.API(request, function(error, response) {
    
      console.log(response.statusCode);
      console.log(response.body);
      console.log(response.headers);
      callback(response.statusCode);
    });    
}


module.exports = router;

