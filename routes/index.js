const express = require('express');
const router = express.Router();
var sg = require('sendgrid')(process.env.SENDGRID_API_KEY || "");

router.get('/', function(req, res, next) {
  res.render('pages/index');
});

router.get('/contactus', function(req,res){
    res.render('pages/contactus');
});

router.post('/contact', function(req, res) {
 let status = sendMail(req, function(status){
    if(status==202){
        res.json({success:1});
    }else{
        res.json({success:0});
    }
 });
  
});

function sendMail(req, callback){
    let [name, replyTo, mailtext] = [req.body.name, req.body.replyTo, req.body.mailtext];
    let request = sg.emptyRequest({
        method: 'POST',
        path: '/v3/mail/send',
        body: {
          personalizations: [
            {
              to: [
                {
                  email: 'connor.p.hamlet@gmail.com',
                },
              ],
              subject: 'QueepBot Question: '+ name,
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

